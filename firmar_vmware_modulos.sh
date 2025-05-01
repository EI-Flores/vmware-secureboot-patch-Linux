#!/bin/bash
#
# Script: firmar_vmware_modulos.sh
# Descripción: Firma automáticamente los módulos vmmon y vmnet para VMware con Secure Boot activado.
# Autor: Juan2 <https://github.com/EI-Flores>
# Licencia: MIT
# Repositorio: https://github.com/EI-Flores/vmware-secureboot-patch-Linux/
# Fecha de creación: 2025-05-01
#
# Uso: ./firmar_vmware_modulos.sh


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
    echo "🔐 Firmando $mod_name..."
    if [ -f $SIGN_TOOL ]; then
      sudo "$SIGN_TOOL" sha256 "$PRIVATE_KEY" "$PUBLIC_CERT" "$mod_file"
      echo -e "${GREEN}✔ Módulo $mod_name firmado correctamente.${NC}"
    fi
  else
    echo -e "${RED}❌ No se encontró $mod_name en $MOD_PATH${NC}"
  fi
}

# Function para preparar el entorno
preparar_entorno() {

# Función para comprobar si los paquetes estan instalados 
if [ -f "$OPENSSL_BINARY" ] && [ -f "$MOKUTIL_BINARY" ]; then
  echo -e  "${GREEN} ✅ Las dependencias ya estan instaladas!"
else
  if [ -f "$DEBIAN_BASED_PACKAGE_MANAGER" ]; then
    echo -e "${GREEN} ✅ El binario apt fue detectado!"
    sudo $DEBIAN_BASED_PACKAGE_MANAGER install mokutil openssl -y
  fi
  if [ -f "$FEDORA_PACKAGE_MANAGER" ]; then
    echo -e "${GREEN} ✅ El binario dnf fue detectado!"
    sudo $FEDORA_PACKAGE_MANAGER install mokutil openssl -y
  fi
  if [ -f "$ARCH_PACKAGE_MANAGER" ]; then
    echo -e  "${GREEN} ✅ El binario pacman fue detectado!"
    sudo $ARCH_PACKAGE_MANAGER -Sy openssl mokutil
  fi
fi
echo "Creando directorios..."
if [ ! -d ~/vmware-signing ]; then
  mkdir -p ~/vmware-signing
else
  echo -e "${RED} La carpeta ya existe!"
fi
echo "Creando certificados necessarios para firmar los modulos."
$OPENSSL_BINARY req -new -x509 -newkey rsa:2048 -keyout ~/vmware-signing/MOK.priv -outform DER -out ~/vmware-signing/MOK.der -nodes -days 36500 -subj "/CN=VMware Kernel Module Signing/"
echo "Importando MOK.der a Secure Boot"
sudo $MOKUTIL_BINARY --import $PUBLIC_CERT
echo "Se ha preparado el entorno! Procediendo a firmar los modulos...."

# Comprobar si los certificados fueron creados
# Verificación de existencia
if [ ! -f "$PRIVATE_KEY" ] || [ ! -f "$PUBLIC_CERT" ]; then
  echo -e "${RED}❌ Claves no encontradas en $SIGN_DIR. Asegúrate de haberlas generado.${NC}"
  exit 1
fi

# Ejecutar firmado
firmar_modulo "vmmon.ko"
firmar_modulo "vmnet.ko"

echo "Iniciando vmmon y vmnet"
sudo "$MODPROBE_BINARY" vmmon
sudo "$MODPROBE_BINARY" vmnet
lsmod | grep vm*
echo "${GREEN} ✅ Si sale en la lista quiere decir que se ha cargado con exito!"
}
preparar_entorno
