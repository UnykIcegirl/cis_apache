#!/usr/bin/env bash

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
   nombre="3.1 Ensure the Apache Web Server Runs As a Non-Root User"
   descripcion="Although Apache is typically started with root privileges in order to listen on port 80 and 443, it can and should run as another non-root user in order to perform the web services. The Apache User and Group directives are used to designate the user and group that the Apache worker processes will assume."
   remediacion="Perform the following:  1. If the apache user and group do not already exist, create the account and group as a unique system account: # groupadd -r apache # useradd apache -r -g apache -d /var/www -s /sbin/nologin   2. Configure the Apache user and group in the Apache configuration file httpd.conf: User apache  Group apache"

   sal_31=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "Configuracion existente: Directorio configuración $dirConf Usuario: $usuario id-($iduser)  Grupo: $grupo id-($idgpo) UID_MIN: $uid_min")
   #echo -e "\n \n $sal_31"
}

function Mod3_2(){
   echo -e "\n\n\n 3.2 Ensure the Apache User Account Has an Invalid Shell"
   echo    "============================================================================"
   ((++total))
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
   nombre="3.2 Ensure the Apache User Account Has an Invalid Shell"
   descripcion="The apache account must not be used as a regular login account, and should be assigned an invalid or nologin shell to ensure that the account cannot be used to login."
   remediacion="Change the apache account to use the nologin shell or an invalid shell such as /dev/null:  # chsh -s /sbin/nologin apache "
   evidencia="$(getEvidencia "2" "$(grep -E ^$usuario /etc/passwd)")"

   sal_32=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_32"
}

function Mod3_3(){
   echo -e "\n\n\n 3.3 Ensure the Apache User Account Is Locked"
   echo    "============================================================================"
   ((++total))
   variable=$(passwd -S "$usuario" | grep -E '.*(Contraseña bloqueada.*)$' || passwd -S "$usuario" | grep -E '.*(Password locked.*)$'  || passwd -S "$usuario" | grep -E '.*(Contraseña establecida.*)$')
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
   nombre="3.3 Ensure the Apache User Account Is Locked"
   descripcion="The user account under which Apache runs should not have a valid password, but should be locked."
   remediacion="Use the passwd command to lock the apache account: # passwd -l apache"
   evidencia="$(getEvidencia "1" "$(passwd -S $usuario)")"

   sal_33=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_33"
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
   if [ "$variable" = "$no_existe" ] && [ "$var_www" = "$no_existe" ] ; then
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
   cmd1="$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -user root -ls | head -1)"
   cmd2="$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -user root -ls | head -1)"
   nombre="3.4 Ensure Apache Directories and Files Are Owned By Root"
   descripcion="The Apache directories and files should be owned by root. This applies to all of the Apache software directories and files installed."
   remediacion="Perform the following:  Set ownership on the $APACHE_PREFIX directories such as /usr/local/apache2: $ chown -R root $APACHE_PREFIX"
   evidencia="$(getEvidencia "2" "$cmd1")"
   evid2="$(getEvidencia "2" "$cmd2")"

   sal_34=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2")
   #echo -e "\n \n $sal_34"
}

