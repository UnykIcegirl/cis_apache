#!/usr/bin/env bash

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 10
# Fecha: 15/06/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 10
function Mod10_1(){
   echo -e "\n\n\n 10.1 Ensure the LimitRequestLine directive is Set to 512 or less"
   echo    "=========================================================================="
   ((++total))

   busqueda='LimitRequestline'
   cadena=$(cat "$dirConf" | grep "$busqueda")
   cuenta=$(grep -c "$busqueda" "$dirConf")
   
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
        if [ "$num" -ge 513 ]; then
           #echo "Es mayor";
           contFinal=contFinal+1;
        else
           #echo "Es menor o igual a 512"
           let contFinal=0;
        fi
     fi
   else
      #echo "No existe en el archivo";
      let contFinal=contFinal+1;
   fi

   local resultado   
   # we captured output of the subshell, let's interpret it
   if [[ "$contFinal" > 0 ]]; then
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-66"
   nombre="10.1 Ensure the LimitRequestLine directive is Set to 512 or less"
   descripcion="Buffer Overflow attacks attempt to exploit an application by providing more data than the application buffer can contain. If the application allows copying data to the buffer to overflow the boundaries of the buffer, then the application is vulnerable to a buffer overflow. The results of Buffer overflow vulnerabilities vary, and may result in the application crashing, or may allow the attacker to execute instructions provided in the data. The Apache LimitRequest* directives allow the Apache web server to limit the sizes of requests and request fields and can be used to help protect programs and applications processing those requests.  Specifically, the LimitRequestLine directive limits the allowed size of a client's HTTP request-line, which consists of the HTTP method, URI, and protocol version."
   remediacion="Perform the following to implement the recommended state:   Add or modify the LimitRequestline directive in the Apache configuration to have a value of 512 or shorter.  LimitRequestline 512"
   evidencia="La configuración de la directiva LimitRequestLine es: $cadena"

   sal_101=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_101"
}

function Mod10_2(){
   echo -e "\n\n\n 10.2 Ensure the LimitRequestFields Directive is Set to 100 or Less"
   echo    "==========================================================================="
   ((++total))

   busqueda='LimitRequestFields'
   cadena=$(cat "$dirConf" | grep -i "$busqueda")
   cuenta=$(grep -i -c "$busqueda" "$dirConf")
   
   contFinal=0
   contAux=$(echo "$cadena" | tr -dc '0-9')
   num=$(echo "$contAux" | bc)
   #echo $cadena
   
   if [[ "$cuenta" > 0 ]]; then
          # echo "Tiene la cadena ";
     if [[ "$cadena" == *"#"* ]]; then
         # echo "Esta comentado, no hace nada";
          contFinal=contFinal+1;
     else
         	#echo "No esta comentado";
        if [ "$num" -ge 101 ]; then
        #echo "Es mayor";
         contFinal=contFinal+1;
        else
        #echo "Es menor o igual a 100"
        let contFinal=0;
         fi
     fi
      else
          #echo "No existe en el archivo";
           let contFinal=contFinal+1;
   fi
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-67"
   nombre="10.2 Ensure the LimitRequestFields Directive is Set to 100 or Less"
   descripcion="The LimitRequestFields directive limits the number of fields allowed in an HTTP request."
   remediacion="Perform the following to implement the recommended state:   Add or modify the LimitRequestFields directive in the Apache configuration to have a value of 100 or less. If the directive is not present the default depends on a compile time configuration, but defaults to a value of 100.  LimitRequestFields 100"
   evidencia="La configuración de la directiva LimitRequestFields es: $cadena"

   sal_102=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_102"
}

function Mod10_3(){
   echo -e "\n\n\n 10.3 Ensure the LimitRequestFieldsize Directive is Set to 1024 or Less"
   echo    "===================================================================================="
   ((++total))

   busqueda='LimitRequestFieldsize'
   cadena=$(cat "$dirConf" | grep -i "$busqueda")
   cuenta=$(grep -i -c "$busqueda" "$dirConf")
   #echo $cadena
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
        if [ "$num" -ge 1025 ]; then
        #echo "Es mayor";
         contFinal=contFinal+1;
                   else
                   #echo "Es menor o igual a 1024"
                   let contFinal=0;
         fi
     fi
      else
          #echo "No existe en el archivo";
           let contFinal=contFinal+1;
   fi
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-68"
   nombre="10.3 Ensure the LimitRequestFieldsize Directive is Set to 1024 or Less"
   descripcion="The LimitRequestFieldSize limits the number of bytes that will be allowed in an HTTP request header. It is recommended that the LimitRequestFieldSize directive be set to 1024 or less."
   remediacion="Perform the following to implement the recommended state:   Add or modify the LimitRequestFieldsize directive in the Apache configuration to have a value of 1024 or less.  LimitRequestFieldsize 1024"
   evidencia="La configuración de la directiva LimitRequestFieldsize es: $cadena"

   sal_103=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")"  "$id")
   #echo -e "\n \n $sal_103"
}

function Mod10_4(){
   echo -e "\n\n\n 10.4 Ensure the LimitRequestBody Directive is Set to 102400 or Less"
   echo    "============================================================================="
   ((++total))

   busqueda='LimitRequestBody'
   cadena=$(cat "$dirConf" | grep -i "$busqueda")
   cuenta=$(grep -i -c "$busqueda" "$dirConf")
   echo $cadena
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
        if [ "$num" -ge 102401 ]; then
        #echo "Es mayor";
         contFinal=contFinal+1;
        else
        #echo "Es menor o igual a 102400"
        let contFinal=0;
         fi
     fi
      else
          #echo "No existe en el archivo";
           let contFinal=contFinal+1;
   fi
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-69"
   nombre="10.4 Ensure the LimitRequestBody Directive is Set to 102400 or Less"
   descripcion="The LimitRequestBody directive limits the number of bytes that are allowed in a request body. Size of requests may vary greatly; for example, during a file upload the size of the file must fit within this limit."
   remediacion="Perform the following to implement the recommended state:   Add or modify the LimitRequestBody directive in the Apache configuration to have a value of 102400 (100K) or less. Please read the Apache documentation so that it is understood that this directive will limit the size of file up-loads to the web server.  LimitRequestBody 102400"
   evidencia="La configuración de la directiva LimitRequestBody es: $cadena"

   sal_104=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_104"
}


function mod10(){
   # MODULO 10
   #++++++++++
   Mod10_1
   Mod10_2
   Mod10_3
   Mod10_4

   sal_mod10="$sal_101, $sal_102, $sal_103, $sal_104"
   #echo -e "\n\n $sal_mod10"
   
}
mod10

