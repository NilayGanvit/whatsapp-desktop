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
