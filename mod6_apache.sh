#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 6
# Fecha: 29/05/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 6
function Mod6_1(){
   echo -e "\n\n\n 6.1 Ensure the Error Log Filename and Severity Level Are Configured Correctly"
   echo    "======================================================================================="
   ((++total))

   loglevel=$(grep -i \^LogLevel "$dirConf" | awk '{print $2}')
   loglevelcore=$(grep -i \^LogLevel.*core:info "$dirConf")
   errorlog=$(grep -i \^ErrorLog "$dirConf")
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if ([ "$loglevel" == "info" ] || [ "$loglevelcore" != "" ]) && [ "$errorlog" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   nombre="6.1 Ensure the Error Log Filename and Severity Level Are Configured Correctly"
   descripcion="The LogLevel directive is used to configure the severity level for the error logs. While the ErrorLog directive configures the error log file name. The log level values are the standard syslog levels of emerg, alert, crit, error, warn, notice, info and debug. The recommended level is notice for most modules, so that all errors from the emerg level through notice level will be logged. The recommended setting for the core module is info so that any not found requests will be included in the error logs."
   remediacion="Perform the following to implement the recommended state:   1. Add or modify the LogLevel in the Apache configuration to have a value of info or lower for the core module and notice or lower for all other modules. Note that is it is compliant to have a value of info or debug if there is a need for a more verbose log and the storage and monitoring processes are capable of handling the extra load. The recommended value is notice core:info.  LogLevel notice core:info   2. Add an ErrorLog directive if not already configured. The file path may be relative or absolute, or the logs may be configured to be sent to a syslog server.  ErrorLog \"logs/error_log\"   3. Add a similar ErrorLog directive for each virtual host configured if the virtual host will have different people responsible for the web site. Each responsible individual or organization needs access to their own web logs and needs the skills/training/tools for monitoring the logs."
   evid2="$(getEvidencia "1" "$loglevelcore")"
   evid3="$(getEvidencia "1" "$errorlog")"

   sal_61=$(getJsonEv3 "$nombre" "$descripcion" "$remediacion" "$resultado" "Nivel de log: $evidencia" "$evid2" "$evid3")
   #echo -e "$sal_61"
}

function Mod6_2(){
   echo -e "\n\n\n 6.2 Ensure a Syslog Facility Is Configured for Error Logging"
   echo    "======================================================================="
   ((++total))

   errorlog=$(grep -i \^\s*ErrorLog.*syslog:local1\" "$dirConf")
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$errorlog" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   nombre="6.2 Ensure a Syslog Facility Is Configured for Error Logging"
   descripcion="The ErrorLog directive should be configured to send logs to a syslog facility so that the logs can be processed and monitored along with the system logs."
   remediacion="Perform the following to implement the recommended state:   1. Add an ErrorLog directive if not already configured. Any appropriate syslog facility may be used in place of local1. ErrorLog \"syslog:local1\"   2. Add a similar ErrorLog directive for each virtual host if necessary."
   evidencia="$(getEvidencia "1" "$errorlog")"

   sal_62=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "$sal_62"

}

function Mod6_3(){
   echo -e "\n\n\n 6.3 Ensure the Server Access Log Is Configured Correctly"
   echo    "==================================================================="
   ((++total))

   logformat=$(grep -i "^\s*LogFormat\s\"\(%[h,l,u,t]\s\)\{4\}\\\\\"\%r\\\\\"\s\%>s\s\%b\s\\\\\"\%{Referer}i\\\\\"\s\\\\\"\%{User-Agent}i\\\\\"\"\scombined" "$dirConf")
   customlog=$(grep -i \^\\s*CustomLog.*combined  "$dirConf")
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$logformat" != "" ] && [ "$customlog" != "" ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   nombre="6.3 Ensure the Server Access Log Is Configured Correctly"
   descripcion="The LogFormat directive defines a nickname for a log format and information to be included in the access log entries. The CustomLog directive specifies the log file, syslog facility or piped logging utility."
   remediacion="Perform the following to implement the recommended state:   1. Add or modify the LogFormat directives in the Apache configuration to use the combined format show as shown below.  LogFormat \"%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"\" combined   2. Add or modify the CustomLog directives in the Apache configuration to use the combined format with an appropriate log file, syslog facility or piped logging utility.  CustomLog log/access_log combined   3. Add a similar CustomLog directives for each virtual host configured if the virtual host will have different people responsible for the web site. Each responsible individual or organization needs access to their own web logs as well as the skills/training/tools for monitoring the logs."
   evid2="$(getEvidencia "1" "$customlog")"
   #"La configuración de formato de log: $(grep -i "^\s*LogFormat\s.*combined" "$dirConf" | tr '\n' ' ')"

   sal_63=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evid2")
   #echo -e "$sal_63"

}

function Mod6_4(){
   echo -e "\n\n\n 6.4 Ensure Log Storage and Rotation Is Configured Correctly"
   echo    "======================================================================"
   ((++total))

   logrotate=$(grep -i "^\s*/bin/kill -HUP 'cat /var/run/httpd.pid 2>/dev/null' 2> /dev/null || true" /etc/logrotate.d/httpd)
   weekly=$(grep -i ^weekly /etc/logrotate.conf)
   rotate=$(grep -i ^rotate /etc/logrotate.conf | awk '{print $2}')
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$logrotate" != "" ] && [ "$weekly" != ""  ] && [ $rotate -ge 13  ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   nombre="6.4 Ensure Log Storage and Rotation Is Configured Correctly"
   descripcion="It is important that there is adequate disk space on the partition that will hold all the log files, and that log rotation is configured to retain at least 3 months or 13 weeks if central logging is not used for storage."
   remediacion="To implement the recommended state, do either option 'a' if using the Linux logrotate utility or option 'b' if using a piped logging utility such as the Apache rotatelogs:  a) File Logging with Logrotate:   1. Add or modify the web log rotation configuration to match your configured log files in /etc/logrotate.d/httpd to be similar to the following.  /var/log/httpd/*log {     missingok    notifempty    sharedscripts     postrotate    /bin/kill -HUP 'cat /var/run/httpd.pid 2>/dev/null' 2> /dev/null || true     endscript }    2. Modify the rotation period and number of logs to keep so that at least 13 weeks or 3 months of logs are retained. This may be done as the default value for all logs in /etc/logrotate.conf or in the web specific log rotation configuration in /etc/logrotate.d/httpdto be similar to the following.  # rotate log files weekly weekly # keep 13 weeks of backlogs rotate 13    3. For each virtual host configured with its own log files ensure that those log files are also included in a similar log rotation.   b) Piped Logging:    1. Configure the log rotation interval and log file names to a suitable interval such as daily. CustomLog \"|bin/rotatelogs -l /var/logs/logfile.%Y.%m.%d 86400\" combined   2. Ensure the log file naming and any rotation scripts provide for retaining at least 3 months or 13 weeks of log files.   3. For each virtual host configured with its own log files ensure that those log files are also included in a similar log rotation."
   evidencia="$(getEvidencia "1" "$logrotate")"
   evid2="$(getEvidencia "1" "$weekly")"

   sal_64=$(getJsonEv3 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "Configuración de la rotación de log: $rotate")
   #echo -e "$sal_64"

}

function Mod6_6(){
   echo -e "\n\n\n 6.6 Ensure ModSecurity Is Installed and Enabled"
   echo    "=========================================================="
   ((++total))

   output=$(httpd -M | grep -i security2_module || apachectl -M | grep -i security2_module)
   #echo $output

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != "" ] ; then
      # echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
      # echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   nombre="6.6 Ensure ModSecurity Is Installed and Enabled"
   descripcion="ModSecurity is an open source web application firewall (WAF) for real-time web application monitoring, logging, and access control. It enables but does not include a powerful customizable rule set, which may be used to detect and block common web application attacks. Installation of ModSecurity without a rule set does not provide additional security for the protected web applications. Refer to the benchmark recommendation "Install and Enable OWASP ModSecurity Core Rule Set" for details on a recommended rule set."
   remediacion=" 1. Install the ModSecurity module if it is not already installed in modules/mod_security2.so. It may be installed via OS package installation (such as apt-get or yum) or built from the source files. See https://www.modsecurity.org/download.html for details.   2. Add or modify the LoadModule directive if not already present in the Apache configuration as shown below. Typically, the LoadModule directive is placed in file named mod_security.conf which is included in the Apache configuration:  LoadModule security2_module modules/mod_security2.so"
   evidencia="$(getEvidencia "1" "$output")"

   sal_66=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
   #echo -e "$sal_66"

}

function Mod6_7(){
   echo -e "\n\n\n 6.7 Ensure the OWASP ModSecurity Core Rule Set Is Installed and Enabled"
   echo    "=============================================================================="
   ((++total))

   RULE_DIR="$APACHE_PREFIX"/modsecurity.d/owasp-modsecurity-crs
   
   rulecount=$(find $RULE_DIR -name '*.conf' | xargs grep -i '^SecRule ' | wc -l)
   inanomaly=$(find $RULE_DIR -name '*.conf' | xargs egrep -v '^\s*#' | grep -i  "setvar:'tx.inbound_anomaly_score_threshold" | cut -d"=" -f2 | sed "s/'\"//g")
   outanomaly=$(find $RULE_DIR -name '*.conf' | xargs egrep -v '^\s*#' | grep -i  "setvar:'tx.outbound_anomaly_score_threshold" | cut -d"=" -f2 | sed "s/'\"//g")
   paranoia=$(find $RULE_DIR -name '*.conf' | xargs egrep -v '^\s*#' | grep -i  "setvar:tx.paranoia_level" | cut -d"=" -f2 | sed "s/'\"//g")
   
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ $rulecount -gt 325 ] && [ $inanomaly -le 5 ] && [ $outanomaly -le 4 ] && [ $paranoia -ge 1 ]; then 
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON -------------------
   nombre="6.7 Ensure the OWASP ModSecurity Core Rule Set Is Installed and Enabled"
   descripcion="The OWASP ModSecurity Core Rules Set (CRS) is a set of open source web application defensive rules for the ModSecurity web application firewall (WAF). The OWASP ModSecurity CRS provides baseline protections in the following attack/threat categories: * HTTP Protection - detecting violations of the HTTP protocol and a locally defined usage policy. * Real-time Blacklist Lookups - utilizes 3rd Party IP Reputation * HTTP Denial of Service Protections - defense against HTTP Flooding and Slow HTTP DoS Attacks. * Common Web Attacks Protection - detecting common web application security attack. * Automation Detection - detecting bots, crawlers, scanners and other surface malicious activity. * Integration with AV Scanning for File Uploads - detects malicious files uploaded through the web application. * Tracking Sensitive Data - tracks credit card usage and blocks leakages. * Trojan Protection - detecting access to trojan horses. * Identification of Application Defects - alerts on application misconfigurations. * Error Detection and Hiding - disguising error messages sent by the server."
   remediacion="Install, configure and test the OWASP ModSecurity Core Rule Set:   1. Download the OWASP ModSecurity CRS from the project page https://www.owasp.org/index.php/Category:OWASP_ModSecurity_Core_Rule_Set_Project   2. Unbundled the archive and follow the instructions in the INSTALL file.   3. Depending on the CRS version used, the crs-setup.conf or the modsecurity_crs_10_setup.conf file will be required, and rules in the base_rules directory are intended as a baseline useful for most applications.   4. Test the application for correct functionality after installing the CRS. Check web server error logs and the modsec_audit.log file for blocked requests due to false positives.   5. It is also recommended to test the application response to malicious traffic such as an automated web application scanner to ensure the rules are active. The web server error log and modsec_audit.log files should show logs of the attacks and the servers response codes."
   local evidencia="Configuración de RULE_DIR: $rulecount"
   local evid2="Configuración del umbral de anomalía de entrada: $inanomaly" 
   local evid3="Configuración del umbral de anomalía de salida: $outanomaly"
   local evid4="Configuración del nivel de paranoia:  $paranoia"

   sal_67=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3" "$evid4")
   #echo -e "$sal_67"

}

function mod6(){
   # MODULO 6
   #++++++++++
   Mod6_1
   Mod6_2
   Mod6_3
   Mod6_4
   Mod6_6
   Mod6_7

   sal_mod6="$sal_61, $sal_62, $sal_63, $sal_64, $sal_66, $sal_67"
   #echo -e "\n\n $sal_mod6"
   
}

mod6
