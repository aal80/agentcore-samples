const TARGET_DISCOVERY_URL = process.env.TARGET_DISCOVERY_URL;
const PROXY_TOKEN_ENDPOINT = process.env.PROXY_TOKEN_ENDPOINT;

console.log(`TARGET_DISCOVERY_URL=${TARGET_DISCOVERY_URL}`);
console.log(`PROXY_TOKEN_ENDPOINT=${PROXY_TOKEN_ENDPOINT}`);

export const handler = async (event) => {
  const response = await fetch(TARGET_DISCOVERY_URL);
  const responseJson = await response.json();

  if (responseJson.token_endpoint) {
    // delete responseJson.authorization_endpoint;
    // delete responseJson.end_session_endpoint;
    // delete responseJson.revocation_endpoint;
    // delete responseJson.userinfo_endpoint;

    responseJson.token_endpoint = PROXY_TOKEN_ENDPOINT
  }

  return {
    statusCode: response.status,
    body: JSON.stringify(responseJson)
  };
};
