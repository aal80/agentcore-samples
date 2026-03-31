import { jwtDecode } from 'jwt-decode';

const OPA_ENDPOINT = `${process.env.OPA_ENDPOINT}/v1/data/pizzashop`;
console.log(`OPA_ENDPOINT=${OPA_ENDPOINT}`);

export const handler = async (event) => {
  console.log(`incoming event`, JSON.stringify(event, null, 2));

  // Use if you want to intercept both request and response
  // const interceptorResponse = (event.mcp.gatewayResponse === null) ?
  //   await processGatewayRequest(event) : await processGatewayResponse(event);

  // This project implements request interceptor only. 
  const interceptorResponse = await processGatewayRequest(event);

  console.log(`interceptor response:`, JSON.stringify(interceptorResponse, null, 2));
  return interceptorResponse;
};

const processGatewayRequest = async (event) => {
  console.log('> processGatewayRequest')
  if (event.mcp.gatewayRequest.body.method === "tools/list") {
    return noChangeGatewayRequest(event);
  } else { /* tool calls */ 
    return validateAccessPolicies(event);
  }
}

const noChangeGatewayRequest = (event) => {
  console.log('> noChangeGatewayRequest');
  return {
    interceptorOutputVersion: "1.0",
    mcp: {
      transformedGatewayRequest: {
        body: event.mcp.gatewayRequest.body
      }
    }
  }
}

const policyViolationGatewayResponse = (event) => {
  console.log('> policyViolationGatewayResponse');
  return {
    interceptorOutputVersion: "1.0",
    mcp: {
      transformedGatewayResponse: {
        statusCode: 200,
        body: {
          id: event.mcp.gatewayRequest.body.id,
          jsonrpc: event.mcp.gatewayRequest.body.jsonrpc,
          error: {
            code: -32090,
            message: "Policy violation. Request rejected."
          }
        }
      }
    }
  }
}


const validateAccessPolicies = async (event) => {
  console.log('> validateAccessPolicies');
  const accessToken = event.mcp.gatewayRequest.headers.authorization;
  const tokenPayload = jwtDecode(accessToken);
  const scope = tokenPayload.scope;
  const mcpMethod = event.mcp.gatewayRequest.body.method;
  const mcpToolName = event.mcp.gatewayRequest.body.params.name;
  const mcpToolArguments = event.mcp.gatewayRequest.body.params.arguments;

  const opaInput = { scope, mcpMethod, mcpToolName, mcpToolArguments };

  console.log({ opaInput });
  const opaResponse = await getOpaResponse(opaInput);
  console.log({ opaResponse });

  if (opaResponse.result===true){
    return noChangeGatewayRequest(event);
  } else {
    return policyViolationGatewayResponse(event);
  }
}

const getOpaResponse = async (opaInput) => {
  console.log(`> getOpaResponse`);
  let opaEndpoint = OPA_ENDPOINT;
  switch (opaInput.mcpToolName) {
    case "get-menu___get-menu":
      opaEndpoint = opaEndpoint += "/allowed_to_get_menu"; break
    case "create-order___create-order":
      opaEndpoint = opaEndpoint += "/allowed_to_create_orders"; break
  }
  console.log(` | opaEndpoint=${opaEndpoint}`);

  try {
    const resp = await fetch(opaEndpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ input: opaInput })
    });

    const respJson = await resp.json();
    return respJson;
  } catch(e){
    console.error(`ERROR: `, e);
  }
}


