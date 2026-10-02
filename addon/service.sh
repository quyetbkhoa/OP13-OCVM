#!/system/bin/sh

chown -R root:root $MODPATH/odm/etc
find $MODPATH/odm/etc -type d -exec chmod 755 {} +
find $MODPATH/odm/etc -type f -exec chmod 644 {} +
chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/odm/etc

# chown -R root:shell $MODPATH/odm/etc/camera/hybridraw_models
# find $MODPATH/odm/etc/camera/hybridraw_models -type d -exec chmod 755 {} +
# find $MODPATH/odm/etc/camera/hybridraw_models -type f -exec chmod 644 {} +
# chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/odm/etc/camera/hybridraw_models

chown -R root:root $MODPATH/odm/lib64
find $MODPATH/odm/lib64 -type d -exec chmod 755 {} +
find $MODPATH/odm/lib64 -type f -exec chmod 644 {} +
chcon -R u:object_r:same_process_hal_file:s0 $MODPATH/odm/lib64

chown -R root:root $MODPATH/odm/lib64/camera
find $MODPATH/odm/lib64/camera -type d -exec chmod 755 {} +
find $MODPATH/odm/lib64/camera -type f -exec chmod 644 {} +
chcon -R u:object_r:vendor_file:s0 $MODPATH/odm/lib64/camera

chown -R root:root $MODPATH/odm/lib64/hw
find $MODPATH/odm/lib64/hw -type d -exec chmod 755 {} +
find $MODPATH/odm/lib64/hw -type f -exec chmod 644 {} +
chcon -R u:object_r:vendor_file:s0 $MODPATH/odm/lib64/hw

chown -R root:root $MODPATH/vendor/lib64
find $MODPATH/vendor/lib64 -type d -exec chmod 755 {} +
find $MODPATH/vendor/lib64 -type f -exec chmod 644 {} +
chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor/lib64

chown root:root $MODPATH/odm/lib64/libCS.so
chmod 644 $MODPATH/odm/lib64/libCS.so
chcon u:object_r:vendor_file:s0 $MODPATH/odm/lib64/libCS.so

chown root:root $MODPATH/odm/lib64/libOplusPDCore.so
chmod 644 $MODPATH/odm/lib64/libOplusPDCore.so
chcon u:object_r:vendor_file:s0 $MODPATH/odm/lib64/libOplusPDCore.so

chown root:root $MODPATH/odm/lib64/libPDParamParser.so
chmod 644 $MODPATH/odm/lib64/libPDParamParser.so
chcon u:object_r:vendor_file:s0 $MODPATH/odm/lib64/libPDParamParser.so

chown root:root $MODPATH/odm/lib64/libopluspdparam.so
chmod 644 $MODPATH/odm/lib64/libopluspdparam.so
chcon u:object_r:vendor_file:s0 $MODPATH/odm/lib64/libopluspdparam.so

