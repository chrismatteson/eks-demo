variable "aws_region" {
  default     = "us-west-2"
  description = "Region where resources will be provisioned"
}

variable "cluster_name" {
  default     = "eks-demo"
  description = "Name of kubernetes cluster to  be provisioned"
}
