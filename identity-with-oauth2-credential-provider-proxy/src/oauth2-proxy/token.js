const TARGET_TOKEN_ENDPOINT = process.env.TARGET_TOKEN_ENDPOINT;
console.log(`TARGET_TOKEN_ENDPOINT=${TARGET_TOKEN_ENDPOINT}`);

export const handleToken = async (authHeader) => {
  console.log(`> handleToken`);
  console.log(`authHeader=${authHeader.slice(0, 10)}.....`);

  const [, value] = authHeader.split(" ");
  const [client_id, client_secret] = Buffer.from(value, "base64")
    .toString("utf8")
    .split(":");

  console.log(`client_id=${client_id}`);
  console.log(`client_secret=${client_secret.slice(0, 2)}.....`);

  const targetAuthHeader = `Basic ${Buffer.from(`${client_id}:${client_secret}`).toString("base64")}`;

  const targetResponse = await fetch(TARGET_TOKEN_ENDPOINT, {
    method: "POST",
    headers: {
      "content-type": "application/x-www-form-urlencoded",
      authorization: targetAuthHeader,
    },
    body: new URLSearchParams({ grant_type: "client_credentials" }),
  });

  const responseJson = await targetResponse.json();
  console.log(`targetResponse.status=${targetResponse.status}`);

  return {
    statusCode: targetResponse.status,
    headers: {
      "Content-Type":"application/json"
    },
    body: JSON.stringify(responseJson),
  };
};
