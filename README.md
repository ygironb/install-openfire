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

## Una vez completada la instalación le mostrará una salida como a siguiente
![Instalación Terminada](./imgs/01-Instalaci%C3%B3n%20Terminada.png)
