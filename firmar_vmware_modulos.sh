#!/bin/bash
#
# Script: firmar_vmware_modulos.sh
# Describe: Automatically signs the vmmon and vmnet modules for VMware with Secure Boot enabled. - Firma automáticamente los módulos vmmon y vmnet para VMware con Secure Boot activado. - Signiert automatisch die vmmon- und vmnet-Module für VMware mit aktiviertem Secure Boot.
# Autor: Juan2 <https://github.com/EI-Flores>
# License: MIT
# Repository: https://github.com/EI-Flores/vmware-secureboot-patch-Linux/
# Made: 2025-05-01
#
# Use: ./firmar_vmware_modulos.sh


# Ruta base
SIGN_DIR="$HOME/vmware-signing"
PRIVATE_KEY="$SIGN_DIR/MOK.priv"
PUBLIC_CERT="$SIGN_DIR/MOK.der"

# Kernel y scripts
KERNEL_VERSION=$(uname -r)
SIGN_TOOL="/usr/src/kernels/$KERNEL_VERSION/scripts/sign-file"
MOD_PATH="/lib/modules/$KERNEL_VERSION/misc"

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Ubicacion de gestores de paquetes
# which comando para obtener ruta de un binario especifico
DEBIAN_BASED_PACKAGE_MANAGER=$(which apt)
FEDORA_PACKAGE_MANAGER=$(which dnf)
ARCH_PACKAGE_MANAGER="$(which pacman)"

# Ubicación binarios
MOKUTIL_BINARY=$(which mokutil)
OPENSSL_BINARY=$(which openssl)
MODPROBE_BINARY=$(which modprobe)


# Función para firmar un módulo
firmar_modulo() {
  local mod_name=$1
  local mod_file="$MOD_PATH/$mod_name"

  if [ -f "$mod_file" ]; then
    echo "🔐 Signing $mod_name..."
    echo "🔐 Firmando $mod_name..."
    echo "🔐 Signierung von $mod_name …"
    if [ -f $SIGN_TOOL ]; then
      sudo "$SIGN_TOOL" sha256 "$PRIVATE_KEY" "$PUBLIC_CERT" "$mod_file"
      echo -e "${GREEN}✔ Module $mod_name signed successfully.${NC}"
      echo -e "${GREEN}✔ Módulo $mod_name firmado correctamente.${NC}"
      echo -e "${GREEN}✔ Modul $mod_name erfolgreich signiert.${NC}"
    fi
  else
    echo -e "${RED}❌ $mod_name not found in $MOD_PATH${NC}"
    echo -e "${RED}❌ No se encontró $mod_name en $MOD_PATH${NC}"
    echo -e "${RED}❌ $mod_name nicht gefunden in $MOD_PATH${NC}"
  fi
}

