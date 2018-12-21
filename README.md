# Terraform w/ ACK Samples

## Create a new cluster

```
cd create-cluster
export ALICLOUD_ACCESS_KEY="xxx"
export ALICLOUD_SECRET_KEY="xxx"
terraform apply
```
Change variables.tf if you have diferent configuration settings.

## Create a multi AZ cluster

```
cd multi-az-cluster
export ALICLOUD_ACCESS_KEY="xxx"
export ALICLOUD_SECRET_KEY="xxx"
terraform apply
```

Reference [https://github.com/alibabacloud-howto/devops/tree/master/tutorials/getting_started_with_rancher/environment/kubernetes-cluster](https://github.com/alibabacloud-howto/devops/tree/master/tutorials/getting_started_with_rancher/environment/kubernetes-cluster)




## Find out available ECS instance types in one region

```
cd planning
export ALICLOUD_ACCESS_KEY="xxx"
export ALICLOUD_SECRET_KEY="xxx"
terraform apply
```



Outputs in file instance_types.json.



## Manage resource in multiple regions


```
cd planning
export ALICLOUD_ACCESS_KEY="xxx"
export ALICLOUD_SECRET_KEY="xxx"
terraform apply
```



## Create a Managed K8S

In [managed-cluster](managed-cluster) directory



## Create a Managed K8S, VPC and a ECS instance

In [managed-cluster-and-vpc](managed-cluster-and-vpc) directory.



## References

[https://github.com/alibabacloud-howto/devops](https://github.com/alibabacloud-howto/devops)

