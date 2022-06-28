import json
import argparse
import codecs
import sys

parser = argparse.ArgumentParser()
parser.add_argument("-f","--file",help="archivo json a mostrar en el reporte", type=str)
parser.add_argument("-o","--output",help="nombre del archivo destino", type=str)
args = parser.parse_args()
print (args.file)

file= open(args.file,"r")
myjson=json.load(file)

strFor =  "<!DOCTYPE html>"
strFor = strFor + "<html><head>"
strFor = strFor + "<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>"		
strFor = strFor +  "<title> Hardening de seguridad para " + myjson['informacion_escaneo']['tecnologia'] + " V" + myjson['informacion_escaneo']['version_script'] +"  - Salida script de validacion </title>"		
strFor = strFor + '<style type="text/css">  '
strFor = strFor + 'body { font-family: "Arial", "Arial Unicode MS", sans-serif; font-style: normal; font-weight: normal; font-size: 12pt; background-color: #505050; } '
strFor = strFor + 'p { font-size: 12pt; font-weight: bold; font-style: normal; } ' 
strFor = strFor + "pre { position: relative; left: 30px; top: 0px; width: 90%; min-height: 20px; max-height: 250px; height: auto; background-color: rgb(0, 0, 0); color: rgb(0, 255, 0); overflow: auto;}"
strFor = strFor + 'h1 { font-size: 20pt; text-align: center } h2 { font-size: 16pt; } h3 { font-size: 14pt; } '
strFor = strFor + 'div, span { font-weight: normal; font-style: normal; font-size: 12pt; } '
strFor = strFor + '#red { color: #FF0000; text-align: center} '
strFor = strFor + '#green { color: #008000; text-align: center} '
strFor = strFor + '#reportContainer{ width: 892px; margin: 0 auto; background-color: #ffffff; }'
strFor = strFor + '#footerContainer { width: 892px; margin-left: -10px; margin-bottom: -10px; } '
strFor = strFor + '#ruleTitle { color: #1F497D; width: 100%; height: 40px; margin-top: 10px; background-color: #dddddd; font-weight: bold; font-style: normal; font-size: 16pt; } '
strFor = strFor + '#ruleResultArea { margin-top: 10px }'
strFor = strFor + 'table { empty-cells: show; font-weight: normal; font-style: normal; font-size: smaller; } '
strFor = strFor + 'thead { color: rgb(255,255,255); background-color:rgb(0, 59, 92); } '
strFor = strFor + '#t-tbody { color: inherit; background-color: #f0f0f0; border: 1px solid; font-size: 8pt; font-weight: bold; font-style: normal; } '
strFor = strFor + '#t-title { color: inherit; background-color: #dddddd; border:none} '
strFor = strFor + '</style>'


strFor = strFor +  "<body lang='es'>"
strFor = strFor +  "<div id='reportContainer'>"	
strFor = strFor +  "<span><h1>Hardening de seguridad para " + myjson['informacion_escaneo']['tecnologia']+ " V" + myjson['informacion_escaneo']['version_script'] + "    Version(s): "+ str(myjson['informacion_escaneo']['version_tecnologica'])+"</h1></span>"
strFor = strFor +  "<div style='margin: 4px 20px 0 20px;'>"		
strFor = strFor +  "<br><br>"		
strFor = strFor +  "<div style='width:100%; background-color: #FFFFFF;'>"
strFor = strFor +  "<label>Equipo:"+ myjson['informacion_sistema']['hostname']  +"</label><br>"
for i in myjson['informacion_sistema']['net_interfaces']:
    strFor = strFor +  "<label>Ip: "+ i['ip_address']+" Interface: " + i['nombre'] + "</label><br>"
