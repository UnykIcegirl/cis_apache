#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# Maribel HG   04/26/21   Validate configuration into the file /etc/audit/rules.d/*.rules

no_existe=""

#variable=$(grep "^\s*-e\s*2\s*$" /etc/audit/rules.d/*.rules)
variable=$(grep "$XCCDF_VALUE_REGEX" /etc/audit/rules.d/*.rules)

#echo "CIS: " "$XCCDF_VALUE_REGEX"
echo "Configuracion: " "$variable"

# If the regex matched, output would be generated.  If so, we pass
if [ "$variable" = "$no_existe" ] ; then
    echo "La configuración no está realizada"
    exit "${XCCDF_RESULT_FAIL:-102}"
else
    # print the reason why we are failing
    echo "La configuración es valida"
    exit "${XCCDF_RESULT_PASS:-101}"
fi



