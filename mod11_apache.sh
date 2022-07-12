#!/usr/bin/env bash

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 11
# Fecha: 15/06/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 11
function Mod11_1(){
   echo -e "\n\n\n 11.1 Ensure SELinux Is Enabled in Enforcing Mode"
   echo    "=========================================================="
   ((++total))

   output=$(sestatus | grep -i mode)
   cuenta=$(sestatus | grep -i -c "mode")
   
   #echo $cuenta
   #echo $output
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$cuenta" -eq 2 ]; then
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   id="APH-GS-CSA-70"
   nombre="11.1 Ensure SELinux Is Enabled in Enforcing Mode"
   descripcion="SELinux (Security-Enhanced Linux) is a Linux kernel security module that provides mandatory access control security policies with type enforcement that are checked after the traditional discretionary access controls. It was created by the US National Security Agency and can enforce rules on files and processes in a Linux system, and restrict actions, based on defined policies."
   remediacion="Perform the following to implement the recommended state:   If SELinux is not enabled in the configuration file, edit the file /etc/selinux/config and set the value of SELINUX as enforcing and reboot the system for the new configuration to be effective.  SELINUX=enforcing   If the current mode is not enforcing, and an immediate reboot is not possible, the current mode can be set to enforcing with the setenable command shown below.  # setenforce 1"
   evidencia="Configuración del módulo SELinux: $(sestatus | grep -i mode | head -1)"

   sal_111=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")" "$id" )
   #echo -e "\n \n $sal_111"
}

function Mod11_2(){
   echo -e "\n\n\n 11.2 Ensure Apache Processes Run in the httpd_t Confined Context"
   echo    "=========================================================================="
   ((++total))

   output=$(ps -eZ | grep -i httpd)
   cuenta=$(ps -eZ | grep -i -c "httpd")
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [[ "$output" == *"httpd_t"* ]] ; then
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   id="APH-GS-CSA-71"
   nombre="11.2 Ensure Apache Processes Run in the httpd_t Confined Context"
   descripcion="SELinux includes customizable targeted policies that may be used to confine the Apache httpd server to enforce least privileges so that the httpd server has only the minimal access to specified directories, files and network ports. Access is controlled by process types (domains) defined for the httpd process. There are over a hundred individual httpd related types defined in a default Apache SELinux policy which includes many of the common Apache add-ons and applications such as php, nagios, smokeping and many others. The default SELinux policies work well for a default Apache installation, but implementation of SELinux targeted polices on a complex or highly customized web server requires a rather significant development and testing effort which comprehends both the workings of SELinux and the detailed operations and requirements of the web application.  All directories and files to be accessed by the web server process must have security labels with appropriate types. The following types are a sample of the most commonly used: - http_port_t - Network ports allowed for listening  - httpd_sys_content_t - Read access to directories and files with web content  - httpd_log_t - Directories and files to be used for writable log data  - httpd_sys_script_exec_t - Directories and files for executable content."
   remediacion="If the running httpd processes are not confined to the httpd_t SELinux context. Then check the context for the httpd binary and the apachectl binary and set the httpd binary to have a context of httpd_exec_t and the apachectl executable should have a context of initrc_exec_t as shown below. Also note that on some platforms such as Ubuntu, the Apache executable is named apache2 instead of httpd.  # ls -alZ /usr/sbin/httpd /usr/sbin/httpd.* /usr/sbin/apachectl  If the executable files are not labeled correctly, they may be relabeled with the chcon command, as shown, however the file system labeling is based on the SELinux file context polices and the file systems will on some occasions be relabeled according to the policy.  # chcon -t initrc_exec_t /usr/sbin/apachectl  # chcon -t httpd_exec_t /usr/sbin/httpd /usr/sbin/httpd.*   Since the file system may be relabeled based on SELinux policy, it's best to check the SELinux policy with semanage fcontext -l option. If the policy is not present, then add the pattern to the policy using the -a option. The restorecon command shown below will restore the file context label according to the current policy, which is required if a pattern was added.  # ### Check the Policy   # semanage fcontext -l | fgrep 'apachectl'  # semanage fcontext -l | fgrep '/usr/sbin/httpd'  # ### Add to the policy, if not present  # semanage fcontext -f -- -a -t httpd_exec_t '/usr/sbin/httpd'  # semanage fcontext -f -- -a -t httpd_exec_t '/usr/sbin/httpd.worker'  # semanage fcontext -f -- -a -t httpd_exec_t '/usr/sbin/httpd.event'  # semanage fcontext -f -- -a -t initrc_exec_t /usr/sbin/apachectl     # ### Restore the file labeling accord to the SELinux policy  # restorecon -v /usr/sbin/httpd /usr/sbin/httpd.* /usr/sbin/apachectl"
   evidencia="La configuración de las políticas de Apache http es: $(ps -eZ | grep -i httpd | head -1)"

   sal_112=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_112"
}

function Mod11_3(){
   echo -e "\n\n\n 11.3 Ensure the httpd_t Type is Not in Permissive Mode"
   echo    "================================================================"
   ((++total))

   output=$(semodule -l | grep -i permissive_httpd_t)
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" == "" ] ; then
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   id="APH-GS-CSA-72"
   nombre="11.3 Ensure the httpd_t Type is Not in Permissive Mode"
   descripcion="In addition to setting the entire SELinux configuration in permissive mode, it is possible to set individual process types (domains) such as httpd_t into a permissive mode as well. The permissive mode will not prevent any access or actions, instead, any actions that would have been denied are simply logged."
   remediacion="Perform the following to implement the recommended state:   If the httpd_t type is in permissive mode; the customized permissive mode should be deleted with the following semanage command.  # semanage permissive -d httpd_t"
   evidencia="$(getEvidencia "2" "$output")"

   sal_113=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_113"
}


function mod11(){
   # MODULO 11
   #++++++++++
   Mod11_1
   Mod11_2
   Mod11_3

   sal_mod11="$sal_111, $sal_112, $sal_113"
   #echo -e "\n\n $sal_mod11"
   
}
mod11
