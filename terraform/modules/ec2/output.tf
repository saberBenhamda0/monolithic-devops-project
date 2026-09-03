output "ec2_ids" {
  value       = { for k, v in aws_instance.instances : k => v.id }
  description = "map of instance name to ec2 id"
}