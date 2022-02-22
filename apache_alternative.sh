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
   
   FilExis=$(find / -name ScoreBoardFile |wc -l)
   FilExNoRut=$(find -L $APACHE_PREFIX -name ScoreBoardFile |wc -l)
   PerFil=$(find $APACHE_PREFIX -name ScoreBoardFile \! -user root |wc -l)
   PerFilGP=$(find $APACHE_PREFIX -name ScoreBoardFile \! -group root |wc -l)
   PerRW=$(find $APACHE_PREFIX -name ScoreBoardFile \! -perm -644 |wc -l)
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
   echo -e "\n\n\n 3.13 Ensure Group Write Access for the Document Root Directories and Files Is Properly Restricted"
   echo    "============================================================================================================"
   ((++total))
   GRP=$(grep '^Group' $dirConf | cut -d' ' -f2)
   echo "A" $GRP
   output=$(find -L $DocumentRoot -group $GRP -perm /g=w -ls)
   echo "B" $output

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








function calificacion(){
    echo -e "**********************************************************************************************************************************\n"
    echo -e Controles totales: $total
    echo -e Controles cumplidos: ${YELLOW} $pass ${WHITE} 
    echo -e Controles no cumplidos ${RED} $fail ${WHITE}
    echo -e Porcentaje de cumplimiento: ${YELLOW} $((pass * 100 / total)) % ${WHITE} 
    #echo -e Porcentaje de cumplimiento: $((puntaje * 100 / 18)) % >> instancias_jboss_$(hostname)_${fechan}.txt
    echo -e "***********************************************************************************************************************************\n"
}

function main(){
   #instanciasactivas
   Mod2_2
   Mod2_3
   Mod2_4
   Mod2_5
   Mod2_6
   Mod2_7
   Mod2_8
   Mod2_9
   
   #MODULO 3
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

   calificacion
   
}

main

# TOTALES
#echo -e "\n\n\n\n"
#echo "PASS ----- ["$pass"]"
#echo "FAIL ----- ["$fail"]"
#echo "TOTAL -----["$total"]"
