#!/usr/bin/env bash

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 9
# Fecha: 16/06/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 9
function Mod9_1(){
   echo -e "\n\n\n 9.1 Ensure the TimeOut Is Set to 10 or Less"
   echo    "======================================================="
   ((++total))

   busqueda='TimeOut'
   cadena=$(cat "$dirConf" | grep -i "$busqueda")
   cuenta=$(grep -i -c "$busqueda" "$dirConf")
   
   contFinal=0
   #echo $cadena
   contAux=$(echo "$cadena" | tr -dc '0-9')
   num=$(echo "$contAux" | bc)
   
   if [[ "$cuenta" > 0 ]]; then
          # echo "Tiene la cadena ";
     if [[ "$cadena" == *"#"* ]]; then
         # echo "Esta comentado, no hace nada";
          contFinal=contFinal+1;
     else
         	#echo "No esta comentado";
        if [ "$num" -ge 11 ]; then
        #echo "Es mayor";
         contFinal=contFinal+1;
   		else
   		#echo "Es menor o igual a 10"
   		let contFinal=0;
         fi
     fi
      else
          #echo "No existe en el archivo";
           let contFinal=contFinal+1;
   fi
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   nombre="9.1 Ensure the TimeOut Is Set to 10 or Less"
   descripcion="Denial of Service (DoS) is an attack technique with the intent of preventing a web site from serving normal user activity. DoS attacks, which are normally applied to the network layer, are also possible at the application layer. These malicious attacks can succeed by starving a system of critical resources, vulnerability exploit, or abuse of functionality. Although there is no 100% solution for preventing DoS attacks, the following recommendation uses the Timeout directive to mitigate some of the risk, by requiring more effort for a successful DoS attack. Of course, DoS attacks can happen in rather unintentional ways as well as intentional and these directives will help in many of those situations as well."
   remediacion="Perform the following to implement the recommended state: Add or modify the Timeout directive in the Apache configuration to have a value of 10 seconds or shorter.  Timeout 10"
   evidencia="Valor actual del atributo 'Timeout' es: $(cat "$dirConf" | grep -iE "^Timeout [0-9]{,2}")"

   sal_91=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_91"
}

function Mod9_2(){
   echo -e "\n\n\n 9.2 Ensure KeepAlive Is Enabled"
   echo    "=========================================="
   ((++total))

   output=$(grep -i "^\s*KeepAlive On" "$dirConf" | awk '{print $2}')
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != "On" ] ; then
       # print the reason why we are failing
       #echo "No cumple"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       #echo "Cumple"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   nombre="9.2 Ensure KeepAlive Is Enabled"
   descripcion="The KeepAlive directive controls whether Apache will reuse the same TCP connection per client to process subsequent HTTP requests from that client. It is recommended that the KeepAlive directive be set to On."
   remediacion="Perform the following to implement the recommended state: Add or modify the KeepAlive directive in the Apache configuration to have a value of On, so that KeepAlive connections are enabled.   keepAlive On"
   evidencia="El valor del atributo 'KeepAlive' es: $(grep -i "^\s*KeepAlive " "$dirConf")"

   sal_92=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_92"
}

