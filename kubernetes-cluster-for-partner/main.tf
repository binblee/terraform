// Alibaba Cloud provider (source: https://github.com/terraform-providers/terraform-provider-alicloud)
provider "alicloud" {
  region = var.region
}

// Instance_types data source for instance_type
data "alicloud_instance_types" "default" {
  cpu_core_count = var.cpu_core_count
  memory_size    = var.memory_size
  instance_type_family = var.instance_type_family
}

// Zones data source for availability_zone
data "alicloud_zones" "default" {
  available_instance_type = data.alicloud_instance_types.default.instance_types[0].id
}

// If there is not specifying vpc_id, the module will launch a new vpc
resource "alicloud_vpc" "vpc" {
  count      = var.vpc_id == "" ? 1 : 0
  cidr_block = var.vpc_cidr
  name       = var.vpc_name == "" ? var.cluster_name : var.vpc_name
}

// According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "vswitches" {
  count             = length(var.vswitch_ids) > 0 ? 0 : length(var.vswitch_cidrs)
  vpc_id            = var.vpc_id == "" ? join("", alicloud_vpc.vpc.*.id) : var.vpc_id
  cidr_block        = var.vswitch_cidrs[count.index]
  availability_zone = var.availability_zone
  name              = var.vswitch_name_prefix == "" ? format("%s-%s", var.cluster_name, format(var.number_format, count.index+1)) : format("%s-%s", var.vswitch_name_prefix, format(var.number_format, count.index+1))
}

resource "alicloud_nat_gateway" "default" {
  count  = var.new_nat_gateway == "true" ? 1 : 0
  vpc_id = var.vpc_id == "" ? join("", alicloud_vpc.vpc.*.id) : var.vpc_id
  name   = var.cluster_name
}

resource "alicloud_eip" "default" {
  count     = var.new_nat_gateway == "true" ? 1 : 0
  bandwidth = 100
}

resource "alicloud_eip_association" "default" {
  count         = var.new_nat_gateway == "true" ? 1 : 0
  allocation_id = alicloud_eip.default.*.id[count.index]
  instance_id   = alicloud_nat_gateway.default.*.id[count.index]
}

resource "alicloud_snat_entry" "default" {
  count             = var.new_nat_gateway == "false" ? 0 : length(var.vswitch_ids) > 0 ? length(var.vswitch_ids) : length(var.vswitch_cidrs)
  snat_table_id     = alicloud_nat_gateway.default[0].snat_table_ids
  source_vswitch_id = length(var.vswitch_ids) > 0 ? split(",", join(",", var.vswitch_ids))[count.index%length(split(",", join(",", var.vswitch_ids)))] : length(var.vswitch_cidrs) < 1 ? "" : split(",", join(",", alicloud_vswitch.vswitches.*.id))[count.index%length(split(",", join(",", alicloud_vswitch.vswitches.*.id)))]
  snat_ip           = alicloud_eip.default[0].ip_address
}

# slb instance
resource "alicloud_slb" "slb" {
  name                = format("%s-%s", var.tf_prefix_name,"slb")
 internet_charge_type = var.internet_charge_type
  address_type             = var.address_type
  specification        = var.load_balancer_spec
  vswitch_id = var.address_type == "internet"?"":alicloud_vswitch.vswitches.0.id

  tags = {
    "${var.tag_key}" = var.tag_value
  }
}

# ecs instance
resource "alicloud_security_group" "security_group" {
  name        = format("%s-%s", var.tf_prefix_name,"security_group")
  description = "New security group for terraform"
  vpc_id      = alicloud_vpc.vpc.0.id
}

resource "alicloud_security_group_rule" "allow_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = var.nic_type
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.security_group.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_disk" "disk" {
  availability_zone = alicloud_instance.instance[0].availability_zone
  category          = var.disk_category
  size              = var.disk_size
  count             = var.number
}

