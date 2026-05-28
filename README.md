# 🛠️ Poner el servicio de Openfire en funcionamiento

### ⚠️ Si su servidor está detrás de un proxy corporativo, antes de descargar el script tiene que exportar las variables para que pueda salir a internet. Si lo usas con autenticación utilice el siguiente formato reajustando los datos de su infraestructura:
http://user:password@proxy.enterprise.cu:3128

Si lo anterior no es su escenario, vaya directo al punto #1

``` sh
export http_proxy="http://proxy.cualquiera.cu:3128/"
export https_proxy="http://proxy.cualquiera.cu:3128/"
```
#### ✒️ También tienes que correr los comandos siguientes para que "git" funcione correctamente:

``` sh
echo "[http]" >> ~/.gitconfig
echo "    proxy = http://proxy.cualquiera.cu:3128/" >> ~/.gitconfig
```

### 1️⃣.  Clone el repositorio para descargar el script en su servidor, copie y pegue en la terminal

``` sh
   git clone https://github.com/ygironb/install-openfire.git
```
### 2️⃣.  Permisos de ejecución
``` sh
   chmod +x install_openfire+ssl.sh
```
### 3️⃣.  Ejecutarlo  

``` sh
  ./install_openfire+ssl.sh
```

### Una vez completada la instalación le mostrará la salida siguiente
![InstalaciónTerminada](./imgs/01-Instalaci%C3%B3n%20Terminada.png)

### Puede abrir poniendo la URL con **_"https"_** sin el puerto **_"9090"_**
![AbriendoConsola Web](./imgs/02-Abrir%20la%20web.png)

### Opciones para la sincronización de Openfire con el Directorio Activo
![DirectorioActivo](./imgs/03-Directorio-Activo.png)

### Escogiendo la Base de Datosm usuario y contraseña de Openfire 
![BD](./imgs/04-BD.png)

### Conexión válida través del puerto 636 si lo tienes configurados, sino usa el 389  
![ConexiónVálida](./imgs/05-Conexi%C3%B3n%20v%C3%A1lida.png)

### Usuario para administrar la consola, se debió aber creado en el Directorio Activo  
![UsuarioAdmin](./imgs/07-Usuario%20openfire_admin%20consola.png)

### Configuración completa  
![ConfiguracionCompleta](.imgs/08-Configuraci%C3%B3n%20Completa.png