function Mod9_3(){
   echo -e "\n\n\n 9.3 Ensure MaxKeepAliveRequests is Set to a Value of 100 or Greater"
   echo    "=============================================================================="
   ((++total))

   busqueda='MaxKeepAliveRequests '
   cadena=$(cat "$dirConf" | grep -i "$busqueda")
   cuenta=$(grep -i -c "$busqueda" "$dirConf")
   
   contFinal=0
   contAux=$(echo "$cadena" | tr -dc '0-9')
   num=$(echo "$contAux" | bc)
   
   if [[ "$cuenta" > 0 ]]; then
          # echo "Tiene la cadena ";
     if [[ "$cadena" == *"#"* ]]; then
         # echo "Esta comentado, no hace nada";
          contFinal=contFinal+1;
     else
        #echo "No esta comentado";
        if [ "$num" -ge 100 ]; then
        #echo "Es mayor";
         contFinal=0;
                   else
                   #echo "Es menor o igual a 100"
                   let contFinal=contFinal+1;
         fi
     fi
      else
          #echo "No existe en el archivo";
           let contFinal=contFinal+1;
   fi
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then
     #echo "No cumple";
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
     #echo "Cumple";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   nombre="9.3 Ensure MaxKeepAliveRequests is Set to a Value of 100 or Greater"
   descripcion="The MaxKeepAliveRequests directive limits the number of requests allowed per connection when KeepAlive is on. If it is set to 0, unlimited requests will be allowed."
   remediacion="Perform the following to implement the recommended state: Add or modify the MaxKeepAliveRequests directive in the Apache configuration to have a value of 100 or more.  MaxKeepAliveRequests 100"
   evidencia="El valor actual del atributo 'MaxKeepAliveRequests' es: $cadena "

   sal_93=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_93"
}

function Mod9_4(){
   echo -e "\n\n\n 9.4 Ensure KeepAliveTimeout is Set to a Value of 15 or Less"
   echo    "====================================================================="
   ((++total))

   busqueda='KeepAliveTimeout '
   cadena=$(cat "$dirConf" | grep -i "$busqueda")
   cuenta=$(grep -i -c "$busqueda" "$dirConf")
   
   contFinal=0
   contAux=$(echo "$cadena" | tr -dc '0-9')
   num=$(echo "$contAux" | bc)
   
   if [[ "$cuenta" > 0 ]]; then
          # echo "Tiene la cadena ";
     if [[ "$cadena" == *"#"* ]]; then
         # echo "Esta comentado, no hace nada";
          contFinal=contFinal+1;
     else
         	#echo "No esta comentado";
        if [ "$num" -ge 16 ]; then
        #echo "Es mayor";
         contFinal=contFinal+1;
                   else
                   #echo "Es menor o igual a 10"
                   let contFinal=0;
         fi
     fi
      else
          #echo "No existe en el archivo";
           let contFinal=contFinal+1;
   fi
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then
     #echo "No cumple";
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
     #echo "Cumple";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   nombre="9.4 Ensure KeepAliveTimeout is Set to a Value of 15 or Less"
   descripcion="The KeepAliveTimeout directive specifies the number of seconds Apache will wait for a subsequent request before closing a connection that is being kept alive."
   remediacion="Perform the following to implement the recommended state: Add or modify the KeepAliveTimeout directive in the Apache configuration to have a value of 15 or less.  KeepAliveTimeout 15"
   evidencia="El valor actual del atributo 'KeepAliveTimeout' es: $cadena "

   sal_94=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_94"
}

function Mod9_5(){
   echo -e "\n\n\n 9.5 Ensure the Timeout Limits for Request Headers is Set to 40 or Less"
   echo    "================================================================================="
   ((++total))

   variable="$(httpd -M |grep reqtimeout || apachectl -M | grep reqtimeout)"
   output="$($variable |wc -l)"
   output2=$(grep -i "^\s*RequestReadTimeout" "$dirConf" | cut -d'=' -f 2 | cut -c 1,2,3,4,5)
   
   if [ "$output" > 0 ] && [ "$output2" > 0 ]; then
     if [ "$variable" == *"#"* ] || [ "$output2" == *"#"* ]; then
          #echo "Esta comentado, no hace nada";
          let contFinal=contFinal+1
     else
        #echo "No esta comentado";
        if [ "$output2" != "20-40" ]; then
           #echo "No es igual, no cumple";
           let contFinal=contFinal+1
          else
           #echo "Es menor o igual a 40"
           let contFinal=0
         fi
     fi
      else
         # echo "No existe en el archivo";
         let contFinal=contFinal+1
   fi
   
   local resultado   
   if [[ "$output" == "1" ]] && [[ "$contFinal" == 0 ]]; then
    #echo "Cumple";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))   
   else
     #echo "No cumple";
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON --------------------------------------------------------------------------------
   nombre="9.5 Ensure the Timeout Limits for Request Headers is Set to 40 or Less"
   descripcion="The RequestReadTimeout directive allows configuration of timeout limits for client requests. The header portion of the directive provides for an initial timeout value, a maximum timeout and a minimum rate. The minimum rate specifies that after the initial timeout, the server will wait an additional 1 second for each N bytes received. The recommended setting is to have a maximum timeout of 40 seconds or less. Keep in mind that for SSL/TLS virtual hosts the time for the TLS handshake must fit within the timeout."
   remediacion="Perform the following to implement the recommended state:    1. Load the mod_requesttimeout module in the Apache configuration with the following configuration.  LoadModule reqtimeout_module modules/mod_reqtimeout.so   2. Add a RequestReadTimeout directive similar to the one below with the maximum request header timeout value of 40 seconds or less.  RequestReadTimeout header=20-40,MinRate=500 body=20,MinRate=500"
   evidencia="Configuración del Módulo 'mod_requesttimeout': $variable "
   evid2="Valor de la directiva 'RequestReadTimeout'  $(grep -i "^\s*RequestReadTimeout" "$dirConf")"

   sal_95=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia", $evid2)
   #echo -e "\n \n $sal_95"
}

