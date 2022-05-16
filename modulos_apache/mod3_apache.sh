#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 3
# Fecha: 16/05/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

# ------  Modulo 3 --------------------
##### MODULO 3
function Mod3_1(){
   echo -e "\n\n\n 3.1 Ensure the Apache Web Server Runs As a Non-Root User"
   echo    "============================================================================"
   ((++total))
   #dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
   #usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
   #grupo=$(grep -i '^Group' "$dirConf"| awk {'print $2'})
   iduser=$(id -u "$usuario")
   idgpo=$(id -g "$usuario")
   uid_min=$(grep '^UID_MIN' /etc/login.defs | awk '{print $2}')
   variable=$(ps -axu | grep httpd | grep $usuario)

   echo -e "Configuracion existente: \n" "Directorio configuración $dirConf \n" "Usuario: $usuario id-($iduser) \n" "Grupo: $grupo id-($idgpo)\n" "UID_MIN: $uid_min \n"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [[ $usuario = "root" || $grupo = "root" ]];
   then
      # print the reason why we are failing
      echo "Se debe de crear un usuario y grupo sin privilegios para el servidor de aplicaciones para cumplir el control ---------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   else
      if [[ $(($iduser < $uid_min)) && $(($idgpo < $uid_min)) ]];
      then
         if [[ ("$variable" = "$no_existe") ]];
         then
            echo -e "\n \n Asegúrese de que el servicio está ejecutandose con el usuario $usuario configurado--------- -----------${RED} No Cumple ${WHITE}"
            resultado="No Cumple"
            ((++fail))
         else
            echo -e "\n \n El usuario y grupo son especiales para el servicio-----------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
            resultado="Cumple"
            non_rootUser="true"
            ((++pass))
         fi
      else
         echo -e "\n \n Asegúrese de que la cuenta de apache sea única y se haya creado con un UID menor que la cuenta de usuario normal mínima -----------${RED} No Cumple ${WHITE}"
         resultado="No Cumple"
         ((++fail))
      fi
   fi

   # JSON ---------------------------
   sal_31=$(jo id="3.1 Ensure the Apache Web Server Runs As a Non-Root User" descripcion="Although Apache is typically started with root privileges in order to listen on port 80 and 443, it can and should run as another non-root user in order to perform the web services. The Apache User and Group directives are used to designate the user and group that the Apache worker processes will assume" como_cumplirlo="Ensure the apache account is unique and has been created with a UID less than the minimum normal user account with the Apache group and configured in the httpd.conf file." evidencia="Configuracion existente: \n" "Directorio configuración $dirConf Usuario: $usuario id-($iduser)  Grupo: $grupo id-($idgpo) UID_MIN: $uid_min" estado="$resultado")
   echo -e "\n \n $sal_31"
}

function Mod3_2(){
   echo -e "\n\n\n 3.2 Ensure the Apache User Account Has an Invalid Shell"
   echo    "============================================================================"
   ((++total))
   #dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
   #usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
   variable=$(grep -E ^$usuario.*\/sbin\/nologin$ /etc/passwd || grep -E ^$usuario.*\/dev\/null$ /etc/passwd)

   echo -e "Configuracion existente: \n" "$(grep -E ^$usuario.* /etc/passwd)"

   local resultado
   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      # print the reason why we are failing
      echo -e "\n \n Cambie la cuenta de '$usuario' para usar el shell nologin para cumplir el control ------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   else
      echo -e "La cuenta '$usuario' no se pueda usar para iniciar sesión ------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   fi

   # JSON ---------------------------
   sal_32=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_32"
}

function Mod3_3(){
   echo -e "\n\n\n 3.3 Ensure the Apache User Account Is Locked"
   echo    "============================================================================"
   ((++total))
   #dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
   #usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
   variable=$(passwd -S "$usuario" | grep -E '^"$usuario".*(Contraseña bloqueada.*)$' || passwd -S "$usuario" | grep -E '^"$usuario".*(Password locked.*)$')
   echo -e "Configuracion existente: \n" $(passwd -S $usuario)

   local resultado
   # If the user of apache not have a valid password. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      # print the reason why we are failing
      echo -e "\n \n Use el commando 'passwd' paa bloquear la cuenta '$usuario'-------------------------------------------------------------------${RED} No cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   else
      echo -e "La cuenta '$usuario' se encuentra bloqueada ---------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   fi

   # JSON ---------------------------
   sal_33=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_33"
}

