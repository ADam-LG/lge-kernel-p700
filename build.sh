export ARCH=arm
export SUBARCH=arm
export TARGET_PRODUCT=u0_open_eu
#export CROSS_COMPILE=~/toolchains/arm-eabi-4.4.3/bin/arm-eabi-
#export CROSS_COMPILE=~/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-
export CROSS_COMPILE=~/toolchains_google/arm-eabi-4.6/bin/arm-eabi-
#export CROSS_COMPILE=~/android-ndk-r9b/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
#export CROSS_COMPILE=~/toolchains/arm-eabi-linaro-4.7.4/bin/arm-eabi-
#export CROSS_COMPILE=~/toolchains/arm-eabi-linaro-4.8.2/bin/arm-linux-androideabi-
#-Wno-maybe-uninitialized
#export CROSS_COMPILE=~/toolchains/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-
#-Wno-sizeof-pointer-memaccess
#export CROSS_COMPILE=~/android-ndk-r9/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
export LOCALVERSION=
#export INSTALL_MOD_PATH=modules
START=$(date +%s)
rm -rf modules/*

if [ "$1" = "clean" ]
then
    make clean && make mrproper
    make u0_open_eu-perf_defconfig
fi

if [ -n "$(git status --porcelain)" ]
then
    echo Tree is dirty
    echo git add .
    echo git commit --amend -C HEAD
#    exit
fi

make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` zImage modules

cp arch/arm/boot/zImage modules/

mkdir modules/volans
find . -type f -name '*.ko' -exec cp '{}' modules/ \;
mv modules/cfg80211.ko modules/volans/
cp proprietary/WCN1314_rf.ko.blob modules/volans/WCN1314_rf.ko
# patch vermagic
newmagic=$(modinfo -F vermagic modules/volans/cfg80211.ko | cut -d ':' -f 1)
offset=$[$(LC_ALL=C grep -a -b -o $'vermagic=' modules/volans/WCN1314_rf.ko | cut -d ':' -f 1)+9]
printf $newmagic | dd of=modules/volans/WCN1314_rf.ko bs=1 seek=$offset count=${#newmagic} conv=notrunc

END=$(date +%s)
BUILDTIME=$((END - START))
B_MIN=$((BUILDTIME / 60))
B_SEC=$((BUILDTIME - E_MIN * 60))
echo -ne "\033[32mBuildtime: "
[ $B_MIN != 0 ] && echo -ne "$B_MIN min(s) "
echo -e "$B_SEC sec(s)\033[0m"
echo Check vermagic string for proprietary module
find modules/ -type f \( -name 'WCN1314_rf.ko' -o -name 'cfg80211.ko' \) -exec modinfo '{}' \; | grep 'filename\|vermagic'
