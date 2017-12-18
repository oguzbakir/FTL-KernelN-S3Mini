#!/tmp/packing/sbin/busybox sh

#### Based on AGNi pureCM ANYROM-AROMA Kernel (psndna88@gmail.com)
#### AGNi Kernel-Patcher (based on original implementation for GT-S5830)

#### DEFINE version info ####################################################################################
DEVICE_MODEL="I8190,I8190N,I8190L"
DEVICE_NAME="golden"
BOOT_PARTITION="/dev/block/mmcblk0p20"
#############################################################################################################
#### DEFINE MKBOOTIMG PARAMETERS (Device specifics) #########################################################
MK_BASE=00000000
MK_RAMADDR=01000000
MK_PAGESIZE=2048
MK_CMDLINE="androidboot.selinux=permissive"
#############################################################################################################

ROM_BUILD_PROP="/system/build.prop"
ANYROM_LOG_FILE="/data/.ANYROM/ANYROM_install.log"

ln -s /tmp/bootimgtools /tmp/mkbootimg;
ln -s /tmp/bootimgtools /tmp/unpack_bootimg;
chmod +x /tmp/mkbootimg;
chmod +x /tmp/unpack_bootimg;

mkdir -p /data/.ANYROM
mkdir -p /tmp/oldboot
mkdir -p /tmp/extracted
mkdir -p /tmp/bootimg
chmod -R 775 /tmp/oldboot
chmod -R 775 /tmp/extracted
chmod -R 775 /tmp/bootimg

RAMFS_EXTRACT_FAIL="0"
touch $ANYROM_LOG_FILE
chmod 666 $ANYROM_LOG_FILE

echo " " > $ANYROM_LOG_FILE
echo " " >> $ANYROM_LOG_FILE
echo "############################################################################" >> $ANYROM_LOG_FILE
echo "			ANYROM Installer LOG " >> $ANYROM_LOG_FILE
echo "############################################################################" >> $ANYROM_LOG_FILE
echo " " >> $ANYROM_LOG_FILE
echo "Dated: `date` " >> $ANYROM_LOG_FILE
echo "   Target device model(s)	: $DEVICE_MODEL" >> $ANYROM_LOG_FILE
echo "   Target device name(s)	: $DEVICE_NAME" >> $ANYROM_LOG_FILE
echo " " >> $ANYROM_LOG_FILE
echo "ROM BUILD INFO :-" >> $ANYROM_LOG_FILE
echo "  `grep ro.cm.version $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.modversion $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.cm.display.version $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.build.user $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.build.host $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.build.date= $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.build.display.id $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.build.version.release $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.product.model $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.product.device= $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo "  `grep ro.cm.device $ROM_BUILD_PROP` " >> $ANYROM_LOG_FILE
echo " " >> $ANYROM_LOG_FILE

echo " Extracting existing flashed boot.img... " >> $ANYROM_LOG_FILE
dd if=$BOOT_PARTITION of=/tmp/oldboot/boot.img bs=$MK_PAGESIZE;
echo " Extracted existing flashed boot.img ! " >> $ANYROM_LOG_FILE
echo "	=====>	Size: `du -h /tmp/oldboot/boot.img`" >> $ANYROM_LOG_FILE

echo " Extracting contents of existing flashed boot.img... " >> $ANYROM_LOG_FILE
/tmp/unpack_bootimg -i /tmp/oldboot/boot.img -o /tmp/oldboot;
mv /tmp/oldboot/boot.img-zImage /tmp/oldboot/old_zImage
cp /tmp/oldboot/boot.img-ramdisk.gz /tmp/oldboot/old_ramdisk.gz
mv /tmp/oldboot/boot.img-ramdisk.gz /tmp/bootimg/orig-ramdisk.gz
echo " Extracted contents of existing flashed boot.img ! " 	>> $ANYROM_LOG_FILE
echo "	=====>	Size: `du -h /tmp/oldboot/old_zImage`" >> $ANYROM_LOG_FILE
echo "	=====>	Size: `du -h /tmp/oldboot/old_ramdisk.gz`" >> $ANYROM_LOG_FILE

echo "  " >> $ANYROM_LOG_FILE
if [ "`grep i8190 $ROM_BUILD_PROP`" ] || [ "`grep i8190 $ROM_BUILD_PROP`" ];
	then
	mv /tmp/bootimg/kernel/zImage /tmp/bootimg/new-zImage && GOLDEN_TYPE="i8190" && touch /tmp/bootimg/zImage-is-i8190
	else
	mv /tmp/bootimg/kernel/zImage /tmp/bootimg/new-zImage && GOLDEN_TYPE="i8190x" && touch /tmp/bootimg/zImage-is-i8190x
fi

echo " Contents of new boot.img ! " 	>> $ANYROM_LOG_FILE
echo "	=====>	Size: `du -h /tmp/bootimg/new-zImage`" >> $ANYROM_LOG_FILE
echo "	=====>	Size: `du -h /tmp/bootimg/orig-ramdisk.gz`" >> $ANYROM_LOG_FILE

echo "   " >> $ANYROM_LOG_FILE
echo " Assembling PATCHED boot.img for flashing... " >> $ANYROM_LOG_FILE
chmod -R 644 /tmp/bootimg/*
/tmp/mkbootimg --kernel /tmp/bootimg/new-zImage --ramdisk /tmp/bootimg/orig-ramdisk.gz --base $MK_BASE --ramdiskaddr $MK_RAMADDR --pagesize $MK_PAGESIZE --cmdline "$MK_CMDLINE" -o /tmp/boot.img;
chmod 644 /tmp/boot.img
echo "      PATCHED boot.img ready to flash ! " >> $ANYROM_LOG_FILE
echo "		Golden type	: $GOLDEN_TYPE " >> $ANYROM_LOG_FILE
echo "		base		: $MK_BASE " >> $ANYROM_LOG_FILE
echo "		ramdiskaddr	: $MK_RAMADDR " >> $ANYROM_LOG_FILE
echo "		pagesize	: $MK_PAGESIZE " >> $ANYROM_LOG_FILE
echo "		cmdline		: $MK_CMDLINE " >> $ANYROM_LOG_FILE
echo "	=====>	Size: `du -h /tmp/boot.img`" >> $ANYROM_LOG_FILE

##### Optional placing copy of old and new patched boot.imgs  ###############################################
if [ -f /data/.ANYROM/copy_bootimg ];
	then
	mkdir -p /data/.ANYROM/unpatched_boot.img_copy
	mkdir -p /data/.ANYROM/patched_boot.img_copy
	rm /data/.ANYROM/unpatched_boot.img_copy/boot.img
	rm /data/.ANYROM/patched_boot.img_copy/boot.img
	cp /tmp/oldboot/boot.img /data/.ANYROM/unpatched_boot.img_copy/boot.img
	cp /tmp/boot.img /data/.ANYROM/patched_boot.img_copy/boot.img
	chmod -R 775 /data/.ANYROM
	echo " Placed copy of old and new patched boot.imgs !  " >> $ANYROM_LOG_FILE
	echo "	=====>	Size: `du -h /data/.ANYROM/unpatched_boot.img_copy/boot.img`" >> $ANYROM_LOG_FILE
	echo "	=====>	Size: `du -h /data/.ANYROM/patched_boot.img_copy/boot.img`" >> $ANYROM_LOG_FILE
fi
echo "   " >> $ANYROM_LOG_FILE
echo " END OF LOG. Dated: `date` " >> $ANYROM_LOG_FILE
echo "   " >> $ANYROM_LOG_FILE
echo "############################################################################" >> $ANYROM_LOG_FILE
#############################################################################################################