function Mod3_4(){
   echo -e "\n\n\n 3.4 Ensure Apache Directories and Files Are Owned By Root"
   echo    "============================================================================"
   ((++total))
   variable=$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -user root -ls 2>/dev/null)
   var_www=$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -user root -ls 2>/dev/null)
   echo -e "Configuracion existente: \n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -user root -ls | head -5) "\n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -user root -ls | head -5) "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" && "$var_www" = "$no_existe" ] ; then
      # print the reason why we are pass
      echo -e "El directorio es propiedad del usuario root ---------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      echo -e "El directorio debe ser propioedad del usuario root --------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_34=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_34"
}

function Mod3_5(){
   echo -e "\n\n\n 3.5 Ensure the Group Is Set Correctly on Apache Directories and Files"
   echo    "==============================================================================="
   # SE DEBERA JUSTIFICAR
   ((++total))
   variable=$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls 2>/dev/null)
   var_www=$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls 2>/dev/null)
   echo -e "Configuracion existente: \n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls | head -5) "\n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls | head -5)

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" && "$var_www" = "$no_existe" ] ; then
      # print the reason why we are pass
      echo -e "El directorio es propiedad del grupo root -----------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      echo -e "El directorio debe ser del grupo root ---------------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_35=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_35"
}

function Mod3_6(){
   echo -e "\n\n\n 3.6 Ensure Other Write Access on Apache Directories and Files Is Restricted"
   echo    "====================================================================================="
   ((++total))
   variable=$(find -L $APACHE_PREFIX \! -type l -perm -o=w -ls 2>/dev/null)
   echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /o=w -ls 2>/dev/null) "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] ; then
      # print the reason why we are pass
      echo -e "Esta restringido el acceso de escritura para 'other' ------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   else
      echo -e "'other' tiene acceso de escritura al directorio------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_36=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_36"
}

function Mod3_7(){
   echo -e "\n\n\n 3.7 Ensure the Core Dump Directory Is Secured"
   echo    "======================================================"
   ((++total))
   variable=$(`grep -i dump $dirConf` 2>/dev/null)
   variable2=$(find $APACHE_PREFIX/logs/ -type d -perm -o=rwx -ls 2>/dev/null)
   #echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /o=w -ls 2>/dev/null) "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] ; then
      if [ "$variable2" = "$no_existe" ] ; then
         # print the reason why we are pass
         echo -e "Es seguro el directorio 'Core Dump' -----------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
         resultado="Cumple"
         ((++pass))
      else
         echo -e "Configuracion existente: \n" $(find /var/log/httpd/ -type d -perm /o=rwx -ls) "\n"
         echo -e "Se tienen permisos no permitidos------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
         resultado="No Cumple"
         ((++fail))
      fi
   else
      echo -e "Configuracion existente: \n" $(grep -i dump $dirConf) "\n"
      echo -e "Se tiene la directiva de 'CoreDumpDirectory' habilitada ------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_37=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_37"
}

function Mod3_8(){
   echo -e "\n\n\n 3.8 Ensure the Lock File Is Secured"
   echo    "============================================"
   ((++total))
   variable=$(`find -name httpd.lock|wc -l` 2>/dev/null)
   variable2=$(`find $APACHE_PREFIX/logs/ -type d -perm -o=rwx -ls` 2>/dev/null)
   
   usuario_validar=""
   grupo_validar=""
   if [ "$non_rootUser" = "true" ]; then
      usuario_validar=$usuario
      grupo_validar=$grupo
   else
      usuario_validar="root"
      grupo_validar="root"
   fi

   #echo "usuario: $usuario_validar  grupo: $grupo_validar"
   
   variable3=$(`find $APACHE_PREFIX/logs \! -user $usuario_validar -ls` 2>/dev/null)
   variable4=$(`find $APACHE_PREFIX/logs \! -group $grupo_validar -ls` 2>/dev/null)
   #echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /o=w -ls 2>/dev/null) "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] ; then
      if [ "$variable2" = "$no_existe" ] && [ "$variable3" = "$no_existe" ] && [ "$variable4" = "$no_existe" ]; then
         # print the reason why we are pass
         echo -e "Es seguro el directorio 'Core Dump' -----------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
         resultado="Cumple"
         ((++pass))
      else
         echo -e "Se tienen permisos no permitidos------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
         resultado="No Cumple"
         ((++fail))
      fi
   else
      echo -e "Configuracion existente: \n" $(grep -i dump $dirConf) "\n"
      echo -e "Se tiene la directiva de 'CoreDumpDirectory' habilitada ------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   sal_38=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_38"
}