function Mod3_5(){
   echo -e "\n\n\n 3.5 Ensure the Group Is Set Correctly on Apache Directories and Files"
   echo    "==============================================================================="
   # SE DEBERA JUSTIFICAR
   ((++total))
   variable=$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls 2>/dev/null)
   var_www=$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls 2>/dev/null)
   echo -e "Configuracion existente: \n"  "\n" $(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls | head -5)

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] && [ "$var_www" = "$no_existe" ] ; then
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
   cmd1="$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls | head -1)"
   cmd2="$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls | head -1)"
   nombre="3.5 Ensure the Group Is Set Correctly on Apache Directories and Files"
   descripcion="The Apache directories and files should be set to have a group Id of root, (or a root equivalent) group. This applies to all of the Apache software directories and files installed. The only expected exception is that the Apache web document root ($APACHE_PREFIX/htdocs) is likely to need a designated group to allow web content to be updated (such as webupdate) through a change management process."
   remediacion="Perform the following:  Set ownership on the $APACHE_PREFIX directories such as /usr/local/apache2:  $ chgrp -R root $APACHE_PREFIX"
   evidencia="$(getEvidencia "2" "$cmd1")"
   evid2="$(getEvidencia "2" "$cmd2")"

   sal_35=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2")
   #echo -e "\n \n $sal_35"
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
   cmd1=$(find -L $APACHE_PREFIX \! -type l -perm -o=w -ls | head -1 | xargs)
   nombre="3.6 Ensure Other Write Access on Apache Directories and Files Is Restricted"
   descripcion="Permissions on Apache directories should generally be rwxr-xr-x (755) and file permissions should be similar except not executable unless appropriate. This applies to all of the Apache software directories and files installed with the possible exception of the web document root $APACHE_PREFIX/htdocs. The directories and files in the web document root may have a designated group with write access to allow web content to be updated. In summary, the minimum recommendation is to not allow write access by other."
   remediacion="Perform the following to remove other write access on the $APACHE_PREFIX directories.  # chmod -R o-w $APACHE_PREFIX"
   evidencia="$(getEvidencia "2" "$cmd1")"

   sal_36=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_36"
}

function Mod3_7(){
   echo -e "\n\n\n 3.7 Ensure the Core Dump Directory Is Secured"
   echo    "======================================================"
   ((++total))
   variable=$(`grep -i dump $dirConf` 2>/dev/null)
   varDir=$(find $APACHE_PREFIX -name 'CoreDump*' || find $APACHE_PREFIX/htdocs -name 'CoreDump*')
   variable2=$(find $dirLogs -type d -perm -o=rwx -ls)
   echo -e "Configuracion existente: \n a)" $(grep -i dump $dirConf) "\n b)" $(find $APACHE_PREFIX -name 'CoreDump*' || find $APACHE_PREFIX/htdocs -name 'CoreDump*') "\n c)" $(find $dirLogs -type d -perm -o=rwx -ls)

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] && [ "$varDir" = "$no_existe" ]; then
      if [ "$variable2" = "$no_existe" ] ; then
         # print the reason why we are pass
         echo -e "Es seguro el directorio 'Core Dump' -----------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
         resultado="Cumple"
         ((++pass))
      else
         echo -e "Configuracion existente: \n" $(find $dirLogs -type d -perm -o=rwx -ls) "\n"
         echo -e "Se tienen permisos no permitidos------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
         resultado="No Cumple"
         ((++fail))
      fi
   else
      echo -e "Configuracion existente: \n" $(grep -i dump $dirConf) "\n" $(find $APACHE_PREFIX -name 'CoreDump*' || find $APACHE_PREFIX/htdocs -name 'CoreDump*') "\n"
      echo -e "Se tiene la directiva de 'CoreDumpDirectory' habilitada ------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   nombre="3.7 Ensure the Core Dump Directory Is Secured"
   descripcion="The CoreDumpDirectory directive is used to specify the directory Apache attempts to switch to before creating the core dump. Core dumps will be disabled if the directory is not writable by the Apache user. Also, core dumps will be disabled if the server is started as root and switches to a non-root user, as is typical. It is recommended that the CoreDumpDirectory directive be set to a directory that is owned by the root user, owned by the group the Apache HTTPD process executes as, and be inaccessible to other users."
   remediacion="Either remove the CoreDumpDirectory directive from the Apache configuration files or ensure that the configured directory meets the following requirements.  1. CoreDumpDirectory is not to be within the Apache web document root ($APACHE_PREFIX/htdocs)  2. Must be owned by root and have a group ownership of the Apache group (as defined via the Group directive)  # chown root:apache /var/log/httpd   3. Must have no read-write-search access permission for other users.  # chmod o-rwx /var/log/httpd"
   evidencia="$(getEvidencia "2" "$variable")"
   evid2="$(getEvidencia "2" "$varDir")"
   evid3="$(getEvidencia "2" "$variable2")"

   sal_37=$(getJsonEv3 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3")
   #echo -e "\n \n $sal_37"
}

