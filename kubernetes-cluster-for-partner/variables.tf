//# common variables

variable "region" {
  description = "Region to launch resources."
  default = "cn-shanghai"
}

variable "tag_key" {
  description = "key of tag."
  default = "terraform"
}

variable "tag_value" {
  description = "value of tag."
  default = "true"
}

variable "password" {
  default = "Test12345"
}

variable "availability_zone" {
  description = "The available zone to launch ecs instance and other resources."
  default     = "cn-shanghai-g"
}

variable "number_format" {
  description = "The number format used to output."
  default     = "%02d"
}

variable "cluster_name" {
  default = "tf-example-kubernetes"
}

variable "tf_prefix_name" {
  description = "The prefix  of name "
  default = "tf-example"
}

# Instance typs variables

variable "instance_type_family" {
  description = "Filter the results based on their family name. For example: 'ecs.n4'"
  default     = "ecs.c5"
}

variable "cpu_core_count" {
  description = "CPU core count is used to fetch instance types."
  default     = 4
}

variable "memory_size" {
  description = "Memory size used to fetch instance types."
  default     = 8
}

# VPC variables
variable "vpc_name" {
  description = "The vpc name used to create a new vpc when 'vpc_id' is not specified. Default to variable `cluster_name`"
  default     = ""
}

variable "vpc_id" {
  description = "A existing vpc id used to create several vswitches and other resources."
  default     = ""
}

variable "vpc_cidr" {
  description = "The cidr block used to launch a new vpc when 'vpc_id' is not specified."
  default     = "192.168.0.0/16"
}

# VSwitch variables
variable "vswitch_name_prefix" {
  description = "The vswitch name prefix used to create several new vswitches. Default to variable `cluster_name`"
  default     = ""
}

variable "vswitch_ids" {
  description = "List of existing vswitch id."
  type        = "list"
  default     = []
}

variable "vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches when 'vswitch_ids' is not specified."
  type        = "list"
  default     = ["192.168.1.0/24"]
}

variable "new_nat_gateway" {
  description = "Whether to create a new nat gateway. In this template, a new nat gateway will create a nat gateway, eip and server snat entries."
  default     = "true"
}

# SLB variables

variable "internet_charge_type" {
  description = "The Internet  Charge Type of SLB Instance"
  default = "PayByTraffic"
}

variable "address_type" {
  description = "The AddressType of SLB Instance, `internet`, `intranet`"
  default = "internet"
}

variable "load_balancer_spec" {
  description = "The instance type of SLB Instance,ig. slb.s2.small"
  default = "slb.s2.small"
}


# ECS variables
variable "number" {
  description = "The numer of  ecs instances"
  default = "2"
}

variable "nic_type" {
  description = "The security rule type"
  default = "intranet"
}

variable "disk_category" {
  description = "The data disk category"
  default = "cloud_ssd"
}

variable "disk_size" {
  description = "The data disk size"
  default = "400"
}

variable "role" {
  description = "The middle name of instance"
  default = "nodes"
}

variable "data_disk_name" {
  description = "The prefix name of data disk"
  default = "data-disk"
}

variable "internet_max_bandwidth_out" {
  description = "The internet max bandwidth out"
  default = 100
}

variable "image_id" {
  description = "The image id of ecs instance"
  default = "centos_7_06_64_20G_alibase_20190711.vhd"
}

variable "instance_charge_type" {
  description = "The ecs instance charge type"
  default = "PostPaid"
}

# RDS variables
variable "engine" {
  default = "MySQL"
}

variable "engine_version" {
  default = "8.0"
}

variable "instance_class" {
  default = "mysql.n2.small.1"
}

variable "storage" {
  default = "100"
}

variable "db_count" {
  default = "2"
}

variable "backup_period" {
  default = ["Tuesday", "Wednesday"]
}

variable "backup_time" {
  default = "10:00Z-11:00Z"
}

variable "net_type" {
  default = "Intranet"
}

variable "user_name" {
  default = "tf_tester"
}

variable "database_name" {
  default = "bookstore"
}

variable "database_character" {
  default = "utf8"
}

variable "tf_account_prefix_name" {
  description = "The prefix  of account name "
  default = "tf_account"
}

# Redis variables
variable "redis_instance_class" {
  default = "redis.master.small.default"
}

variable "security_ips" {
  default =  ["1.1.1.1", "2.2.2.2", "3.3.3.3"]
}


# Cluster nodes variables

variable "worker_instance_type" {
  description = "The ecs instance type used to launch worker nodes. Default from instance typs datasource."
  default     = ""
}

variable "worker_disk_category" {
  description = "The system disk category used to launch one or more worker nodes."
  # default     = "cloud_efficiency"
  default = "cloud_ssd"
}

variable "worker_disk_size" {
  description = "The system disk size used to launch one or more worker nodes."
  default     = "100"
}

variable "worker_data_disk_category" {
  description = "The data disk category of worker node. Its valid value are cloud_ssd and cloud_efficiency, if not set, data disk will not be created."
  default     = "cloud_ssd"
}

variable "worker_data_disk_size" {
  description = "The data disk size of worker node. Its valid value range [20~32768] in GB. When worker_data_disk_category is presented, it defaults to 40."
  default = "200"
}

variable "ecs_keyname" {
  description = "keypair name of ECS to be created"
  default = ""
}


variable "k8s_number" {
  description = "The number of kubernetes cluster."
  default     = 1
}

variable "k8s_worker_number" {
  description = "The number of worker nodes in each kubernetes cluster."
  default     = 3
}

variable "k8s_name_prefix" {
  description = "The name prefix used to create several kubernetes clusters. Default to variable `cluster_name`"
  default     = ""
}

variable "k8s_pod_cidr" {
  description = "The kubernetes pod cidr block. It cannot be equals to vpc's or vswitch's and cannot be in them."
  default     = "172.20.0.0/16"
}

variable "k8s_service_cidr" {
  description = "The kubernetes service cidr block. It cannot be equals to vpc's or vswitch's or pod's and cannot be in them."
  default     = "172.21.0.0/20"
}

variable "cluster_network_type" {
  description = "Network type, valid options are flannel, terway"
  default = "terway"
}
