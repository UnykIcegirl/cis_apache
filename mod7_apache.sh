#!/usr/bin/env bash

#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# MODULO 7
# Fecha: 16/06/2022
# CSA: Maribel Hernandez Gtz
####################################################

declare RED='\e[1;31m'
declare WHITE='\e[1;0m'
declare GREEN='\e[1;32m'
declare YELLOW='\e[1;33m'

#Modulo 7
function Mod7_1(){
   echo -e "\n\n\n 7.1 Ensure mod_ssl and/or mod_nss Is Installed"
   echo    "========================================================="
   ((++total))
   busqueda1='ssl_module'
   busqueda2='nss_module'
   variable=$(httpd -M | egrep 'ssl_module|nss_module' || apachectl -M | egrep 'ssl_module|nss_module' )
   
   local resultado
   if [[ "$variable" == *"$busqueda1"* ]] || [[ "$variable" == *"$busqueda2"* ]]; then
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       #echo "esta mal configurado NO TIENE ssl_module o nss_module.";
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-44"
   nombre="7.1 Ensure mod_ssl and/or mod_nss Is Installed"
   descripcion="Secure Sockets Layer (SSL) was developed by Netscape and turned into an open standard and was renamed Transport Layer Security (TLS) as part of the process. TLS is important for protecting communication and can provide authentication of the server and even the client. However, contrary to vendor claims, implementing SSL does NOT directly make your web server more secure! SSL is used to encrypt traffic and therefore does provide confidentiality of private information and users credentials. Keep in mind, however that just because you have encrypted the data in transit does not mean that the data provided by the client is secure while it is on the server. Also, SSL does not protect the web server, as attackers will easily target SSL-Enabled web servers, and the attack will be hidden in the encrypted channel.  The mod_ssl module is the standard, most used module that implements SSL/TLS for Apache. A newer module found on Red Hat systems can be a compliment or replacement for mod_ssl and provides the same functionality plus additional security services. The mod_nss is an Apache module implementation of the Network Security Services (NSS) software from Mozilla, which implements a wide range of cryptographic functions in addition to TLS."
   remediacion="Perform either of the following to implement the recommended state:   1. For Apache installations built from the source, use the option --with-ssl= to specify the openssl path, and the --enable-ssl configure option to add the SSL modules to the build. The --with-included-apr configure option may be necessary if there are conflicts with the platform version. If a new version of Openssl is needed it may be downloaded from http://www.openssl.org/ See the Apache documentation on building from source http://httpd.apache.org/docs/2.4/install.htmlfor details.  # ./configure --with-included-apr --with-ssl=$OPENSSL_DIR --enable-ssl   2. For installations using OS packages, it is typically just a matter of ensuring the mod_ssl package is installed. The mod_nss package might also be installed. The following yum commands are suitable for Red Hat Linux.  # yum install mod_ssl "
   evidencia="$(getEvidencia "1" "$variable")"

   sal_71=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_71"
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
         let contAux=contAux+1
      else
         #echo "fallo una de las valiacciones-----"
         let contFinal=contFinal+1
      fi
   else
      #echo "No, no existe el archivo"
      let contFinal=contFinal+1
   fi
   
   local resultado   
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-45"
   nombre="7.2 Ensure a Valid Trusted Certificate Is Installed"
   descripcion="The default SSL certificate is self-signed and is not trusted. Install a valid certificate signed by a commonly trusted certificate authority. To be valid, the certificate must be:  * Signed by a trusted certificate authority  * Not be expired, and  * Have a common name that matches the host name of the web server, such as www.example.com."
   remediacion="Perform the following to implement the recommended state:   1. Decide on the host name to be used for the certificate. It is important to remember that the browser will compare the host name in the URL to the common name in the certificate, so that it is important that all https: URL's match the correct host name. Specifically, the host name www.example.com is not the same as example.com nor the same as ssl.example.com.   2. Generate a private key using openssl. Although certificate key lengths of 1024 have been common in the past, a key length of 2048 is now recommended for strong authentication. The key must be kept confidential and will be encrypted with a passphrase by default. Follow the steps below and respond to the prompts for a passphrase. See the Apache or OpenSSL documentation for details: * https://httpd.apache.org/docs/2.4/ssl/ssl_faq.html#realcert  * https://www.openssl.org/docs/HOWTO/certificates.txt   3. Create a certificate specific template configuration file. It is important that common name in the certificate exactly make the web host name in the intended URL. If there are multiple host names which may be used, as is very common, then the subjectAltName (SAN) field should be filled with all of the alternate names. Creating a template configuration file specific to the server certificate is helpful, as it allows for multiple entries in the subjectAltName. Also, any typos in the CSR can be potentially costly due to the lost time, so using a file, rather than hand typing helps prevent errors. To create a template configuration file, make a local copy of the openssl.cnf typically found in /etc/ssl/ or /etc/pki/tls/  # cp /etc/ssl/openssl.cnf ex1.cnf   4. Find the request section which follows the line '[ req ]'. Then add or modify the configuration file to include the appropriate values for the host names. It is recommended (but not required) that the first subjectAltName match the commonName.   5. Continue editing the configuration file under the request distinguished name section to change the existing default values in the configuration file to match the desired certificates information.   6. Now generate the CSR from the template file, verifying the information. If the default values were placed in the template, then just press enter to confirm the default value.   7. Review and verify the CSR information including the SAN by displaying the information.   8. Now move the private key to its intended directory.  # mv www.example.com.key /etc/ssl/private/   9. Send the certificate signing request (CSR) to a certificate signing authority to be signed, and follow their instructions for submission and validation. The CSR and the final signed certificate are just encoded text and need to be protected for integrity, but not confidentiality. This certificate will be given out for every SSL connection made.   10. The resulting signed certificate may be named www.example.com.crt and placed in /etc/ssl/certs/ as readable by all (mode 0444). Please note that the certificate authority does not need the private key (example.com.key) and this file must be carefully protected. With a decrypted copy of the private key, it would be possible to decrypt all conversations with the server.   11. Do not forget the passphrase used to encrypt the private key. It will be required every time the server is started in https mode. If it is necessary to avoid requiring an administrator having to type the passphrase every time the httpd service is started, the private key may be stored in clear text. Storing the private key in clear text increases the convenience while increasing the risk of disclosure of the key, but may be appropriate for the sake of being able to restart, if the risks are well managed. Be sure that the key file is only readable by root. To decrypt the private key and store it in clear text file the following openssl command may be used. You can tell by the private key headers whether it is encrypted or clear text.  # cd /etc/ssl/private/  # umask 077  # openssl rsa -in www.example.com.key -out www.example.com.key.clear   12. Locate the Apache configuration file for mod_ssl and add or modify the SSLCertificateFile and SSLCertificateKeyFiledirectives to have the correct path for the private key and signed certificate files. If a clear text key is referenced then a passphrase will not be required. You may need to configure the CA's certificate along with any intermediate CA certificates that signed your certificate using the SSLCertificateChainFile directive. As an alternative, starting with Apache version 2.4.8 the CA and intermediate certificates may be concatenated to the server certificate configured with the SSLCertificateFile directive instead.   13. Lastly, start or restart the httpd service and verify correct functioning with your favorite browser. "
   evidencia="Valor del atributo 'SSLEngine': $(grep -i "^\s*SSLEngine" "$SSLCONF") )"
   evid2="Valor del atributo 'SSLCertificateFile': $(grep -i "^\s*SSLCertificateFile" "$SSLCONF") )"
   evid3="Valor del atributo 'SSLCertificateKeyFile': $(grep -i "^\s*SSLCertificateKeyFile" "$SSLCONF") )"
   evid4="Valor del atributo 'SSLCertificateChainFile': $(grep -i "^\s*SSLCertificateChainFile" "$SSLCONF") )"

   sal_72=$(getJsonEv4 "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")"  "$(getBase64 "$evid2")"  "$(getBase64 "$evid3")"  "$(getBase64 "$evid4")"  "$id")
   #echo -e "\n \n $sal_72"
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
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-46"
   nombre="7.3 Ensure the Server's Private Key Is Protected"
   descripcion="It is critical to protect the server's private key. The server's private key is encrypted by default as a means of protecting it. However, having it encrypted means that the passphrase is required each time the server is started up, and now it is necessary to protect the passphrase as well. The passphrase may be typed in when it is manually started up or provided by an automated program. To summarize, the options are:  1. Use SSLPassPhraseDialog builtin, - requires a passphrase to be manually entered.  2. Use SSLPassPhraseDialog |/path/to/program to provide the passphrase.  3. Use SSLPassPhraseDialog exec:/path/to/program to provide the passphrase,  4. Store the private key in clear text so that a passphrase is not required. Any of the above options 1-4 are acceptable as long as the key and passphrase are protected as described below. Option 1 has the additional security benefit of not storing the passphrase, but is not generally acceptable for most production web servers, since it requires the web server to be manually started. Options 2 and 3 can provide additional security if the programs providing them are secure. Option 4 is the simplest, is widely used and is acceptable as long as the private key is appropriately protected."
   remediacion="Perform the following to implement the recommended state:   1. All private keys must be stored separately from the public certificates. Find all SSLCertificateFile directives in the Apache configuration files. For any SSLCertificateFile directives that do not have a corresponding separate SSLCertificateKeyFile directive, move the key to a separate file from the certificate, and add the SSLCertificateKeyFile directive for the key file.   2. For each of the SSLCertificateKeyFile directives, change the ownership and permissions on the server private key to be owned by root:root with permission 0400."
   evidencia="Configuración de la llave privada: $FILEKEY"

   sal_73=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_73"
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
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-47"
   nombre="7.4 Ensure the TLSv1.0 and TLSv1.1 Protocols are Disable"
   descripcion="The TLSv1.0 and TLSv1.1 protocols should be disabled via the SSLProtocol directive. The TLSv1.0 protocol is vulnerable to information disclosure and both protocols lack support for modern cryptographic algorithms including authenticated encryption. The only SSL/TLS protocols that should be allowed is TLSv1.2 along with the newer TLSv1.3 protocol."
   remediacion="Perform the following to implement the recommended state:   1. Check if the TLSv1.3 protocol is supported by the Apache server by either checking that the version of OpenSSL is 1.1.1 or later or place the TLSv1.3 value in the SSLProtocol string of a configuration file and check the syntax with the ‘httpd -t’ command before using the file in production. Two examples below are shown of servers that do support the TLSv1.3 protocol.  $ openssl version  OpenSSL 1.1.1a  20 Nov 2018    ### _(Add TLSv1.3 to the SSLProtocol directive)_  # httpd -t  Syntax OK    2. Search the Apache configuration files for the SSLProtocol directive; add the directive, if not present, or change the value to TLSv1.2 or TLSv1.2 TLSv1.3 if the TLSv1.3 protocol is supported."
   evidencia="Los protocolos TLS habilitados son: $rescat"

   sal_74=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")" "$id" )
   #echo -e "\n \n $sal_74"
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
   
   local resultado   
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-48"
   nombre="7.5 Ensure Weak SSL/TLS Ciphers Are Disabled"
   descripcion="Disable weak SSL ciphers using the SSLCipherSuite, and SSLHonorCipherOrder directives. The SSLCipherSuite directive specifies which ciphers are allowed in the negotiation with the client. While the SSLHonorCipherOrder causes the server's preferred ciphers to be used instead of the clients' specified preferences."
   remediacion="Perform the following to implement the recommended state: Ensure the SSLCipherSuite includes all of the following: !NULL:!SSLv2:!RC4:!aNULL values. For example, add or modify the following line in the Apache server level configuration and every virtual host that is TLS enabled:  SSLHonorCipherOrder On  SSLCipherSuite ALL:!EXP:!NULL:!LOW:!SSLv2:!RC4:!aNULL   It is not recommended to add !SSLv3 to the directive even if the SSLv3 protocol is not in use. Doing so disables ALL of the ciphers that may used with SSLv3, which includes the same ciphers used with the TLS protocols. The !aNULL will disable both the ADH and AECDH ciphers, so the !ADH is not required.   IMPORTANT NOTE: The above SSLCipherSuite value disables only the weak ciphers but allows medium strength and other ciphers which should also be disabled. Refer to the remaining TLS benchmark recommendations for stronger cipher suite values. The following cipher suite value will meet all of the level 1 and level 2 benchmark recommendations. As always, testing prior to production use is highly recommended.  SSLHonorCipherOrder On  SSLCipherSuite EECDH:EDH:!NULL:!SSLv2:!RC4:!aNULL:!3DES:!IDEA"
   evidencia="El valor del atributo 'SSLHonorCipherOrder' es: $rescat"
   evid2="El valor del atributo 'SSLCipherSuite' es: $rescat2"

   sal_75=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")"  "$(getBase64 "$evid2")"  "$id")
   #echo -e "\n \n $sal_75"
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
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       resultado="Cumple"
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-49"
   nombre="7.6 Ensure Insecure SSL Renegotiation Is Not Enabled"
   descripcion="A man-in-the-middle renegotiation attack was discovered in SSLv3 and TLSv1 in November, 2009 (CVE-2009-3555). First, a work around and then a fix was approved as an Internet Standard as RFC 574, Feb 2010. The work around, which removes the renegotiation, is available from OpenSSL as of version 0.9.8l and newer versions. For details: https://www.openssl.org/news/secadv_20091111.txt The SSLInsecureRenegotiation directive was added in Apache 2.2.15, for web servers linked with OpenSSL version 0.9.8m or later, to provide backward compatibility to clients with the older, unpatched SSL implementations."
   remediacion="Perform the following to implement the recommended state:   Search the Apache configuration files for the SSLInsecureRenegotiation directive. If the directive is present modify the value to be off. If the directive is not present then no action is required.  SSLInsecureRenegotiation off"
   evidencia="El valor del atributo 'SSLInsecureRenegotiation' es: $rescat"

   sal_76=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")"  "$id")
   #echo -e "\n \n $sal_76"
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
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then    
      echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
      resultado="No Cumple"
      ((++fail))
   else
      echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
      resultado="Cumple"
      ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-50"
   nombre="7.7 Ensure SSL Compression is not Enabled"
   descripcion="The SSLCompression directive controls whether SSL compression is used by Apache when serving content over HTTPS. It is recommended that the SSLCompression directive be set to off."
   remediacion="Perform the following to implement the recommended state:   1. Search the Apache configuration files for the SSLCompression directive.   2. If the directive is present, set it to off."
   evidencia="El valor del atributo 'SSLCompression' es: $rescat"

   sal_77=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_77"
}

