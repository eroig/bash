#!/bin/bash

# ============================================================
# Script de instalación y configuración de Podman
# ============================================================

set -e  # Detener la ejecución si hay algún error

echo ">>> [1/3] Instalando dependencias..."
apt update
apt install -y podman podman-compose btop

echo ">>> [2/3] Habilitando el servicio de Podman..."
systemctl enable --now podman

echo ">>> [3/3] Configurando el registro de contenedores..."
if ! grep -q 'unqualified-search-registries' /etc/containers/registries.conf; then
    echo 'unqualified-search-registries = ["docker.io"]' >> /etc/containers/registries.conf
    echo "    Configuración añadida a registries.conf"
else
    echo "    La configuración ya existe, omitiendo..."
fi

echo ""
echo "============================================================"
echo "  Instalación completada."
echo "============================================================"
echo "  Verifica con:"
echo "    podman --version"
echo "    podman-compose --version"
echo "    btop"
echo "============================================================"
