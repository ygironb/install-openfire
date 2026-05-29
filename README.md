## Openfire es un servidor de mensajería y colaboración en tiempo real de código abierto (Apache 2.0) basado en el protocolo estándar XMPP (Jabber) . Está escrito en Java, lo que lo hace multiplataforma, y destaca por su facilidad de instalación y su potente interfaz de administración web .

## Características Principales
Gestión sencilla: Panel de control web intuitivo para gestionar usuarios, salas y configuraciones sin necesidad de editar archivos manualmente .
* Base de datos integrada: Utiliza una base de datos embebida (HSQLDB/Apache Derby) que permite ejecutar el servidor sin configuraciones externas complejas, aunque soporta sistemas como MySQL o PostgreSQL .
* Comunicación enriquecida: Soporta salas de chat multiusuario (MUC) , transferencia de archivos, almacenamiento de mensajes offline y libretas de contactos (roster) .
* Extensible: Su arquitectura basada en plugins permite añadir funcionalidades como filtros antispam, integración con redes sociales antiguas o conexiones SIP .
* Seguridad y Empresa: Ofrece cifrado TLS/SSL para las comunicaciones e integración con LDAP / Active Directory para sincronizar usuarios corporativos .
* Alto rendimiento: Capaz de soportar miles de usuarios concurrentes en un solo servidor, ideal para empresas o proyectos educativos .

## 🛠️ Poner el servicio de Openfire en funcionamiento

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

### Puede abrir la Web poniendo el protocolo **_"https"_** y sin el puerto **_"9090"_**
![AbriendoConsola Web](./imgs/02-Abrir%20la%20web.png)

### Opciones para la sincronización de Openfire con el Directorio Activo (AD)
![DirectorioActivo](./imgs/03-Directorio-Activo.png)

### Poniendo la DB, usuario y contraseña de Openfire 
![BD](./imgs/04-BD.png)

### Conexión válida con el AD través de LDAPS:636 si lo tienes configurados, sino usa LDAP:389  
![ConexiónVálida](./imgs/05-Conexi%C3%B3n%20v%C3%A1lida.png)

### Usuario para administrar la consola, se debió haber creado previamente en el AD  
![UsuarioAdmin](./imgs/07-Usuario%20openfire_admin%20consola.png)

### Configuración completa  
![ConfiguracionCompleta](./imgs/08-Configuraci%C3%B3n%20Completa.png)
