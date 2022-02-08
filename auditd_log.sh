#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# Maribel HG   04/27/21   Validate configuration into the file /etc/audit/auditd.conf

no_existe=""

variable=$(grep "$XCCDF_VALUE_REGEX" /etc/audit/auditd.conf)
#variable=$(grep '^\s*max_log_file\s*=\s*\S*\s*\?$' /etc/audit/auditd.conf)

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



