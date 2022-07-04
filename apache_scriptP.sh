#!/usr/bin/env bash


#####################################################
# DSI-CSA                                                                                
# Script para evaluación de Apache Httpd V1.0
# Fecha: 15/05/2022                                                                      
# CSA: Maribel Hernandez Gtz
####################################################

declare fecha=$(date "+%d-%m-%Y %H:%M:%S")
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

# -- Borramos los archivos de salida json y html -----
echo -e "Borrando archivo "$dirEjecucion/salida_apache.json""
rm -f "$dirEjecucion/salida_apache.json"
echo -e "Borrando archivo "$dirEjecucion/Totalsec_Apache.html" \n \n"
rm -f "$dirEjecucion/Totalsec_Apache.html"
# ----------------------------------------------


# -- Biblioteca JO -----------------------------------
#descomprimir carpeta
dirJO="$dirEjecucion/jo-master"
if [ ! -d "$dirJO" ]; then
    unzip -d "$dirEjecucion" "jo-master-v1.zip"
fi

#Exportar la ruta al PATH
export PATH="$dirJO:$PATH"
source ~/.bashrc
#echo $PATH
#--- Fin Biblioteca JO ---------------------------------

# -- Variables Configuracion Apache -------------------------------------
dirConf=$(ps -ef | grep httpd | grep -oE '/.*conf.*conf'| cut -d ' ' -f3| awk '{print $1}'| uniq)
#Validar si se encuentra ejecutandose apache en rhel o no se tiene variables globales
if [ -z "$dirConf" -a "$dirConf" != " " ]; then
    # Consideremos la ruta 'HTTPD_ROOT'
    dirConf=$(httpd -V|grep 'HTTPD_ROOT'| cut -d'=' -f 2 | sed "s/\"//g")"/"$(httpd -V|grep 'SERVER_CONFIG_FILE'| cut -d'=' -f 2 | sed "s/\"//g")
    if [ -z "$dirConf" -a "$dirConf" != " " ]; then
        echo -e "\n\n     ---No se puede recuperar el directorio de configuración de Apache----"
        exit $dirConf
    fi
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
export dirEjecucion
#--------------------------------------------------


cd $APACHE_PREFIX
echo "PWD: $(pwd)"
echo ""

# ----- INFORMACION SISTEMA Y ESCANEO   ------------------------------
  function getInformacion_escaneo() {
    fecha_escaneo=$(/bin/date +'%d-%m-%Y - %T')
    usuario_ejecutor=$(whoami)
    version_script="'1.0'"
    tipo_de_servidor="WEB"
    tecnologia=$(httpd -V|grep 'Server version' | cut -d':' -f 2)
    version_tecnologia=["'2.4.53'","'2'"]
    version=$(httpd -V|grep 'Server version' | cut -d':' -f 2 | cut -d'/' -f 2 | cut -d' ' -f 1)
              
    # JSON ---------------------------
    local informacion_escaneo=$(jo fecha_escaneo="$fecha_escaneo" usuario_ejecutor="$usuario_ejecutor" version_script="$version_script"  tipo_de_servidor="WEB" tecnologia="$tecnologia" version_tecnologica[]="2.4")
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
     directorio_instalacion=$APACHE_PREFIX
     directorio_conf=$dirConf
     usuario_apache=$usuario
     grupo_apache=$grupo

     local informacion_sistema="{\"hostname\":\"$hostname\",\"dominio\":\"$dominio\",\"sistema_operativo\":\"$sistema_operativo\",\"detalleSO\":\"$detalleSO\",\"releaseSO\":\"$releaseSO\",\"net_interfaces\":[$(getNetInterfaces)],\"version\":\"Version $version_apache\", \"directorio_instalacion\":\"$directorio_instalacion\", \"directorio_conf\":\"$directorio_conf\",  \"usuario_apache\":\"$usuario_apache\", \"grupo_apache\":\"$grupo_apache\" }"
     echo "$informacion_sistema"

  }
# ---- Fin INFORMACION SISTEMA

# --- Funciones que generan el JSON
function getJsonEv() {
    nombre=$1
    descripcion=$2
    remediacion=$3
    resultado=$4
    evidencia=$5

    json=$(jo id="AP-BAZ-XXX" nombre="$nombre" descripcion="$descripcion" remediacion="$remediacion" estado="$resultado" evidencia[]="$evidencia")
    echo "$json"

}

function getJsonEv2() {
    nombre=$1
    descripcion=$2
    remediacion=$3
    resultado=$4
    evid=$5
    evid2=$6

    json=$(jo id="AP-BAZ-XXX" nombre="$nombre" descripcion="$descripcion" remediacion="$remediacion" estado="$resultado" evidencia[]="$evid" evidencia[]="$evid2")
    echo "$json"

}

