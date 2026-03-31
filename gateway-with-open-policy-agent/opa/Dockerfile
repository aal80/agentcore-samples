FROM openpolicyagent/opa:latest

COPY policy.rego /policies/policy.rego
COPY config.yaml /config.yaml

EXPOSE 8181

ENTRYPOINT ["/opa"]
CMD ["run", "--server", "--addr", "0.0.0.0:8181", "--log-level", "info", "--config-file", "/config.yaml", "/policies"]
