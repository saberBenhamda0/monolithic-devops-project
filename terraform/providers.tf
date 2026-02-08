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
      version = "~> 5.35  "
    }
  argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.12.4"
    }
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

  username    = "admin"
  password    = "gYdHpkrrpvbOk7Jf" # Use a secret or variable!
  insecure    = true
  
  # this if you wanat to leaave argocd private
  port_forward_with_namespace = "argocd"

  # This tells the provider how to authenticate with Kubernetes for the port-forward
  kubernetes {
    host                   = module.eks.aws_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks.aws_eks_cluster.certificate_authority[0].data)
    token                  = module.eks.token
  }
}