resource "alicloud_instance" "instance" {
  instance_name   = "${var.tf_prefix_name}-${var.role}-${format(var.number_format, count.index + 1)}"
  host_name       = "${var.tf_prefix_name}-${var.role}-${format(var.number_format, count.index + 1)}"
  image_id        = var.image_id
  instance_type   = data.alicloud_instance_types.default.instance_types[0].id
  count           = var.number
  security_groups = alicloud_security_group.security_group.*.id
  vswitch_id      = alicloud_vswitch.vswitches.0.id

  internet_charge_type       = var.internet_charge_type
  internet_max_bandwidth_out = var.internet_max_bandwidth_out

  password = var.password

  instance_charge_type          = var.instance_charge_type
  system_disk_category          = var.disk_category
  security_enhancement_strategy = "Deactive"

  data_disks {
    name        = "${var.data_disk_name}-${format(var.number_format, count.index + 1)}"
    size        = var.disk_size
    category    = var.disk_category
    description = "data disk"
  }

  tags = {
    "${var.tag_key}" = var.tag_value
  }
}


# rds instance
resource "alicloud_db_instance" "instance" {
  engine           = var.engine
  engine_version   = var.engine_version
  instance_type    = var.instance_class
  instance_storage = var.storage
  vswitch_id       = alicloud_vswitch.vswitches.0.id

  tags = {
    "${var.tag_key}" = var.tag_value
  }
}

resource "alicloud_db_account" "account" {
  count       = var.db_count
  instance_id = alicloud_db_instance.instance.id
  name        = format("%s_%s", var.tf_account_prefix_name,count.index)
  password    = var.password
}

resource "alicloud_db_backup_policy" "backup" {
  instance_id   = alicloud_db_instance.instance.id
  backup_period = var.backup_period
  backup_time   = var.backup_time
}

resource "alicloud_db_database" "db" {
  count       = var.db_count
  instance_id = alicloud_db_instance.instance.id
  name        = "${var.database_name}_${count.index}"
}

resource "alicloud_db_account_privilege" "privilege" {
  count        = var.db_count
  instance_id  = alicloud_db_instance.instance.id
  account_name = alicloud_db_account.account.*.name[count.index]
  db_names     = alicloud_db_database.db.*.name
}


# redis instance
resource "alicloud_kvstore_instance" "instance" {
  instance_class = var.redis_instance_class
  instance_name  = format("%s-%s", var.tf_prefix_name,"redis")
  password       = var.password
  vswitch_id     = alicloud_vswitch.vswitches.0.id
  security_ips   = var.security_ips
  vpc_auth_mode  = "Close"

  //Refer to https://help.aliyun.com/document_detail/43885.html
  parameters {
    name = "maxmemory-policy"
    value = "volatile-ttl"
  }
}

resource "alicloud_kvstore_backup_policy" "redisbackup" {
  instance_id   = alicloud_kvstore_instance.instance.id
  backup_time   = var.backup_time
  backup_period = var.backup_period
}

# k8s cluster
resource "alicloud_cs_managed_kubernetes" "k8s" {
  count                 = var.k8s_number
  name                  = var.k8s_name_prefix == "" ? format("%s-%s", var.cluster_name, format(var.number_format, count.index+1)) : format("%s-%s", var.k8s_name_prefix, format(var.number_format, count.index+1))
  vswitch_ids           = [length(var.vswitch_ids) > 0 ? split(",", join(",", var.vswitch_ids))[count.index%length(split(",", join(",", var.vswitch_ids)))] : length(var.vswitch_cidrs) < 1 ? "" : split(",", join(",", alicloud_vswitch.vswitches.*.id))[count.index%length(split(",", join(",", alicloud_vswitch.vswitches.*.id)))]]
  new_nat_gateway = true
  worker_instance_types = [var.worker_instance_type == "" ? data.alicloud_instance_types.default.instance_types.0.id : var.worker_instance_type]
  worker_number        = var.k8s_worker_number
  worker_disk_category  = var.worker_disk_category
  worker_disk_size      = var.worker_disk_size
  worker_data_disk_category = var.worker_data_disk_category
  worker_data_disk_size = var.worker_data_disk_size
  # key_name              = "${var.ecs_keyname}"
  password              = var.password
  pod_cidr              = var.k8s_pod_cidr
  service_cidr          = var.k8s_service_cidr
  #enable_ssh            = true
  slb_internet_enabled = true
  install_cloud_monitor = true
  cluster_network_type  = var.cluster_network_type
  log_config {
    type = "SLS"
  }

  depends_on = ["alicloud_snat_entry.default"]
}