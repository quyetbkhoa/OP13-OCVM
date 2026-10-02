##########################################################################################
#
# MMT Extended Config Script - OP13-OCVM Main Module
#
##########################################################################################

# Config Flags
PARTOVER=false

# Replace list
REPLACE="
"

# Permissions
set_permissions() {
  [ -d "$MODPATH/system/bin" ] && set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
  [ -d "$MODPATH/tools" ] && set_perm_recursive $MODPATH/tools 0 0 0755 0755
}

##########################################################################################
# MMT Extended Logic - Don't modify anything after this
##########################################################################################

SKIPUNZIP=1
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh
