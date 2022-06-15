#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 12
# Fecha: 15/06/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 12
function Mod12_1(){
   echo -e "\n\n\n 12.1 Ensure the AppArmor Framework Is Enabled"
   echo    "======================================================="
   ((++total))

   output=$(aa-status --enabled && echo Enabled)
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" == "Enabled" ] ; then
   #    echo "Cumple"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
       
   else
   #    echo "No Cumple"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   nombre="12.1 Ensure the AppArmor Framework Is Enabled"
   descripcion="AppArmor is a Linux kernel security module that provides a named based mandatory access control with security policies. AppArmor can enforce rules on programs for file access and network connections and restrict actions based on defined policies."
   remediacion="Perform the following to implement the recommended state:   * If the aa-status command is not found, then the AppArmor package is not installed and needs to be installed using the appropriate the Linux distribution package management. For example:  # apt-get install apparmor  # apt-get install libapache2-mod-apparmor   * To enable the AppArmor framework run the init.d script as shown below.  # /etc/init.d/apparmor start"
   evidencia="Estatus del módulo AppArmor: $output"

   sal_121=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_121"
}

function Mod12_3(){
   echo -e "\n\n\n 12.3 Ensure Apache AppArmor Profile is in Enforce Mode"
   echo    "================================================================"
   ((++total))

   output=$(aa-unconfined --paranoid | grep -i apache2)
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" == *"enforce"* ] && [ "$output" == *"confined by"* ] ; then
   #    echo "Cumple"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
       
   else
   #    echo "No Cumple"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No cumple"
       ((++fail))
   fi

  # JSON --------------------------------------------------------------------------------
   nombre="12.3 Ensure Apache AppArmor Profile is in Enforce Mode"
   descripcion="AppArmor profiles may be in one of three modes: disabled, complain or enforce. In the complain mode, any violations of the access controls are logged but the restrictions are not enforced. Also, once a profile mode has been changed, it is recommended to restart the Apache server, otherwise the currently running process may not be confined by the policy."
   remediacion="Perform the following to implement the recommended state:   1. Set the profile state to enforce mode.  # aa-enforce apache2  Setting /usr/sbin/apache2 to enforce mode.   2. Stop the Apache server and confirm that is it not running. In some cases, the AppArmor controls may prevent the web server from stopping properly, and it may be necessary to stop the process manually or even reboot the server.  # service apache2 stop   * Stopping web server apache2  # service apache2 status   * apache2 is not running    3. Restart the Apache service.  # service apache2 start  * Starting web server apache2"
   evidencia="El estatus del perfil AppArmor es: $output"

   sal_123=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_123"
}


function mod12(){
   # MODULO 12
   #++++++++++
   Mod12_1
   Mod12_3

   sal_mod12="$sal_121, $sal_123"
   #echo -e "\n\n $sal_mod6"
   
}
mod12
