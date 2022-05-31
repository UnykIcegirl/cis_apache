#!/bin/sh

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 5
# Fecha: 21/05/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

##### MODULO 5
function Mod5_1(){
   echo -e "\n\n\n 5.1 Ensure Options for the OS Root Directory Are Restricte"
   echo    "===================================================================="
   ((++total))

   param1=$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep Directory |wc -l)
   param2=$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep "Options None" |wc -l)

   output=$(expr $param1 / 2)
   #echo $output

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ $output != $param2 ] ; then
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_51=$(jo id="5.1 Ensure Options for the OS Root Directory Are Restricte" descripcion="The Apache Options directive allows for specific configuration of options, including execution of CGI, following symbolic links, server side includes, and content negotiation." como_cumplirlo="The Options directive for the root OS level is used to create a default minimal options policy that allows only the minimal options at the root directory level. Then for specific web sites or portions of the web site, options may be enabled as needed and appropriate. No options should be enabled and the value for the Options directive should be None." evidencia="Existen $output 'Directory' y existen $param2 'Options None'" estado="$resultado")
   #echo -e "\n \n $sal_51"

}

function Mod5_2(){
   echo -e "\n\n\n 5.2 Ensure Options for the Web Root Directory Are Restricted"
   echo    "======================================================================"
   ((++total))

   param1=$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i Directory |wc -l)
   param2=$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options None" |wc -l)
   param3=$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options Multiviews" |wc -l)


   output=`expr $param1 / 2`
   #echo $output

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ $output != $param2 ] || [ $output != $param3 ] ; then
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_52=$(jo id="5.2 Ensure Options for the Web Root Directory Are Restricted" descripcion="The Apache Options directive allows for specific configuration of options, including: * Execution of CGI  * Following symbolic links  * Server side includes  * Content negotiation" como_cumplirlo="The Options directive at the web root or document root level also needs to be restricted to the minimal options required. A setting of None is highly recommended, however it is recognized that this level content negotiation may be needed if multiple languages are supported. No other options should be enabled. Add or modify any existing Options directive to have a value of None or Multiviews." evidencia="Existen $output 'Directory', existen $param2 'Options None' y  existen $param3 'Options Multiviews'" estado="$resultado")
   #echo -e "\n \n $sal_52"

}

function Mod5_3(){
   echo -e "\n\n\n 5.3 Ensure Options for Other Directories Are Minimized"
   echo    "===================================================================="
   ((++total))

   output=$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options Includes" | wc -l)

   #echo $output

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] ; then
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON ---------------------------
   sal_53=$(jo id="5.3 Ensure Options for Other Directories Are Minimized" descripcion="The Apache Options directive allows for specific configuration of options, including execution of CGI, following symbolic links, server side includes, and content negotiation." como_cumplirlo="Likewise, the options for other directories and hosts needs to be restricted to the minimal options required. A setting of None is recommended, however it is recognized that other options may be needed in some cases. Add or modify any existing Options directive to NOT have a value of Includes. Other options may be set if necessary and appropriate as described above." evidencia="$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options Includes")" estado="$resultado")
   #echo -e "\n \n $sal_53"

}

function Mod5_4(){
   echo -e "\n\n\n 5.4 Ensure Default HTML Content Is Removed"
   echo    "======================================================="
   ((++total))

   param=$(rpm -q httpd-manual | grep "no está instalado" | wc -l) 2>/dev/null
   param2=$(grep -i -A 0 '#<LocationMatch ' $APACHE_PREFIX/conf.d/welcome.conf| wc -l)
   param3=$(grep -i -A 0 '#<Location /server-status' $dirConf | wc -l)
   param31=$(grep -i -A 0 '<Location /server-status' $dirConf)
   param4=$(grep -i -A 0  '#<Location /perl-status' $dirConf | wc -l)
   param41=$(grep -i -A 0  '<Location /perl-status' $dirConf)
   output=0
   echo "param4: $param41"

   if [ "$param" = 0 ] ; then
      output=1
   fi
   if [ "$param2" = 0 ] ; then
      output=1
   fi
   if [ "$param3" = 0 ] && [ "$param31" != "$no_existe" ] ; then
      output=1
   fi
   if [ "$param4" = 0 ] && [ "$param41" != "$no_existe" ] ; then
      output=1
   fi
   
   #echo $output
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != 0 ] ; then
      #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
      #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_54=$(jo id="5.4 Ensure Default HTML Content Is Removed" descripcion="Apache installations have default content that is not needed or appropriate for production use. The primary function for this sample content is to provide a default web site, provide user manuals or to demonstrate special features of the web server. All content that is not needed should be removed." como_cumplirlo="Review all pre-installed content and remove content which is not required. In particular look for the unnecessary content which may be found in the document root directory, a configuration directory such as conf/extra directory, or as a Unix/Linux package." evidencia[]="Paquete httpd-manual: $(rpm -q httpd-manual)" evidencia[]="$(grep -i -A 0 '<LocationMatch' $APACHE_PREFIX/conf.d/welcome.conf)" evidencia[]="$(grep -i '<Location /server-status' $dirConf)" evidencia[]="$(grep -i '<Location /perl-status' $dirConf)" estado="$resultado")
   #echo -e "\n \n $sal_54"

}

