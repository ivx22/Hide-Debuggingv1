#!/system/bin/sh

# Wait until Android boot is fully completed
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

#  Critical: Disable the global ADB setting (hides "USB Debugging" toggle)
# This prevents apps from seeing that ADB is enabled in Developer Options
settings put global adb_enabled 0

# Optional: Disable ADB installer verification (minor extra stealth)
settings put global verifier_verify_adb_installer 0

# 🔁 Start persistent property spoofing loop
{
    while true; do
        # Hide ADB daemon state
        resetprop -n init.svc.adbd stopped

        # Hide USB configuration/state
        resetprop -n sys.usb.config mtp
        resetprop -n sys.usb.state mtp
        resetprop -n persist.sys.usb.config mtp
        resetprop -n persist.sys.usb.reboot.func mtp
        resetprop -n sys.usb.ffs.ready 0

        # Spoof secure build properties
        resetprop -n ro.secure 1
        resetprop -n ro.debuggable 0
        resetprop -n ro.adb.secure 1

        sleep 5
    done
} &
