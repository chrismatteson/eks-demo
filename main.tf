provider "aws" {
  region = "${var.aws_region}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform-eks-demo"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Use   = "eks-demo"
    Owner = "chrismatteson"
  }
}

resource "aws_iam_role" "eks-example" {
  name = "terraform-eks-demo"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-example.name}"
}

resource "aws_iam_role_policy_attachment" "eks-example-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-example.name}"
}

resource "aws_eks_cluster" "demo" {
  name     = "terraform-eks-demo"
  role_arn = "${aws_iam_role.eks-example.arn}"

  vpc_config {
    subnet_ids = ["${module.vpc.public_subnets}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-example-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-example-AmazonEKSServicePolicy",
  ]
}

locals {
  kubeconfig-aws-1-9 = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    auth-provider:
      config:
        cluster-id: ${var.cluster_name}
      name: aws
KUBECONFIG
}

output "kubeconfig-aws-1-9" {
  value = "${local.kubeconfig-aws-1-9}"
}
