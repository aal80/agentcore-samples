# Amazon Bedrock AgentCore Harness Basics

Amazon Bedrock AgentCore Harness lets you define and run AI agents declaratively — no agent loop to implement, no orchestration code to write. You configure the model, system prompt, tools, and memory at the Harness level, then invoke it. AgentCore handles model invocation, session management, tool execution, and memory retrieval on your behalf.

This project demonstrates how to create and invoke Harness using the AWS CLI and Python SDK. Covers three scenarios: basic invocation, tool use via MCP, and persistent memory.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Python >= 3.13
- `uv` and `jq`

## Architecture

Terraform provisions:
- IAM execution role for the harness 
- AgentCore Memory resource 

As of writing this, Harness is in Preview and does not provide Terraform support yet, hence you'll create it using the AWS CLI.

## Walkthrough

### Deploy infrastructure

```bash
make deploy-infra
```

Creates IAM roles and memory resources. Saves outputs to `tmp/`:

| File | Contents |
|------|----------|
| `tmp/harness_iam_role_arn.txt` | Execution role ARN |
| `tmp/memory_id.txt` | Memory resource ID |
| `tmp/memory_arn.txt` | Memory resource ARN |
| `tmp/aws_region.txt` | AWS region |
| `tmp/aws_account_id.txt` | AWS account ID |

### Create harness

```bash
make create-harness
```

This is a shortcut to the following AWS CLI command, defined in the `Makefile`:

```bash
aws bedrock-agentcore-control create-harness \
    --harness-name "test_harness" \
    --execution-role-arn "...." \
    --model '{"bedrockModelConfig": {"modelId": "us.amazon.nova-2-lite-v1:0"}}' \
    --system-prompt '[{"text": "You are a famous chef. Your replies MUST be less than 100 words."}]' \
```

Note the model and system prompt. Harness configuration can be defined globally, at the Harness level. But it can also be overridden at per-invoke level, as you will see shortly. 

Running the above command creates a harness named `test_harness` using default `us.amazon.nova-2-lite-v1:0` model with a chef persona system prompt. Saves `tmp/harness_id.txt` and `tmp/harness_arn.txt`.

It will take the new Harness a couple of minutes to activate. Monitor the status by running `make get-harness`. You should see `status: READY`. 

```
... REDACTED ...
skills: []

status: READY <-- this is what you're looking for!

systemPrompt:
... REDACTED ...
```

### Basic functionality and default overrides

Explore [./src/demo-basics.py](./src/demo-basics.py). Note how easy it is to invoke the Harness. 

```python
response = client.invoke_harness(
    harnessArn=harness_arn,
    runtimeSessionId=str(uuid.uuid4()),
    messages=[{
        "role": "user",
        "content": [{"text": "How do I cook pizza?"}]
    }],

    # Some commented out properties
)
```

Run the demo

```bash
make demo-basics
```

As you saw in `demo-basic.py`, this demo sends a simple "How do I cook pizza?" prompt to the harness using `invoke_harness`, see [./src/demo-basics.py](./src/demo-basics.py)

Expected output:
```
harness_arn=arn:aws:bedrock-agentcore:us-east-1:123456789012:harness/test_harness-eYLchU0JZV

Making a great pizza starts with the dough — mix flour, yeast, salt, and water, knead well,
and let it rise for an hour. Stretch it thin, spread a simple tomato sauce, add fresh mozzarella,
and your favorite toppings. Bake at the highest oven temperature (ideally 500°F/260°C) for 8–10
minutes until the crust is golden and the cheese is bubbling. Buon appetito!
```

Now let's customize the invocation and override the default configuration set at the global Harness level. Edit the [./src/demo-basics.py](./src/demo-basics.py) and uncomment the lines defining new system prompt and model to use. 

```python
response = client.invoke_harness(
    harnessArn=harness_arn,
    runtimeSessionId=str(uuid.uuid4()),
    messages=[{
        "role": "user",
        "content": [{"text": "How do I cook pizza?"}]
    }],
    
    # Uncomment the below section
    systemPrompt=[{
        "text":"You're a Japanese sushi chef, everything you do has Japanese twist"
        }],
    model={
        "bedrockModelConfig": {
            "modelId": "us.anthropic.claude-opus-4-5-20251101-v1:0"
        }
    }
)
```

Run the demo again with `make demo-basics`. Now you're getting a very different response for the same prompt. 

```
harness_arn=arn:aws:bedrock-agentcore:us-east-1:281024298475:harness/test_harness-4CvC8jUSGz

Ah, pizza-san! 🍕 

While pizza is not traditional Japanese cuisine, as a sushi chef, I appreciate all forms of culinary art! Let me share with you the way of the pizza, with a little Japanese spirit - **"Shokunin"** (職人) - the craftsman's dedication to perfection!
```

This illustrates one of the core principles of Harness. You can set defaults at the Harness level, and then override at the per-invoke granularity. This applies to models, system prompts, message history, and more. 

[See AgentCore Harness docs for additional info.](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness.html)

