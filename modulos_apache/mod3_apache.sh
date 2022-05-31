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
   sal_31=$(jo id="3.1 Ensure the Apache Web Server Runs As a Non-Root User" descripcion="Although Apache is typically started with root privileges in order to listen on port 80 and 443, it can and should run as another non-root user in order to perform the web services. The Apache User and Group directives are used to designate the user and group that the Apache worker processes will assume" como_cumplirlo="Ensure the apache account is unique and has been created with a UID less than the minimum normal user account with the Apache group and configured in the httpd.conf file." evidencia="Configuracion existente: Directorio configuración $dirConf Usuario: $usuario id-($iduser)  Grupo: $grupo id-($idgpo) UID_MIN: $uid_min" estado="$resultado")
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
   sal_32=$(jo id="3.2 Ensure the Apache User Account Has an Invalid Shell" descripcion="The apache account must not be used as a regular login account, and should be assigned an invalid or nologin shell to ensure that the account cannot be used to login." como_cumplirlo=" # grep apache /etc/passwd   The apache account shell must be /sbin/nologin or /dev/null similar to the following: /etc/passwd:apache:x:48:48:Apache:/var/www:/sbin/nologin" evidencia="$(grep -E ^$usuario /etc/passwd)" estado="$resultado")
   #echo -e "\n \n $sal_32"
}

