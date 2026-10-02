#!/system/bin/sh

# Apply persist properties for camera pipeline
resetprop -p --file "$MODPATH"/persist.prop

# Restart cameraserver after boot completed to ensure clean session
(
  while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
  done
  stop cameraserver; start cameraserver
)&
