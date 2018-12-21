// Alibaba Cloud provider (source: https://github.com/terraform-providers/terraform-provider-alicloud)
provider "alicloud" {
  region = "cn-shanghai"
}

// Instance_types data source for instance_type
data "alicloud_instance_types" "default" {
  cpu_core_count = "4"
  memory_size    = "8"
  output_file = "instance_types.json"
}