function Mod3_3(){
   echo -e "\n\n\n 3.3 Ensure the Apache User Account Is Locked"
   echo    "============================================================================"
   ((++total))
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
   sal_33=$(jo id="3.3 Ensure the Apache User Account Is Locked" descripcion="The user account under which Apache runs should not have a valid password, but should be locked." como_cumplirlo="Ensure the apache account is locked using the following command:   # passwd -S apache " evidencia="$(passwd -S $usuario)" estado="$resultado")
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
   sal_34=$(jo id="3.4 Ensure Apache Directories and Files Are Owned By Root" descripcion="The Apache directories and files should be owned by root. This applies to all of the Apache software directories and files installed." como_cumplirlo="Identify files in the Apache directory that are not owned by root" evidencia[]="$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -user root -ls | head -1)" evidencia[]="$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -user root -ls | head -1)" estado="$resultado")
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
   sal_35=$(jo id="3.5 Ensure the Group Is Set Correctly on Apache Directories and Files" descripcion="The Apache directories and files should be set to have a group Id of root, (or a root equivalent) group. This applies to all of the Apache software directories and files installed. The only expected exception is that the Apache web document root ($APACHE_PREFIX/htdocs) is likely to need a designated group to allow web content to be updated (such as webupdate) through a change management process." como_cumplirlo="Identify files in the Apache directories other than htdocs with a group other than root. " evidencia[]="$(find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls | head -1)" evidencia[]="$(find $APACHE_PREFIX -path $APACHE_PREFIX/www -prune -o \! -group root -ls | head -1)" estado="$resultado")
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
   sal_36=$(jo id="3.6 Ensure Other Write Access on Apache Directories and Files Is Restricted" descripcion="Permissions on Apache directories should generally be rwxr-xr-x (755) and file permissions should be similar except not executable unless appropriate. This applies to all of the Apache software directories and files installed with the possible exception of the web document root $APACHE_PREFIX/htdocs. The directories and files in the web document root may have a designated group with write access to allow web content to be updated. In summary, the minimum recommendation is to not allow write access by other." como_cumplirlo="None of the Apache files and directories, including the Web document root must allow other write access. Identify files or directories in the Apache directory with other write access, excluding symbolic links: # find -L $APACHE_PREFIX \\\! -type l -perm -o=w -ls" evidencia="$(find -L $APACHE_PREFIX \! -type l -perm -o=w -ls | head -1)" estado="$resultado")
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
   sal_37=$(jo id="3.7 Ensure the Core Dump Directory Is Secured" descripcion="The CoreDumpDirectory directive is used to specify the directory Apache attempts to switch to before creating the core dump. Core dumps will be disabled if the directory is not writable by the Apache user. Also, core dumps will be disabled if the server is started as root and switches to a non-root user, as is typical. It is recommended that the CoreDumpDirectory directive be set to a directory that is owned by the root user, owned by the group the Apache HTTPD process executes as, and be inaccessible to other users." como_cumplirlo="Verify that either the CoreDumpDirectory directive is not enabled in any of the Apache configuration files or that the configured directory meets the following requirements: \\n 1. CoreDumpDirectory is not within the Apache web document root ($APACHE_PREFIX/htdocs) \\n 2. Must be owned by root and have a group ownership of the Apache group (as defined via the Group directive) \\n 3. Must have no read-write-search access permission for other users. (e.g. o=rwx)" evidencia[]="$variable" evidencia[]="$varDir" evidencia[]="$variable2" estado="$resultado")
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
         echo -e "Es seguro el el archivo 'lock file'-----------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
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
   sal_38=$(jo id="3.8 Ensure the Lock File Is Secured" descripcion="The Mutex directive sets the locking mechanism used to serialize access to resources. It may be used to specify that a lock file is to be used as a mutex mechanism and may provide the path to the lock file to be used with the fcntl(2) or flock(2) system calls. Most Linux systems will default to using semaphores instead, so the directive may not apply. However, in the event a lock file is used, it is important for the lock file to be in a local directory that is not writable by other users." como_cumplirlo="Verify the configuration does NOT include a Mutex directive with the mechanism of fcntl, flock or file. If one of the file locking mechanisms is configured, then find the directory in which the lock file would be created. The default value is the ServerRoot/logs directory." evidencia[]="$variable" evidencia[]="$variable2" evidencia[]="$variable3" evidencia[]="$variable4" estado="$resultado")
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
   sal_39=$(jo id="3.9 Ensure the Pid File Is Secured" descripcion="The PidFile directive sets the file path to the process ID file to which the server records the process id of the server, which is useful for sending a signal to the server process or for checking on the health of the process." como_cumplirlo="Change the permissions so that the directory is only writable by root, or the user under which Apache initially starts up (default is root). The default process ID file is logs/httpd.pid." evidencia[]="$DireNot" evidencia[]="$RutPid" evidencia[]="$variable" estado="$resultado")
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

   # JSON ---------------------------
   sal_310=$(jo id="3.10 Ensure the ScoreBoard File Is Secured" descripcion="The ScoreBoardFile directive sets a file path which the server will use for inter-process communication (IPC) among the Apache processes. On most Linux platforms, shared memory will be used instead of a file in the file system, so this directive is not generally needed and does not need to be specified. However, if the directive is specified, then Apache will use the configured file for the inter-process communication. Therefore, if it is specified, it needs to be located in a secure directory." como_cumplirlo="1. Check to see if the ScoreBoardFile is specified in any of the Apache configuration files. If it is not present, the configuration is compliant. \\n 2.Find the directory in which the ScoreBoardFile would be created. The default value is the ServerRoot/logs directory. \\n 3. Verify that the scoreboard file directory is not a directory within the Apache DocumentRoot. \\n 4. Verify that the ownership and group of the directory is root:root (or the user under which Apache initially starts up if not root). \\n 5. Change the permissions so that the directory is only writable by root (or the startup user if not root). \\n 6. Check that the scoreboard file directory is on a locally mounted hard drive rather than an NFS mounted file system." evidencia[]="$scoreConf" evidencia[]="$PerFil" evidencia[]="$PerFilGP" evidencia[]="$PerRW" estado="$resultado")
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
   sal_311=$(jo id="3.11 Ensure Group Write Access for the Apache Directories and Files Is Properly Restricted" descripcion="Group permissions on Apache directories should generally be r-x and file permissions should be similar except not executable if executable is not appropriate. This applies to all of the Apache software directories and files installed with the possible exception of the web document root $DOCROOT defined by Apache DocumentRoot and defaults to $APACHE_PREFIX/htdocs. The directories and files in the web document root may have a designated web development group with write access to allow web content to be updated." como_cumplirlo="Restricting write permissions on the Apache files and directories can help mitigate attacks that modify web content to provide unauthorized access, or to attack web clients." evidencia="$(find -L $APACHE_PREFIX \! -type l -perm /g=w -ls | head -1)" estado="$resultado")
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
   sal_312=$(jo id="3.12 Ensure Group Write Access for the Document Root Directories and Files Is Properly Restricted" descripcion="Group permissions on Apache Document Root directories $DOCROOT may need to be writable by an authorized group such as development, support, or a production content management tool. However, it is important that the Apache group used to run the server does not have write access to any directories or files in the document root." como_cumplirlo="Preventing Apache from writing to the web document root helps mitigate risk associated with web application vulnerabilities associated with file uploads or command execution. Typically, if an application hosted by Apache needs to write to directory, it is best practice to have that directory live outside the web root." evidencia="$(find -L $APACHE_PREFIX -group $GRP -perm /g=w -ls | head -1)" estado="$resultado")
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
