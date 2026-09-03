# data "aws_ssoadmin_instances" "this" {}

# locals {
#   identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
#   sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
# }

# # we create a user in the identity store
# resource "aws_identitystore_user" "sara" {
#   identity_store_id = local.identity_store_id

#   display_name = var.users["user1"].display_name
#   user_name    = var.users["user1"].user_name

#   name {
#     given_name  = var.users["user1"].given_name
#     family_name = var.users["user1"].family_name
#   }

#   emails {
#     value   = var.users["user1"].email
#     primary = true
#   }
# }

# # here we create an identity store group
# resource "aws_identitystore_group" "developers" {
#   identity_store_id = local.identity_store_id
#   display_name      = "Developers"
#   description       = "Dev team access"
# }

# # we added sara to the developers group
# resource "aws_identitystore_group_membership" "sara_in_developers" {
#   # aws identity store id
#   identity_store_id = local.identity_store_id

#   # group_id
#   group_id          = aws_identitystore_group.developers.group_id

#   # the user we wanna add to the group
#   member_id         = aws_identitystore_user.sara.user_id
# }

# # it create a an empty shell where we can add premission to it.
# resource "aws_ssoadmin_permission_set" "developer_access" {
#   name             = "DeveloperAccess"
#   instance_arn     = local.sso_instance_arn
#   session_duration = "PT4H" # 4 hour session, ISO 8601 duration format

#   description = "Standard developer access"
# }

# # this is the resources that actualy add the premission to the empty shell.
# resource "aws_ssoadmin_managed_policy_attachment" "developer_policy" {
#   instance_arn       = local.sso_instance_arn
#   permission_set_arn = aws_ssoadmin_permission_set.developer_access.arn

#   # full access except IAM/account management
#   managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess" 
# }

# # Assign the group to an AWS account with that permission set
# # so you can think about it like activating the premission we talked about
# # here we gave it to the developers group.
# resource "aws_ssoadmin_account_assignment" "developers_dev_account" {

#   instance_arn       = local.sso_instance_arn
#   permission_set_arn = aws_ssoadmin_permission_set.developer_access.arn

#   principal_id   = aws_identitystore_group.developers.group_id
#   principal_type = "GROUP"

#     # this is the account you will be granted access after login to the portal sara account
#   target_id   = aws_organizations_account.dev_account.id # target AWS account ID
#   target_type = "AWS_ACCOUNT"
# }

# resource "aws_organizations_account" "dev_account" {
#   name  = "Dev Account"
#   email = "aws-dev+unique@example.com" # must be a globally unique email, not used by any other AWS account ever

#   # parent_id = aws_organizations_organizational_unit.dev_ou.id # optional, place it in an OU
#   role_name = "OrganizationAccountAccessRole" # default IAM role created for management-account access

#   tags = {
#     Environment = "Dev"
#   }
# }