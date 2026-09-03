terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.12.4"
    }
  }

  backend "s3" {
    bucket         = "backend2you-terraform-state"
    key            = "global/s3/terraform.tfstate" # path inside the bucket
    region         = "us-east-1"
    use_lockfile = true
    encrypt        = true
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.aws_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks.aws_eks_cluster.certificate_authority[0].data)
    token                  = module.eks.token
  }
}

provider "kubernetes" {
  host                   = module.eks.aws_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks.aws_eks_cluster.certificate_authority[0].data)
  token                  = module.eks.token
}

provider "argocd" {

  # this option if you want argo to public avaible.
  # server_addr = "a1b2c3d4e5.elb.amazonaws.com:443"

  username = var.argocd_username
  password = var.argocd_password
  insecure = true

  # this if you wanat to leaave argocd private
  port_forward_with_namespace = "argocd"

  # This tells the provider how to authenticate with Kubernetes for the port-forward
  kubernetes {
    host                   = module.eks.aws_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks.aws_eks_cluster.certificate_authority[0].data)
    token                  = module.eks.token
  }
}