function Mod3_8(){
   echo -e "\n\n\n 3.8 Ensure the Lock File Is Secured"
   echo    "============================================"
   ((++total))
   variable=$(find $APACHE_PREFIX -name httpd.lock)
   variable2=$(find $dirLogs -type d -perm -o=rwx -ls)
   
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
   
   variable3=$(`find $dirLogs \! -user $usuario_validar -ls` 2>/dev/null)
   variable4=$(`find $dirLogs \! -group $grupo_validar -ls` 2>/dev/null)
   #echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX \! -type l -perm /o=w -ls 2>/dev/null) "\n"

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$variable" = "$no_existe" ] ; then
      if [ "$variable2" = "$no_existe" ] && [ "$variable3" = "$no_existe" ] && [ "$variable4" = "$no_existe" ]; then
         # print the reason why we are pass
         echo -e "Es seguro el archivo 'lock file'-----------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
         resultado="Cumple"
         ((++pass))
      else
         echo -e "Se tienen permisos no permitidos------------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
         resultado="No Cumple"
         ((++fail))
      fi
   else
      echo -e "Configuracion existente: \n" $(grep -i dump $dirConf) "\n"
      echo -e "Se tiene habilitada la directiva 'Mutex' ------------------------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   fi

   # JSON ---------------------------
   nombre="3.8 Ensure the Lock File Is Secured"
   descripcion="The Mutex directive sets the locking mechanism used to serialize access to resources. It may be used to specify that a lock file is to be used as a mutex mechanism and may provide the path to the lock file to be used with the fcntl(2) or flock(2) system calls. Most Linux systems will default to using semaphores instead, so the directive may not apply. However, in the event a lock file is used, it is important for the lock file to be in a local directory that is not writable by other users."
   remediacion="Find the directory path in which the lock file would be created. The default value is the ServerRoot/logs directory.  1. Modify the directory if the path is a directory within the Apache DocumentRoot  2. Change the ownership and group to be root:root, if not already.  3. Change the permissions so that the directory is only writable by root, or the user under which Apache initially starts up (default is root),  4. Check that the lock file directory is on a locally mounted hard drive rather than an NFS mounted file system."

   sal_38=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$(getEvidencia "2" "$variable2")" "$(getEvidencia "2" "$variable3")" "$(getEvidencia "2" "$variable4")")
   #echo -e "\n \n $sal_38"
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
   variable=$(`find $dirLogs -type d -perm -o=rwx -ls` 2>/dev/null)
   output=0
   echo -e "Configuracion existente: \n" $(find -L $APACHE_PREFIX -name httpd.pid \! -user $usuario_validar) "\n"

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
   nombre="3.9 Ensure the Pid File Is Secured"
   descripcion="The PidFile directive sets the file path to the process ID file to which the server records the process id of the server, which is useful for sending a signal to the server process or for checking on the health of the process."
   remediacion="1. Find the directory in which the PidFile would be created. The default value is the ServerRoot/logs directory.  2. Modify the directory if the PidFile is in a directory within the Apache `DocumentRoot`.  3. Change the ownership and group to be root:root, if not already.  4. Change the permissions so that the directory is only writable by root, or the user under which Apache initially starts up (default is root)."
   evidencia="$(getEvidencia "2" "$(find -L $APACHE_PREFIX/www/ -name httpd.pid | head -1 )")"
   evid2="$(getEvidencia "2" "$(find -L $APACHE_PREFIX -name httpd.pid \! -user $usuario_validar | head -1)")"
   evid3="$(getEvidencia "2" "$(find -L $APACHE_PREFIX -name httpd.pid \! -group $grupo_validar | head -1)")"
   evid4="$(getEvidencia "2" "$(find $dirLogs -type d -perm -o=rwx -ls | head -1)")"

   sal_39=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3" "$evid4")
   #echo -e "\n \n $sal_39"
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
   
   scoreConf=$(grep 'ScoreBoard' $dirConf)
   FilExis=$(find $APACHE_PREFIX -name ScoreBoardFile |wc -l)
   FilExNoRut=`find -L $APACHE_PREFIX/www/ -name ScoreBoardFile |wc -l` 2>/dev/null
   PerFil=`find $APACHE_PREFIX -name ScoreBoardFile \! -user $usuario_validar |wc -l` 2>/dev/null
   PerFilGP=`find $APACHE_PREFIX -name ScoreBoardFile \! -group $grupo_validar |wc -l` 2>/dev/null
   PerRW=`find $APACHE_PREFIX -name ScoreBoardFile \! -perm -644 |wc -l` 2>/dev/null
   output=0

   if [ "$FilExis" != 0 ] && [ "$scoreConf" = "$no_existe" ] ; then
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

   # JSON ----------------------------
   nombre="3.10 Ensure the ScoreBoard File Is Secured"
   descripcion="The ScoreBoardFile directive sets a file path which the server will use for inter-process communication (IPC) among the Apache processes. On most Linux platforms, shared memory will be used instead of a file in the file system, so this directive is not generally needed and does not need to be specified. However, if the directive is specified, then Apache will use the configured file for the inter-process communication. Therefore, if it is specified, it needs to be located in a secure directory."
   remediacion="1. Check to see if the ScoreBoardFile is specified in any of the Apache configuration files. If it is not present, no changes are required.  2. If the directive is present, find the directory in which the ScoreBoardFile would be created. The default value is the ServerRoot/logs directory.  3. Modify the directory if the ScoreBoardFile is in a directory within the Apache DocumentRoot  4. Change the ownership and group to be root:root, if not already.  5. Change the permissions so that the directory is only writable by root, or the user under which apache initially starts up (default is root).  6. Check that the scoreboard file directory is on a locally mounted hard drive rather than an NFS mounted file system."
   evidencia="$(getEvidencia "2" "$scoreConf")"
   evid2="$(getEvidencia "2" "$(find $APACHE_PREFIX -name ScoreBoardFile \! -user $usuario_validar | head -1)")"
   evid3="$(getEvidencia "2" "$(find $APACHE_PREFIX -name ScoreBoardFile \! -group $grupo_validar | head -1)")"
   evid4="$(getEvidencia "2" "$(find $APACHE_PREFIX -name ScoreBoardFile \! -perm -644 | head -1)")"

   sal_310=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3" "$evid4")
   #echo -e "\n \n $sal_310"
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
   nombre="3.11 Ensure Group Write Access for the Apache Directories and Files Is Properly Restricted"
   descripcion="Group permissions on Apache directories should generally be r-x and file permissions should be similar except not executable if executable is not appropriate. This applies to all of the Apache software directories and files installed with the possible exception of the web document root $DOCROOT defined by Apache DocumentRoot and defaults to $APACHE_PREFIX/htdocs. The directories and files in the web document root may have a designated web development group with write access to allow web content to be updated."
   remediacion="Perform the following to remove group write access on the $APACHE_PREFIX directories. # chmod -R g-w $APACHE_PREFIX"
   evidencia="$(getEvidencia "2" "$(find -L $APACHE_PREFIX \! -type l -perm /g=w -ls | head -1)")"

   sal_311=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_311"
}

