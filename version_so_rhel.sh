#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# Maribel HG   04/15/21   Validate the version of rhel

version=$(cat /etc/redhat-release | grep -Eo '[0-9].[0-9]')
so=$(cat /etc/redhat-release)
echo "version host:" $so

# If the regex matched, output would be generated.  If so, we pass
if [ "$version" = "$XCCDF_VALUE_REGEX" ] ; then
    echo "La version $XCCDF_VALUE_REGEX es valida"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "se espera la version  $XCCDF_VALUE_REGEX, la actual no es valida"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi



