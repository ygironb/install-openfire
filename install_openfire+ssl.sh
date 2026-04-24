#!/bin/bash
# Instalación Completa: MariaDB + OpenJDK 25/21 + Openfire + Nginx + SSL
# Compatible con Debian 13 / Ubuntu 24.04 LTS
set -euo pipefail
# ===========================================================================================
# 🎨  COLORES Y FUNCIONES DE SALIDA 
# ===========================================================================================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; \
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'; 
#ok(GREEN)|warn(YELLOW)|error(RED)|step(BLUE)|info(CYAN)|mark(MAGENTA)

#==================================================${NC}"
#🛡️  VERIFICACIÓN DE PRIVILEGIOS ${NC}"
#==================================================${NC}"
trap 'echo -e "\n${RED} Proceso cancelado por el usuario.${NC}"; exit 1' INT TERM
#echo -e "${BLUE}🔒 Verificado usuario root${NC}"
if [[ $EUID -ne 0 ]]; then
    echo -e "${MAGENTA} 🚫 Este script debe ejecutarse como root o con sudo.${NC}"
    exit 1
fi
# ===========================================================================================
# 🗽  VARIABLES FIJAS 
# ===========================================================================================
DOWNLOAD_DIR="/tmp/openfire_install"
SSL_DIR="/etc/ssl/openfire"
OPENFIRE_DB="openfire"
OPENFIRE_USER="openfire"
OPENFIRE_PASS="OpenFireDB_$(openssl rand -hex 4)"
TZ_NAME="America/Havana"
# ===========================================================================================
mkdir -p "$DOWNLOAD_DIR" "$SSL_DIR"
# ===========================================================================================
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}1. 🕒 CONFIGURAR ZONA HORARIA ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[1/14] Configurando Zona Horaria (America/Havana)...⌛${NC}"
DEBIAN_FRONTEND=noninteractive apt install -y tzdata &>/dev/null
if [ -f "/usr/share/zoneinfo/$TZ_NAME" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ_NAME" /etc/localtime
    echo "$TZ_NAME" > /etc/timezone
    command -v timedatectl &>/dev/null && timedatectl set-timezone "$TZ_NAME" 2>/dev/null || true
    dpkg-reconfigure -f noninteractive tzdata &>/dev/null || true
    hwclock --systohc &>/dev/null || true
    echo -e "${GREEN}✔️ Zona horaria configurada a $TZ_NAME ${NC}"
fi
echo -e "${GREEN}👌 Fecha y Hora del Sistema: $(date) ${NC}"
# ===========================================================================================
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}2. 🔍  ACTUALIZAR INDICE Y PAQUETES DEL SISTEMA ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[2/14] Actualizando Indice y Paquetes de Sistema...⌛${NC}"
apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}3. 📦  INSTALANDO DEPENDENCIAS NECESARIAS ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[3/14] Instalando Dependencias...⌛${NC}"
apt install -y curl openssl git

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}4. 🔧  INSTALAR NGINX ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[4/14] Instalando Nginx...⌛${NC}"
apt install -y nginx
systemctl enable --now nginx

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}5. 🔧 INSTALAR MARIADB ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[5/14] Instalando MariaDB...⌛${NC}"
apt install -y mariadb-server mariadb-client
systemctl enable --now mariadb

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}6. 🔑 CONFIGURACIÓN DE CONTRASEÑA ROOT MARIADB ${NC}"
echo -e "${CYAN}==================================================${NC}"
read -p "Ingrese la contraseña para el usuario root de MariaDB: " -s ROOT_PASS
echo
read -p "Confirme la contraseña: " -s ROOT_PASS_CONFIRM
echo
if [ "$ROOT_PASS" != "$ROOT_PASS_CONFIRM" ]; then
    echo -e "${MAGENTA}Las contraseñas no coinciden. Intente de nuevo.${NC}"
    exit 1
fi
if [ -z "$ROOT_PASS" ]; then
    echo -e "${MAGENTA}La contraseña no puede estar vacía.${NC}"
    exit 1
fi

