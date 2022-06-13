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
   nombre="5.1 Ensure Options for the OS Root Directory Are Restricte"
   descripcion="The Apache Options directive allows for specific configuration of options, including execution of CGI, following symbolic links, server side includes, and content negotiation."
   remediacion="Perform the following to implement the recommended state:  1. Search the Apache configuration files (httpd.conf and any included configuration files) to find a root <Directory> element.   2. Add a single Options directive if there is none.   3. Set the value for Options to None."

   sal_51=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "Existen $output 'Directory' y existen $param2 'Options None'")
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
   nombre="5.2 Ensure Options for the Web Root Directory Are Restricted"
   descripcion="The Apache Options directive allows for specific configuration of options, including: * Execution of CGI  * Following symbolic links  * Server side includes  * Content negotiation"
   remediacion="Perform the following to implement the recommended state:   1. Search the Apache configuration files (httpd.conf and any included configuration files) to find the document root <Directory> element.   2. Add or modify any existing Options directive to have a value of None or Multiviews, if multiviews are needed."

   sal_52=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "Existen $output 'Directory', existen $param2 'Options None' y  existen $param3 'Options Multiviews'")
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
   nombre="5.3 Ensure Options for Other Directories Are Minimized"
   descripcion="The Apache Options directive allows for specific configuration of options, including execution of CGI, following symbolic links, server side includes, and content negotiation."
   remediacion="Perform the following to implement the recommended state:   1. Search the Apache configuration files (httpd.conf and any included configuration files) to find all <Directory> elements.   2. Add or modify any existing Options directive to NOT have a value of Includes. Other options may be set if necessary and appropriate as described above."
   evidencia="$(getEvidencia "2" "$(perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $dirConf |grep -i "Options Includes")")"

   sal_53=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
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
   nombre="5.4 Ensure Default HTML Content Is Removed"
   descripcion="Apache installations have default content that is not needed or appropriate for production use. The primary function for this sample content is to provide a default web site, provide user manuals or to demonstrate special features of the web server. All content that is not needed should be removed."
   remediacion="Review all pre-installed content and remove content which is not required. In particular look for the unnecessary content which may be found in the document root directory, a configuration directory such as conf/extra directory, or as a Unix/Linux package.   1. Remove the default index.html or welcome page if it is a separate package. If it is part of main Apache httpd package such as it is on Red Hat Linux, then comment out the configuration as shown below. Removing a file such as the welcome.conf, is not recommended as it may get replaced if the package is updated.   2. Remove the Apache user manual content or comment out configurations referencing the manual.   3. Remove or comment out any Server Status handler configuration.   4. Remove or comment out any Server Information handler configuration.   5. Remove or comment out any other handler configuration such as perl-status."
   evidencia="$(getEvidencia "1" "$(rpm -q httpd-manual | grep "no está instalado" )")"
   evid2="$(getEvidencia "1" "$(grep -i -A 0 '<LocationMatch' $APACHE_PREFIX/conf.d/welcome.conf)")"
   evid3="$(getEvidencia "2" "$(grep -i '<Location /server-status' $dirConf)")"
   evid4="$(getEvidencia "2" "$(grep -i '<Location /perl-status' $dirConf)")"

   sal_54=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3" "$evid4")
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
   nombre="5.5 Ensure the Default CGI Content printenv Script Is Removed"
   descripcion="Most Web Servers, including Apache installations have default CGI content which is not needed or appropriate for production use. The primary function for these sample programs is to demonstrate the capabilities of the web server. One common default CGI content for Apache installations is the script printenv. This script will print back to the requester all of the CGI environment variables which includes many server configuration details and system paths."
   remediacion="Perform the following to implement the recommended state:  1. Locate cgi-bin files and directories enabled in the Apache configuration via Script, ScriptAlias, ScriptAliasMatch, or ScriptInterpreterSource directives.   2. Remove the printenvdefault CGI in cgi-bin directory if it is installed.  # rm $APACHE_PREFIX/cgi-bin/printenv"
   evidencia="$(getEvidencia "1" "$(grep -i -A 0 'ScriptAlias /cgi-bin/' $dirConf)")"
   evid2="$(getEvidencia "2" "$(grep -i -A 0 'ScriptAlias /cgi-bin/' $dirConf)")"

   sal_55=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2")
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
   nombre="5.6 Ensure the Default CGI Content test-cgi Script Is Removed"
   descripcion="Most Web Servers, including Apache installations have default CGI content which is not needed or appropriate for production use. The primary function for these sample programs is to demonstrate the capabilities of the web server. A common default CGI content for Apache installations is the script test-cgi. This script will print back to the requester CGI environment variables which includes many server configuration details."
   remediacion="Perform the following to implement the recommended state:   1. Locate cgi-bin files and directories enabled in the Apache configuration via Script, ScriptAlias, ScriptAliasMatch, or ScriptInterpreterSource directives.   2. Remove the test-cgi default CGI in cgi-bin directory if it is installed.  # rm $APACHE_PREFIX/cgi-bin/test-cgi"
   evidencia="$(getEvidencia "2" "$(find $APACHE_PREFIX -name cgi-bin)")"
   evid2="$(getEvidencia "2" "$(find $APACHE_PREFIX -name test-cgi)")"

   sal_56=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2")
   echo -e "\n \n $sal_56"

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
   cmd="$(awk '/^.Directory/{p=1}/^.\/Directory./{p=0;print}p' "$dirConf" | grep -i -1 "^\s*<LimitExcept GET POST OPTIONS>" | grep -i "^\s*Require all denied")"
   nombre="5.7 Ensure HTTP Request Methods Are Restricted"
   descripcion="Use the Apache <LimitExcept> directive to restrict unnecessary HTTP request methods of the web server to only accept and process the GET, HEAD, POST and OPTIONS HTTP request methods."
   remediacion="Perform the following to implement the recommended state:   1. Locate the Apache configuration files and included configuration files.   2. Search for the directive on the document root directory.   3. Add a directive as shown below within the group of document root directives.  <LimitExcept GET POST OPTIONS>       Require all denied   </LimitExcept>   4. Search for other directives in the Apache configuration files other than the OS root directory and add the same directives to each. It is very important to understand that the directives are based on the OS file system hierarchy as accessed by Apache and not the hierarchy of the locations within web site URLs."
   evidencia="$(getEvidencia "1" "$cmd")"

   sal_57=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
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
   nombre="5.8 Ensure the HTTP TRACE Method Is Disabled"
   descripcion="Use the Apache TraceEnable directive to disable the HTTP TRACE request method."
   remediacion="Perform the following to implement the recommended state:   1. Locate the main Apache configuration file such as httpd.conf.   2. Add a TraceEnable directive to the server level configuration with a value of off. Server level configuration is the top-level configuration, not nested within any other directives like <Directory> or <Location>."
   evidencia="$(getEvidencia "1" "$(grep -i "^\s*TraceEnable" "$dirConf")" )"

   sal_58=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia")
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
   nombre="5.9 Ensure Old HTTP Protocol Versions Are Disallowed"
   descripcion="The Apache modules mod_rewrite or mod_security can be used to disallow old and invalid HTTP protocols versions. The HTTP version 1.1 RFC is dated June 1999 and has been supported by Apache since version 1.2. It should no longer be necessary to allow ancient versions of HTTP such as 1.0 and prior."
   remediacion="Perform the following to implement the recommended state:   1. Load the mod_rewrite module for Apache by doing either one of the following:  * Build Apache with mod_rewrite statically loaded during the build, by adding the --enable-rewrite option to the ./configure script.  ./configure --enable-rewrite.  * Or, dynamically loading the module with the LoadModule directive in the httpd.conf configuration file.  LoadModule rewrite_module modules/mod_rewrite.so   2. Locate the main Apache configuration file such as httpd.conf and add the following rewrite condition to match HTTP/1.1 and the rewrite rule to the global server level configuration to disallow other protocol versions.  RewriteEngine On  RewriteCond %{THE_REQUEST} !HTTP\/1\\\.1\\\\$  RewriteRule .* - [F]   3. By default, mod_rewrite configuration settings from the main server context are not inherited by virtual hosts. Therefore, it is also necessary to add the following directives in each section to inherit the main server settings.  RewriteEngine On  RewriteOptions Inherit"
   evidencia="$(getEvidencia "1" "$lodedmodule")"
   evid2="$(getEvidencia "1" "$engine")"
   evid3="$(getEvidencia "1" "$cond1")"
   evid4="$(getEvidencia "1" "$rule")"

   sal_59=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3" "$evid4" )
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
   nombre="5.10 Ensure Access to .ht* Files Is Restricted"
   descripcion="Restrict access to any files beginning with .ht using the FilesMatch directive."
   remediacion="Perform the following to implement the recommended state:  Add or modify the following lines in the Apache configuration file at the server configuration level. <FilesMatch \"^\\\\.ht\">   Require all denied   </FilesMatch> "
   evidencia="$(getEvidencia "1" "$filesmatch")"
   evid2="$(getEvidencia "1" "$filesmatch2")"
   evid3="$(getEvidencia "1" "$(grep -i "^\s*Require all denied" "$dirConf" | head -1)")"

   sal_510=$(getJsonEv3 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3")
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
   nombre="5.11 Ensure Access to Inappropriate File Extensions Is Restricte"
   descripcion="Restrict access to inappropriate file extensions that are not expected to be a legitimate part of web sites using the FilesMatch directive."
   remediacion="Perform the following to implement the recommended state:   1. Compile a list of existing file extension on the web server. The following find/awk command may be useful, but is likely to need some customization according to the appropriate webroot directories for your web server. Please note that the find command skips over any files without a dot (.) in the file name, as these are not expected to be appropriate web content.  find */htdocs -type f -name '*.*' | awk -F. '{print $NF }' | sort -u   2. Review the list of existing file extensions, for appropriate content for the web server, remove those that are inappropriate and add any additional file extensions expected to be added to the web server in the near future.   3. Add the FilesMatch directive below which denies access to all files by default.   4. Add another a FilesMatch directive that allows access to those file extensions specifically allowed from the review process in step 2. An example FilesMatch directive is below. The file extensions in the regular expression should match your approved list, and not necessarily the expression below.  # Allow files with specifically approved file extensions  # Such as (css, htm; html; js; pdf; txt; xml; xsl; ...),  # images (gif; ico; jpeg; jpg; png; ...), multimedia  <FilesMatch \"^.*\\\\.(gif|ico|jpeg|png)\\\\$\">     Require all granted  </FilesMatch>"
   evidencia="$(getEvidencia "1" "$filesmatch")"
   evid2="$(getEvidencia "1" "$filesmatch2")"
   evid3="$(getEvidencia "1" "$(grep -i "^\s*Require all denied" "$dirConf" | head -1)")"
   evid4="$(getEvidencia "1" "$(grep -i "^\s*Require all granted" "$dirConf" | head -1)")"

   sal_511=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3" "$evid4")
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
   nombre="5.12 Ensure IP Address Based Requests Are Disallowed"
   descripcion="The Apache module mod_rewrite can be used to disallow access for requests that use an IP address instead of a host name for the URL. Most normal access to the website from browsers and automated software will use a host name which will therefore include the host name in the HTTP HOST header."
   remediacion="Perform the following to implement the recommended state:   1. Load the mod_rewrite module for Apache by doing either one of the following:  * Build Apache with mod_rewrite statically loaded during the build, by adding the --enable-rewrite option to the ./configure script.  ./configure --enable-rewrite  * Or, dynamically loading the module with the LoadModule directive in the httpd.conf configuration file. LoadModule rewrite_module modules/mod_rewrite.so   2. Add the RewriteEngine directive to the configuration within the global server context with the value of on so that the rewrite engine is enabled.  RewriteEngine On   3. Locate the Apache configuration file such as httpd.conf and add the following rewrite condition to match the expected host name of the top server level configuration.  RewriteCond %{HTTP_HOST} !^www\\\\.example\\\\.com [NC]  RewriteCond %{REQUEST_URI} !^/error [NC]  RewriteRule ^.(.*) - [L,F]"
   evidencia="$(getEvidencia "1" "$lodedmodule")"
   evid2="$(getEvidencia "1" "$engine")"
   evid3="$(getEvidencia "1" "$cond1")"
   evid4="$(getEvidencia "1" "$rule")"

   sal_512=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$evidencia" "$evid2" "$evid3" "$evid4")
   #echo -e "\n \n $sal_512"

}

