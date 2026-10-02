##########################################################################################
#
# MMT Extended Config Script - OP13-OCVM Addon Module
#
##########################################################################################

PARTOVER=true
PARTITIONS="/odm"

# Replace list
REPLACE="
"

# Permissions
set_permissions() {
  [ -d "$MODPATH/system/bin" ] && set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
  [ -d "$MODPATH/tools" ] && set_perm_recursive $MODPATH/tools 0 0 0755 0755
  set_perm_recursive $MODPATH/odm/lib64 0 0 0755 0644 u:object_r:same_process_hal_file:s0
  set_perm_recursive $MODPATH/odm/lib64/camera 0 0 0755 0644 u:object_r:vendor_file:s0
  set_perm_recursive $MODPATH/odm/etc/camera 0 0 0755 0644 u:object_r:vendor_configs_file:s0
}

##########################################################################################
# MMT Extended Logic - Don't modify anything after this
##########################################################################################

SKIPUNZIP=1
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh
