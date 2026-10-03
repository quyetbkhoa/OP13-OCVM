#!/system/bin/sh
# --- ISP / clock / bandwidth boost ---
resetprop persist.vendor.camera.max_isp_clk 1
resetprop persist.vendor.camera.max_bw 1
resetprop persist.vendor.camera.perf_mode 1
resetprop vendor.camera.hal.perf_mode 1
resetprop vendor.camera.hal.perf_boost 1
resetprop persist.vendor.camera.hal.perf_mode 1
resetprop persist.vendor.camera.enable_dsp_boost 1
resetprop persist.vendor.camera.dsp_boost 1
resetprop persist.vendor.camera.boost_cp 1

# --- RAW burst / preview buffers ---
resetprop vendor.arcsoft.arc_burst_buffer_num_raw 14
resetprop vendor.arcsoft.arc_burst_buffer_num 14
resetprop vendor.camera.hal.max_preview_buffers 10

# --- JPEG quality ---
resetprop persist.vendor.camera.jpeg.quality 100
resetprop ro.media.enc.jpeg.quality 100
resetprop vendor.camera.image.jpeg.quality 100
resetprop vendor.camera.image.quality 100

# --- Allow X8U libs to read /odm/lib64 and /odm/etc/camera ---
setprop persist.sys.odm_libs_ready 1

# --- Dual Portrait & HCS Framework Activation (v83) ---
resetprop persist.camera.aps.bokeh.HR.suport 1
resetprop persist.vendor.oplus.turbobokeh.enable 1
resetprop persist.vendor.oplus.turbohdr.bokeh.debug 1
resetprop oplus.bokeh.largeMemory 1

# --- SELinux: Unblock ColorOS CamX initPropertyInfo gate ---
setenforce 0

# --- HDR Transform Suite & AITM Pipeline Activation (v84) ---
resetprop persist.camera.hdrtrans.debug 1
resetprop persist.camera.hdrtrans.emptynode 0
resetprop persist.camera.oplus.fbhc.bypass 0
resetprop persist.camera.hybridraw.closeLightUp 0

# --- Striping log cleanup ---
rm -f /data/vendor/camera/OplusSATFusionOfflineReprocess0_*
rm -f /data/vendor/camera/RealtimeDefault1_*
rm -f /data/vendor/camera/StripingLog_MfsrPrefilter_*
rm -f /data/vendor/camera/StripingLog_OfflineReprocess0_*
rm -f /data/vendor/camera/StripingLog_OfflineReprocess1_*
rm -f /data/vendor/camera/StripingLog_OfflineReprocess2_*
rm -f /data/vendor/camera/StripingLog_OplusOfflineReprocess0_*
rm -f /data/vendor/camera/StripingLog_OplusSATFusionOfflineReprocess0_*
rm -f /data/vendor/camera/StripingLog_ZSLSnapshotFormatConvertor_*
rm -f /data/vendor/camera/StripingLog_ZSLSnapshotYUVHAL_*
rm -f /data/vendor/camera/StripingLog_ZSLSnapshotYUVHAL1_*
