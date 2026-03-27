resource "awscc_bedrockagentcore_policy_engine" "this" {
  name = "${local.project_name_underscore}"
}

# resource "awscc_bedrockagentcore_policy" "permit_all" {
#   name             = "permit_all"
#   policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
#   validation_mode  = "IGNORE_ALL_FINDINGS"

#   definition = {
#     cedar = {
#       statement = "permit(principal, action, resource is AgentCore::Gateway);"
#     }
#   }
# }

# resource "awscc_bedrockagentcore_policy" "allow_get_menu" {
#   name             = "allow_get_menu"
#   policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
#   validation_mode  = "IGNORE_ALL_FINDINGS"

#   definition = {
#     cedar = {
#       statement = <<-EOT
#         permit(
#           principal,
#           action == AgentCore::Action::"get-menu___get-menu",
#           resource == AgentCore::Gateway::"${awscc_bedrockagentcore_gateway.this.gateway_arn}"
#         );
#       EOT
#     }
#   }
# }

# resource "awscc_bedrockagentcore_policy" "allow_create_order_with_scope" {
#   name             = "allow_create_order_with_scope"
#   policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
#   validation_mode  = "IGNORE_ALL_FINDINGS"

#   definition = {
#     cedar = {
#       statement = <<-EOT
#         permit(
#           principal, 
#           action == AgentCore::Action::"create-order___create-order", 
#           resource == AgentCore::Gateway::"${awscc_bedrockagentcore_gateway.this.gateway_arn}"
#         )
#         when {
#           principal.hasTag("scope") &&
#           principal.getTag("scope") like "*gateway/create_order*"
#         };
#       EOT
#     }
#   }
# }

# resource "awscc_bedrockagentcore_policy" "forbid_pineapple_pizza" {
#   name             = "forbid_pineapple_pizza"
#   policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
#   validation_mode  = "IGNORE_ALL_FINDINGS"

#   definition = {
#     cedar = {
#       statement = <<-EOT
#         forbid (
#           principal, 
#           action == AgentCore::Action::"create-order___create-order", 
#           resource == AgentCore::Gateway::"${awscc_bedrockagentcore_gateway.this.gateway_arn}"
#         )
#         when {
#           context.input.pizzaId == 5
#         };
#       EOT
#     }
#   }
# }