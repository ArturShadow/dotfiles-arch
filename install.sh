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
sudo pacman -Syu --noconfirm
sudo pacman -S --needed git base-devel xorg xorg-xinit zsh awesome rofi kitty \
    lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings accountsservice \
    betterlockscreen picom papirus-icon-theme unzip neovim lxappearance \
    noto-fonts ttf-jetbrains-mono ttf-font-awesome zsh-syntax-highlighting \
    zsh-autosuggestions wget curl

# Instalar Powerlevel10k
echo "🚀 Instalando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Instalar Oh My Zsh
echo "🚀 Instalando Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Activar Powerlevel10k en .zshrc
sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"

# Añadir plugins a .zshrc si no están
grep -q "zsh-autosuggestions" "$HOME/.zshrc" || echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$HOME/.zshrc"
grep -q "zsh-syntax-highlighting" "$HOME/.zshrc" || echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$HOME/.zshrc"

# Aura para instalar AUR
echo "⬇️ Clonando aura-bin desde AUR..."
cd /tmp
rm -rf aura-bin
git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin
makepkg -si --noconfirm

# Instalar rofi-power-menu
echo "🚀 Instalando rofi-power-menu..."
sudo aura -A --noconfirm rofi-power-menu

# Copiar configuraciones personalizadas
echo "🚀 Copiando configuraciones desde $(pwd)/.config/copy a $HOME/.config"
cp -rf "$(pwd)/.config-copy" "$HOME/.config"

# Preparar .local/bin
DEST="$HOME/.local/bin"
if [ ! -d "$DEST" ]; then
    mkdir -p "$DEST"
    echo "📁 Se creó $DEST"
fi

# Mover y dar permisos al script personalizado de rofi
mv "$HOME/.config/-copy/rofi-powermenu.sh" "$DEST/"
chmod +x "$DEST/rofi-powermenu.sh"

# Enlace simbólico para lightdm
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

# Permisos para la imagen del lockscreen
IMAGE_DIR="$(dirname "$IMAGE_PATH")"
chmod +x "$HOME"
chmod +x "$IMAGE_DIR"
chmod 644 "$IMAGE_PATH"

# Inicializar betterlockscreen
betterlockscreen -u "$IMAGE_PATH"
echo "✅ betterlockscreen configurado con $IMAGE_PATH"

# Habilitar servicios
sudo systemctl enable lightdm.service

echo "✅ Instalación completa."

echo "Estableciendo el avatar para el greteer [lightdm-gtk-greeter]"

# Crear carpetas necesarias para AccountsService
echo "📁 Creando carpetas para AccountsService..."
sudo mkdir -p /var/lib/AccountsService/icons
sudo mkdir -p /var/lib/AccountsService/users

# Configurar avatar del usuario
USERNAME="$(whoami)"
AVATAR_SOURCE="$(pwd)/res/avatar.png"
AVATAR_DEST="/var/lib/AccountsService/icons/$USERNAME"
USER_CONFIG="/var/lib/AccountsService/users/$USERNAME"

if [ -f "$AVATAR_SOURCE" ]; then
    echo "🧑‍🎨 Configurando avatar desde $AVATAR_SOURCE para $USERNAME"
    sudo cp "$AVATAR_SOURCE" "$AVATAR_DEST"
    sudo chmod 644 "$AVATAR_DEST"

    # Crear archivo de configuración del usuario
    sudo tee "$USER_CONFIG" > /dev/null <<EOF
[User]
Icon=$AVATAR_DEST
SystemAccount=false
EOF

    sudo chmod 644 "$USER_CONFIG"
    echo "✅ Avatar configurado correctamente"
else
    echo "⚠️ Avatar no encontrado en $AVATAR_SOURCE. Saltando configuración de avatar."
fi
