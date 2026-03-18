#!/usr/bin/env bash
set -euo pipefail

FAILED=false

echo "============================================"
echo " Checking Observability Prereqs"
echo "============================================"

echo ""
echo "--- Transaction Search enabled ---"
echo "aws xray get-trace-segment-destination MUST equal CloudWatchLogs"
DEST=$(aws xray get-trace-segment-destination --query Destination --output text 2>/dev/null || echo "")
if [ "$DEST" = "CloudWatchLogs" ]; then
    echo "  PASS"
else
    echo "  FAIL: destination is \"$DEST\" (expected \"CloudWatchLogs\")"
    echo "  -> CloudWatch console -> Application Signals -> Transaction Search -> Enable"
    FAILED=true
fi

echo ""
echo "--- aws/spans log group exists ---"
echo "aws/spans CloudWatch Log Group MUST exist"
RESULT=$(aws logs describe-log-groups --log-group-name-prefix "aws/spans" \
    --query 'logGroups[?logGroupName==`aws/spans`].logGroupName' --output text 2>/dev/null || echo "")
if echo "$RESULT" | grep -q "aws/spans"; then
    echo "  PASS"
else
    echo "  FAIL: log group \"aws/spans\" does not exist"
    echo "  -> This is auto-created when you enable Transaction Search"
    echo "  -> If already enabled, try disabling and re-enabling it"
    FAILED=true
fi

echo ""
echo "============================================"
if [ "$FAILED" = true ]; then
    echo " Fix the issues above before running terraform."
    exit 1
else
    echo " All prereqs met. "
    echo ""
    echo " Note: Required CloudWatch resource policies will be created during 'terraform apply'"
fi
echo "============================================"
