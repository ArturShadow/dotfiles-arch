#!/bin/bash

# Variables
IMAGE_PATH=""

# Leer argumentos
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--image)
            IMAGE_PATH="$2"
            shift
            ;;
        *)
            echo "❌ Opción desconocida: $1"
            echo "Uso: $0 --image /ruta/a/imagen.jpg"
            exit 1
            ;;
    esac
    shift
done

# Validar que pasaron la imagen
if [ -z "$IMAGE_PATH" ]; then
    echo "❌ Debes especificar la imagen con --image"
    echo "Uso: $0 --image /ruta/a/imagen.jpg"
    exit 1
fi

echo "🚀 Usando imagen: $IMAGE_PATH"

echo "🚀 Instalando dependencias necesarias..."
sudo pacman -S --needed git base-devel

echo "⬇️ Clonando aura-bin desde AUR..."
cd /tmp
rm -rf aura-bin
git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin
makepkg -si --noconfirm
echo "✅ Aura instalado correctamente."

echo "🚀 Instalando rofi-power-menu..."
sudo aura -A --noconfirm rofi-power-menu
echo "✅ rofi-power-menu instalado."

echo "🚀 Instalando betterlockscreen..."
sudo pacman -S --needed betterlockscreen
echo "✅ betterlockscreen instalado."

echo "🚀 Instalando picom y papirus-icon-theme..."
sudo pacman -S --needed picom papirus-icon-theme
echo "✅ picom y Papirus icon theme instalados."

echo "🚀 Copiando configuraciones desde $(pwd)/copy-config a $HOME/.config"
cp -rf "$(pwd)/copy-config" "$HOME/.config"


# Preparar .local/bin
DEST="$HOME/.local/bin"
if [ ! -d "$DEST" ]; then
    mkdir -p "$DEST"
    echo "📁 Se creó $DEST"
fi

# Mover y dar permisos al script
mv "$HOME/.config/copy-config/rofi-powermenu.sh" "$DEST/"
chmod +x "$DEST/rofi-powermenu.sh"
echo "🚀 Se movió y dio permisos a $DEST/rofi-powermenu.sh"

# Enlace simbólico para lightdm
# Enlace simbólico para lightdm con backup
SRC="$HOME/.config/lightdm/lightdm-gtk-greeter.conf"
DEST_ETC="/etc/lightdm/lightdm-gtk-greeter.conf"

if [ -L "$DEST_ETC" ]; then
    echo "✅ El enlace simbólico ya existe: $DEST_ETC"
else
    if [ -f "$DEST_ETC" ]; then
        sudo mv "$DEST_ETC" "$DEST_ETC-backup"
        echo "🗄 Archivo original movido a $DEST_ETC-backup"
    fi
    sudo ln -s "$SRC" "$DEST_ETC"
    echo "🔗 Enlace creado: $DEST_ETC -> $SRC"
fi


# Permisos al background
IMAGE_DIR="$(dirname "$IMAGE_PATH")"
chmod +x "$HOME"
chmod +x "$IMAGE_DIR"
chmod 644 "$IMAGE_PATH"
echo "🔒 Permisos dados a $IMAGE_PATH"

# Inicializar betterlockscreen
betterlockscreen -u "$IMAGE_PATH"
echo "✅ betterlockscreen configurado con $IMAGE_PATH"
