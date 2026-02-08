output "token" {
  value =  data.aws_eks_cluster_auth.eks.token
}

output "aws_eks_cluster" {
  value = data.aws_eks_cluster.eks
}

output "aws_eks_node_group" {
  value = aws_eks_node_group.general
}

output "eks" {
    value = aws_eks_cluster.eks
}