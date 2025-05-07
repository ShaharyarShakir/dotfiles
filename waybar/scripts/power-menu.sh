#!/bin/bash
# Display a simple menu for power options using wofi

# Show menu and capture the user's selection
action=$(echo -e "Logout\nShutdown\nReboot" | wofi --dmenu --prompt "Power Options" --width 300 --height 300)

# Execute based on the user's choice
case "$action" in
    "Logout")
       hyprctl dispatch exit
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    *)
        echo "No valid option selected. Exiting."
        exit 0
        ;;
esac

