resource "aws_iam_user" "developer" {
  name = "developer"
  tags = var.tags
}

resource "aws_iam_user" "manager" {
  name = "manager"
  tags = var.tags
}
