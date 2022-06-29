#!/usr/bin/env bash

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 8
# Fecha: 16/06/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 8
function Mod8_1(){
   echo -e "\n\n\n 8.1 Ensure ServerTokens is Set to 'Prod' or 'ProductOnly'"
   echo    "===================================================================="
   ((++total))

   busqueda='ServerTokens'
   contador=$(grep -i -c "$busqueda" "$dirConf")
   rescat=$(cat "$dirConf" | grep -i "$busqueda")
   
   contFinal=0
   contAux=0
   
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena "; 
     if [[ "$rescat" == *"#"* ]]; then
       #echo "esta comentado";
   	let contFinal=contFinal+1
     else
   	#echo "no esta comentada"; 
   	if [[ "$rescat" == *"Prod"* ]]; then
           #echo "esta bien configurado";
   		let contAux=0; 
       else
   		#echo "esta mal configurado"; 
   		let contFinal=contFinal+1 
       fi
     fi 
   else
     #echo "no tiene la cadena falta agregarla con los valores"; 
     let contFinal=contFinal+1 
   fi
   
   local resultado
   #echo "contador "$contFinal   
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
   nombre="8.1 Ensure ServerTokens is Set to 'Prod' or 'ProductOnly'"
   descripcion="Configure the Apache ServerTokens directive to provide minimal information. By setting the value to Prod or ProductOnly. The only version information given in the server HTTP response header will be Apache rather than details on modules and versions installed."
   remediacion="Perform the following to implement the recommended state: Add or modify the ServerTokens directive as shown below to have the value of Prod or ProductOnly:   ServerTokens Prod"
   evidencia="La configuración del atributo ServerTokens es: $rescat"

   sal_81=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_81"
}

function Mod8_2(){
   echo -e "\n\n\n 8.2 Ensure ServerSignature Is Not Enabled"
   echo    "===================================================="
   ((++total))

   busqueda='ServerSignature'
   contador=$(grep -i -c "$busqueda" "$dirConf")
   rescat=$(cat "$dirConf" | grep -i "$busqueda")
   
   contFinal=0
   contAux=0
   
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena "; 
     if [[ "$rescat" == *"#"* ]]; then
       #echo "esta comentado";
   	let contAux=0; 
     else
   	#echo "no esta comentada"; 
   	if [[ "$rescat" == *"off"* ]] || [[ "$rescat" == *"Off"* ]] || [[ "$rescat" == *"OFF"* ]]; then
           #echo "esta deshabilitado";
   		let contAux=0; 
       else
   		#echo "esta habilitado - mal"; 
   		let contFinal=contFinal+1 
       fi
     fi 
   fi
   
   local resultado
   # we captured output of the subshell, let's interpret it
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
   nombre="8.2 Ensure ServerSignature Is Not Enabled"
   descripcion="Disable the server signatures which generates a signature line as a trailing footer at the bottom of server generated documents such as error pages."
   remediacion="Perform the following to implement the recommended state: Add or modify the ServerSignature directive as shown below to have the value of Off:   ServerSignature Off"
   evidencia="La configuración del atributo ServerSignature es: $rescat"

   sal_82=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_82"
}

function Mod8_3(){
   echo -e "\n\n\n 8.3 Ensure All Default Apache Content Is Removed"
   echo    "=========================================================="
   ((++total))

   busqueda='Include conf/extra/httpd-autoindex.conf'
   busqueda2='Alias /icons/'
   contador=$(grep -i -c "$busqueda" "$dirConf")
   contador2=$(grep -i -c "$busqueda2" "$dirConf")
   rescat=$(cat "$dirConf" | grep -i "$busqueda")
   rescat2=$(cat "$dirConf" | grep -i "$busqueda2")
   
   contFinal=0
   contAux=0
   
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena "; 
     if [[ "$rescat" == *"#"* ]]; then
       #echo "esta comentado no hace nada";
   	let contAux=0; 
     else
   	#echo "no esta comentado"; 
   	let contFinal=contFinal+1 
     fi 
   fi
   
   if [[ "$contador2" > 0 ]]; then    
     #echo "tiene la cadena "; 
     if [[ "$rescat2" == *"#"* ]]; then
       #echo "esta comentado no hace nada";
   	let contAux=0; 
     else
   	#echo "no esta comentado"; 
   	let contFinal=contFinal+1 
     fi 
   fi
   
   local resultado
   # we captured output of the subshell, let's interpret it
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
   nombre="8.3 Ensure All Default Apache Content Is Removed"
   descripcion="In previous recommendations, we have removed default content such as the Apache manuals and default CGI programs. However, if you want to further restrict information leakage about the web server, it is important that default content such as icons are not left on the web server."
   remediacion="Perform either of the following to implement the recommended state:   1. The default source build places the auto-index and icon configurations in the extra/httpd-autoindex.conf file, so it can be disabled by leaving the include line commented out in the main httpd.conffile as shown below.  # Fancy directory listings  #Include conf/extra/httpd-autoindex.conf   2. Alternatively, the icon alias directive and the directory access control configuration can be commented out as shown if present:  # We include the /icons/ alias for FancyIndexed directory listings. If  # you do not use FancyIndexing, you may comment this out.  #  #Alias /icons/ '/var/www/icons/'  #<Directory '/var/www/icons'>  #     Options Indexes MultiViews FollowSymLinks  #     AllowOverride None  #     Order allow,deny  #     Allow from all  #</Directory>"  
   evidencia="Valor actual de la etiqueta 'Fancy directory listings': $rescat"
   evid2="Valor actual de la directiva 'alis': $rescat2"

   sal_83=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2")
   #echo -e "\n \n $sal_83"
}

function Mod8_4(){
   echo -e "\n\n\n 8.4 Ensure ETag Response Header Fields Do Not Include Inodes"
   echo    "========================================================================"
   ((++total))

   busqueda='FileETag'
   contador=$(grep -i -c "$busqueda" "$dirConf")
   rescat=$(cat "$dirConf" | grep -i "$busqueda")
   
   contFinal=0
   contAux=0
   
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena "; 
     if [[ "$rescat" == *"#"* ]]; then
      #echo "esta comentado";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada"; 
   	if [[ "$rescat" == *"None"* ]] || [[ "$rescat" == *"MTime Size"* ]] || [[ "$rescat" == *""* ]]; then
           #echo "esta deshabilitado";
   		let contFinal=0; 
       else
   		#echo "esta habilitado - mal"; 
   		#echo $rescat		
   	let contFinal=contFinal+1 
       fi
     fi 
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
   nombre="8.4 Ensure ETag Response Header Fields Do Not Include Inodes"
   descripcion="The FileETag directive configures the file attributes that are used to create the ETag (entity tag) response header field when the document is based on a static file. The ETag value is used in cache management to save network bandwidth. The value returned may be based on combinations of the file inode, the modification time, and the file size."
   remediacion="Perform the following to implement the recommended state:   Remove all instances of the FileETag directive. Alternatively, add or modify the FileETag directive in the server and each virtual host configuration to have either the value None or MTime Size."
   evidencia="El valor actual de la directiva 'FileETag' es: $rescat"

   sal_84=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_84"
}


function mod8(){
   # MODULO 8
   #++++++++++
   Mod8_1
   Mod8_2
   Mod8_3
   Mod8_4

   sal_mod8="$sal_81, $sal_82, $sal_83, $sal_84"
   #echo -e "\n\n $sal_mod8"
   
}
mod8

