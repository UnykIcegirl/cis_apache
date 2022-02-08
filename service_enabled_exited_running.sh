#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# Maribel HG   04/15/21   Check that service is running and not disabled or masked

active=""
exited=""
passing=""

systemctl status "$XCCDF_VALUE_REGEX" | grep -q "Active: active (running) " && systemctl is-enabled "$XCCDF_VALUE_REGEX" | grep -q enabled && active="y"
systemctl status "$XCCDF_VALUE_REGEX" | grep -q "Active: active (exited) " && systemctl is-enabled "$XCCDF_VALUE_REGEX" | grep -q enabled && exited="y"

[ "$active" = y ] || [ "$exited" = y ] && passing="true"

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
    echo "Service $XCCDF_VALUE_REGEX is running and enabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "Service $XCCDF_VALUE_REGEX is not running or disabled"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi

