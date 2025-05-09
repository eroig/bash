#!/bin/bash

# Script para copiar una clave pública SSH a múltiples hosts remotos usando ssh-copy-id

echo "--- Copiador de Clave Pública SSH ---"
echo "Este script te ayudará a distribuir tu clave pública SSH a múltiples hosts remotos."

# --- Solicitar información inicial ---

# Solicitar la ruta de la clave pública
read -r -p "Introduce la ruta completa de la clave pública SSH (.pub): " public_key_path

# Validar que el archivo existe y no es un directorio
if [ ! -f "$public_key_path" ]; then
  echo "Error: El archivo de clave pública '$public_key_path' no existe."
  exit 1
fi

# Opcional: Validar que parece un archivo de clave pública (simple chequeo de extensión)
if [[ "$public_key_path" != *.pub ]]; then
    read -r -p "La ruta '$public_key_path' no termina en .pub. ¿Continuar de todos modos? (s/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Cancelado por el usuario."
        exit 1
    fi
fi


# Solicitar el nombre de usuario remoto
read -r -p "Introduce el nombre de usuario remoto para la conexión SSH (ej: ansible, root): " remote_user

echo ""
echo "--- Listo para copiar la clave ---"
echo "Ahora introduce el nombre del host o dirección IP remoto cada vez que se solicite."
echo "Deja la entrada **en blanco** y presiona Enter para **finalizar** el script."
echo ""

# --- Bucle para copiar a múltiples hosts ---

while true; do
  read -r -p "Host o IP remoto de destino (deja en blanco para salir): " remote_host

  # Salir del bucle si la entrada del host está vacía
  if [ -z "$remote_host" ]; then
    echo "Entrada vacía detectada. Finalizando el proceso de copiado."
    break
  fi

  # Construir el destino en formato usuario@host
  destination="${remote_user}@${remote_host}"

  # Ejecutar ssh-copy-id
  echo "--> Intentando copiar clave para ${destination}..."

  # La opción -i especifica el archivo de identidad (clave pública)
  ssh-copy-id -i "$public_key_path" "$destination"

  # Comprobar el resultado del comando ssh-copy-id
  # ssh-copy-id devuelve 0 si tuvo éxito (ya sea copiando o si la clave ya estaba)
  # o un valor distinto de 0 si hubo un error (ej: conexión fallida, contraseña incorrecta)
  if [ $? -eq 0 ]; then
    echo "--> Clave copiada exitosamente (o ya presente) en ${remote_host}"
  else
    echo "--> !!! ERROR !!! Falló al copiar la clave a ${remote_host}."
    echo "    Posibles causas: Host inaccesible, nombre de usuario incorrecto,"
    echo "    o contraseña incorrecta si te la solicitó (ssh-copy-id usa autenticación por contraseña la primera vez si es necesario)."
  fi

  echo "" # Línea en blanco para separar la salida de cada host

done

echo "--- Proceso de copiado finalizado ---"
echo "Recuerda que es posible que se te haya solicitado la contraseña del usuario remoto"
echo "la primera vez que ssh-copy-id intentó conectarse a cada host."
echo "Ahora deberías poder conectar a esos hosts como el usuario '$remote_user'"
echo "desde esta máquina sin necesidad de contraseña."
