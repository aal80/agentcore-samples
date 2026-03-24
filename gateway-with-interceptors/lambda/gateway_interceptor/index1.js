exports.handler = async (event) => { 
  console.log(`incoming event`, JSON.stringify(event, null, 2));

  let interceptorResponse;

  if (event.mcp.gatewayResponse){
    console.log('> gateway response intercepted');

    // No changes to outgoing response
    interceptorResponse = {
      interceptorOutputVersion: "1.0",
      mcp: {
        transformedGatewayResponse : {
            statusCode: event.mcp.gatewayResponse.statusCode,
            body: event.mcp.gatewayResponse.body
        }
      }
    }
  } else if (event.mcp.gatewayRequest){
    console.log('> gateway request intercepted');

    // No changes to incoming request
    interceptorResponse = {
      interceptorOutputVersion:"1.0",
      mcp: {
        transformedGatewayRequest: {
          body: event.mcp.gatewayRequest.body
        }
      }
    }

  }
  
  console.log(`interceptor response:`, JSON.stringify(interceptorResponse, null, 2));   
  return interceptorResponse;
};