function Mod5_5(){
   echo -e "\n\n\n 5.5 Ensure the Default CGI Content printenv Script Is Removed"
   echo    "======================================================================="
   ((++total))

   param=$(grep -i -A 0 '#ScriptAlias /cgi-bin/' $dirConf |wc -l)
   param2=$(find $APACHE_PREFIX -name printenv |wc -l)
   output=0

   if [ "$param" = 0 ] ; then
      output=1
   fi
   if [ "$param2" != 0 ] ; then
      output=1
   fi
   
   #echo $output
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" = 0 ] ; then
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON ---------------------------
   sal_55=$(jo id="5.5 Ensure the Default CGI Content printenv Script Is Removed" descripcion="Most Web Servers, including Apache installations have default CGI content which is not needed or appropriate for production use. The primary function for these sample programs is to demonstrate the capabilities of the web server. One common default CGI content for Apache installations is the script printenv. This script will print back to the requester all of the CGI environment variables which includes many server configuration details and system paths." como_cumplirlo="Perform the following to determine if the recommended state is implemented:  1. Locate cgi-bin files and directories enabled in the Apache configuration via Script, ScriptAlias or ScriptAliasMatch or ScriptInterpreterSource directives.  2. Ensure the printenv CGI is not installed in any configured cgi-bin directory." evidencia[]="$(grep -i -A 0 'ScriptAlias /cgi-bin/' $dirConf)" evidencia[]="$(find $APACHE_PREFIX -name printenv)" estado="$resultado")
   #echo -e "\n \n $sal_55"

}

function Mod5_6(){
   echo -e "\n\n\n 5.6 Ensure the Default CGI Content test-cgi Script Is Removed"
   echo    "======================================================================="
   ((++total))

   output1=$(find $APACHE_PREFIX -name cgi-bin)
   output2=$(find $APACHE_PREFIX -name test-cgi)

   #echo $output1
   #echo $output2

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output1" != "" ] || [ "$output2" != "" ] ; then
       #echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       #echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_56=$(jo id="5.6 Ensure the Default CGI Content test-cgi Script Is Removed" descripcion="Most Web Servers, including Apache installations have default CGI content which is not needed or appropriate for production use. The primary function for these sample programs is to demonstrate the capabilities of the web server. A common default CGI content for Apache installations is the script test-cgi. This script will print back to the requester CGI environment variables which includes many server configuration details." como_cumplirlo="Perform the following to determine if the recommended state is implemented:  1. Locate cgi-bin files and directories enabled in the Apache configuration via Script, ScriptAlias or ScriptAliasMatch other ScriptInterpreterSource directives.  2. Ensure the test-cgi script is not installed in any configured cgi-bin directory." evidencia[]="$(find $APACHE_PREFIX -name cgi-bin)"  evidencia[]="$(find $APACHE_PREFIX -name test-cgi)" estado="$resultado")
   #echo -e "\n \n $sal_56"

}

