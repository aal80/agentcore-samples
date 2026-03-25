# Stores information about user preferences, scoped to a particular users.
# Preferences persist across different sessions. 
resource "aws_bedrockagentcore_memory_strategy" "user_preference" {
  name        = "user_preference"
  memory_id   = aws_bedrockagentcore_memory.this.id
  type        = "USER_PREFERENCE"
  namespaces  = ["/strategy/{memoryStrategyId}/actor/{actorId}/preferences/"]
}

# Extracted semantic facts are tied to a particular session of a particular user. 
resource "aws_bedrockagentcore_memory_strategy" "semantic" {
  name        = "semantic"
  memory_id   = aws_bedrockagentcore_memory.this.id
  type        = "SEMANTIC"
  namespaces  = ["/strategy/{memoryStrategyId}/actors/{actorId}/session/{sessionId}/facts/"]
}

resource "aws_bedrockagentcore_memory_strategy" "session_summary" {
  name        = "session_summary"
  memory_id   = aws_bedrockagentcore_memory.this.id
  type        = "SUMMARIZATION"
  namespaces  = ["/strategy/{memoryStrategyId}/summaries/actors/{actorId}/session/{sessionId}"]
}

resource "local_file" "summarization_strategy_id" {
  content         = aws_bedrockagentcore_memory_strategy.session_summary.memory_strategy_id
  filename        = "${path.module}/../tmp/summarization_strategy_id.txt"
  directory_permission = "0755"
  file_permission      = "0644"
}
