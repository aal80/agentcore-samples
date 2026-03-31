FROM --platform=linux/amd64 openpolicyagent/opa:latest

# Lambda Web Adapter — translates Lambda invocations into HTTP requests to OPA
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:1.0.0 /lambda-adapter /opt/extensions/lambda-adapter

COPY policy.rego /policies/policy.rego
COPY config.yaml /config.yaml

EXPOSE 8181

# Tell the adapter which port OPA is listening on
ENV AWS_LWA_PORT=8181
ENV AWS_LWA_READINESS_CHECK_PATH="/health"

ENTRYPOINT ["/opa"]
CMD ["run", "--server", "--addr", "0.0.0.0:8181", "--log-level", "info", "--config-file", "/config.yaml", "/policies"]
