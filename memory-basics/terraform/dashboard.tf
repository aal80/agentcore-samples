locals {
  cw_namespace = "AWS/Bedrock-AgentCore"
  memory_arn   = aws_bedrockagentcore_memory.this.arn
  region       = data.aws_region.current.region
}

resource "aws_cloudwatch_dashboard" "memory" {
  dashboard_name = "${local.project_name}"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: Event Ingestion
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# Event Ingestion"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 8
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "Invocations", "Resource", local.memory_arn, "Operation", "CreateEvent", { stat = "Sum" }]
          ]
          title  = "CreateEvent Invocations"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 1
        width  = 8
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "Latency", "Resource", local.memory_arn, "Operation", "CreateEvent", { stat = "Average", label = "Avg" }],
            [local.cw_namespace, "Latency", "Resource", local.memory_arn, "Operation", "CreateEvent", { stat = "p99", label = "p99" }]
          ]
          title  = "CreateEvent Latency (ms)"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 1
        width  = 8
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "CreationCount", "Resource", local.memory_arn, "ItemType", "Event", { stat = "Sum", label = "Events", yAxis = "left" }],
            [local.cw_namespace, "CreationCount", "Resource", local.memory_arn, "ItemType", "MemoryRecordsExtracted", { stat = "Sum", label = "Memory Records", yAxis = "right" }]
          ]
          title  = "Events & Records Created"
          region = local.region
          period = 300
          view   = "timeSeries"
          yAxis = {
            left  = { label = "Events" }
            right = { label = "Memory Records" }
          }
        }
      },

      # Row 2: Errors & Token count
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 8
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "Errors", "Resource", local.memory_arn, "Operation", "CreateEvent", { stat = "Sum", label = "CreateEvent" }],
            [local.cw_namespace, "Errors", "Resource", local.memory_arn, "Operation", "ListMemoryRecords", { stat = "Sum", label = "ListMemoryRecords" }]
          ]
          title  = "Errors by Operation"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 8
        width  = 8
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "UserErrors", "Resource", local.memory_arn, "Operation", "CreateEvent", { stat = "Sum", label = "CreateEvent" }],
            [local.cw_namespace, "UserErrors", "Resource", local.memory_arn, "Operation", "ListMemoryRecords", { stat = "Sum", label = "ListMemoryRecords" }]
          ]
          title  = "User Errors by Operation"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 8
        width  = 8
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "TokenCount", "Resource", local.memory_arn, "Operation", "LongTermMemoryProcessing", { stat = "Sum" }]
          ]
          title  = "Token Count (LongTermMemoryProcessing)"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },

      # Row 3: Strategy Processing - Extraction
      {
        type   = "text"
        x      = 0
        y      = 14
        width  = 24
        height = 1
        properties = {
          markdown = "# Strategy Processing — Extraction"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 15
        width  = 12
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "Invocations", "StrategyType", "Preference", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.user_preference.memory_strategy_id, "Operation", "Extraction", { stat = "Sum", label = "User Preference" }],
            [local.cw_namespace, "Invocations", "StrategyType", "Semantic", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.semantic.memory_strategy_id, "Operation", "Extraction", { stat = "Sum", label = "Semantic" }],
            [local.cw_namespace, "Invocations", "StrategyType", "BuiltIn", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.session_summary.memory_strategy_id, "Operation", "Extraction", { stat = "Sum", label = "Session Summary" }]
          ]
          title  = "Extraction Invocations by Strategy"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 15
        width  = 12
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "Latency", "StrategyType", "Preference", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.user_preference.memory_strategy_id, "Operation", "Extraction", { stat = "Average", label = "User Preference" }],
            [local.cw_namespace, "Latency", "StrategyType", "Semantic", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.semantic.memory_strategy_id, "Operation", "Extraction", { stat = "Average", label = "Semantic" }],
            [local.cw_namespace, "Latency", "StrategyType", "BuiltIn", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.session_summary.memory_strategy_id, "Operation", "Extraction", { stat = "Average", label = "Session Summary" }]
          ]
          title  = "Extraction Latency (ms) by Strategy"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },

      # Row 4: Strategy Processing - Consolidation
      {
        type   = "text"
        x      = 0
        y      = 21
        width  = 24
        height = 1
        properties = {
          markdown = "# Strategy Processing — Consolidation"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 22
        width  = 12
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "Invocations", "StrategyType", "Preference", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.user_preference.memory_strategy_id, "Operation", "Consolidation", { stat = "Sum", label = "User Preference" }],
            [local.cw_namespace, "Invocations", "StrategyType", "Semantic", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.semantic.memory_strategy_id, "Operation", "Consolidation", { stat = "Sum", label = "Semantic" }],
            [local.cw_namespace, "Invocations", "StrategyType", "BuiltIn", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.session_summary.memory_strategy_id, "Operation", "Consolidation", { stat = "Sum", label = "Session Summary" }]
          ]
          title  = "Consolidation Invocations by Strategy"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 22
        width  = 12
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "Latency", "StrategyType", "Preference", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.user_preference.memory_strategy_id, "Operation", "Consolidation", { stat = "Average", label = "User Preference" }],
            [local.cw_namespace, "Latency", "StrategyType", "Semantic", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.semantic.memory_strategy_id, "Operation", "Consolidation", { stat = "Average", label = "Semantic" }],
            [local.cw_namespace, "Latency", "StrategyType", "BuiltIn", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.session_summary.memory_strategy_id, "Operation", "Consolidation", { stat = "Average", label = "Session Summary" }]
          ]
          title  = "Consolidation Latency (ms) by Strategy"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      },

      # Row 5: Token Usage by Strategy
      {
        type   = "text"
        x      = 0
        y      = 28
        width  = 24
        height = 1
        properties = {
          markdown = "# Token Usage by Strategy"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 29
        width  = 24
        height = 6
        properties = {
          metrics = [
            [local.cw_namespace, "TokenCount", "StrategyType", "Preference", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.user_preference.memory_strategy_id, "Operation", "LongTermMemoryProcessing", { stat = "Sum", label = "User Preference" }],
            [local.cw_namespace, "TokenCount", "StrategyType", "Semantic", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.semantic.memory_strategy_id, "Operation", "LongTermMemoryProcessing", { stat = "Sum", label = "Semantic" }],
            [local.cw_namespace, "TokenCount", "StrategyType", "BuiltIn", "Resource", local.memory_arn, "StrategyId", aws_bedrockagentcore_memory_strategy.session_summary.memory_strategy_id, "Operation", "LongTermMemoryProcessing", { stat = "Sum", label = "Session Summary" }]
          ]
          title  = "Token Usage by Strategy"
          region = local.region
          period = 300
          view   = "timeSeries"
        }
      }
    ]
  })
}
