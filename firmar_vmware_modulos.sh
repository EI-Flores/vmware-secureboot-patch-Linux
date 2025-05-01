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

# Función para firmar un módulo
firmar_modulo() {
  local mod_name=$1
  local mod_file="$MOD_PATH/$mod_name"

  if [ -f "$mod_file" ]; then
    echo "🔐 Firmando $mod_name..."
    sudo "$SIGN_TOOL" sha256 "$PRIVATE_KEY" "$PUBLIC_CERT" "$mod_file"
    echo -e "${GREEN}✔ Módulo $mod_name firmado correctamente.${NC}"
  else
    echo -e "${RED}❌ No se encontró $mod_name en $MOD_PATH${NC}"
  fi
}

# Verificación de existencia
if [ ! -f "$PRIVATE_KEY" ] || [ ! -f "$PUBLIC_CERT" ]; then
  echo -e "${RED}❌ Claves no encontradas en $SIGN_DIR. Asegúrate de haberlas generado.${NC}"
  exit 1
fi

# Ejecutar firmado
firmar_modulo "vmmon.ko"
firmar_modulo "vmnet.ko"

# Final
echo -e "${GREEN}✅ Proceso finalizado. Puedes probar cargar con 'modprobe vmmon' y 'modprobe vmnet'.${NC}"

