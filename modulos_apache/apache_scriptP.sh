#!/bin/bash

#!/bin/sh


#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# Fecha: 15/05/2022                                                                      
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

confDirectorio=""
APACHE_PREFIX=""
usuario=""
grupo=""
fileError=""
errorDir=""
dirError=""

echo -e "\n\n\n\nEquipo: " $hostname
echo "Fecha: " $fecha
echo "=================================="

dirEjecucion="$(cd "$(dirname "$0")"; pwd)"

# -- Borramos el archivo salida_apache.json -----
echo -e "Borrando archivo "$dirEjecucion/salida_apache.json" \n \n"
rm -f "$dirEjecucion/salida_apache.json"
# ----------------------------------------------


# -- Exportar directorio JO -----------------------------------
dirJO="$dirEjecucion/jo/jo-master"
export PATH="$dirJO:$PATH"
source ~/.bashrc
#--------------------------------------------------------------

# -- Variables Configuracion Apache -------------------------------------
dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
#Validar si se encuentra ejecutandose apache en rhel o no se tiene variables globales
if [ -z "$dirConf" -a "$dirConf" != " " ]; then
    echo -e "\n\n     ---No se puede recuperar el directorio de configuración de Apache----"
    exit $dirConf
fi

confDirectorio=${dirConf%/*}
APACHE_PREFIX=${confDirectorio%?????}
usuario=$(grep -i '^User' "$dirConf"| awk {'print $2'})
grupo=$(grep -i '^Group' "$dirConf"| awk {'print $2'})

  # -- Directorio de LOGS
fileError=$(httpd -V|grep 'ERRORLOG' | cut -d'=' -f 2|sed "s/\"//g")
errorDir=${fileError%/*}
dirLogs=$APACHE_PREFIX/$errorDir
# -------------------------------------------------------------

echo -e "\n\nArchivo de configuración: $dirConf"
echo "Directorio Apache: $APACHE_PREFIX"
echo "Usuario: $usuario"
echo "Grupo: $grupo"

#----------- EXPORT de variables -----------------
export pass
export fail
export total

export dirConf
export APACHE_PREFIX
export usuario
export grupo
export dirEjecucicion
#--------------------------------------------------


cd $APACHE_PREFIX
echo "PWD: $(pwd)"
echo -e "\n \n Instancias activas:" | tee  instancias_apache_$(hostname)_${fechan}.txt
ps -fea | grep -ie httpd | grep -oE  "\-f /.*conf.*.conf " | cut -d ' ' -f2 | awk '{print $1}'| uniq | tee instancias_activas.txt
echo ""

# ----- INFORMACION SISTEMA Y ESCANEO   ------------------------------
  function getInformacion_escaneo() {
    fecha_escaneo=$(/bin/date +'%d-%m-%Y - %T')
    usuario_ejecutor=$(whoami)
    version_script="1.0"
    tipo_de_servidor="WEB"
    tecnologia="Apache HTTP Server"
    version_tecnologia=["'2.4.53'","'2'"]
              
    # JSON ---------------------------
    local informacion_escaneo=$(jo fecha_escaneo="$fecha_escaneo" usuario_ejecutor="$usuario_ejecutor" version_script=1.0  tipo_de_servidor="WEB" tecnologia="Apache HTTP Server" version_tecnologica[]='2.2' version_tecnologica[]='2.4')
    echo "$informacion_escaneo"

  }
              

  function getNetInterfaces() {
    IFS=$ class="hljs-string">'\n'
    mapfile -t lines < <(ip -o -4 addr show)
    array=()

    for i in ${lines[@]}; do
       nombre=$(echo $i | awk  '{print $2}')
       ip=$(echo $i | awk  '{print $4}' | cut -d\/ -f1)
       broadcast=$(echo $i | awk  '{print $6}')
       pruebaSal=$(jo "nombre"="$nombre" "ip_address"="$ip" "netmask"=" " "broadcast"="$broadcast")
       array=("${array[@]}" $pruebaSal)
    done

    cadena=""
    for i in ${array[@]}; do
       cadena="$cadena $i,"
    done

    #quitamos la ultima coma
    len=${#cadena}
    interfaces=${cadena::len-1}
    echo "$interfaces"
     
  }
              

  function getInformacion_sistema() {
     hostname=$(hostname)
     dominio=$(domainname)
     sistema_operativo=$(hostnamectl | grep -e Kernel| awk '{print $2}')
     detalleSO=$(uname -r)
     releaseSO=$(hostnamectl | grep -e "Operating System"| cut -d: -f2 ) 
     net_interfaces=( $(getNetInterfaces) )
     version_apache=$(httpd -V | grep 'version' | cut -d: -f2 | cut -d" " -f2)

     local informacion_sistema="{\"hostname\":\"$hostname\",\"dominio\":\"$dominio\",\"sistema_operativo\":\"$sistema_operativo\",\"detalleSO\":\"$detalleSO\",\"releaseSO\":\"$releaseSO\",\"net_interfaces\":[$(getNetInterfaces)],\"version_apache\":\"$version_apache\" }"
     echo "$informacion_sistema"

  }
# ---- Fin INFORMACION SISTEMA

function calificacion(){
    echo -e "\n\n\n**********************************************************************************************************************************\n"
    echo -e Controles totales: $total
    echo -e Controles cumplidos: ${YELLOW} $pass ${WHITE} 
    echo -e Controles no cumplidos ${RED} $fail ${WHITE}
    echo -e Porcentaje de cumplimiento: ${YELLOW} $((pass * 100 / total)) % ${WHITE}
    echo -e "***********************************************************************************************************************************\n"
}

# --- Funciones para las evidencias de resultados
function getResultadoEvidencia() {
    #Valor 1 Exitosa
    #Valor 2 se espera que tenga una salida vacia o nula
    arg1=$1
    #Salida del comando
    arg2=$2
    #arg3=$3

    local cadenaRes
    #Configuracion Correcta
    if [ "$arg1" = 1 ] ; then
       if [ "$arg2" != no_existe ] ; then
           cadenaRes="Configuración existente correcta, la salida existente es ==> $arg2."
       else
           cadenaRes="Configuración existente correcta, no se encontro valor/etiqueta."
       fi       
    fi

    #Falta configuracion
    if [ "$arg1" = 2 ] ; then
       if [ "$arg2" != no_existe ] ; then
           cadenaRes="Falta realizar la configuración, actualmente existe ==> $arg2."
       else
           cadenaRes="Falta realizar configuración ya que no se encontro valor/etiqueta, la salida existente es ==> $arg2."
       fi
    fi

    echo "$cadenaRes"

}

export -f myfun

# ------------------------------------------------

function main(){
   # ---- Invocacion de los módulos 
   # -- MODULOS
   #. $dirEjecucion"/mod2_apache.sh"
   #. $dirEjecucion"/mod3_apache.sh"
   . $dirEjecucion"/mod4_apache.sh"
   #. $dirEjecucion"/mod5_apache.sh"
   #. $dirEjecucion"/mod6_apache.sh"


   # --- Generacion JSON SALIDA  ----------------
   output="{\"tipo\": \"Resultado_de_revision\", \"informacion_escaneo\":$(getInformacion_escaneo), \"informacion_sistema\":$(getInformacion_sistema),"
   output="$output \"resultados\":[ $sal_mod4 ] }"
   echo -e "\n\n $output"
   
   echo $output >> "$dirEjecucion/salida_apache.json"
   # --------------------------------------------


   calificacion
}

main

# --- FIN SCRIPT 