function Mod5_13(){
   echo -e "\n\n\n 5.13 Ensure the IP Addresses for Listening for Requests Are Specified"
   echo    "==============================================================================="
   ((++total))

   output=($(cat "$dirConf" | grep -i \^Listen | awk '{print $2}'))
   good=0
   
   #Se valida si es una ip
   for item in ${output[@]}; do
      if [[ "$item" =~ ([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]* ]]; then
            good=$(($good + 1))
         #echo $good
      fi
   done
    
   local resultado
   # we captured output of the subshell, let's interpret it
   if [[ "$good" == ${#output[@]} ]]; then
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       # print the reason why we are failing
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON ---------------------------
   nombre="5.13 Ensure the IP Addresses for Listening for Requests Are Specified"
   descripcion="The Apache Listen directive specifies the IP addresses and port numbers the Apache web server will listen for requests. Rather than be unrestricted to listen on all IP addresses available to the system, the specific IP address or addresses intended should be explicitly specified. Specifically, a Listen directive with no IP address specified, or with an IP address of zeros should not be used."
   remediacion="Perform the following to implement the recommended state:   1. Find any Listen directives in the Apache configuration file with no IP address specified, or with an IP address of all zeros similar to the examples below. Keep in mind there may be both IPv4 and IPv6 addresses on the system. Listen 80  Listen 0.0.0.0:80  Listen [::ffff:0.0.0.0]:80   2. Modify the Listen directives in the Apache configuration file to have explicit IP addresses according to the intended usage. Multiple Listendirectives may be specified for each IP address & Port.  Listen 10.1.2.3:80  Listen 192.168.4.5:80  Listen [2001:db8::a00:20ff:fea7:ccea]:80"

   sal_513=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "Configuración actual $(cat "$dirConf" | grep -i \^Listen )")
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
   nombre="5.14 Ensure Browser Framing Is Restricted"
   descripcion="To prevent Clickjacking or UI Redressing attacks, it’s important for the server to include an HTTP header which instructs browsers to restrict the content from being framed. There are two headers that may be used. The Content-Security-Policy header, or the X-Frame-Options header. The Header directive allows server HTTP response headers to be added, replaced or merged. We will use the directive to add a server HTTP response header to tell browsers to restrict all of the web pages from being framed by other web sites."
   remediacion="Perform the following to implement the recommended state:   Add or modify the Header directive for the Content-Security-Policy header in the Apache configuration to have the condition always, an action of append and a value of frame-ancestors self, as shown below.  Header always append 'Content-Security-Policy frame-ancestors self'"

   sal_514=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "Configuración existente de cabecero de X-Frame-Option: $(grep -i X-Frame-Options $dirConf) y configuración de cabecero Content-Security-Policy:  $(grep -i Content-Security-Policy $dirConf)")
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
   #echo -e "\n\n $sal_mod5"
   
}

mod5
