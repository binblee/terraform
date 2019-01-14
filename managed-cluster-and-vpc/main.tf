// Alibaba Cloud provider (source: https://github.com/terraform-providers/terraform-provider-alicloud)
provider "alicloud" {
  region = "${var.region}"
}
// Instance_types data source for instance_type
data "alicloud_instance_types" "default" {
  cpu_core_count = "${var.cpu_core_count}"
  memory_size    = "${var.memory_size}"
  instance_type_family = "${var.instance_type_family}"
}
// Zones data source for availability_zone
data "alicloud_zones" "default" {
  available_instance_type = "${data.alicloud_instance_types.default.instance_types.0.id}"
}

// If there is not specifying vpc_id, the module will launch a new vpc
resource "alicloud_vpc" "vpc" {
  count      = "${var.vpc_id == "" ? 1 : 0}"
  cidr_block = "${var.vpc_cidr}"
  name       = "${var.vpc_name == "" ? var.cluster_name : var.vpc_name}"
}

// According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "vswitches" {
  count             = "${length(var.vswitch_ids) > 0 ? 0 : length(var.vswitch_cidrs)}"
  vpc_id            = "${var.vpc_id == "" ? join("", alicloud_vpc.vpc.*.id) : var.vpc_id}"
  cidr_block        = "${element(var.vswitch_cidrs, count.index)}"
  # availability_zone = "${lookup(data.alicloud_zones.default.zones[count.index%length(data.alicloud_zones.default.zones)], "id")}"
  availability_zone = "${var.availability_zone}"
  name              = "${var.vswitch_name_prefix == "" ? format("%s-%s", var.cluster_name, format(var.number_format, count.index+1)) : format("%s-%s", var.vswitch_name_prefix, format(var.number_format, count.index+1))}"
}

resource "alicloud_nat_gateway" "default" {
  count  = "${var.new_nat_gateway == true ? 1 : 0}"
  vpc_id = "${var.vpc_id == "" ? join("", alicloud_vpc.vpc.*.id) : var.vpc_id}"
  name   = "${var.cluster_name}"
}

resource "alicloud_eip" "default" {
  count     = "${var.new_nat_gateway == "true" ? 1 : 0}"
  bandwidth = 10
}

resource "alicloud_eip_association" "default" {
  count         = "${var.new_nat_gateway == "true" ? 1 : 0}"
  allocation_id = "${alicloud_eip.default.id}"
  instance_id   = "${alicloud_nat_gateway.default.id}"
}

resource "alicloud_snat_entry" "default" {
  count             = "${var.new_nat_gateway == "false" ? 0 : length(var.vswitch_ids) > 0 ? length(var.vswitch_ids) : length(var.vswitch_cidrs)}"
  snat_table_id     = "${alicloud_nat_gateway.default.snat_table_ids}"
  source_vswitch_id = "${length(var.vswitch_ids) > 0 ? element(split(",", join(",", var.vswitch_ids)), count.index%length(split(",", join(",", var.vswitch_ids)))) : length(var.vswitch_cidrs) < 1 ? "" : element(split(",", join(",", alicloud_vswitch.vswitches.*.id)), count.index%length(split(",", join(",", alicloud_vswitch.vswitches.*.id))))}"
  snat_ip           = "${alicloud_eip.default.ip_address}"
}

resource "alicloud_cs_managed_kubernetes" "k8s" {
  name                  = "${var.cluster_name}"
  availability_zone     = "${var.availability_zone}"
  vswitch_ids           = ["${length(var.vswitch_ids) > 0 ? element(split(",", join(",", var.vswitch_ids)), count.index%length(split(",", join(",", var.vswitch_ids)))) : length(var.vswitch_cidrs) < 1 ? "" : element(split(",", join(",", alicloud_vswitch.vswitches.*.id)), count.index%length(split(",", join(",", alicloud_vswitch.vswitches.*.id))))}"]
  new_nat_gateway       = true
  worker_instance_types = ["${var.worker_instance_type == "" ? data.alicloud_instance_types.default.instance_types.0.id : var.worker_instance_type}"]
  worker_numbers        = ["${var.k8s_worker_number}"]
  worker_disk_category  = "${var.worker_disk_category}"
  worker_disk_size      = "${var.master_disk_size}"
  worker_data_disk_category = "${var.worker_data_disk_category}"
  worker_data_disk_size = "${var.worker_data_disk_size}"
  # key_name              = "${var.ecs_keyname}"
  password              = "${var.ecs_password}"
  pod_cidr              = "${var.k8s_pod_cidr}"
  service_cidr          = "${var.k8s_service_cidr}"
  install_cloud_monitor = true
  cluster_network_type  = "${var.cluster_network_type}"
}

// Security group
resource "alicloud_security_group" "stage_sg" {
  name = "${var.cluster_name}-stage-sg"
  vpc_id = "${alicloud_vpc.vpc.id}"
}
resource "alicloud_security_group_rule" "accept_22_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${alicloud_security_group.stage_sg.id}"
  cidr_ip = "0.0.0.0/0"
}

// Stage server instance
data "alicloud_images" "ubuntu_images" {
  owners = "system"
  name_regex = "ubuntu_16[a-zA-Z0-9_]+64"
  most_recent = true
}
resource "alicloud_instance" "stage_ecs" {
  instance_name = "${var.cluster_name}-stage"

  host_name = "${var.cluster_name}-stage"
  # key_name              = "${var.ecs_keyname}"
  password              = "${var.ecs_password}"

  image_id = "${data.alicloud_images.ubuntu_images.images.0.id}"
  instance_type = "${alicloud_cs_managed_kubernetes.k8s.worker_instance_types.0}"
  system_disk_category = "cloud_ssd"
  system_disk_size = "500"

  vswitch_id = "${alicloud_cs_managed_kubernetes.k8s.vswitch_ids.0}"
  security_groups = [
    "${alicloud_security_group.stage_sg.id}",
    "${alicloud_cs_managed_kubernetes.k8s.security_group_id}"
  ]
}

resource "alicloud_eip" "stage_eip" {
  name = "stage-eip"
  bandwidth = 10
}

resource "alicloud_eip_association" "stage_eip_association" {
  allocation_id = "${alicloud_eip.stage_eip.id}"
  instance_id = "${alicloud_instance.stage_ecs.id}"
}