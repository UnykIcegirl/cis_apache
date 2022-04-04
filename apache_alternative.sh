#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# Fecha: 31/08/2021                                                                      
# CSA: Maribel Hernandez Gtz
####################################################

declare fecha=$(date "+%d-%m-%Y %H:%M:%S")
declare fechan=$(date "+%d-%m-%Y")
declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

clear

#sección variables
declare pass=0
declare fail=0
declare total=0

#Declaracion variables
no_existe=""
non_rootUser="false"

echo -e "\n\n\n\n Equipo: " $hostname
echo "Fecha: " $fecha
echo "=================================="

dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
confDirectorio=${dirConf%/*}
APACHE_PREFIX=${confDirectorio%?????}
usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
grupo=$(grep -i '^Group' "$dirConf"| awk {'print $2'})

fileError=$(httpd -V|grep 'ERRORLOG' | cut -d'=' -f 2|sed "s/\"//g")%/*
errorDir=${fileError%/*}
dirError=$APACHE_PREFIX$errorDir

echo "Archivo de configuración: $dirConf"
echo "Directorio Apache: $APACHE_PREFIX"
echo "Usuario: $usuario"
echo "Grupo: $grupo"

cd $APACHE_PREFIX
echo "PWD: $(pwd)"
echo -e "\n \n Instancias activas:" | tee  instancias_apache_$(hostname)_${fechan}.txt
ps -fea | grep -ie httpd | grep -oE  "\-f /.*conf.*.conf " | cut -d ' ' -f2 | awk '{print $1}'| uniq | tee instancias_activas.txt
echo ""

#archivo="instancias_activas.txt"
#instancias=$(cat $archivo)

#Obtener instancias activas
function instanciasActivas(){ 
    echo -e "Instancia" ${YELLOW} $ni ${WHITE}
    #echo -e "Ruta:" $instancia
    #echo -e "Ruta de instancia $ni:" $instancia  
    #echo -e "Fecha de ejecución:" $fecha >> instancias_apache_$(hostname)_${fechan}.txt
    #echo -e "Puertos utilizados:" >> instancias_apache_$(hostname)_${fechan}.txt
    echo -e "Cumplimiento de controles:" >> instancias_apache_$(hostname)_${fechan}.txt
}

#Modulo 2
function Mod2_2(){
   echo -e "\n 2.2 Ensure the Log Config Module Is Enabled"
   echo -e "================================================="
   ((++total))
   variable=$(httpd -M | grep log_config || apachectl -M | grep log_config )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo LOG CONFIG esta deshabilitado -----------------------------------------------------------------${RED} No cumple ${WHITE}" 
      ((++fail))
   else
      # print the reason why we are failing
      echo -e "\n \n El módulo LOG CONFIG esta habilitado -----------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
fi
}

function Mod2_3(){
   echo -e "\n 2.3 Ensure the WebDAV Modules Are Disabled"
   echo -e "============================================="
   ((++total))
   variable=$(httpd -M | grep dav_* || apachectl -M | grep dav_* )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo WebDAV esta deshabilitado ---------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo WebDAV para cumplir el control --------------------------------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod2_4(){
   echo -e "\n 2.4 Ensure the Status Module Is Disabled"
   echo -e "============================================"
   ((++total))

   variable=$(httpd -M | grep 'status_module' || apachectl -M | grep 'status_module' )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo STATUS esta deshabilitado -----------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo STATUS para cumplir el control -----------------------------------------------------------------${RED} No cumple ${WHITE}" 
      ((++fail))
   fi
}

function Mod2_5(){
   echo -e "\n\n\n 2.5 Ensure the Autoindex Module Is Disabled"
   echo    "================================================"
   ((++total))
   variable=$(httpd -M | grep autoindex_module || apachectl -M | grep autoindex_module )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo WebDAV esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo WebDAV para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod2_6(){
   echo -e "\n\n\n 2.6 Ensure the Proxy Modules Are Disabled"
   echo    "================================================"
   ((++total))
   variable=$(httpd -M | grep proxy_ || apachectl -M | grep proxy_ )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo Proxy esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo Proxy para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod2_7(){
   echo -e "\n\n\n 2.7 Ensure the User Directories Module Is Disabled"
   echo    "==========================================================="
   ((++total))
   variable=$(httpd -M | grep userdir_ || apachectl -M | grep userdir_ )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo 'user directories' esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo 'user directories' para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod2_8(){
   echo -e "\n\n\n 2.8 Ensure the Info Module Is Disabled"
   echo    "==============================================="
   ((++total))
   variable=$(httpd -M | egrep info_module || apachectl -M | egrep info_module )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo Info esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo Info para cumplir el control ------------------------------------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod2_9(){
   echo -e "\n\n\n 2.9 Ensure the Basic and Digest Authentication Modules are Disabled"
   echo    "============================================================================"
   ((++total))
   variable=$(httpd -M | grep auth_basic_module || apachectl -M | grep auth_basic_module )

   echo -e "Configuracion existente: \n" "$variable"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      echo "El módulo 'basic and digest authentication' esta deshabilitado ------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      # print the reason why we are failing
      echo -e "\n \n Deshabilitar el módulo 'basic and digest authentication' para cumplir el control ----------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   fi
}

##### MODULO 3
function Mod3_1(){
   echo -e "\n\n\n 3.1 Ensure the Apache Web Server Runs As a Non-Root User"
   echo    "============================================================================"
   ((++total))
   #dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
   #usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
   grupo=$(grep -i '^Group' "$dirConf"| awk {'print $2'})
   iduser=$(id -u "$usuario")
   idgpo=$(id -g "$usuario")
   uid_min=$(grep '^UID_MIN' /etc/login.defs | awk '{print $2}')
   variable=$(ps -axu | grep httpd | grep $usuario)

   echo -e "Configuracion existente: \n" "Directorio configuración $dirConf \n" "Usuario: $usuario id-($iduser) \n" "Grupo: $grupo id-($idgpo)\n" "UID_MIN: $uid_min \n"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [[ $usuario = "root" || $grupo = "root" ]];
   then
      # print the reason why we are failing
      echo "Se debe de crear un usuario y grupo sin privilegios para el servidor de aplicaciones para cumplir el control ---------------------------------${RED} No Cumple ${WHITE}"
      ((++fail))
   else
      if [[ $(($iduser < $uid_min)) && $(($idgpo < $uid_min)) ]];
      then
         if [[ ("$variable" = "$no_existe") ]];
         then
            echo -e "\n \n Asegúrese de que el servicio está ejecutandose con el usuario $usuario configurado--------- -----------${RED} No Cumple ${WHITE}"
            ((++fail))
         else
            echo -e "\n \n El usuario y grupo son especiales para el servicio-----------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
            non_rootUser="true"
            ((++pass))
         fi
      else
         echo -e "\n \n Asegúrese de que la cuenta de apache sea única y se haya creado con un UID menor que la cuenta de usuario normal mínima -----------${RED} No Cumple ${WHITE}"
         ((++fail))
      fi
   fi
}

function Mod3_2(){
   echo -e "\n\n\n 3.2 Ensure the Apache User Account Has an Invalid Shell"
   echo    "============================================================================"
   ((++total))
   #dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
   #usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
   variable=$(grep -E ^$usuario.*\/sbin\/nologin$ /etc/passwd || grep -E ^$usuario.*\/dev\/null$ /etc/passwd)

   echo -e "Configuracion existente: \n" "$(grep -E ^$usuario.* /etc/passwd)"

   # If the modules are correctly disabled, there will be no output when executing the above command. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      # print the reason why we are failing
      echo -e "\n \n Cambie la cuenta de '$usuario' para usar el shell nologin para cumplir el control ------------------------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   else
      echo -e "La cuenta '$usuario' no se pueda usar para iniciar sesión ------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   fi
}

function Mod3_3(){
   echo -e "\n\n\n 3.3 Ensure the Apache User Account Is Locked"
   echo    "============================================================================"
   ((++total))
   #dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
   #usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
   variable=$(passwd -S "$usuario" | grep -E '^"$usuario".*(Contraseña bloqueada.*)$' || passwd -S "$usuario" | grep -E '^"$usuario".*(Password locked.*)$')
   echo -e "Configuracion existente: \n" $(passwd -S $usuario)

   # If the user of apache not have a valid password. If so, we pass
   if [ "$variable" = "$no_existe" ] ; then
      # print the reason why we are failing
      echo -e "\n \n Use el commando 'passwd' paa bloquear la cuenta '$usuario'-------------------------------------------------------------------${RED} No cumple ${WHITE}"
      ((++fail))
   else
      echo -e "La cuenta '$usuario' se encuentra bloqueada ---------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   fi
}

function Mod3_4(){
   echo -e "\n\n\n 3.4 Ensure Apache Directories and Files Are Owned By Root"
   echo    "============================================================================"
   ((++total))
   variable=$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -user root -ls 2>/dev/null)
   var_www=$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -user root -ls 2>/dev/null)
   echo -e "Configuracion existente: \n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -user root -ls | head -5) "\n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -user root -ls | head -5) "\n"

   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" && "$var_www" = "$no_existe" ] ; then
      # print the reason why we are pass
      echo -e "El directorio es propiedad del usuario root ---------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      echo -e "El directorio debe ser propioedad del usuario root --------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod3_5(){
   echo -e "\n\n\n 3.5 Ensure the Group Is Set Correctly on Apache Directories and Files"
   echo    "==============================================================================="
   # SE DEBERA JUSTIFICAR
   ((++total))
   variable=$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls 2>/dev/null)
   var_www=$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls 2>/dev/null)
   echo -e "Configuracion existente: \n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls | head -5) "\n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls | head -5)

   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" && "$var_www" = "$no_existe" ] ; then
      # print the reason why we are pass
      echo -e "El directorio es propiedad del grupo root -----------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      echo -e "El directorio debe ser del grupo root ---------------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod3_6(){
   echo -e "\n\n\n 3.6 Ensure Other Write Access on Apache Directories and Files Is Restricted"
   echo    "====================================================================================="
   ((++total))
   variable=$(find -L $APACHE_PREFIX \! -type l -perm -o=w -ls 2>/dev/null)
   echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /o=w -ls 2>/dev/null) "\n"

   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] ; then
      # print the reason why we are pass
      echo -e "Esta restringido el acceso de escritura para 'other' ------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      ((++pass))
   else
      echo -e "'other' tiene acceso de escritura al directorio------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      ((++fail))
   fi
}

function Mod3_7(){
   echo -e "\n\n\n 3.7 Ensure the Core Dump Directory Is Secured"
   echo    "======================================================"
   ((++total))
   variable=$(`grep -i dump $dirConf` 2>/dev/null)
   variable2=$(find $APACHE_PREFIX/logs/ -type d -perm -o=rwx -ls 2>/dev/null)
   #echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /o=w -ls 2>/dev/null) "\n"

   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] ; then
      if [ "$variable2" = "$no_existe" ] ; then
         # print the reason why we are pass
         echo -e "Es seguro el directorio 'Core Dump' -----------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
         ((++pass))
      else
         echo -e "Configuracion existente: \n" $(find /var/log/httpd/ -type d -perm /o=rwx -ls) "\n"
         echo -e "Se tienen permisos no permitidos------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
         ((++fail))
      fi
   else
      echo -e "Configuracion existente: \n" $(grep -i dump $dirConf) "\n"
      echo -e "Se tiene la directiva de 'CoreDumpDirectory' habilitada ------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      ((++fail))
   fi
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

   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] ; then
      if [ "$variable2" = "$no_existe" ] && [ "$variable3" = "$no_existe" ] && [ "$variable4" = "$no_existe" ]; then
         # print the reason why we are pass
         echo -e "Es seguro el directorio 'Core Dump' -----------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
         ((++pass))
      else
         echo -e "Se tienen permisos no permitidos------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
         ((++fail))
      fi
   else
      echo -e "Configuracion existente: \n" $(grep -i dump $dirConf) "\n"
      echo -e "Se tiene la directiva de 'CoreDumpDirectory' habilitada ------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      ((++fail))
   fi
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
        ((++fail))
   else
        echo -e "Configuración correcta para el archivo 'pidfile'' ----------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
        ((++pass))
   fi
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

   # we captured output of the subshell, let's interpret it
   if [ "$output" != 0 ] ; then
       # print the reason why we are failing
       echo -e "El archivo 'scoreboard' debe tener los permisos de 'root:root' ---------------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
       echo -e "Configuración correcta para el archivo 'scoreboard' o no existe --------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod3_11(){
   echo -e "\n\n\n 3.11 Ensure Group Write Access for the Apache Directories and Files Is Properly Restricted"
   echo    "==================================================================================================="
   ((++total))
   echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /g=w -ls| head -5) "\n"

   output=`find -L $APACHE_PREFIX \! -type l -perm /g=w -ls` 2>/dev/null

   # we captured output of the subshell, let's interpret it
   if [ "$output" != "" ] ; then
       # print the reason why we are failing
       echo -e "Los permisos en los directorios deberá ser 'r-x' -----------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
       echo -e "Los permisos de escritura están restringidos correctamente -------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod3_12(){
   echo -e "\n\n\n 3.12 Ensure Group Write Access for the Document Root Directories and Files Is Properly Restricted"
   echo    "============================================================================================================"
   ((++total))
   GRP=$(grep '^Group' $dirConf | cut -d' ' -f2)
   output=$(find -L $DocumentRoot -group $GRP -perm /g=w -ls)

   echo -e "Configuracion existente: \n" $(find -L $DocumentRoot -group $GRP -perm /g=w -ls| head -5) "\n"

   # we captured output of the subshell, let's interpret it
   if [ "$output" != "" ] ; then
       # print the reason why we are failing
       echo -e "Los permisos de escritura en 'DocumentRoot' deben ser restringidos -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
       echo -e "Los permisos de escritura están restringidos correctamente -------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod4_1(){
   echo -e "\n\n\n 4.1 Ensure Access to OS Root Directory Is Denied By Default"
   echo    "======================================================================"
   ((++total))

   output=`perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "Require all denied" |wc -l` 2>/dev/null
   var2=`perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "Require all denied" |wc -l` 2>/dev/null

   echo -e "Configuracion existente: \n" $(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "Require all denied") "\n"

   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] ; then
       # print the reason why we are failing
       echo -e "Se tiene la función de acceso predeterminado --------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
   #   echo "pass"
       echo -e "Se tiene denegado el acceso al directorio raíz del SO ---- -------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod4_3(){
   echo -e "\n\n\n 4.3 Ensure OverRide Is Disabled for the OS Root Directory"
   echo    "==================================================================="
   ((++total))

   output=`perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf|grep "AllowOverride None" | wc -l` 2>/dev/null
   var2=`perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf|grep "AllowOverrideList" | wc -l` 2>/dev/null  #(debe ser salida 0)

   echo -e "Configuracion existente: \n" $(perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $dirConf |grep "AllowOverride None") "\n"

   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] || [ "$var2" = 1  ]; then
       # print the reason why we are failing
       echo -e "No se tiene las directivas configuradas -------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
   #   echo "pass"
       echo -e "Configuración de directivas correctas  ---------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod4_4(){
   echo -e "\n\n\n 4.4 Ensure OverRide Is Disabled for All Directories"
   echo    "=============================================================="
   ((++total))

   output=`grep -i AllowOverride "$dirConf"| grep -i "AllowOverrideList" |wc -l` 2>/dev/null
   echo -e "Configuracion existente: \n" "$(grep -i "AllowOverride" "$dirConf" | grep -i "AllowOverrideList")" "\n"
   
   # we captured output of the subshell, let's interpret it
   if [ "$output" != 0 ]; then
	echo -e "Elimine la directiva 'AllowOverrideList' ------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
	((++fail))
   else
	echo -e "Configuración de directivas correctas ---------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
	((++pass))
   fi
}

##### MODULO 5
function Mod5_1(){
   echo -e "\n\n\n 5.1 Ensure Options for the OS Root Directory Are Restricte"
   echo    "===================================================================="
   ((++total))

   param1=`perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep Directory |wc -l` 2>/dev/null
   param2=`perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep "Options None" |wc -l` 2>/dev/null

   output=`expr $param1 / 2`
   #echo $output
   # we captured output of the subshell, let's interpret it
   if [ $output != $param2 ] ; then
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
	((++pass))
   fi
}

function Mod5_2(){
   echo -e "\n\n\n 5.2 Ensure Options for the Web Root Directory Are Restricted"
   echo    "===================================================================="
   ((++total))

   param1=`perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i Directory |wc -l` 2>/dev/null
   param2=`perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options None" |wc -l` 2>/dev/null
   param3=`perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options Multiviews" |wc -l` 2>/dev/null


   output=`expr $param1 / 2`
   #echo $output
   # we captured output of the subshell, let's interpret it
   if [ $output != $param2 ] || [ $output != $param3 ] ; then
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
	((++pass))
   fi
}

function Mod5_3(){
   echo -e "\n\n\n 5.3 Ensure Options for Other Directories Are Minimized"
   echo    "===================================================================="
   ((++total))

   output=`perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options Includes" | wc -l` 2>/dev/null

   #echo $output
   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] ; then
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
	((++pass))
   else
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod5_4(){
   echo -e "\n\n\n 5.4 Ensure Default HTML Content Is Removed"
   echo    "======================================================="
   ((++total))

   param=$(rpm -q httpd-manual | grep "no está instalado" | wc -l) 2>/dev/null
   param2=$(grep -i -A 0 '#<LocationMatch[[:space:]]' $APACHE_PREFIX/conf.d/welcome.conf| wc -l) 2>/dev/null
   param3=$(grep -i -A 0 '#<Location[[:space:]]"/server-status"' $dirConf | wc -l) 2>/dev/null
   param31=$(grep -i -A 0 '<Location[[:space:]]"/server-status"' $dirConf | wc -l) 2>/dev/null
   param4=$(grep -i -A 0  '#<Location[[:space:]]/perl-status' $dirConf | wc -l) 2>/dev/null
   param41=$(grep -i -A 0  '<Location[[:space:]]/perl-status' $dirConf | wc -l) 2>/dev/null
   output=0

   if [ "$param" = 0 ] ; then
      output=1
   fi
   if [ "$param2" = 0 ] ; then
      output=1
   fi
   if [ "$param3" = 0 ] || [ "$param31" != 0 ] ; then
      output=1
   fi
   if [ "$param4" = 0 ] || [ "$param41" != 0 ] ; then
      output=1
   fi
   
   #echo $output
   # we captured output of the subshell, let's interpret it
   if [ "$output" != 0 ] ; then
      #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
      #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
	((++pass))
   fi
}

function Mod5_5(){
   echo -e "\n\n\n 5.5 Ensure the Default CGI Content printenv Script Is Removed"
   echo    "======================================================================="
   ((++total))

   param=$(grep -i -A 0 '#ScriptAlias /cgi-bin/' $dirConf |wc -l) 2>/dev/null
   param2=$(find -name printenv |wc -l) 2>/dev/null
   output=0

   if [ "$param" != "" ] ; then
      output=1
   fi
   if [ "$param2" != "" ] ; then
      output=1
   fi
   
   #echo $output
   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] ; then
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
	((++pass))
   else
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod5_6(){
   echo -e "\n\n\n 5.6 Ensure the Default CGI Content test-cgi Script Is Removed"
   echo    "======================================================================="
   ((++total))

   output1=$(find / -name cgi-bin)
   output2=$(find / -name test-cgi)

   #echo $output1
   #echo $output2
   # we captured output of the subshell, let's interpret it
   if [ "$output1" != "" ] || [ "$output2" != "" ] ; then
       #echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
       #echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod5_7(){
   echo -e "\n\n\n 5.7 Ensure HTTP Request Methods Are Restricted"
   echo    "========================================================"
   ((++total))
  
   # No. de bloques Directory a configurar
   param1=$(awk '/^.Directory/{p=1}/^.\/Directory./{p=0;print}p' "$dirConf" | grep -i Directory | wc -l) 2>/dev/null
   output=$(expr $param1 / 2)
   # La configuracion de LimitExcept que se busca
   param2=$(awk '/^.Directory/{p=1}/^.\/Directory./{p=0;print}p' "$dirConf" | grep -i -1 "^\s*<LimitExcept GET POST OPTIONS>" | grep -i "^\s*Require all denied" | wc -l) 2>/dev/null

   # we captured output of the subshell, let's interpret it
   if [ "$output" != $param2 ] ; then
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod5_8(){
   echo -e "\n\n\n 5.8 Ensure the HTTP TRACE Method Is Disabled"
   echo    "====================================================="
   ((++total))

   output=$(grep -i "^\s*TraceEnable" "$dirConf" | awk '{print $2}')

   # we captured output of the subshell, let's interpret it
   if [ "$output" != "off" ] ; then
       # print the reason why we are failing
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod5_9(){
   echo -e "\n\n\n 5.9 Ensure Old HTTP Protocol Versions Are Disallowed"
   echo    "============================================================="
   ((++total))

   lodedmodule=$(httpd -M | grep -i rewrite)
   engine=$(grep -i ^\s*RewriteEngine "$dirConf" | awk '{print $2}') 
   cond1=$(grep -i "^\s*RewriteCond.*THE_REQUEST.*HTTP/1\\\.1\\$" "$dirConf")
   rule=$(grep -i ^\s*RewriteRule "$dirConf")

   engine=$(echo "$engine" | awk '{print tolower($0)}')
   
   # we captured output of the subshell, let's interpret it
   if [ "$lodedmodule" != ""  ] &&  [ "$engine" == "on" ] && [ "$cond1" != ""  ] && [ "$rule" != ""  ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod5_10(){
   echo -e "\n\n\n 5.10 Ensure Access to .ht* Files Is Restricted"
   echo    "========================================================="
   ((++total))

   filesmatch=$(grep -i "^\s*<FilesMatch\s\"^\\\\\.ht\">" "$dirConf")
   filesmatch2=$(grep -i "^\s*<FilesMatch\s\"^\.\*\\$\">" "$dirConf")
   require=$(grep -i "^\s*Require all denied" "$dirConf") 

   engine=$(echo "$engine" | awk '{print tolower($0)}')
   
   # we captured output of the subshell, let's interpret it
   if ([ "$filesmatch" != ""  ] ||  [ "$filesmatch2" != "" ]) && [ "$require" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod5_11(){
   echo -e "\n\n\n 5.11 Ensure Access to Inappropriate File Extensions Is Restricted"
   echo    "==========================================================================="
   ((++total))

   filesmatch=$(grep -i "^\s*<FilesMatch\s\"^\.\*\\\\.*>" "$dirConf")
   filesmatch2=$(egrep "\bFilesMatch.+css.+png.+$" "$dirConf")
   require=$(grep -i "^\s*Require all denied" "$dirConf") 
   require2=$(grep -i "^\s*Require all granted" "$dirConf")

   engine=$(echo "$engine" | awk '{print tolower($0)}')

   # we captured output of the subshell, let's interpret it
   if [ "$filesmatch" != ""  ] && [ "$filesmatch2" != "" ] && [ "$require" != "" ] && [ "$require2" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod5_12(){
   echo -e "\n\n\n 5.12 Ensure IP Address Based Requests Are Disallowed"
   echo    "================================================================="
   ((++total))

   lodedmodule=$(httpd -M | grep -i rewrite)
   #echo $engine "as0"
   engine=$(grep -i ^\s*RewriteEngine "$dirConf" | awk '{print $2}') 
   #echo $engine "as1" 
   cond1=$(grep -i ^\s*RewriteCond.*HTTP_HOST.* "$dirConf")
   #echo $cond1 "as2"
   cond2=$(grep -i "^\s*RewriteCond.*REQUEST_URI.*" "$dirConf")
   #echo $cond2 "as3"
   rule=$(grep -i "^\s*RewriteRule ^.(.*) - \[L,F\]" "$dirConf")
   #echo $rule "as4"
   
   engine=$(echo "$engine" | awk '{print tolower($0)}')

   # we captured output of the subshell, let's interpret it
   if [ "$lodedmodule" != ""  ] &&  [ "$engine" == "on" ] && [ "$cond1" != ""  ] && [ "$cond2" != "" ] && [ "$rule" != ""  ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod5_13(){
   echo -e "\n\n\n 5.13 Ensure the IP Addresses for Listening for Requests Are Specified"
   echo    "==============================================================================="
   ((++total))

   output=($(cat "$dirConf" | grep -i \^Listen | awk '{print $2}'))
   good=0
   
   for item in ${output[@]}; do
   	if [[ "$item" =~ ([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]* ]]; then
       		good=$(($good + 1))
   		#echo $good
   	fi
   done
    
   
   # we captured output of the subshell, let's interpret it
   if [[ "$good" == ${#output[@]} ]]; then
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
       # print the reason why we are failing
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod5_14(){
   echo -e "\n\n\n 5.14 Ensure Browser Framing Is Restricted"
   echo    "===================================================="
   ((++total))

   bandera=0
   output=$(grep -i X-Frame-Options $dirConf)
   always=$(echo $output | awk '{print $2}')
   append=$(echo $output | awk '{print $3}')
   origin=$(echo $output | awk '{print $5}')
   
   if [ "$always" == "always" ] && ([ "$append" == "append" ] || [ "$append" == "set" ]) && ([ "$origin" == "DENY" ] || [ "$origin" == "SAMEORIGIN" ]) ; then
       bandera=1
   fi

   output=$(grep -i Content-Security-Policy $dirConf)
   always=$(echo $output | awk '{print $2}')
   append=$(echo $output | awk '{print $3}')
   frame=$(echo $output | awk '{print $5}')
   origin=$(echo $output | awk '{print $5}')
   
   if [ "$always" == "always" ] && ([ "$append" == "append" ] || [ "$append" == "set" ]) && [ "$frame" == "frame-ancestors" ] && ([ "$origin" == "none" ] || [ "$origin" == "self" ]) ; then
       bandera=1
   fi

   # we captured output of the subshell, let's interpret it   
   if [ "$bandera" = 1 ] ; then
       #echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
       #echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

##### MODULO 6
function Mod6_1(){
   echo -e "\n\n\n 6.1 Ensure the Error Log Filename and Severity Level Are Configured Correctly"
   echo    "======================================================================================="
   ((++total))

   loglevel=$(grep -i \^LogLevel "$dirConf" | awk '{print $2}')
   loglevelcore=$(grep -i \^LogLevel.*core:info "$dirConf")
   errorlog=$(grep -i \^ErrorLog "$dirConf")
   
   # we captured output of the subshell, let's interpret it
   if ([ "$loglevel" == "info" ] || [ "$loglevelcore" != "" ]) && [ "$errorlog" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod6_2(){
   echo -e "\n\n\n 6.2 Ensure a Syslog Facility Is Configured for Error Logging"
   echo    "======================================================================="
   ((++total))

   errorlog=$(grep -i \^\s*ErrorLog.*syslog:local1\" "$dirConf")
   
   # we captured output of the subshell, let's interpret it
   if [ "$errorlog" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod6_3(){
   echo -e "\n\n\n 6.3 Ensure the Server Access Log Is Configured Correctly"
   echo    "==================================================================="
   ((++total))

   logformat=$(grep -i "^\s*LogFormat\s\"\(%[h,l,u,t]\s\)\{4\}\\\\\"\%r\\\\\"\s\%>s\s\%b\s\\\\\"\%{Referer}i\\\\\"\s\\\\\"\%{User-Agent}i\\\\\"\"\scombined" "$dirConf")
   customlog=$(grep -i \^\\s*CustomLog.*combined  "$dirConf")
   
   # we captured output of the subshell, let's interpret it
   if [ "$logformat" != "" ] && [ "$customlog" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod6_4(){
   echo -e "\n\n\n 6.4 Ensure Log Storage and Rotation Is Configured Correctly"
   echo    "======================================================================"
   ((++total))

   logrotate=$(grep -i "^\s*/bin/kill -HUP 'cat /var/run/httpd.pid 2>/dev/null' 2> /dev/null || true" /etc/logrotate.d/httpd)
   weekly=$(grep -i ^weekly /etc/logrotate.conf)
   rotate=$(grep -i ^rotate /etc/logrotate.conf | awk '{print $2}')
   
   # we captured output of the subshell, let's interpret it
   if [ "$logrotate" != "" ] && [ "$weekly" != ""  ] && [ $rotate -ge 13  ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod6_6(){
   echo -e "\n\n\n 6.6 Ensure ModSecurity Is Installed and Enabled"
   echo    "=========================================================="
   ((++total))

   output=$(httpd -M | grep -i security2_module)
   #echo $output
   # we captured output of the subshell, let's interpret it
   if [ "$output" != "" ] ; then
      # echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
      # echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod6_7(){
   echo -e "\n\n\n 6.7 Ensure the OWASP ModSecurity Core Rule Set Is Installed and Enabled"
   echo    "=============================================================================="
   ((++total))

   RULE_DIR="$APACHE_PREFIX"/modsecurity.d/owasp-modsecurity-crs
   
   rulecount=$(find $RULE_DIR -name '*.conf' | xargs grep -i '^SecRule ' | wc -l)
   inanomaly=$(find $RULE_DIR -name '*.conf' | xargs egrep -v '^\s*#' | grep -i  "setvar:'tx.inbound_anomaly_score_threshold" | cut -d"=" -f2 | sed "s/'\"//g")
   outanomaly=$(find $RULE_DIR -name '*.conf' | xargs egrep -v '^\s*#' | grep -i  "setvar:'tx.outbound_anomaly_score_threshold" | cut -d"=" -f2 | sed "s/'\"//g")
   paranoia=$(find $RULE_DIR -name '*.conf' | xargs egrep -v '^\s*#' | grep -i  "setvar:'tx.outbound_anomaly_score_threshold" | cut -d"=" -f2 | sed "s/'\"//g")
   
   
   # we captured output of the subshell, let's interpret it
   if [ $rulecount -gt 325 ] && [ $inanomaly -le 5 ] && [ $outanomaly -le 4 ] && [ $paranoia -ge 1 ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}


##### MODULO 7
function Mod7_1(){
   echo -e "\n\n\n 7.1 Ensure mod_ssl and/or mod_nss Is Installed"
   echo    "========================================================="
   ((++total))
   busqueda1='ssl_module'
   busqueda2='nss_module'
   variable=$(httpd -M | egrep 'ssl_module|nss_module' || apachectl -M | egrep 'ssl_module|nss_module' )
   
   #echo "cadena es: "$variable
   if [[ "$variable" == *"$busqueda1"* ]] || [[ "$variable" == *"$busqueda2"* ]]; then
   	# echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
       #echo "esta mal configurado NO TIENE ssl_module o nss_module.";
       # echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod7_2(){
   echo -e "\n\n\n 7.2 Ensure a Valid Trusted Certificate Is Installed"
   echo    "============================================================="
   ((++total))
   SSLCONF="$APACHE_PREFIX"/"conf.d/ssl.conf"
   #echo "archivo::: "$SSLCONF		
   contFinal=0
   contAux=0
   	
   if [[ -f "$SSLCONF" ]]; then
   	#echo "Sí, sí existe el archivo"
   	
   	SSL=$(grep -i "^\s*SSLEngine" "$SSLCONF" | awk '{print $2}')
   	SSLC=$(grep -i "^\s*SSLCertificateFile" "$SSLCONF" | awk '{print $2}')
   	SSLK=$(grep -i "^\s*SSLCertificateKeyFile" "$SSLCONF" | awk '{print $2}')
   	SSLCH=$(grep -i "^\s*SSLCertificateChainFile" "$SSLCONF" | awk '{print $2}')
   	#echo "FILEKEY::: "$SSL
   	#echo "STRING1::: "$SSLC
   	#echo "STRING2::: "$SSLK
   	#echo "STRING3::: "$SSLCH
   	if [[ "$SSL" == "on" ]] && [[ -f "$SSLC" ]] && [[ -f "$SSLK" ]] && [[ -f "$SSLCH" ]]; then
   		#echo "PASO-----"
   		let contAux=contAux+1
   	else
   		#echo "fallo una de las valiacciones-----"
   		let contFinal=contFinal+1
   	fi
   else
   	#echo "No, no existe el archivo"
   	let contFinal=contFinal+1
   fi
   
   #echo "contador "$contFinal
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_3(){
   echo -e "\n\n\n 7.3 Ensure the Server's Private Key Is Protected"
   echo    "=========================================================="
   ((++total))

   SSLCONF="$APACHE_PREFIX"/"conf.d/ssl.conf"
   #echo "archivo::: "$SSLCONF		
   contFinal=0
   contAux=0
   	
   if [[ -f "$SSLCONF" ]]; then
   	#echo "Sí, sí existe el archivo"
   	
   	
   	FILEKEY=$(grep -i "^\s*SSLCertificateKeyFile" "$SSLCONF" | awk '{print $2}')
   	STRING1=$(ls -l "$SSLCONF" | awk '{print $1}')
   	STRING2=$(ls -l "$SSLCONF" | awk '{print $3}')
   	STRING3=$(ls -l "$SSLCONF" | awk '{print $4}')
   	
   	#echo "FILEKEY::: "$FILEKEY
   	#echo "STRING1::: "$STRING1
   	#echo "STRING2::: "$STRING2
   	#echo "STRING3::: "$STRING3
   	
   	if [[ "$STRING1" == *"-rw-r--r--."* ]] && [[ "$STRING2" == *"root"* ]] && [[ "$STRING3" == *"root"* ]]; then
   		#echo "esta bien"; 
   		let contAux=contAux+1
   	else
   		#echo "esta mal";
   		let contFinal=contFinal+1  
   	fi
   	
   else
   	#echo "No, no existe el archivo"
   	let contFinal=contFinal+1
   fi
   
   #echo "contador "$contFinal   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
        echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
        echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_4(){
   echo -e "\n\n\n 7.4 Ensure the TLSv1.0 and TLSv1.1 Protocols are Disabled"
   echo    "=================================================================="
   ((++total))

   fnd=`find $APACHE_PREFIX -name ssl.conf`
   #echo $fnd
   
   busqueda='SSLProtocol'
   contador=$(grep -i -c "$busqueda" "$fnd")
   rescat=$(cat "$fnd" | grep -i "$busqueda")
   
   contFinal=0
   contAux=0
   
   #echo "cadena es::: "$rescat
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena SSLProtocol"; 
     if [[ "$rescat" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLProtocol"; 
   	if [[ "$rescat" == *"TLSv1.2"* ]] || [[ "$rescat" == *"TLSv1.3"* ]]; then
   		#echo "tiene SSLProtocol y tiene TLSv1.2 o TLSv1.3";
   		let contAux=contAux+1
   	else
   		#echo "esta mal configurado ya que no tiene TLSv1.2 o TLSv1.3";
   		let contFinal=contFinal+1  
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLProtocol falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "contador "$contFinal
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_5(){
   echo -e "\n\n\n 7.5 Ensure Weak SSL/TLS Ciphers Are Disabled"
   echo    "======================================================"
   ((++total))

   fnd=`find $APACHE_PREFIX -name ssl.conf`
   busqueda='SSLHonorCipherOrder On'
   contador=$(grep -i -c "$busqueda" "$fnd")
   rescat=$(cat "$fnd" | grep -i "$busqueda")
   #echo $rescat
   busqueda2='SSLCipherSuite ALL:!EXP:!NULL:!LOW:!SSLv2:!RC4:!aNULL'
   contador2=$(grep -i -c "$busqueda2" "$fnd")
   rescat2=$(cat "$fnd" | grep -i "$busqueda2")
   echo $rescat2
   contFinal=0
   contAux=0
   
   #echo "cadena es::: "$rescat
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena SSLHonorCipherOrder"; 
     if [[ "$rescat" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLHonorCipherOrder"; 
   	if [[ "$rescat" == *"off"* ]] || [[ "$rescat" == *"Off"* ]] || [[ "$rescat" == *"OFF"* ]]; then
   		#echo "esta mal configurado ya que tiene off."; 
   		let contFinal=contFinal+1  
   	else
   		#echo "tiene SSLHonorCipherOrder no encontro off";
   		let contAux=contAux+1
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLHonorCipherOrder falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "cadena es::: "$rescat2
   if [[ "$contador2" > 0 ]]; then    
     #echo "tiene la cadena SSLCipherSuite"; 
     if [[ "$rescat2" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLCipherSuite"; 
   	if [[ "$rescat2" == *"!NULL"* ]] && [[ "$rescat2" == *"!SSLv2"* ]] && [[ "$rescat2" == *"!RC4"* ]] && [[ "$rescat2" == *"!aNULL"* ]] ; then
   		#echo "tiene SSLCipherSuite y tiene estos !NULL:!SSLv2:!RC4:!aNULL";
   		let contAux=contAux+1 
   	else
   		#echo "esta mal configurado ya que no la tiene estos !NULL:!SSLv2:!RC4:!aNULL"; 
   		let contFinal=contFinal+1 
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLCipherSuite falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "contador "$contFinal
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_6(){
   echo -e "\n\n\n 7.6 Ensure Insecure SSL Renegotiation Is Not Enabled"
   echo    "==============================================================="
   ((++total))

   busqueda='SSLInsecureRenegotiation'
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
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_7(){
   echo -e "\n\n\n 7.7 Ensure SSL Compression is not Enabled"
   echo    "==================================================="
   ((++total))

   busqueda='SSLCompression'
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
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
      echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
      echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_8(){
   echo -e "\n\n\n 7.8 Ensure Medium Strength SSL/TLS Ciphers Are Disabled"
   echo    "================================================================="
   ((++total))

   fnd=`find $APACHE_PREFIX -name ssl.conf`
   busqueda='SSLHonorCipherOrder On'
   contador=$(grep -i -c "$busqueda" "$fnd")
   rescat=$(cat "$fnd" | grep -i "$busqueda")
   
   busqueda2='SSLCipherSuite ALL:!EXP:!NULL:!LOW:!SSLv2:!RC4:!aNULL:!3DES:!IDEA'
   contador2=$(grep -i -c "$busqueda2" "$fnd")
   rescat2=$(cat "$fnd" | grep -i "$busqueda2")
   
   contFinal=0
   contAux=0
   
   #echo "cadena es::: "$rescat
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena SSLHonorCipherOrder"; 
     if [[ "$rescat" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLHonorCipherOrder"; 
   	if [[ "$rescat" == *"off"* ]] || [[ "$rescat" == *"Off"* ]] || [[ "$rescat" == *"OFF"* ]]; then
   		#echo "esta mal configurado ya que tiene off."; 
   		let contFinal=contFinal+1  
   	else
   		#echo "tiene SSLHonorCipherOrder no encontro off";
   		let contAux=contAux+1
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLHonorCipherOrder falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "cadena es::: "$rescat2
   if [[ "$contador2" > 0 ]]; then    
     #echo "tiene la cadena SSLCipherSuite"; 
     if [[ "$rescat2" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLCipherSuite"; 
   	if [[ "$rescat2" == *"!3DES"* ]] && [[ "$rescat2" == *"!IDEA"* ]]; then
   		#echo "tiene SSLCipherSuite y tiene estos !NULL:!SSLv2:!RC4:!aNULL";
   		let contAux=contAux+1 
   	else
   		#echo "esta mal configurado ya que no la tiene estos !NULL:!SSLv2:!RC4:!aNULL"; 
   		let contFinal=contFinal+1 
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLCipherSuite falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "contador "$contFinal
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_9(){
   echo -e "\n\n\n 7.9 Ensure All Web Content is Accessed via HTTPS"
   echo    "=========================================================="
   ((++total))

   cadena=$(grep -i "^\s*Redirect" "$dirConf")
   #echo "salida: "$cadena;
   
   # we captured output of the subshell, let's interpret it
   if [[ "$cadena" == *"https"* ]] ; then
       #echo "PASO"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   else
       #echo "FALLO"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   fi
}

function Mod7_10(){
   echo -e "\n\n\n 7.10 Ensure OCSP Stapling Is Enabled"
   echo    "==============================================="
   ((++total))

   fnd=`find $APACHE_PREFIX -name ssl.conf`
   
   busqueda='SSLUseStapling'
   contador=$(grep -i -c "$busqueda" "$fnd")
   rescat=$(cat "$fnd" | grep -i "$busqueda")
   
   busqueda2='SSLStaplingCache'
   contador2=$(grep -i -c "$busqueda2" "$fnd")
   rescat2=$(cat "$fnd" | grep -i "$busqueda2")
   
   contFinal=0
   contAux=0
   
   #echo "cadena es::: "$rescat
   if [[ "$contador" > 0 ]]; then    
     #echo "tiene la cadena SSLUseStapling"; 
     if [[ "$rescat" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLUseStapling"; 
   	if [[ "$rescat" == *"on"* ]] || [[ "$rescat" == *"On"* ]] || [[ "$rescat" == *"ON"* ]]; then
   		#echo "tiene SSLUseStapling y esta en ON";
   		let contAux=contAux+1
   	else
   		#echo "esta mal configurado ya que tiene on."; 
   		let contFinal=contFinal+1  
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLUseStapling falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "cadena es::: "$rescat2
   if [[ "$contador2" > 0 ]]; then    
     #echo "tiene la cadena SSLStaplingCache"; 
     if [[ "$rescat2" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLStaplingCache"; 
   	if [[ "$rescat2" == *"logs"* ]] || [[ "$rescat2" == *"LOGS"* ]]; then
   		#echo "contiene la palabra logs";
   		let contAux=contAux+1 
   	else
   		#echo "esta mal configurado ya que no la tiene logs"; 
   		let contFinal=contFinal+1 
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLStaplingCache falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "contador "$contFinal
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi   
}

function Mod7_11(){
   echo -e "\n\n\n 7.11 Ensure HTTP Strict Transport Security Is Enabled"
   echo    "================================================================"
   ((++total))

   SSLCONF="$APACHE_PREFIX"/"conf.d/ssl.conf"
   
   #echo "archivo::: "$SSLCONF		
   if [[ -f "$SSLCONF" ]]; then
   	#echo "Sí, sí existe el archivo"
   	
   	busqueda='Header always set Strict-Transport-Security'
   	contador=$(grep -i -c "$busqueda" "$SSLCONF")
   	rescat=$(cat "$SSLCONF" | grep -i "$busqueda")
   	contFinal=0
   	contAux=0
   
   	#echo "cadena es::: "$rescat
   	if [[ "$contador" > 0 ]]; then    
   	  #echo "tiene la cadena Header always set Strict-Transport-Security"; 
   	  if [[ "$rescat" == *"#"* ]]; then
   		#echo "esta comentado esta MAL esto.";
   		let contFinal=contFinal+1 
   	  else
   		#echo "no esta comentada la cadena Header always set Strict-Transport-Security"; 
   		if [[ "$rescat" == *"max-age=600"* ]]; then
   			#echo "tiene SSLHonorCipherOrder no encontro off";
   			let contAux=contAux+1
   		else
   			#echo "esta mal configurado ya que NO TIENE max-age=600."; 
   			let contFinal=contFinal+1  
   		fi 
   	  fi
   	else
   	  #echo "no tiene la cadena Header always set Strict-Transport-Security"; 
   	  let contFinal=contFinal+1   
   	fi
   else
   	#echo "No, no existe el archivo"
   	let contFinal=contFinal+1
   fi
   
   #echo "contador "$contFinal
   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

function Mod7_12(){
   echo -e "\n\n\n 7.12 Ensure Only Cipher Suites That Provide Forward Secrecy Are Enabled"
   echo    "================================================================================="
   ((++total))

   fnd=`find $APACHE_PREFIX -name ssl.conf`
   
   busqueda2='SSLCipherSuite EECDH:EDH:!NULL:!SSLv2:!RC4:!aNULL:!3DES:!IDEA'
   contador2=$(grep -i -c "$busqueda2" "$fnd")
   rescat2=$(cat "$fnd" | grep -i "$busqueda2")
   
   contFinal=0
   contAux=0
   
   #echo "cadena es::: "$rescat2
   if [[ "$contador2" > 0 ]]; then    
     #echo "tiene la cadena SSLCipherSuite"; 
     if [[ "$rescat2" == *"#"* ]]; then
       #echo "esta comentado esta MAL esto.";
   	let contFinal=contFinal+1 
     else
   	#echo "no esta comentada la cadena SSLCipherSuite"; 
   	if [[ "$rescat2" == *"EECDH"* ]] || [[ "$rescat2" == *"ECDHE"* ]]; then
   		#echo "tiene SSLCipherSuite y tiene estos  EECDH o ECDHE";
   		
   		if [[ "$rescat2" == *":EDH"* ]] || [[ "$rescat2" == *":DHE"* ]]; then
   			#echo "tiene SSLCipherSuite y tiene estos  EDH o DHE";
   			let contAux=contAux+1 
   		else
   			#echo "esta mal configurado ya que no la tiene estos  EECDH:EDH o ECDHE:DHE"; 
   			let contFinal=contFinal+1 
   		fi 
   	else
   		#echo "esta mal configurado ya que no la tiene estos  EECDH o ECDHE"; 
   		let contFinal=contFinal+1 
   	fi 
     fi
   else
     #echo "no tiene la cadena SSLCipherSuite falta agregarla"; 
     let contFinal=contFinal+1   
   fi
   
   #echo "contador "$contFinal   
   if [[ "$contFinal" > 0 ]]; then    
     #echo "FALLO"; 
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       ((++fail))
   else
     #echo "PASO";
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi
}

##### MODULO 8

##### MODULO 9

##### MODULO 10

##### MODULO 11

##### MODULO 12


function calificacion(){
    echo -e "\n\n\n**********************************************************************************************************************************\n"
    echo -e Controles totales: $total
    echo -e Controles cumplidos: ${YELLOW} $pass ${WHITE} 
    echo -e Controles no cumplidos ${RED} $fail ${WHITE}
    echo -e Porcentaje de cumplimiento: ${YELLOW} $((pass * 100 / total)) % ${WHITE} 
    #echo -e Porcentaje de cumplimiento: $((puntaje * 100 / 18)) % >> instancias_jboss_$(hostname)_${fechan}.txt
    echo -e "***********************************************************************************************************************************\n"
}

function main(){
   #instanciasactivas

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
   
   # MODULO 3
   #++++++++++
   Mod3_1
   Mod3_2
   Mod3_3
   Mod3_4
   Mod3_5
   Mod3_6
   Mod3_7
   Mod3_8
   Mod3_9
   Mod3_10
   Mod3_11
   Mod3_12

   # MODULO 4
   #++++++++++
   Mod4_1
   Mod4_3
   Mod4_4

   # MODULO 5
   #++++++++++
   Mod5_1
   Mod5_2
   Mod5_3
   Mod5_4
   Mod5_5
   Mod5_6
   Mod5_7
   Mod5_8
   Mod5_9
   Mod5_10
   Mod5_11
   Mod5_12
   Mod5_13
   Mod5_14

   # MODULO 6
   #++++++++++
   Mod6_1
   Mod6_2
   Mod6_3
   Mod6_4
   Mod6_6
   Mod6_7

   # MODULO 7
   #++++++++++
   Mod7_1
   Mod7_2
   Mod7_3
   Mod7_4
   Mod7_5
   Mod7_6
   Mod7_7
   Mod7_8
   Mod7_9
   Mod7_10
   Mod7_11
   Mod7_12

   # MODULO 8
   #++++++++++

   # MODULO 9
   #++++++++++

   # MODULO 10
   #++++++++++

   # MODULO 11
   #++++++++++

   # MODULO 12
   #++++++++++

   calificacion
   
}

main

# TOTALES
#echo -e "\n\n\n\n"
#echo "PASS ----- ["$pass"]"
#echo "FAIL ----- ["$fail"]"
#echo "TOTAL -----["$total"]"
