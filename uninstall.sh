#!/system/bin/sh
# Safe uninstaller
resetprop -d persist.vendor.camera.forceDisableUBWCOnIfeIpeLink
resetprop -d persist.vendor.camera.disableIPEInternalDownscale
resetprop -d persist.vendor.camera.maxRAWSizes
resetprop -d persist.vendor.camera.overrideOPPCLOCK
resetprop -d persist.vendor.camera.enableInternalHALPixelStreamConfig
resetprop -d persist.vendor.camera.csidClockFrequencyMHz
resetprop -d persist.vendor.camera.ife.clockFrequencyMHz
resetprop -d persist.vendor.camera.ife.camnocBandwidthMBytes
resetprop -d persist.vendor.camera.ife.externalBandwidthMBytes
resetprop -d persist.vendor.camera.dynamicPropertiesEnabled
resetprop -d persist.vendor.camera.IFEnumFramesHighBW
stop cameraserver; start cameraserver
