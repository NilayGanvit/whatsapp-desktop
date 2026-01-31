BROWSER="brave-browser" # Or "firefox", "google-chrome" 
APP_NAME="WhatsApp"
APP_EXEC="${BROWSER} --app=https://web.whatsapp.com"
ICON_URL="https://static.whatsapp.net/rsrc.php/v3/yP/r/rYZqPCBaG70.png"
ICON_PATH="${HOME}/.local/share/icons/whatsapp.png"
DESKTOP_FILE="${HOME}/.local/share/applications/whatsapp-webapp.desktop"

# Check if browser is installed
if ! command -v ${BROWSER} &> /dev/null; then
    echo "Error: ${BROWSER} is not installed. Please install it first."
    exit 1
fi

# Download icon
if [ ! -d "${HOME}/.local/share/icons" ]; then
    mkdir -p "${HOME}/.local/share/icons"
fi

if ! curl -s ${ICON_URL} -o ${ICON_PATH}; then         
    echo "Warning: Could not download icon."
fi

# Create desktop file
cat > ${DESKTOP_FILE} << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
Comment=WhatsApp Web as Desktop App
Exec=${APP_EXEC}
Icon=${ICON_PATH}
Terminal=false
Categories=Network;InstantMessaging;
EOF

# Set executable permissions
chmod +x ${DESKTOP_FILE}
echo "WhatsApp Web App has been successfully installed!"
echo "You can find it in your application menu or with: ${APP_EXEC}"

# Create keyboard shortcut (Super+W)
echo ""
echo "Setting up keyboard shortcut (Super+W)..."

# Try to set shortcut via dconf (GNOME)
if command -v dconf &> /dev/null; then
    CUSTOM_KEYBINDINGS="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
    KEYBINDING_PATH="${CUSTOM_KEYBINDINGS}/whatsapp-webapp/"
    
    # Get current custom keybindings
    CURRENT_BINDINGS=$(dconf read ${CUSTOM_KEYBINDINGS})
    
    # Add new keybinding if not already present
    if [[ ! "$CURRENT_BINDINGS" =~ "whatsapp-webapp" ]]; then
        # Set the custom keybinding values
        dconf write "${KEYBINDING_PATH}name" "'Open WhatsApp'" 2>/dev/null
        dconf write "${KEYBINDING_PATH}command" "'${APP_EXEC}'" 2>/dev/null
        dconf write "${KEYBINDING_PATH}binding" "'<Super>w'" 2>/dev/null
        
        echo "Keyboard shortcut (Super+W) has been set via GNOME Settings!"
    else
        echo "WhatsApp keyboard shortcut already exists."
    fi
elif command -v xbindkeys &> /dev/null; then
    # Fallback: Use xbindkeys
    XBINDKEYS_CONFIG="${HOME}/.xbindkeysrc"
    
    # Add binding to xbindkeys config if not present
    if ! grep -q "whatsapp" "${XBINDKEYS_CONFIG}" 2>/dev/null; then
        echo "" >> "${XBINDKEYS_CONFIG}"
        echo "# WhatsApp Web App" >> "${XBINDKEYS_CONFIG}"
        echo "\"${APP_EXEC}\"" >> "${XBINDKEYS_CONFIG}"
        echo "  mod4 + w" >> "${XBINDKEYS_CONFIG}"
        
        # Restart xbindkeys
        pkill xbindkeys 2>/dev/null
        xbindkeys &
        echo "Keyboard shortcut (Super+W) has been set via xbindkeys!"
    else
        echo "WhatsApp keyboard shortcut already exists in xbindkeys."
    fi
else
    echo "Warning: No supported keyboard shortcut manager found (GNOME or xbindkeys)."
    echo "Please manually bind Super+W to: ${APP_EXEC}"
fi
