#!/bin/bash -e

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Enable U2F devices
if [ ! -f /etc/udev/rules.d/70-u2f.rules ]; then
  echo "Copying U2F udev rules (requires sudo)..."
  sudo cp "${SCRIPT_DIR}/../../config/70-u2f.rules" /etc/udev/rules.d/70-u2f.rules
fi

# Configure touchpad
dconf write /org/gnome/desktop/peripherals/touchpad/two-finger-scrolling-enabled true
dconf write  /org/gnome/desktop/peripherals/touchpad/natural-scroll true

# Automatic suspend
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'suspend'"
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout 1200
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'suspend'"
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout 3600

# Configure launch on Super + Space
# dconf write /org/gnome/desktop/wm/keybindings/switch-input-source "@as []"
# dconf write /org/gnome/desktop/wm/keybindings/switch-input-source-backward "@as []"
# dconf write /org/gnome/shell/extensions/pop-shell/search "['<Super>space']"

# Set up 24 h clock
dconf write /org/gnome/desktop/interface/clock-format "'24h'"
dconf write /org/gtk/settings/file-chooser/clock-format "'24h'"
#dconf write /system/locale/region "'en_DK.UTF-8'"

# Add week numbers to calendar
dconf write /org/gnome/desktop/calendar/show-weekdate true

# Configure dock to auto hide on the left
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'LEFT'"
dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide false

# Add Sound Output extension
if [ ! -d "${HOME}/.local/share/gnome-shell/extensions/sound-output-device-chooser@kgshank.net" ]; then
  SOUND_OUTPUT_EXTENSION="sound-output-device-chooserkgshank.net.v40.shell-extension.zip"
  wget -P /tmp "https://extensions.gnome.org/extension-data/${SOUND_OUTPUT_EXTENSION}"
  gnome-extensions install "/tmp/${SOUND_OUTPUT_EXTENSION}"
  rm "/tmp/${SOUND_OUTPUT_EXTENSION}"

  # Restart shell to update extensions info
  gnome-shell --replace
  gnome-extensions enable sound-output-device-chooser@kgshank.net
fi

# Configure Docker daemon to run as non-root user
if systemctl is-active --quiet docker.service; then
  echo "Disabling system-wide Docker daemon..."
  sudo systemctl disable --now docker.service docker.socket
fi
if ! systemctl is-active --user --quiet docker.service; then
  echo "Enabling rootless Docker daemon..."
  dockerd-rootless-setuptool.sh install
fi