function Mod7_8(){
   echo -e "\n\n\n 7.8 Ensure Medium Strength SSL/TLS Ciphers Are Disabled"
   echo    "================================================================="
   ((++total))

   fnd=`find $APACHE_PREFIX -name ssl.conf`
   busqueda='SSLHonorCipherOrder'
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
   
   local resultado   
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-51"
   nombre="7.8 Ensure Medium Strength SSL/TLS Ciphers Are Disabled"
   descripcion="The SSLCipherSuite directive specifies which ciphers are allowed in the negotiation with the client. Disable the medium strength ciphers such as Triple DES (3DES) and IDEA by adding !3DES and !IDEA in the SSLCipherSuite directive."
   remediacion="Perform the following to implement the recommended stateÑ Add or modify the following lines in the Apache server level configuration and every virtual host that is SSL-TLS enabled:  SSLHonorCipherOrder On  SSLCipherSuite ALLÑ!EXPÑ!NULLÑ!LOWÑ!SSLv2Ñ!RC4Ñ!aNULLÑ!3DESÑ!IDEA"
   evidencia="El valor del atributo 'SSLHonorCipherOrder' es: $rescat"
   evid2="El valor del atributo 'SSLCipherSuite' es: $rescat2"

   sal_78=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")"  "$(getBase64 "$evid2")"  "$id")
   #echo -e "\n \n $sal_78"
}

