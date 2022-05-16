#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 2
# Fecha: 9/05/2022
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
   variable=$(apachectl -M | grep log_config || httpd -M | grep log_config || apache2 -M | grep log_config)

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

   # JSON -------------------
   sal_22=$(jo id="2.2 Ensure the Log Config Module Is Enabled" descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
   #echo -e "$sal_22"
}


function Mod2_3(){
   echo -e "\n 2.3 Ensure the WebDAV Modules Are Disabled"
   echo -e "============================================="
   ((++total))
   variable=$(httpd -M | grep dav_* || apachectl -M | grep dav_* || apache2 -M | grep dav_* )
   evidencia=$(httpd -M | grep -m 1 dav_* || apachectl -M | grep -m 1 dav_*|| apache2 -M | grep -m 1 dav_*)

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

   # JSON ---------------------------------------------
   sal_23=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="The Apache `mod_dav` and `mod_dav_fs` modules support WebDAV ('Web-based Distributed Authoring and Versioning') functionality for Apache. WebDAV is an extension to the HTTP protocol which allows clients to create, move, and delete files and resources on the web server." como_cumplirlo="Disabling WebDAV modules will improve the security posture of the web server by reducing the amount of potentially vulnerable code paths exposed to the network and reducing potential for unauthorized access to files via misconfigured WebDAV access controls." evidencia="$evidencia" estado="$resultado")
   #echo -e "\n \n $sal_23"
}

function Mod2_4(){
   echo -e "\n 2.4 Ensure the Status Module Is Disabled"
   echo -e "============================================"
   ((++total))

   variable=$(httpd -M | grep 'status_module' || apachectl -M | grep 'status_module' || apache2 -M | grep 'status_module')

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo STATUS esta deshabilitado -----------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo STATUS para cumplir el control -----------------------------------------------------------------${RED} No cumple ${WHITE}" 
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------
   sal_24=$(jo id="2.4 Ensure the Status Module Is Disabled" descripcion="The Apache `mod_status` module provides current server performance statistics." como_cumplirlo="If the modules are correctly disabled, there will be no output when executing the above command.  # httpd -M | egrep 'status_module'" evidencia="$variable" estado="$resultado")
   #echo -e "\n \n $sal_24"
}

function Mod2_5(){
   echo -e "\n\n\n 2.5 Ensure the Autoindex Module Is Disabled"
   echo    "================================================"
   ((++total))
   variable=$(httpd -M | grep autoindex_module || apachectl -M | grep autoindex_module || apache2 -M | grep autoindex_module)

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo WebDAV esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo WebDAV para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_25=$(jo id="2.5 Ensure the Autoindex Module Is Disabled" descripcion="The Apache `autoindex` module automatically generates web page listing the contents of directories on the server, typically used so that an `index.html` does not have to be generated." como_cumplirlo="If the module is correctly disabled, there will be no output when executing the above command. # httpd -M | grep autoindex_module" evidencia="$variable" estado="$resultado")
   #echo -e "\n \n $sal_25"
}

function Mod2_6(){
   echo -e "\n\n\n 2.6 Ensure the Proxy Modules Are Disabled"
   echo    "================================================"
   ((++total))
   variable=$(httpd -M | grep proxy_ || apachectl -M | grep proxy_ || apache2 -M | grep proxy_)
   evidencia=$(httpd -M | grep -m 1 proxy_ || apachectl -M | grep -m 1 proxy_ || apache2 -M | grep -m 1 proxy_)

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo Proxy esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo Proxy para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_26=$(jo id="2.6 Ensure the Proxy Modules Are Disabled" descripcion="The Apache proxy modules allow the server to act as a proxy (either forward or reverse proxy) of HTTP and other protocols with additional proxy modules loaded. If the Apache installation is not intended to proxy requests to or from another network then the proxy module should not be loaded." como_cumplirlo="If the modules are correctly disabled, there will be no output when executing the above command. # httpd -M | grep proxy_" evidencia="$evidencia" estado="$resultado")
   #echo -e "\n \n $sal_26"
}

function Mod2_7(){
   echo -e "\n\n\n 2.7 Ensure the User Directories Module Is Disabled"
   echo    "==========================================================="
   ((++total))
   variable=$(httpd -M | grep userdir_ || apachectl -M | grep userdir_ || apache2 -M | grep userdir_)

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo 'user directories' esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo 'user directories' para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_27=$(jo id="2.7 Ensure the User Directories Module Is Disabled" descripcion="The UserDir directive must be disabled so that user home directories are not accessed via the web site with a tilde (~) preceding the username. The directive also sets the path name of the directory that will be accessed." como_cumplirlo=" If the modules are correctly disabled, there will be no output when executing the above command. # httpd -M | grep userdir_" evidencia="$variable" estado="$resultado")
   #echo -e "\n \n $sal_27"
}

function Mod2_8(){
   echo -e "\n\n\n 2.8 Ensure the Info Module Is Disabled"
   echo    "==============================================="
   ((++total))
   variable=$(httpd -M | egrep info_module || apachectl -M | egrep info_module || apache2 -M | egrep info_module)

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo Info esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo Info para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_28=$(jo id="2.8 Ensure the Info Module Is Disabled" descripcion="The Apache mod_info module provides information on the server configuration via access to a /server-info URL location." como_cumplirlo="If the module is correctly disabled, there will be no output when executing the above command. # httpd -M | egrep 'info_module'" evidencia="$variable" estado="$resultado")
   #echo -e "\n \n $sal_28"
}

function Mod2_9(){
   echo -e "\n\n\n 2.9 Ensure the Basic and Digest Authentication Modules are Disabled"
   echo    "============================================================================"
   ((++total))
   variable=$(httpd -M | grep auth_basic_module || apachectl -M | grep auth_basic_module || apache2 -M | grep auth_basic_module)
   variable2=$(httpd -M | grep auth_digest_module || apachectl -M | grep auth_digest_module || apache2 -M | grep auth_digest_module)

   echo -e "Configuracion existente: \n" "$variable"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" && "$variable2" = "$no_existe" ] ; then
      echo "El módulo 'basic and digest authentication' esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo 'basic and digest authentication' para cumplir el control ----------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_29=$(jo id="2.9 Ensure the Basic and Digest Authentication Modules are Disabled" descripcion="The Apache mod_auth_basic and mod_auth_digest modules support HTTP Basic Authentication and HTTP Digest Authentication respectively. The two authentication protocols are used to restrict access to users who provide a valid user name and password." como_cumplirlo="If the modules are correctly disabled, there will be no output when executing either of the above commands. # httpd -M | grep auth_basic_module    # httpd -M | grep auth_digest_module" evidencia="$variable $variable2" estado="$resultado")
   #echo -e "\n \n $sal_29"
}



function mod2(){
   # MODULO 2
   #++++++++++
   Mod2_2
   Mod2_3
   Mod2_4
   Mod2_5
   Mod2_6
   Mod2_7
   Mod2_8
   Mod2_9

   sal_mod2="$sal_22, $sal_23, $sal_24, $sal_25, $sal_26, $sal_27, $sal_28, $sal_29"

   #echo -e "\n\n $sal_mod2"
   
}

mod2
