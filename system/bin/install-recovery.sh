#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:11035536:bf58a70e7512ddbc50bee39f32b3f93ae11ef68b; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/platform/bootdevice/by-name/boot:9362320:4f6e4b85e70d24375069e2ce5fdf1941cc494111 EMMC:/dev/block/platform/bootdevice/by-name/recovery bf58a70e7512ddbc50bee39f32b3f93ae11ef68b 11035536 4f6e4b85e70d24375069e2ce5fdf1941cc494111:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
