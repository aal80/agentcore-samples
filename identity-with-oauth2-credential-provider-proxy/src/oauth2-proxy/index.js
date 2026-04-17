import { handleDiscovery } from "./discovery.js";
import { handleToken } from "./token.js";

export const handler = async (event) => {
  // console.log(event);

  const path = event.requestContext?.http?.path ?? "";
  const method = event.requestContext?.http?.method ?? "";

  console.log(`>> ${method} ${path}`);

  if (method === "GET" && path.endsWith("/.well-known/openid-configuration")) {
    return handleDiscovery();
  } 

  if (method === "POST" && path.endsWith("/oauth2/token")) {
    const authHeader = event.headers.Authorization ?? event.headers.authorization;
    return handleToken(authHeader);
  }

  return {
    statusCode: 404,
    body: JSON.stringify({ error: "not_found", path, method }),
  };
};