### Using tools with harness

Harness allows you to specify tools globally, or per `invoke_harness` call, as shown in this demo. 

[Exa](https://exa.ai) MCP server (`https://mcp.exa.ai/mcp`) as a `remote_mcp` tool that allows to search web using its `web_search_exa` tool. See [./src/demo-tools.py](./src/demo-tools.py) for how this tool can be configured for using with Harness

```python
tools = [
    {
        "type":"remote_mcp",
        "name":"exa",
        "config": {"remoteMcp": {"url": "https://mcp.exa.ai/mcp"}},
    }
]
```

The code in `demo-tools.py` passes the tool configuration at invocation time — no harness update needed. The agent uses the tool to look up current weather for Austin, TX before answering. The chef persona is still in effect, so the response frames the weather advice around dining outdoors.

Initially the tool usage is commented out (see line 22), so the result is:

```
I can't directly check the weather for you, but I can guide you on how to find reliable forecasts. For accurate weather in Austin, TX, use trusted weather services like:

- **Weather.com**
- **AccuWeather**
- **National Weather Service**
- **Your preferred weather app**
```

To enable Harness to use it, edit [./src/demo-tools.py](./src/demo-tools.py) and update `invoke_harness` call by uncommenting tools usage:

```python
response = client.invoke_harness(
    harnessArn=harness_arn,
    runtimeSessionId=str(uuid.uuid4()),
    tools=tools, # <-- Uncomment this line
    messages=[{
        "role": "user",
        "content": [{"text": "What's the weather in Austin TX tomorrow, is it good for eating out?"}]
    }],
)
```

Run `make demo-tools` again. This time, the Harness uses the Exa tool to browse the internet and find the weather forecast. 

Expected output:
```
harness_arn=arn:aws:bedrock-agentcore:us-east-1:123456789012:harness/test_harness-eYLchU0JZV

Tomorrow in Austin, TX looks wonderful for dining al fresco! Expect sunny skies with temperatures
around 78°F (26°C) and a light breeze — perfect conditions for enjoying a meal on a patio.
I'd recommend reserving a terrace table at your favorite spot and perhaps a chilled gazpacho to start!
```

[See AgentCore Harness docs for additional info about wide array of tools you can connect.](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness-tools.html)


### Memory

Memory allows Harness to remember previous conversations with users. Let's update the Harness to use the AgentCore Memory

```bash
make update-harness-for-memory
```

This command uses AWS CLI `update-harness` command to attach the memory resource to the harness. From this point on, the harness can automatically store and retrieve user preferences across sessions using the `actorId` passed at invocation time.

Explore the [./src/demo-memory.py](./src/demo-memory.py). This file uses a fixed `RUNTIME_SESSION_ID` and `ACTOR_ID` so AgentCore associates memory with the same user across calls. 

1. **First run** — See the uncommented message in `src/demo-memory.py`:
   
   ```python
    messages=[{
        "role": "user",
        "content": [{"text": "I really, REALLY like pizza and sushi, especially with spicy sauce!"}]
        # "content": [{"text": "Can you refresh my memory, what's my favorite food?"}]
        # "content": [{"text": "What did we just talked about?"}]
    }],
   ```
   
   Run `make demo-memory`. The harness will acknowledge and store the preference. Expected result:

   ```
    harness_arn=arn:aws:bedrock-agentcore:us-east-1:281024298475:harness/test_harness1-UYtPTa66Z2
    memory_id=zbsv_harness_basics-sr73Xq31mb
    
    Perfect! I've saved your favorite foods—pizza and sushi with spicy sauce. Now we have a delicious reminder of your tastes. Ready to explore new spicy recipes or techniques for these dishes?
   ```

2. **Second run** — update `src/demo-memory.py` to one of the "recall" messages:
   ```python
    messages=[{
        "role": "user",
        # "content": [{"text": "I really, REALLY like pizza and ....."}]
        "content": [{"text": "Can you refresh my memory, what's my favorite food?"}]
        # "content": [{"text": "What did we just talked about?"}]
    }],

   ```

    Run `make demo-memory`. Expected output on the second run:

    ```
    harness_arn=arn:aws:bedrock-agentcore:us-east-1:123456789012:harness/test_harness-eYLchU0JZV
    memory_id=abcd-harness-basics_abcd1234
    
    Ah, from what I recall, you have a passion for pizza and sushi — especially with a kick of spicy sauce!
    ```

[See AgentCore Harness docs for additional info about attaching memory and filesystem to Harness](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness-memory.html)

## Summary

This project walked through three progressive scenarios:

| Demo | What it shows |
|------|---------------|
| `demo-basics` | Invoke a harness with a single message; override model and system prompt per-call |
| `demo-tools` | Attach a remote MCP tool at invocation time to give the agent web search capability |
| `demo-memory` | Use a fixed `actorId` to persist user preferences across sessions via AgentCore Memory |

[See AgentCore Harness docs for additional info.](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness.html)

## Cleanup

```bash
make delete-harness
make destroy
```