function Mod5_7(){
   echo -e "\n\n\n 5.7 Ensure HTTP Request Methods Are Restricted"
   echo    "========================================================"
   ((++total))
  
   # No. de bloques Directory a configurar
   param1=$(awk '/^.Directory/{p=1}/^.\/Directory./{p=0;print}p' "$dirConf" | grep -i Directory | wc -l)
   output=$(expr $param1 / 2)
   # La configuracion de LimitExcept que se busca
   param2=$(awk '/^.Directory/{p=1}/^.\/Directory./{p=0;print}p' "$dirConf" | grep -i -1 "^\s*<LimitExcept GET POST OPTIONS>" | grep -i "^\s*Require all denied" | wc -l)

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != $param2 ] ; then
   #    echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
   #    echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_57=$(jo id="5.7 Ensure HTTP Request Methods Are Restricted" descripcion="Use the Apache <LimitExcept> directive to restrict unnecessary HTTP request methods of the web server to only accept and process the GET, HEAD, POST and OPTIONS HTTP request methods." como_cumplirlo="The HTTP 1.1 protocol supports several request methods which are rarely used and potentially high risk. For example, methods such as PUT and DELETE are rarely used and should be disabled in keeping with the primary security principal of minimize features and options. Also since the usage of these methods is typically to modify resources on the web server, they should be explicitly disallowed. For normal web server operation, you will typically need to allow only the GET, HEAD and POST request methods." evidencia="$(awk '/^.Directory/{p=1}/^.\/Directory./{p=0;print}p' "$dirConf" | grep -i -1 "^\s*<LimitExcept GET POST OPTIONS>" | grep -i "^\s*Require all denied")" estado="$resultado")
   #echo -e "\n \n $sal_57"

}

function Mod5_8(){
   echo -e "\n\n\n 5.8 Ensure the HTTP TRACE Method Is Disabled"
   echo    "====================================================="
   ((++total))

   output=$(grep -i "^\s*TraceEnable" "$dirConf" | awk '{print $2}')

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$output" != "off" ] ; then
       # print the reason why we are failing
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON ---------------------------
   sal_58=$(jo id="5.8 Ensure the HTTP TRACE Method Is Disabled" descripcion="Use the Apache TraceEnable directive to disable the HTTP TRACE request method." como_cumplirlo="The HTTP 1.1 protocol requires support for the TRACE request method which reflects the request back as a response and was intended for diagnostics purposes. The TRACE method is not needed and is easily subjected to abuse and should be disabled." evidencia="$(grep -i "^\s*TraceEnable" "$dirConf")" estado="$resultado")
   #echo -e "\n \n $sal_58"

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
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$lodedmodule" != ""  ] &&  [ "$engine" == "on" ] && [ "$cond1" != ""  ] && [ "$rule" != ""  ]; then 
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

   # JSON ---------------------------
   sal_59=$(jo id="5.9 Ensure Old HTTP Protocol Versions Are Disallowed" descripcion="The Apache modules mod_rewrite or mod_security can be used to disallow old and invalid HTTP protocols versions. The HTTP version 1.1 RFC is dated June 1999 and has been supported by Apache since version 1.2. It should no longer be necessary to allow ancient versions of HTTP such as 1.0 and prior." como_cumplirlo="Perform the following to determine if the recommended state is implemented:  1. Locate the Apache configuration files and included configuration files.  2. Verify there is a rewrite condition within the global server context that disallows requests that do not include the HTTP/1.1 header.  3. Verify the following directives are included in each section so that the main server settings will be inherited." evidencia[]="$lodedmodule" evidencia[]="$engine" evidencia[]="$cond1" evidencia[]="$rule" estado="$resultado")
   #echo -e "\n \n $sal_59"

}

