import { readFileSync } from 'fs';
import { BedrockAgentCoreClient, InvokeAgentRuntimeCommand } from '@aws-sdk/client-bedrock-agentcore';

const runtimeArn = readFileSync('./tmp/agent_runtime_arn.txt', 'utf-8').trim();
console.log(`> RUNTIME_ARN=${runtimeArn}`);

const client = new BedrockAgentCoreClient();
const payload = JSON.stringify({ hello: 'world' });

console.log('> Invoking...');
const command = new InvokeAgentRuntimeCommand({
  agentRuntimeArn: runtimeArn,
  payload: Buffer.from(payload),
  contentType: 'application/json',
});

const response = await client.send(command);
const responseString = await response.response.transformToString()

console.log(responseString);

