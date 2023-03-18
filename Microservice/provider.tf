terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

data "aws_eks_cluster" "stevo" {
  name = "stevo"
}
data "aws_eks_cluster_auth" "stevo" {
  name = "stevo"
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.stevo.endpoint
  token                  = data.aws_eks_cluster_auth.stevo.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.stevo.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name"]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "sock_shop" {
  metadata {
    name = "sock-shop"
  }
}
