# cis_apache

Posicionarte en la carpeta
```
$ cd cis_apache
```

## Ejecución
***
Darle permisos de ejecución a todos los archivos shell
```
$ chmod +x apache_scriptP.sh mod*apache.sh
```

Descomprimir la carpeta 'jo-master-v1.zip'
```
$ unzip jo-master-v1.zip
```

Ejecutar el shell principal con un usuario **root** o con privilegios de root
```
$ ./apache_scriptP.sh
```

Se genera un archivo HTML de reporte con el nombre **Totalsec_Apache.html**


Duda????
Exportar al path la biblioteca **JO** que está en el directorio jo-master
```
$ export PATH="$(cd "$(dirname "$0")"; pwd)/jo-master:$PATH"
```
