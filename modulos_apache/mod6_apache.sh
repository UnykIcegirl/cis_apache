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
   sal_61=$(jo id="The LogLevel directive is used to configure the severity level for the error logs. While the ErrorLog directive configures the error log file name. The log level values are the standard syslog levels of emerg, alert, crit, error, warn, notice, info and debug. The recommended level is notice for most modules, so that all errors from the emerg level through notice level will be logged. The recommended setting for the core module is info so that any not found requests will be included in the error logs." descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
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
   sal_62=$(jo id="2.2 Ensure the Log Config Module Is Enabled" descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
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
   sal_63=$(jo id="2.2 Ensure the Log Config Module Is Enabled" descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
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
   sal_64=$(jo id="2.2 Ensure the Log Config Module Is Enabled" descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
   #echo -e "$sal_64"

}

function Mod6_6(){
   echo -e "\n\n\n 6.6 Ensure ModSecurity Is Installed and Enabled"
   echo    "=========================================================="
   ((++total))

   output=$(httpd -M | grep -i security2_module)
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
   sal_66=$(jo id="2.2 Ensure the Log Config Module Is Enabled" descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
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
   paranoia=$(find $RULE_DIR -name '*.conf' | xargs egrep -v '^\s*#' | grep -i  "setvar:'tx.outbound_anomaly_score_threshold" | cut -d"=" -f2 | sed "s/'\"//g")
   
   
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
   sal_67=$(jo id="2.2 Ensure the Log Config Module Is Enabled" descripcion="The log_config module provides for flexible logging of client requests, and provides for the configuration of the information in each log" como_cumplirlo="If the module is correctly enabled, the output will include the module name and whether it is loaded statically or as a shared module" evidencia="$variable" estado="$resultado")
   #echo -e "$sal_67"

}

function mod6(){
   # MODULO 6
   #++++++++++
   Mod6_1

   sal_mod6="$sal_61"

   #echo -e "\n\n $sal_mod6"
   
}

mod6