function Mod7_9(){
   echo -e "\n\n\n 7.9 Ensure All Web Content is Accessed via HTTPS"
   echo    "=========================================================="
   ((++total))

   cadena=$(grep -i "^\s*Redirect" "$dirConf")
   #echo "salida: "$cadena;
   
   # we captured output of the subshell, let's interpret it
   local resultado
   if [[ "$cadena" == *"https"* ]] ; then
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   else
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-52"
   nombre="7.9 Ensure All Web Content is Accessed via HTTPS"
   descripcion="All of the website content should be served via HTTPS rather than HTTP. A redirect from the HTTP website to the HTTPS content is often useful and is recommended, but all significant content should be accessed via HTTPS so that it is authenticated and encrypted."
   remediacion="Perform the following to implement the recommended state:  Move the web content to a TLS enabled website, and add an HTTP Redirect directive to the Apache configuration file to redirect to the TLS enabled website similar to the example shown.   Redirect permanent / https://www.cisecurity.org/"
   evidencia="El valor del atributo 'Redirect' es: $rescat"

   sal_79=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")" "$id" )
   #echo -e "\n \n $sal_79"
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
   
   local resultado   
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-53"
   nombre="7.10 Ensure OCSP Stapling Is Enabled"
   descripcion="The OCSP (Online Certificate Status Protocol) provides the current revocation status of an X.509 certificate and allows for a certificate authority to revoke the validity of a signed certificate before its expiration date. The URI for the OCSP server is included in the certificate and verified by the browser. The Apache SSLUseStapling directive along with the SSLStaplingCache directive are recommended to enable OCSP Stapling by the web server. If the client requests OCSP stapling, then the web server can include the OCSP server response along with the web server's X.509 certificate."
   remediacion="Perform the following to implement the recommended state: Add or modify the SSLUseStapling directive to have a value of on in the Apache server level configuration and every virtual host that is SSL enabled. Also ensure that SSLStaplingCache is set to one of the three cache types similar to the examples below.   SSLUseStapling On  SSLStaplingCache 'shmcb:logs/ssl_staple_cache(512000)'  - or-   SSLStaplingCache 'dbm:logs/ssl_staple_cache.db'  - or -  SSLStaplingCache  dc:UNIX:logs/ssl_staple_socket"
   evidencia="El valor del atributo 'SSLUseStapling' es: $rescat"
   evid2="El valor del atributo 'SSLStaplingCache' es: $rescat2"

   sal_710=$(getJsonEv2 "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")"  "$(getBase64 "$evid2")"  "$id" )
   #echo -e "\n \n $sal_710"
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
   
   local resultado   
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-54"
   nombre="7.11 Ensure HTTP Strict Transport Security Is Enabled"
   descripcion="HTTP Strict Transport Security (HSTS) is an optional web server security policy mechanism specified by an HTTP Server header. The HSTS header allows a server declaration that only HTTPS communication should be used rather than clear text HTTP communication."
   remediacion="Perform the following to implement the recommended state:   Add a Header directive as shown below in the Apache server level configuration and every virtual host that is SSL enabled. The includeSubDomains and preload flags may be included in the header, but are not required.   Header always set Strict-Transport-Security 'max-age=600'; includeSubDomains; preload  - or -  Header always set Strict-Transport-Security 'max-age=600'"
   evidencia="El valor del atributo 'Strict-Transport-Security' es: $rescat"

   sal_711=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado"  "$(getBase64 "$evidencia")" "$id")
   #echo -e "\n \n $sal_711"
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
   
   local resultado
   if [[ "$contFinal" > 0 ]]; then    
       echo -e "           ------------------------------------------------------- -----------------------------------------------------------------${RED} No Cumple ${WHITE}"
       resultado="No Cumple"
       ((++fail))
   else
       echo -e "           -------------------------------------------------------------------------------------------------------------------------${GREEN} Cumple ${WHITE}"
       resultado="Cumple"
       ((++pass))
   fi

   # JSON --------------------------------------------------------------------------------
   id="APH-GS-CSA-55"
   nombre="7.12 Ensure Only Cipher Suites That Provide Forward Secrecy Are Enabled"
   descripcion="In cryptography, forward secrecy (FS), which is also known as perfect forward secrecy (PFS), is a feature of specific key exchange protocols that give assurance that your session keys will not be compromised even if the private key of the server is compromised. Protocols such as RSA do not provide the forward secrecy, while the protocols ECDHE (Elliptic-Curve Diffie-Hellman Ephemeral) and the DHE (Diffie-Hellman Ephemeral) will provide forward secrecy. The ECDHE is the stronger protocol and should be preferred, while the DHE may be allowed for greater compatibility with older clients. The TLS ciphers should be configured to require either the ECDHE or the DHE ephemeral key exchange, while not allowing other cipher suites."
   remediacion="Perform one of the following to implement the recommended state:   * Add or modify the following line in the Apache server level configuration and every virtual host that is SSL/TLS enabled:  SSLCipherSuite EECDH:EDH:!NULL:!SSLv2:!RC4:!aNULL:!3DES:!IDEA   * The more recent versions of openssl (such as 1.0.2 and newer) will support the usage of ECDHE as a synonym for EECDH and DHE as a synonym for EDH in the cipher specification. The usage of ECDHE and DHE are preferred so that the specification matches the expected output. So, the cipher specification could be:  SSLCipherSuite ECDHE:DHE:!NULL:!SSLv2:!RC4:!aNULL:!3DES:!IDEA"
   evidencia="El valor del atributo 'SSLCipherSuite' es: $rescat"

   sal_712=$(getJsonEv "$nombre" "$descripcion" "$remediacion" "$resultado" "$(getBase64 "$evidencia")"  "$id")
   #echo -e "\n \n $sal_712"
}


function mod7(){
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

   sal_mod7="$sal_71, $sal_72, $sal_73, $sal_74, $sal_75, $sal_76, $sal_77, $sal_78, $sal_79, $sal_710, $sal_711, $sal_712"
   #echo -e "\n\n $sal_mod7"
   
}
mod7
