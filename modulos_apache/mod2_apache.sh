#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 2
# Fecha: 9/02/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 2
function Mod2_2(){
   echo -e "\n 2.2 Ensure the Log Config Module Is Enabled"
   echo -e "================================================="
   ((++total))
   variable=$(apachectl -M | grep log_config || httpd -M | grep log_config)

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo LOG CONFIG esta deshabilitado -----------------------------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   else
      # print the reason why we are failing
      echo -e "\n \n El módulo LOG CONFIG esta habilitado -----------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   fi

   sal_22=$(jo id="2.2 Ensure the Log Config Module Is Enabled" descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
   #echo -e "$sal_22"
}


function Mod2_3(){
   echo -e "\n 2.3 Ensure the WebDAV Modules Are Disabled"
   echo -e "============================================="
   ((++total))
   variable=$(httpd -M | grep -m 1 dav_* || apachectl -M | grep -m 1 dav_* || apache2 -M | grep -m 1 dav_* )

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo WebDAV esta deshabilitado ---------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo WebDAV para cumplir el control --------------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   sal_23=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="The Apache `mod_dav` and `mod_dav_fs` modules support WebDAV ('Web-based Distributed Authoring and Versioning') functionality for Apache. WebDAV is an extension to the HTTP protocol which allows clients to create, move, and delete files and resources on the web server." como_cumplirlo="Disabling WebDAV modules will improve the security posture of the web server by reducing the amount of potentially vulnerable code paths exposed to the network and reducing potential for unauthorized access to files via misconfigured WebDAV access controls." evidencia="$variable" estado="$resultado")
   #echo -e "$sal_23"
}



function mod2(){
   #instanciasactivas

   # MODULO 2
   #++++++++++
   Mod2_2
   Mod2_3

   sal_mod2="$sal_22, $sal_23"

   echo -e "\n\n $sal_mod2"
   
}

mod2
