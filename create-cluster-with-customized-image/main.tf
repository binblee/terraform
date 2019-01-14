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

resource "alicloud_cs_kubernetes" "k8s" {
  count                 = "${var.k8s_number}"
  name                  = "${var.k8s_name_prefix == "" ? format("%s-%s", var.cluster_name, format(var.number_format, count.index+1)) : format("%s-%s", var.k8s_name_prefix, format(var.number_format, count.index+1))}"
  availability_zone     = "${var.availability_zone}"
  new_nat_gateway       = true
  master_instance_types = ["${var.master_instance_type == "" ? data.alicloud_instance_types.default.instance_types.0.id : var.master_instance_type}"]
  worker_instance_types = ["${var.worker_instance_type == "" ? data.alicloud_instance_types.default.instance_types.0.id : var.worker_instance_type}"]
  worker_numbers        = ["${var.k8s_worker_number}"]
  master_disk_category  = "${var.master_disk_category}"
  worker_disk_category  = "${var.worker_disk_category}"
  master_disk_size      = "${var.master_disk_size}"
  worker_disk_size      = "${var.master_disk_size}"
  worker_data_disk_category = "${var.worker_data_disk_category}"
  worker_data_disk_size = "${var.worker_data_disk_size}"
  # key_name              = "${var.ecs_keyname}"
  password              = "${var.ecs_password}"
  pod_cidr              = "${var.k8s_pod_cidr}"
  service_cidr          = "${var.k8s_service_cidr}"
  enable_ssh            = true
  install_cloud_monitor = true
  cluster_network_type  = "${var.cluster_network_type}"
  log_config {
    type = "SLS"
    project = "${var.k8s_name_prefix == "" ? format("%s-%s", var.cluster_name, format(var.number_format, count.index+1)) : format("%s-%s", var.k8s_name_prefix, format(var.number_format, count.index+1))}"
  }
  image_id = "${var.node_image_id}"
}