function Mod9_6(){
   echo -e "\n\n\n 9.6 Ensure Timeout Limits for the Request Body is Set to 20 or Less"
   echo    "==============================================================================="
   ((++total))

   variable="$(httpd -M |grep reqtimeout || apachectl -M | grep reqtimeout)"
   if [ "$variable" = "$no_existe" ] ; then
      output=0
   else
      output=1
   fi
 
   #output="$($variable |wc -l)"
   output2=$(grep -i "^\s*RequestReadTimeout" "$dirConf" | cut -d',' -f 2 | cut -d'=' -f 3)
   
   
   if [ "$output" > 0 ] && [ "$output2" > 0 ]; then
     if [ "$output" == *"#"* ] || [ "$output2" == *"#"* ]; then
          #echo "Esta comentado, no hace nada";
          let contFinal=contFinal+1
     else
        #echo "No esta comentado";
        if [ "$output2" $gt 20  ]; then
           #echo "No es igual, no cumple";
           let contFinal=contFinal+1
          else
           #echo "Es menor o igual a 20"
           let contFinal=0
         fi
     fi
      else
         # echo "No existe en el archivo";
           let contFinal=contFinal+1
   fi
   
   local resultado   
   if [[ "$output" == "1" ]] && [[ "$contFinal" == 0 ]]; then
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   
   else
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON --------------------------------------------------------------------------------
   nombre="9.6 Ensure Timeout Limits for the Request Body is Set to 20 or Less"
   descripcion="The RequestReadTimeout directive also allows setting timeout values for the body portion of a request. The directive provides for an initial timeout value, and a maximum timeout and minimum rate. The minimum rate specifies that after the initial timeout, the server will wait an additional 1 second for each N bytes received. The recommended setting is to have a maximum timeout of 20 seconds or less. The default value is body=20,MinRate=500."
   remediacion="Load the mod_requesttimeout module in the Apache configuration with the following configuration.   LoadModule reqtimeout_module modules/mod_reqtimeout.so  Add a RequestReadTimeout directive similar to the one below with the maximum request body timeout value of 20 seconds or less.   RequestReadTimeout header=20-40,MinRate=500 body=20,MinRate=500"
   evidencia="Valor de la directiva 'RequestReadTimeout' $(grep -i "^\s*RequestReadTimeout" "$dirConf") "

   sal_96=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_96"
}



function mod9(){
   # MODULO 9
   #++++++++++
   Mod9_1
   Mod9_2
   Mod9_3
   Mod9_4
   Mod9_5
   Mod9_6

   sal_mod9="$sal_91, $sal_92, $sal_93, $sal_94, $sal_95, $sal_96"
   #echo -e "\n\n $sal_mod9"
   
}
mod9
