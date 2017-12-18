#!/sbin/busybox sh

################## FIX /data ownership issues (if any)
/tmp/packing/sbin/busybox chown -R media_rw:media_rw /data/media

### cleaning up
rm -rf /tmp/packing
rm -rf /tmp/extracted
rm -rf /tmp/bootimg
rm -rf /tmp/oldboot
rm -f /tmp/mkbootimg
rm -f /tmp/unpack_bootimg
rm -f /tmp/bootimgtools