echo -e "${GREEN}Configurando contraseña de root...${NC}"
if mysql -u root -e "SELECT 1;" &>/dev/null; then
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
FLUSH PRIVILEGES;
EOF
else
    echo -e "${MAGENTA}🚨 Ya existe una contraseña configurada.${NC}"
    read -p "Ingrese la contraseña ACTUAL de root: " -s CURRENT_PASS
    echo
    if [ -z "$CURRENT_PASS" ]; then
        echo -e "${YELLOW} Se requiere la contraseña actual para continuar.${NC}"
        exit 1
    fi
    mysql -u root -p"${CURRENT_PASS}" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
FLUSH PRIVILEGES;
EOF
fi
echo -e "${GREEN}✔️ Contraseña de root actualizada.${NC}"

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN} 7. 🔒 SEGURIDAD EN MARIADB ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[7/14] Aplicando Seguridad en MariaDB...⌛${NC}"
mysql -u root -p"${ROOT_PASS}" <<EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
echo -e "${GREEN}✔️ Seguridad aplicada.${NC}"

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN} 8. 📊 CREAR DB Y USUARIO PARA OPENFIRE ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[8/14] Creando DB y Usuario...${NC}"
mysql -u root -p"${ROOT_PASS}" <<EOF
CREATE DATABASE IF NOT EXISTS ${OPENFIRE_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${OPENFIRE_USER}'@'localhost' IDENTIFIED BY '${OPENFIRE_PASS}';
GRANT ALL PRIVILEGES ON ${OPENFIRE_DB}.* TO '${OPENFIRE_USER}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
echo -e "${GREEN}✔️ DB y Usuario Creados.${NC}"

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN} 9. 🔧 INSTALAR OPENJDK JRE ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[9/14] INSTALAR OPENJDK JRE...⌛${NC}"
if apt-cache show openjdk-25-jre 2>/dev/null | grep -q "Package:"; then
    apt install -y openjdk-25-jre
else
    echo -e "${✔YELLOW}OpenJDK 25 no disponible, instalando 21...⌛${NC}"
    apt install -y openjdk-21-jre
fi
echo -e "${GREEN}✔️ Java instalado: $(java -version 2>&1 | head -n 1)${NC}"

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN} 10. 🔽 DESCAGAR OPENFIRE ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[10/14] Descargando Openfire...⌛${NC}"
OPENFIRE_VERSION=$(curl -s https://api.github.com/repos/igniterealtime/Openfire/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | tr -d 'v')
[ -z "$OPENFIRE_VERSION" ] && OPENFIRE_VERSION="5.0.3"
echo -e "${GREEN}Utima Versión: ${OPENFIRE_VERSION}${NC}"
OPENFIRE_DEB="openfire_${OPENFIRE_VERSION}_all.deb"
OPENFIRE_URL="https://github.com/igniterealtime/Openfire/releases/download/v${OPENFIRE_VERSION}/${OPENFIRE_DEB}"

cd "$DOWNLOAD_DIR"
for attempt in {1..3}; do
    if curl -sL -o "$OPENFIRE_DEB" "$OPENFIRE_URL" && [ -s "$OPENFIRE_DEB" ]; then
        echo -e "${GREEN}✔️ Descarga completada.${NC}"
        break
    fi
    echo -e "${YELLOW}🚨 Intento $attempt fallido...${NC}"
    sleep 2
done
[ ! -f "$OPENFIRE_DEB" ] || [ ! -s "$OPENFIRE_DEB" ] && { echo -e "${RED}❌ Falló la Descarga.${NC}"; exit 1; }

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN} 11. 🔧 INSTALAR OPENFIRE${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[11/14] Instalando Openfire...⌛${NC}"
apt install -y libpam-modules
dpkg -i "$DOWNLOAD_DIR/$OPENFIRE_DEB"
apt install -f -y
echo -e "${GREEN}✔️ Openfire instalado.${NC}"

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}12. ▶️ INICIAR SERVICIO OPENFIRE ${NC}"
echo -e "==================================================${NC}"
echo -e "${BLUE}[12/14] Iniciando Openfire...${NC}"
systemctl enable --now openfire
sleep 5
if systemctl is-active --quiet openfire; then
    echo -e "${GREEN}✔️ Openfire activo.${NC}"
