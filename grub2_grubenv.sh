#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# ---------------------------------------------------------------------------------------
# Maribel HG   04/26/21   Validate configuration into the file /boot/grub2/grubenv rhel8

no_existe=""

variable=$(grep "^\s*kernelopts" /boot/grub2/grubenv | grep "$XCCDF_VALUE_REGEX")

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



