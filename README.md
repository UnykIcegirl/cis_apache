# cis_apache


## Ejecución
***
Darle permisos de ejecución a todos los archivos shell
```
$ chmod +x apache_scriptP.sh mod*apache.sh
```

Exportar al path la biblioteca **JO** que está en el directorio jo-master
```
$ export PATH="$(cd "$(dirname "$0")"; pwd)/jo-master:$PATH"
```

Ejecutar el shell principal con un usuario **root** o con privilegios de root
```
$ ./apache_scriptP.sh
```

Se genera un archivo HTML de reporte con el nombre **Totalsec_Apache.html**
