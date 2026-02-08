module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16" # 2^16
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  zones =  ["us-east-1a", "us-east-1b"]

}

resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [module.eks.aws_eks_node_group]
}

resource "argocd_repository" "manifest_repo" {
  repo = "https://github.com/saberBenhamda0/monolithic-devops-project.git"
  # For private repos, add username/password or ssh_private_key here
}

resource "argocd_application" "my_app" {
  metadata {
    name      = "dev-argo-cd"
    namespace = "argocd"
  }

  spec {
    project = "default"
    source {
      repo_url        = argocd_repository.manifest_repo.repo
      target_revision = "main"
      path            = "backend_v2/overlays/dev" # Path to your manifests
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "dev"
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.aws_eks_cluster.name
  }

  # MUST be updated to match your region 
  set {
    name  = "awsRegion"
    value = "us-east-1"
  }

  depends_on = [helm_release.metrics_server]
}

# resource "helm_release" "aws_lbc" {
#   name = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.7.2"

#   set {
#     name  = "clusterName"
#     value = module.eks.aws_eks_cluster.name
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }
#   set {
#     name  = "vpcId"
#     value = module.vpc.vpc_id
#   }

#   depends_on = [helm_release.cluster_autoscaler]
# }

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "9.2.2" # Use the latest stable version

    # Add this
  skip_crds = true

  # Example of setting values via Terraform
  # set {
  #   name  = "server.service.type"
  #   value = "LoadBalancer"
  # }

  # If you want to use an AWS Application Load Balancer (ALB)
  # set {
  #   name  = "server.ingress.enabled"
  #   value = "true"
  # }
}
module "iam" {
  source = "./modules/iam"

  eks_name = local.eks_name
  
  eks = module.eks.eks
}

module "eks" {
  source = "./modules/eks"

  eks_name = local.eks_name
  eks_version = local.eks_version
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
  cluster_autoscaler_arn = module.iam.cluster_autoscaler_arn

}