function Mod5_10(){
   echo -e "\n\n\n 5.10 Ensure Access to .ht* Files Is Restricted"
   echo    "========================================================="
   ((++total))

   filesmatch=$(grep -i "^\s*<FilesMatch\s\"^\\\\\.ht\">" "$dirConf")
   filesmatch2=$(grep -i "^\s*<FilesMatch\s\"^\.\*\\$\">" "$dirConf")
   require=$(grep -i "^\s*Require all denied" "$dirConf") 

   engine=$(echo "$engine" | awk '{print tolower($0)}')
   
   local resultado
   # we captured output of the subshell, let's interpret it
   if ([ "$filesmatch" != ""  ] ||  [ "$filesmatch2" != "" ]) && [ "$require" != "" ]; then 
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

   # JSON ---------------------------
   sal_510=$(jo id="5.10 Ensure Access to .ht* Files Is Restricted" descripcion="Restrict access to any files beginning with .ht using the FilesMatch directive." como_cumplirlo="Verify that a FilesMatch directive similar to the one below is present in the apache configuration and not commented out. The deprecated Deny from All directive may be used instead of the Require directive." evidencia[]="$filesmatch" evidencia[]="$filesmatch2" evidencia[]="$require" estado="$resultado")
   #echo -e "\n \n $sal_510"

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

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$filesmatch" != ""  ] && [ "$filesmatch2" != "" ] && [ "$require" != "" ] && [ "$require2" != "" ]; then 
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

   # JSON ---------------------------
   sal_511=$(jo id="5.11 Ensure Access to Inappropriate File Extensions Is Restricted" descripcion="Restrict access to inappropriate file extensions that are not expected to be a legitimate part of web sites using the FilesMatch directive." como_cumplirlo="Perform the following steps to determine if the recommended state is implemented:  1. Verify that the FilesMatch directive that denies access to all files is present as shown in step 3 of the remediation.  2. Verify that there is another FilesMatch directive similar to the one in step 4 of the remediation, with an expression that matches the approved file extensions." evidencia[]="$filesmatch" evidencia[]="$filesmatch2" evidencia[]="$(grep -i "^\s*Require all denied" "$dirConf" | head -1)" evidencia[]="$(grep -i "^\s*Require all granted" "$dirConf" | head -1)" estado="$resultado")
   #echo -e "\n \n $sal_511"

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

   local resultado
   # we captured output of the subshell, let's interpret it
   if [ "$lodedmodule" != ""  ] &&  [ "$engine" == "on" ] && [ "$cond1" != ""  ] && [ "$cond2" != "" ] && [ "$rule" != ""  ]; then 
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

   # JSON ---------------------------
   sal_512=$(jo id="5.12 Ensure IP Address Based Requests Are Disallowed" descripcion="The Apache module mod_rewrite can be used to disallow access for requests that use an IP address instead of a host name for the URL. Most normal access to the website from browsers and automated software will use a host name which will therefore include the host name in the HTTP HOST header." como_cumplirlo="Locate the Apache configuration files and included configuration files. Verify there is a rewrite condition within the global server context that disallows IP based requests by requiring a HTTP HOST header similar to the example shown below." evidencia[]="$lodedmodule" evidencia[]="$engine" evidencia[]="$cond1" evidencia[]="$cond2" evidencia[]="$rule" estado="$resultado")
   #echo -e "\n \n $sal_512"

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
    
   local resultado
   # we captured output of the subshell, let's interpret it
   if [[ "$good" == ${#output[@]} ]]; then
   #   echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       # print the reason why we are failing
   #   echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON ---------------------------
   sal_513=$(jo id="5.13 Ensure the IP Addresses for Listening for Requests Are Specified" descripcion="The Apache Listen directive specifies the IP addresses and port numbers the Apache web server will listen for requests. Rather than be unrestricted to listen on all IP addresses available to the system, the specific IP address or addresses intended should be explicitly specified. Specifically, a Listen directive with no IP address specified, or with an IP address of zeros should not be used." como_cumplirlo="Perform the following steps to determine if the recommended state is implemented:  Verify that no Listen directives are in the Apache configuration file with no IP address specified, or with an IP address of all zeros." evidencia="$output" estado="$resultado")
   #echo -e "\n \n $sal_513"

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

   local resultado
   # we captured output of the subshell, let's interpret it   
   if [ "$bandera" = 1 ] ; then
       #echo "pass"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       #echo "fallo"
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON ---------------------------
   sal_514=$(jo id="5.14 Ensure Browser Framing Is Restricted" descripcion="To prevent Clickjacking or UI Redressing attacks, it’s important for the server to include an HTTP header which instructs browsers to restrict the content from being framed. There are two headers that may be used. The Content-Security-Policy header, or the X-Frame-Options header. The Header directive allows server HTTP response headers to be added, replaced or merged. We will use the directive to add a server HTTP response header to tell browsers to restrict all of the web pages from being framed by other web sites." como_cumplirlo="Ensure a Header directive for Content-Security-Policy is present in the Apache configuration and has the condition always, an action of set or append and a directive of frame-ancestors with a value of none or self. If no Content-Security-Policy header is found, check if a header directive for X-Frame-Options is present in the Apache configuration and has the condition always, an action of set or append and a value of SAMEORIGIN or DENY. If either header configuration is present and has as a compliant value, then the server is compliant." evidencia="$output" estado="$resultado")
   #echo -e "\n \n $sal_514"

}



function mod5(){
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


   sal_mod5="$sal_51, $sal_52, $sal_53, $sal_54, $sal_55, $sal_56, $sal_57, $sal_58, $sal_59, $sal_510, $sal_511, $sal_512, $sal_513, $sal_514"

   echo -e "\n\n $sal_mod5"
   
}

mod5
