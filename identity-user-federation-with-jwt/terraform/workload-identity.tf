resource "aws_bedrockagentcore_workload_identity" "agent1" {
  name = "${local.project_name}"
}

resource "local_file" "workload_identity_name" {
  filename = "${path.module}/../tmp/workload_identity_name.txt"
  content = aws_bedrockagentcore_workload_identity.agent1.name
}

output "workload_identity_name" {
  value = aws_bedrockagentcore_workload_identity.agent1.name
}