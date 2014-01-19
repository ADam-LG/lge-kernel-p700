#!/sbin/sh

boot="mmcblk0p9"
p_pid=`grep '^PPid:' /proc/$$/status | grep -o '[0-9]*'`
interface="/proc/$p_pid/fd/`xargs -0 echo < /proc/$p_pid/cmdline | cut -f3 -d' '`"

show_progress() { echo "progress $1 $2" > $interface; }
set_progress() ( echo  "set_progress 0.$1" > $interface )
ui_print() {
 echo -ne "ui_print $1\n" > $interface;
 echo -ne "ui_print\n" > $interface;
}

##main
cd /tmp/
chmod 0755 /tmp/mkbootimg          || exit 16
chmod 0755 /tmp/unpackbootimg      || exit 17

show_progress 1.34 0
ui_print "Unpacking boot"
set_progress 10
/tmp/unpackbootimg -i /dev/block/$boot -o "/tmp/" || exit 22

ui_print "Copy modules"
rm /system/lib/modules/volans/*.ko || exit 25
rm /system/lib/modules/*.ko || exit 26
cp /tmp/modules/volans/*.ko /system/lib/modules/volans/ || exit 27
cp /tmp/modules/*.ko /system/lib/modules/ || exit 28
cd /system/lib/modules/
ln -s volans/WCN1314_rf.ko wlan.ko || exit 30
#cp /system/lib/modules/volans/cfg80211.ko /system/lib/modules/cfg80211.ko || exit 31
ln -s volans/cfg80211.ko cfg80211.ko || exit 31
chmod 644 /system/lib/modules/volans/*.ko || exit 32
chmod 644 /system/lib/modules/*.ko || exit 33
ui_print "Replacing kernel"
set_progress 40
mv /tmp/modules/zImage /tmp/new-zImage || exit 36
mv /tmp/$boot-ramdisk.gz /tmp/new-ramdisk.gz || exit 37

ui_print "Preparing newboot.img"
set_progress 70
/tmp/mkbootimg --kernel /tmp/new-zImage --ramdisk /tmp/new-ramdisk.gz --cmdline "`cat /tmp/$boot-cmdline`" --base 0x`cat /tmp/$boot-base` --pagesize 4096 --output /tmp/newboot.img || exit 41

ui_print "Flashing newboot.img to $boot"
dd if=/tmp/newboot.img of=/dev/block/$boot || exit 44

rm /tmp/newboot.img /tmp/new-ramdisk.gz /tmp/new-zImage /tmp/$boot* || exit 46
rm -rf /tmp/modules || exit 47

exit 0

## not running here
cd /data/local/tmp
chmod 0755 /data/local/tmp/mkbootimg
chmod 0755 /data/local/tmp/unpackbootimg
boot="mmcblk0p9"
/data/local/tmp/unpackbootimg /dev/block/$boot "/data/local/tmp/"
/data/local/tmp/mkbootimg --kernel /data/local/tmp/$boot-zImage --ramdisk /data/local/tmp/$boot-ramdisk.gz --cmdline "`cat /data/local/tmp/$boot-cmdline`" --base 0x`cat /data/local/tmp/$boot-base` --pagesize 4096 --output /data/local/tmp/newboot.img

