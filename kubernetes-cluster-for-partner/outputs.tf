// Output VPC
output "vpc_id" {
  description = "The ID of the VPC."
  value       = alicloud_cs_managed_kubernetes.k8s[0].vpc_id
}

output "vswitch_ids" {
  description = "List ID of the VSwitches."
  value       = [
    alicloud_cs_managed_kubernetes.k8s.*.vswitch_ids]
}

//output "nat_gateway_id" {
//  value = "${alicloud_cs_managed_kubernetes.k8s.0.nat_gateway_id}"
//}

//Output slb resource
output "load_balancer" {
  description = "ID of the kunernetes cluster."
  value       =  alicloud_slb.slb.id
}

//Output ecs resource
output "ecs_security_group_id" {
  description = "ID of the Security Group used to create ecs instances."
  value = alicloud_security_group.security_group.id
}

output "ecs_instances" {
description = "The instances ids of created instance."
value = [alicloud_instance.instance.*.id]
}

//Output rds resource
output "rds_instance" {
  description = "The instances id of created rds instance."
  value = [alicloud_db_instance.instance.*.id]
}

//Output redis resource
output "instance_id" {
  value = alicloud_kvstore_instance.instance.id
}

// Output kubernetes resource
output "cluster_id" {
  description = "ID of the kunernetes cluster."
  value       = [alicloud_cs_managed_kubernetes.k8s.*.id]
}

output "security_group_id" {
  description = "ID of the Security Group used to deploy kubernetes cluster."
  value       = alicloud_cs_managed_kubernetes.k8s[0].security_group_id
}

output "worker_nodes" {
  description = "List worker nodes of cluster."
  value       = [alicloud_cs_managed_kubernetes.k8s.*.worker_nodes]
}