function Mod3_9(){
   echo -e "\n\n\n 3.9 Ensure the Pid File Is Secured"
   echo    "============================================"
   ((++total))

   usuario_validar=""
   grupo_validar=""
   if [ "$non_rootUser" = "true" ]; then
      usuario_validar=$usuario
      grupo_validar=$grupo
   else
      usuario_validar="root"
      grupo_validar="root"
   fi

   DireNot=`find -L $APACHE_PREFIX/www/ -name httpd.pid |wc -l` 2>/dev/null
   RutPid=`find -L $APACHE_PREFIX -name httpd.pid \! -user $usuario_validar |wc -l` 2>/dev/null
   RutPidGp=`find -L $APACHE_PREFIX -name httpd.pid \! -group $grupo_validar |wc -l` 2>/dev/null
   variable=$(`find $APACHE_PREFIX/logs/ -type d -perm -o=rwx -ls` 2>/dev/null)
   output=0
   echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX -name httpd.pid \! -user root) "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$DireNot" != 0 ] ; then
     output=1
   else
    if [ "$RutPid" != 0 ] ; then
     output=1
    else
     if [ "$RutPidGp" != 0 ] && [ "$variable" = "$no_existe" ] ; then
      output=1
     fi
    fi
   fi

   if [ "$output" != 0 ] ; then
        echo -e "El archivo 'pidfile' debe tener los permisos de 'root:root' ------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
        resultado="No Cumple"
        ((++fail))
   else
        echo -e "Configuración correcta para el archivo 'pidfile'' ----------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
        resultado="Cumple"
        ((++pass))
   fi

   # JSON ---------------------------
   sal_39=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_39"
}

function Mod3_10(){
   echo -e "\n\n\n 3.10 Ensure the ScoreBoard File Is Secured"
   echo    "====================================================="
   ((++total))

   usuario_validar=""
   grupo_validar=""
   if [ "$non_rootUser" = "true" ]; then
      usuario_validar=$usuario
      grupo_validar=$grupo
   else
      usuario_validar="root"
      grupo_validar="root"
   fi
   
   FilExis=`find -name ScoreBoardFile |wc -l` 2>/dev/null
   FilExNoRut=`find -L $APACHE_PREFIX/www/ -name ScoreBoardFile |wc -l` 2>/dev/null
   PerFil=`find -name ScoreBoardFile \! -user $usuario_validar |wc -l` 2>/dev/null
   PerFilGP=`find -name ScoreBoardFile \! -group $grupo_validar |wc -l` 2>/dev/null
   PerRW=`find / -name ScoreBoardFile \! -perm -644 |wc -l` 2>/dev/null
   output=0

   if [ "$FilExis" != 0 ] ; then
    if [ "$FilExNoRut" != 0 ] ; then
     output=1
    else
     if [ "$PerFil" != 0 ] ; then
      output=1
     else
      if [ "$PerFilGP" != 0 ] ; then
       output=1
       else
        if [ "$PerRW" != 0 ] ; then
         output=1  
        fi 
      fi
     fi
    fi
   fi

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != 0 ] ; then
       # print the reason why we are failing
       echo -e "El archivo 'scoreboard' debe tener los permisos de 'root:root' ---------------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "Configuración correcta para el archivo 'scoreboard' o no existe --------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_310=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_310"
}

function Mod3_11(){
   echo -e "\n\n\n 3.11 Ensure Group Write Access for the Apache Directories and Files Is Properly Restricted"
   echo    "==================================================================================================="
   ((++total))
   echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /g=w -ls| head -5) "\n"

   output=`find -L $APACHE_PREFIX \! -type l -perm /g=w -ls` 2>/dev/null

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != "" ] ; then
       # print the reason why we are failing
       echo -e "Los permisos en los directorios deberá ser 'r-x' -----------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "Los permisos de escritura están restringidos correctamente -------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_311=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_311"
}

function Mod3_12(){
   echo -e "\n\n\n 3.12 Ensure Group Write Access for the Document Root Directories and Files Is Properly Restricted"
   echo    "============================================================================================================"
   ((++total))
   GRP=$(grep '^Group' $dirConf | cut -d' ' -f2)
   output=$(find -L $DocumentRoot -group $GRP -perm /g=w -ls)

   echo -e "Configuracion existente: \n" $(find -L $DocumentRoot -group $GRP -perm /g=w -ls| head -5) "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != "" ] ; then
       # print the reason why we are failing
       echo -e "Los permisos de escritura en 'DocumentRoot' deben ser restringidos -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "Los permisos de escritura están restringidos correctamente -------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_312=$(jo id="2.3 Ensure the WebDAV Modules Are Disabled" descripcion="" como_cumplirlo="" evidencia="" estado="$resultado")
   echo -e "\n \n $sal_312"
}


function mod3(){
   # MODULO 3
   #++++++++++
   Mod3_1

   sal_mod3="$sal_31"

   #echo -e "\n\n $sal_mod3"
   
}

mod3
