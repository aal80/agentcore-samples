resource "aws_bedrockagentcore_api_key_credential_provider" "this" {
    name = "${local.project_name}"
    api_key = "abcd1234abcd1234"
}

resource "local_file" "credential_provider_name" {
  filename = "./../tmp/credential_provider_name.txt"
  content = aws_bedrockagentcore_api_key_credential_provider.this.name
}

output "credential_provider_name" {
  value = aws_bedrockagentcore_api_key_credential_provider.this.name
}