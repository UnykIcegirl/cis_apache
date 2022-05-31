#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 4
# Fecha: 20/05/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 4
function Mod4_1(){
   echo -e "\n\n\n 4.1 Ensure Access to OS Root Directory Is Denied By Default"
   echo    "======================================================================"
   ((++total))

   output=$(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "Require all denied" |wc -l)
   var2=$(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "Require all denied" |wc -l)

   echo -e "Configuracion existente: \n" $(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "Require all denied") "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] ; then
       # print the reason why we are failing
       echo -e "Se tiene la función de acceso predeterminado --------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
   #   echo "pass"
       echo -e "Se tiene denegado el acceso al directorio raíz del SO ---- -------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_41=$(jo id="4.1 Ensure Access to OS Root Directory Is Denied By Default" descripcion="The Apache Directory directive allows for directory specific configuration of access controls and many other features and options. One important usage is to create a default deny policy that does not allow access to operating system directories and files, except for those specifically allowed. This is done by denying access to the OS root directory." como_cumplirlo="One aspect of Apache, which is occasionally misunderstood, is the feature of default access. That is, unless you take steps to change it, if the server can find its way to a file through normal URL mapping rules, it can and will serve it to clients. Having a default deny is a predominate security principle, and then helps prevent the unintended access, and we do that in this case by denying access to the OS root directory using either of two methods but not both: 1. Using the Apache Deny directive along with an Order directive. 2. Using the Apache Require directive." evidencia="$(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "Require all denied")" estado="$resultado")
   #echo -e "\n \n $sal_41"
}

function Mod4_3(){
   echo -e "\n\n\n 4.3 Ensure OverRide Is Disabled for the OS Root Directory"
   echo    "==================================================================="
   ((++total))

   output=$(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf|grep "AllowOverride None" | wc -l)
   var2=$(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf|grep "AllowOverrideList" | wc -l)

   echo -e "Configuracion existente: \n" $(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "AllowOverride None") "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] || [ "$var2" = 1  ]; then
       # print the reason why we are failing
       echo -e "No se tiene las directivas configuradas -------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
   #   echo "pass"
       echo -e "Configuración de directivas correctas  ---------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_43=$(jo id="4.3 Ensure OverRide Is Disabled for the OS Root Directory" descripcion="The Apache AllowOverRide directive and the new AllowOverrideList directive allow for .htaccess files to be used to override much of the configuration, including authentication, handling of document types, auto generated indexes, access control, and options. When the server finds an .htaccess file \\\(as specified by AccessFileName\\\) it needs to know which directives declared in that file can override earlier access information. When this directive is set to None, then .htaccess files are completely ignored. In this case, the server will not even attempt to read .htaccess files in the filesystem. When this directive is set to All, then any directive which has the .htaccess Context is allowed in the .htaccess files." como_cumplirlo="Perform the following to implement the recommended state: 1.Search the Apache configuration files \\\(httpd.conf and any included configuration files\\\) to find a root \\\<Directory\\\> element.  2. Remove any AllowOverrideList directives found.  3. Add a single AllowOverride directive if there is none.  4. Set the value for AllowOverride to None." evidencia[]="$(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf|grep "AllowOverride None")" evidencia[]="$(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf|grep "AllowOverrideList")" estado="$resultado")
   #echo -e "\n \n $sal_43"
}

function Mod4_4(){
   echo -e "\n\n\n 4.4 Ensure OverRide Is Disabled for All Directories"
   echo    "=============================================================="
   ((++total))

   output=$(grep -i AllowOverride "$dirConf"| grep -i "AllowOverrideList" |wc -l)
   echo -e "Configuracion existente: \n" "$(grep -i "AllowOverride" "$dirConf" | grep -i "AllowOverrideList")" "\n"
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != 0 ]; then
   echo -e "Elimine la directiva 'AllowOverrideList' ------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
   resultado="No Cumple"
   ((++fail))
   else
   echo -e "Configuración de directivas correctas ---------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
   resultado="Cumple"
   ((++pass))
   fi

   # JSON ---------------------------
   sal_44=$(jo id="4.4 Ensure OverRide Is Disabled for All Directories" descripcion="The Apache AllowOverride directive and the new AllowOverrideList directive allow for .htaccess files to be used to override much of the configuration, including authentication, handling of document types, auto generated indexes, access control, and options. When the server finds an .htaccess file (as specified by AccessFileName) it needs to know which directives declared in that file can override earlier access information. When this directive is set to None, then .htaccess files are completely ignored. In this case, the server will not even attempt to read .htaccess files in the filesystem. When this directive is set to All, then any directive which has the .htaccess context is allowed in .htaccess files." como_cumplirlo="Perform the following to determine if the recommended state is implemented:  1. Search the Apache configuration files (httpd.conf and any included configuration files) to find any AllowOverride directives.  2. Ensure there the value for AllowOverride is None.  grep -i AllowOverride $APACHE_PREFIX/conf/httpd.conf" evidencia="$(grep -i AllowOverride "$dirConf"| grep -i "AllowOverrideList")" estado="$resultado")
   #echo -e "\n \n $sal_44"
}


function mod4(){
   # MODULO 4
   #++++++++++
   Mod4_1
   Mod4_3
   Mod4_4

   sal_mod4="$sal_41, $sal_43, $sal_44"

   #echo -e "\n\n $sal_mod4"
   
}

mod4