function Mod3_12(){
   echo -e "\n\n\n 3.12 Ensure Group Write Access for the Document Root Directories and Files Is Properly Restricted"
   echo    "============================================================================================================"
   ((++total))
   GRP=$(grep '^Group' $dirConf | cut -d' ' -f2)
   output=$(find -L $APACHE_PREFIX -group $GRP -perm /g=w -ls)

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
   nombre="3.12 Ensure Group Write Access for the Document Root Directories and Files Is Properly Restricted"
   descripcion="Group permissions on Apache Document Root directories $DOCROOT may need to be writable by an authorized group such as development, support, or a production content management tool. However, it is important that the Apache group used to run the server does not have write access to any directories or files in the document root."
   remediacion="Perform the following to remove group write access on the $DOCROOT directories and files with the apache group.  # find -L $DOCROOT -group $GRP -perm /g=w -print | xargs chmod g-w"
   evidencia="$(getEvidencia "2" "$(find -L $APACHE_PREFIX -group $GRP -perm /g=w -ls | head -1)")"

   sal_312=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "\n \n $sal_312"
}


function mod3(){
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

   sal_mod3="$sal_31, $sal_32, $sal_33, $sal_34, $sal_35, $sal_36, $sal_37, $sal_38, $sal_39, $sal_310, $sal_311, $sal_312"
   #echo -e "\n\n $sal_mod3"
   
}

mod3
