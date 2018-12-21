// Alibaba Cloud provider (source: https://github.com/terraform-providers/terraform-provider-alicloud)
provider "alicloud" {
  region = "cn-shanghai"
}

provider "alicloud" {
  alias = "beijing"
  region = "cn-beijing"
}

// Instance_types data source for instance_type
data "alicloud_instance_types" "default" {
  cpu_core_count = "4"
  memory_size    = "8"
  output_file = "instance_types.json"
}
data "alicloud_instance_types" "beijing" {
  provider = "alicloud.beijing"
  cpu_core_count = "4"
  memory_size    = "8"
  output_file = "instance_types_beijing.json"
}