strFor = strFor + "<label>Dominio: "+ myjson['informacion_sistema']['dominio']  +"</label><br>"
strFor = strFor + "<label>Usuario: "+ myjson['informacion_escaneo']['usuario_ejecutor']+"</label><br>"
strFor = strFor + "<label>Sistema Operativo: "+ myjson['informacion_sistema']['sistema_operativo']  +"</label><br>"
strFor = strFor + "<label>Detalle Sistema Operativo: "+ myjson['informacion_sistema']['detalleSO']  +"</label><br>"
strFor = strFor + "<label>Release: "+ myjson['informacion_sistema']['releaseSO']  +"</label><br>"
strFor = strFor + "<label>Version Apache: "+ myjson['informacion_sistema']['version_apache']  +"</label><br>"
strFor = strFor + "<label>Directorio instalacion: "+ myjson['informacion_sistema']['directorio_instalacion']  +"</label><br>"
strFor = strFor + "<label>Directorio configuracion: "+ myjson['informacion_sistema']['directorio_conf']  +"</label><br>"
strFor = strFor + "<label>Usuario instalacion apache: "+ myjson['informacion_sistema']['usuario_apache']  +"</label><br>"
strFor = strFor + "<label>Grupo instalacion apache: "+ myjson['informacion_sistema']['grupo_apache']  +"</label><br>"
strFor = strFor + "<label>Fecha y hora de ejecucion: "+ myjson['informacion_escaneo']['fecha_escaneo']+"</label><br>"
strFor = strFor + "</div><br><br>"
strFor = strFor + "<h3>Resultado del escaneo</h3><br>"
strFor = strFor + '<table width="100%" >'
strFor = strFor + "<thead>"
strFor = strFor + '<th >ID</th>'
strFor = strFor + '<th >Control</th>'
strFor = strFor + '<th >Resultado</th>'
strFor = strFor + '</thead>'
for r in myjson['resultados']:
    strFor = strFor + "<tr>"
    strFor = strFor + "<td id='t-tbody' width=13%><a href='#"+ r['nombre'] +"'>" + r['id'] + "</a></td>"
    strFor = strFor + "<td id='t-tbody' width=72%><a href='#"+ r['nombre'] +"'>" + r['nombre'] + "</a></td>"
    if "No Cumple" in r['estado']:
        strFor = strFor + "<td id='t-tbody'><div id='red'>" + r['estado'] + "</div></td>"
    elif "Cumple" in r['estado']:
        strFor = strFor + "<td id='t-tbody'><div id='green'>" + r['estado'] + "</div></td>"
    else:
        strFor = strFor + "<td id='t-tbody'>" + r['estado'] + "</td>"
    strFor = strFor + "</tr>"
strFor = strFor + '</table>'
strFor = strFor + "<br><br>"
for r in myjson['resultados']:
    strFor = strFor + '<a name="' + r['nombre'] +'"></a>'
    strFor = strFor + '<div id="t-title">'
    strFor = strFor + '<table width="100%" border="0">'
    strFor = strFor + "<td width=20%><h3>" + r['id'] + "</h3></td>"
    strFor = strFor + "<td width=60%><h3>" + r['nombre'] + "</h3></td>"
    if "No Cumple" in r['estado']:
        strFor = strFor + "<td><h3 id='red'>" + r['estado'] + "</h3></td>"
    elif "Cumple" in r['estado']:
        strFor = strFor + "<td><h3 id='green'>" + r['estado'] + "</h3></td>"
    else:
        strFor = strFor + "<td><h3>" + r['estado'] + "<h3></td>"
    strFor = strFor + '</table>'
    strFor = strFor + "</div>"
    strFor = strFor + "<div id='ruleResultArea'>"
    strFor = strFor + "<h2>Descripcion</h2>"
    strFor = strFor + "<br>"
    strFor = strFor + "<p> &emsp;&emsp;" + r['descripcion'] + "</p>"
    strFor = strFor + "<br>"
    strFor = strFor + "</div>"
    strFor = strFor + "<div id='ruleResultArea'>"
    strFor = strFor + "<h2>Remediacion</h2>"
    strFor = strFor + "<br>"
    strFor = strFor + "<p> &emsp;&emsp;" + r['remediacion'] + "</p>"
    strFor = strFor + "<br>"
    strFor = strFor + "</div>"
    strFor = strFor + "<div id='ruleResultArea'>"
    strFor = strFor + "<h2>Evidencia</h2>"

    for evidencia in r['evidencia']:
      strFor = strFor + "<pre><pre>"+ evidencia + "</pre></pre>"
      
    #strFor = strFor + "<pre><pre>"+ r['evidencia'] + "</pre></pre>"

    strFor = strFor + "</div>"
    strFor = strFor + "<br><br>"
strFor = strFor +  "</div>"
strFor = strFor +  "</div>"
strFor = strFor +  "</body>"
strFor = strFor +  "</html>"

# archivo de salida
file_output=""
if sys.version_info.major == 3:
    # Python3
    file_output = open (args.output,'w')
else:
    # Python2
    OUTPUT_ENCODING = 'utf-8'
    file_output  = codecs.open (args.output,"w", OUTPUT_ENCODING)

file_output.write(strFor)
file_output.close()
