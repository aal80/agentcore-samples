exports.handler = async (event) => { 
  console.log(`incoming event`, JSON.stringify(event, null, 2));

  let interceptorResponse;

  if (event.mcp.gatewayResponse){
    console.log('> gateway response intercepted');

    interceptorResponse = {
      interceptorOutputVersion: "1.0",
      mcp: {
        transformedGatewayResponse : {
            statusCode: event.mcp.gatewayResponse.statusCode,
            body: event.mcp.gatewayResponse.body
        }
      }
    }

    // Add currency
    const responseText = event.mcp.gatewayResponse.body.result.content[0].text;
    console.log(`original responseText=${responseText}`);
    const parsedResponseText = JSON.parse(responseText);
    parsedResponseText.currency = "USD";
    const modifiedResponseText = JSON.stringify(parsedResponseText);
    console.log(`modified responseText=${modifiedResponseText}`);
    interceptorResponse.mcp.transformedGatewayResponse.body.result.content[0].text = modifiedResponseText;
  
  } else if (event.mcp.gatewayRequest){
    console.log('> gateway request intercepted');

    interceptorResponse = {
      interceptorOutputVersion:"1.0",
      mcp: {
        transformedGatewayRequest: {
          body: event.mcp.gatewayRequest.body
        }
      }
    }

    // Replace [1,2,3] with [4,5,6]
    interceptorResponse.mcp.transformedGatewayRequest.body.params.arguments.itemIds = [4,5,6]
  }
  
  console.log(`interceptor response:`, JSON.stringify(interceptorResponse, null, 2));   
  return interceptorResponse;
};