function getJsonEv3() {
    nombre=$1
    descripcion=$2
    remediacion=$3
    resultado=$4
    evid=$5
    evid2=$6
    evid3=$7

    json=$(jo id="AP-BAZ-XXX" nombre="$nombre" descripcion="$descripcion" remediacion="$remediacion" estado="$resultado" evidencia[]="$evid" evidencia[]="$evid2" evidencia[]="$evid3")
    echo "$json"

}

function getJsonEv4() {
    nombre=$1
    descripcion=$2
    remediacion=$3
    resultado=$4
    evid=$5
    evid2=$6
    evid3=$7
    evid4=$8

    json=$(jo id="AP-BAZ-XXX" nombre="$nombre" descripcion="$descripcion" remediacion="$remediacion" estado="$resultado" evidencia[]="$evid" evidencia[]="$evid2" evidencia[]="$evid3" evidencia[]="$evid4")
    echo "$json"

}
#------------------------------------------------------------------------------------------

# --- Funciones para las evidencias de resultados
function getEvidencia() {
    #Valor 1 Se espera que tenga un VALOR
    #Valor 2 se espera que tenga una salida vacia o NULL
    local arg1=$1
    #Salida del comando
    local arg2=$2

    local cadenaRes
    #Configuracion, se espera un valor como exitoso
    if [ "$arg1" = 1 ] ; then
        if [ -z "$arg2" ]; then 
            #echo "NULL"; 
            cadenaRes="Falta realizar configuración ya que no se encontro valor/etiqueta"
        else 
            #echo "Not NULL";
            cadenaRes="Configuración existente correcta, la salida existente es ==> $arg2."
        fi
    fi

    #Configuracion, se espera un valor NULL como exitoso
    if [ "$arg1" = 2 ] ; then
        if [ -z "$arg2" ] || [ "$arg2" = "$no_existe" ]; then 
            #echo "NULL"; 
            cadenaRes="Configuración existente correcta, no se encontro valor/etiqueta."
        else 
            #echo "Not NULL";
            cadenaRes="Falta realizar configuración actualmente existe el valor ==> $arg2."
        fi
    fi

    echo "$cadenaRes"

}

# ------------------------------------------------
function calificacion(){
    echo -e "\n\n\n**********************************************************************************************************************************\n"
    echo -e Controles totales: $total
    echo -e Controles cumplidos: ${YELLOW} $pass ${WHITE} 
    echo -e Controles no cumplidos ${RED} $fail ${WHITE}
    echo -e Porcentaje de cumplimiento: ${YELLOW} $((pass * 100 / total)) % ${WHITE}
    echo -e "***********************************************************************************************************************************\n"
}


# ---  MAIN ----------------------
function main(){
   # ---- Invocacion de los módulos 
   # -- MODULOS
   . $dirEjecucion"/mod2_apache.sh"
   . $dirEjecucion"/mod3_apache.sh"
   . $dirEjecucion"/mod4_apache.sh"
   . $dirEjecucion"/mod5_apache.sh"
   . $dirEjecucion"/mod6_apache.sh"
   . $dirEjecucion"/mod7_apache.sh"
   . $dirEjecucion"/mod8_apache.sh"
   . $dirEjecucion"/mod9_apache.sh"
   . $dirEjecucion"/mod10_apache.sh"
   . $dirEjecucion"/mod11_apache.sh"
   . $dirEjecucion"/mod12_apache.sh"


   # --- Generacion JSON SALIDA  ----------------
   output="{\"tipo\": \"Resultado_de_revision\", \"informacion_escaneo\":$(getInformacion_escaneo), \"informacion_sistema\":$(getInformacion_sistema),"
   output="$output \"resultados\":[ $sal_mod2, $sal_mod3, $sal_mod4, $sal_mod5, $sal_mod6, $sal_mod7, $sal_mod8, $sal_mod9, $sal_mod10, $sal_mod11, $sal_mod12 ] }"
#   echo -e "\n\n $output"
   
   echo $output >> "$dirEjecucion/salida_apache.json"
   # ---------------------------------------------------


   calificacion
}

main

# --- Reporte HTML
cd $dirEjecucion

python_version=$(python --version 2>&1)
script="moduloreporte.py -f salida_apache.json -o Totalsec_Apache.html"

if [[ "$python_version" == *"Python 2"* ]]; then
    python $script
else
    python3 $script
fi
echo "fin Ejecutamos html"
# --- Fin Reporte HTML

# --- FIN SCRIPT 

