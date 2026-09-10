module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16" # 2^16

  public_subnets = {
    public_subnet_k8_a               = { cidr_block = "10.0.1.0/24",  zone = "us-east-1a" }
    public_subnet_k8_b               = { cidr_block = "10.0.2.0/24",  zone = "us-east-1b" }
    public_subnet_vpn                = { cidr_block = "10.0.10.0/24", zone = "us-east-1a" }
    public_subnet_vault              = { cidr_block = "10.0.14.0/24", zone = "us-east-1a" },
    public_subnet_jenkins            = { cidr_block = "10.0.11.0/24", zone = "us-east-1b" }
    public_subnet_postgres_east_1a   = { cidr_block = "10.0.12.0/24", zone = "us-east-1a" }
    public_subnet_postgres_east_1b   = { cidr_block = "10.0.13.0/24", zone = "us-east-1b" }
  }

  private_subnets = {
    private_subnet_k8_a = { cidr_block = "10.0.3.0/24", zone = "us-east-1a" }
    private_subnet_k8_b = { cidr_block = "10.0.4.0/24", zone = "us-east-1b" }
  }
}

# module "iam" {
#   source = "./modules/iam"

#   eks_name = local.eks_name

#   eks = module.eks.eks

#   aws_cloudfront_distribution_frontend_id = module.cloudfront.aws_cloudfront_distribution_frontend_id

#   s3_arn = module.s3.s3_arn
# }


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "ssh_keys" {
  source = "./modules/ssh_keys"

  deployer_public_key = var.deployer_public_key
}

module "security_group_keys" {
  source                        = "./modules/security_group"
  vpc_id                        = module.vpc.vpc_id
  k8_public_subnets_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  vpn_cicd                      = ["10.0.10.0/24"]
  vault_cidr = ["10.0.14.0/24"]
}

module "ebs" {
  source = "./modules/ebs"

  ec2_vault_id = module.ec2.ec2_ids["vault"]
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id                  = module.vpc.vpc_id
  aws_internet_gateway_id = module.vpc.aws_internet_gateway_id

  instances = {
    "vpn" = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
      subnet_id     = module.vpc.public_subnets["public_subnet_vpn"].id
      private_ip    = "10.0.10.10"
      ssh_key_name  = module.ssh_keys.ssh_developer_key_id

      security_group_keys = [module.security_group_keys.security_group_id]

      tags = {
        Name = "vpn-instance"
      }
    },

    "jenkins" = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
      subnet_id     = module.vpc.public_subnets["public_subnet_jenkins"].id
      private_ip    = "10.0.11.10"
      ssh_key_name  = module.ssh_keys.ssh_developer_key_id

      security_group_keys = [module.security_group_keys.jenkins_security_group_id]

      tags = {
        Name = "jenkins-instance"
      }
    },

    "vault" = {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
      subnet_id     = module.vpc.public_subnets["public_subnet_vault"].id
      private_ip    = "10.0.14.10"
      ssh_key_name  = module.ssh_keys.ssh_developer_key_id

      security_group_keys = [module.security_group_keys.vault_sg]

      tags = {
        Name = "vault-instance"
      }

      user_data_script = <<-EOF
          #!/bin/bash
          set -euxo pipefail

          MOUNT_POINT="/mnt/vault-data"
          DEVICE="/dev/xvdf"

          for i in $(seq 1 30); do
            [ -e "$DEVICE" ] && break
            sleep 2
          done

          if ! file -s "$DEVICE" | grep -q filesystem; then
            mkfs -t ext4 "$DEVICE"
          fi

          mkdir -p "$MOUNT_POINT"
          mount "$DEVICE" "$MOUNT_POINT"

          UUID=$(blkid -s UUID -o value "$DEVICE")
          grep -q "$UUID" /etc/fstab || echo "UUID=$UUID $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab
      EOF
    }
  }

  depends_on = [module.vpc, module.security_group_keys, module.ssh_keys]
}

module "postgreSQL" {

  source = "./modules/postgreSQL"

  db_username                       = var.db_username
  db_password                       = var.db_password
  db_name                           = var.db_name
  public_subnet_postgres_east_1a_id = module.vpc.public_subnets["public_subnet_postgres_east_1a"].id
  public_subnet_postgres_east_1b_id = module.vpc.public_subnets["public_subnet_postgres_east_1b"].id

  postgres_sg = module.security_group_keys.postrgesql_security_group_id


}

module "vault" {
  source = "./modules/vault"

  postgresql_database_url = module.postgreSQL.postgres_database_url
  postgresql_database_username = var.db_username
  postgresql_database_password = var.db_password

}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}


# module "waf" {
#   source = "./modules/waf"

#   aws_cloudwatch_waf_logs_arn = module.cloudwatch.aws_cloudwatch_waf_logs_arn

#   aws_internet_gateway_arn = module.vpc.aws_internet_gateway_arn

# }

module "s3" {
  source = "./modules/s3"
}

module "cloudfront" {
  source = "./modules/cloudfront"


  s3_bucket_id                = module.s3.s3_bucket_id
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  s3_bucket                   = module.s3.s3_bucket
  s3_arn                      = module.s3.s3_arn
}


# module "eks" {
#   source = "./modules/eks"

#   eks_name = local.eks_name
#   eks_version = local.eks_version
#   private_subnets = module.vpc.private_subnets
#   public_subnets = module.vpc.public_subnets
#   cluster_autoscaler_arn = module.iam.cluster_autoscaler_arn

# }


# # metrics servier for pod auto scaling
# resource "helm_release" "metrics_server" {
#   name = "metrics-server"

#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"
#   version    = "3.12.1"

#   values = [file("${path.module}/values/metrics-server.yaml")]

#   depends_on = [module.eks.aws_eks_node_group]
# }

# resource "argocd_repository" "manifest_repo" {
#   repo = "https://github.com/saberBenhamda0/monolithic-devops-project.git"
#   # For private repos, add username/password or ssh_private_key here
# }


# # argocd installation
# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = "argocd"
#   create_namespace = true
#   version          = "9.2.2" # Use the latest stable version

#     # Add this
#   skip_crds = true

#   # Example of setting values via Terraform
#   # set {
#   #   name  = "server.service.type"
#   #   value = "LoadBalancer"
#   # }

#   # If you want to use an AWS Application Load Balancer (ALB)
#   # set {
#   #   name  = "server.ingress.enabled"
#   #   value = "true"
#   # }
# }


# argocd application for manga2you
# resource "argocd_application" "prod-manga2you" {
#   metadata {
#     name      = "prod-manga2you"
#     namespace = "argocd"
#   }

#   spec {
#     project = "default"
#     source {
#       repo_url        = argocd_repository.manifest_repo.repo
#       target_revision = "main"
#       path            = "infrastructure/overlays/prod" # Path to your manifests
#     }
#     destination {
#       server    = "https://kubernetes.default.svc"
#       namespace = "prod"
#     }
#     sync_policy {
#       automated {
#         prune     = true
#         self_heal = true
#       }
#     }
#   }
# }

# resource "helm_release" "cluster_autoscaler" {
#   name = "autoscaler"

#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   version    = "9.37.0"

#   set {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"
#   }

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = module.eks.aws_eks_cluster.name
#   }

#   # MUST be updated to match your region 
#   set {
#     name  = "awsRegion"
#     value = "us-east-1"
#   }

#   depends_on = [helm_release.metrics_server]
# }

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