# Function para preparar el entorno
preparar_entorno() {

# Función para comprobar si los paquetes estan instalados 
if [ -f "$OPENSSL_BINARY" ] && [ -f "$MOKUTIL_BINARY" ]; then
  echo -e "${GREEN} ✅ Dependencies are already installed!"
  echo -e  "${GREEN} ✅ Las dependencias ya estan instaladas!"
  echo -e "${GREEN} ✅ Abhängigkeiten sind bereits installiert!"
else
  if [ -f "$DEBIAN_BASED_PACKAGE_MANAGER" ]; then
    echo -e "${GREEN} ✅ The apt binary was detected!"
    echo -e "${GREEN} ✅ El binario apt fue detectado!"
    echo -e "${GREEN} ✅ Die Apt-Binärdatei wurde erkannt!"
    sudo $DEBIAN_BASED_PACKAGE_MANAGER install mokutil openssl -y
  fi
  if [ -f "$FEDORA_PACKAGE_MANAGER" ]; then
    echo -e "${GREEN} ✅ The dnf binary was detected!"
    echo -e "${GREEN} ✅ El binario dnf fue detectado!"
    echo -e "${GREEN} ✅ Die dnf-Binärdatei wurde erkannt!"
    sudo $FEDORA_PACKAGE_MANAGER install mokutil openssl -y
  fi
  if [ -f "$ARCH_PACKAGE_MANAGER" ]; then
    echo -e "${GREEN} ✅ The pacman binary was detected!"
    echo -e "${GREEN} ✅ El binario pacman fue detectado!"
    echo -e "${GREEN} ✅ Die pacman-Binärdatei wurde erkannt!"
    sudo $ARCH_PACKAGE_MANAGER -Sy openssl mokutil
  fi
fi
echo "Creando directorios..."
if [ ! -d ~/vmware-signing ]; then
  mkdir -p ~/vmware-signing
else
  echo -e "${RED} Folder already exists!"
  echo -e "${RED} La carpeta ya existe!"
  echo -e "${RED} Ordner existiert bereits!"
fi
echo "Creando certificados necessarios para firmar los modulos."
$OPENSSL_BINARY req -new -x509 -newkey rsa:2048 -keyout ~/vmware-signing/MOK.priv -outform DER -out ~/vmware-signing/MOK.der -nodes -days 36500 -subj "/CN=VMware Kernel Module Signing/"
echo "Import MOK.der to Secure Boot"
sudo $MOKUTIL_BINARY --import $PUBLIC_CERT
echo "The environment has been prepared! Proceeding to sign the modules...."
echo "Se ha preparado el entorno! Procediendo a firmar los modulos...."
echo "Die Umgebung wurde vorbereitet! Fahren Sie mit der Signierung der Module fort..."

# Comprobar si los certificados fueron creados
# Verificación de existencia
if [ ! -f "$PRIVATE_KEY" ] || [ ! -f "$PUBLIC_CERT" ]; then
  echo -e "\n ${RED}❌ Keys not found in $SIGN_DIR. Make sure you generated them.${NC}"
  echo -e "\n ${RED}❌ Claves no encontradas en $SIGN_DIR. Asegúrate de haberlas generado.${NC}"
  echo -e "\n ${RED}❌ Schlüssel nicht in $SIGN_DIR gefunden. Stellen Sie sicher, dass Sie sie generiert haben.${NC}"
  exit 1
fi

# Ejecutar firmado
firmar_modulo "vmmon.ko"
firmar_modulo "vmnet.ko"

echo "Iniciando vmmon y vmnet"
sudo "$MODPROBE_BINARY" vmmon
sudo "$MODPROBE_BINARY" vmnet
lsmod | grep vm*
echo -e "\n 🇬🇧 ${GREEN} ✅ If it appears in the list, it means it has been loaded successfully!${NC}"
echo -e "\n 🇪🇸 ${GREEN} ✅ Si sale en la lista quiere decir que se ha cargado con exito!${NC}"
echo -e "\n 🇩🇪 ${GREEN} ✅ Wenn es in der Liste erscheint, bedeutet das, dass es erfolgreich geladen wurde!${NC}"

# Verificar si la clave MOK ya está inscrita
if mokutil --list-enrolled | grep -q "VMware Kernel Module Signing"; then
  echo -e "🇬🇧 ${GREEN}✅ The 'VMware Kernel Module Signing' key is already successfully enrolled.${NC}"
  echo -e "🇪🇸 ${GREEN}✅ La clave 'VMware Kernel Module Signing' ya está inscrita correctamente.${NC}"
  echo -e "🇩🇪 ${GREEN}✅ Der Schlüssel „VMware Kernel Module Signing“ wurde bereits erfolgreich registriert.${NC}"
else
  echo -e "🇬🇧"
  echo -e "${RED}⚠️ The key is not enrolled yet.${NC}"
  echo -e "${RED}🔄 Please restart your computer and select 'Enroll MOK' from the blue menu upon startup.${NC}"
  echo -e "${RED}Then run this script again to re-sign the modules.${NC}"
  echo -e "🇪🇸"
  echo -e "${RED}⚠️  La clave aún no está inscrita.${NC}"
  echo -e "${RED}🔄 Por favor, reinicia tu equipo y selecciona 'Enroll MOK' en el menú azul al arrancar.${NC}"
  echo -e "${RED}Luego vuelve a ejecutar este script para firmar nuevamente los módulos.${NC}"
  echo -e "🇩🇪"
  echo -e "${RED}⚠️ Der Schlüssel ist noch nicht registriert.${NC}"
  echo -e "${RED}🔄 Bitte starten Sie Ihren Computer neu und wählen Sie beim Start im blauen Menü „MOK registrieren“ aus.${NC}"
  echo -e "${RED}Führen Sie dieses Skript dann erneut aus, um die Module erneut zu signieren.${NC}"
fi
echo -e "${GREEN}ℹ️ If the modules still fail to load, try restarting and re-running the script.${NC}"
echo -e "${GREEN}ℹ️  Si los módulos siguen sin cargarse, intenta reiniciar y volver a ejecutar el script.${NC}"
echo -e "${GREEN}ℹ️ Wenn das Laden der Module immer noch fehlschlägt, versuchen Sie, das Skript neu zu starten und erneut auszuführen.${NC}"

}
preparar_entorno