else
    echo -e "${MAGENTA}🚨 Openfire no inició. Revisa logs: journalctl -u openfire${NC}"
fi

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN} 13. 🔐 GENERAR EL CERTIFICADO XMPP EN NGINX ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[13/14] Configurando SSL y Nginx...${NC}"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/openfire.key" -out "$SSL_DIR/openfire.crt" \
    -subj "/C=Cu/ST=Hab/L=Hab/O=Openfire/CN=$(hostname -f 2>/dev/null || hostname)" 2>/dev/null

cat > /etc/nginx/sites-available/openfire <<'EOF'
server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    server_name _;
    ssl_certificate /etc/ssl/openfire/openfire.crt;
    ssl_certificate_key /etc/ssl/openfire/openfire.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    location / {
        proxy_pass http://localhost:9090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF
ln -sf /etc/nginx/sites-available/openfire /etc/nginx/sites-enabled/openfire
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
echo -e "${GREEN}✔️ Nginx configurado con SSL.${NC}"

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN} 14. 🔄 SINCRONIZAR EL CERTIFICADO XMPP ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${BLUE}[14/14] SINCRONIZANDO CERTIFICADO XMPP...${NC}"
openssl pkcs12 -export -in "$SSL_DIR/openfire.crt" -inkey "$SSL_DIR/openfire.key" \
    -out /tmp/openfire.p12 -name openfire -passout pass:changeit -nodes 2>/dev/null

OPENFIRE_KEYSTORE="/usr/share/openfire/resources/security/keystore"
OPENFIRE_TRUSTSTORE="/usr/share/openfire/resources/security/truststore"
[ -f "$OPENFIRE_KEYSTORE" ] && cp "$OPENFIRE_KEYSTORE" "${OPENFIRE_KEYSTORE}.bak.$(date +%F)"

keytool -importkeystore -srckeystore /tmp/openfire.p12 -srcstoretype PKCS12 -srcstorepass changeit \
    -destkeystore "$OPENFIRE_KEYSTORE" -deststorepass changeit -destkeypass changeit -alias openfire -noprompt 2>/dev/null || true
keytool -importcert -file "$SSL_DIR/openfire.crt" -keystore "$OPENFIRE_TRUSTSTORE" \
    -storepass changeit -alias openfire-self -noprompt 2>/dev/null || true
chown openfire:openfire "$OPENFIRE_KEYSTORE" "$OPENFIRE_TRUSTSTORE" 2>/dev/null || true
chmod 640 "$OPENFIRE_KEYSTORE" "$OPENFIRE_TRUSTSTORE" 2>/dev/null || true

systemctl restart openfire
sleep 3
rm -f /tmp/openfire.p12
echo -e "${GREEN}✔️ Certificado XMPP sincronizado.${NC}"

echo
echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}  📜 INSTALACIÓN COMPLETADA EXITOSAMENTE${NC}"
echo -e "${CYAN}==================================================${NC}"
echo
echo -e "${GREEN}📊 DATOS OPENFIRE DB:${NC}"
echo "  - Servidor: localhost:3306"
echo "  - DB: $OPENFIRE_DB"
echo "  - User: $OPENFIRE_USER"
echo "  - Pass: $OPENFIRE_PASS"
echo
echo -e "${GREEN}🔐 DATOS MARIADB ROOT:${NC}"
echo "  - User: root"
echo "  - Pass: $ROOT_PASS"
echo
echo -e "${YELLOW}🌐 PANEL WEB: https://$(hostname -f | awk '{print $1}')${NC}"
echo -e "${YELLOW}📂 LOGS: sudo tail -f /var/log/openfire/error.log${NC}"
echo -e "${YELLOW}🔧 Configura un registro tipo A que apunte a la IP de este servidor.${NC}"
echo -e "${YELLOW}👉 Abra la URL, acepta el certificado autofirmado y usa los datos de DB.${NC}"