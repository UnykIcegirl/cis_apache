#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------------
# Maribel HG   13/08/21   Validate the installation of the minimum modules

no_existe=""

variable=$(httpd -M | grep dav_* || apachectl -M | grep "$XCCDF_VALUE_REGEX" )

echo -e "Configuracion existente: \n" "$variable"

# If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
if [ "$variable" = "$no_existe" ] ; then
    echo "El módulo esta deshabilitado"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo -e "\n \n Deshabilitar el módulo " $XCCDF_VALUE_REGEX " para cumplir el control"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi



