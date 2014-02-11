#!/bin/bash
export KBUILD_BUILD_USER=ADam
export KBUILD_BUILD_HOST="`uname -m` `lsb_release -d|cut -f 2`"
export target=${target:=p700}
export ARCH=arm
export SUBARCH=arm
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

if [ -n "$(git status --porcelain)" ]
then
    read -p "Tree is dirty, continue(y|n)" choice
    choice=${choice:=y}
    case "$choice" in
	n|N ) echo Commit your changes; echo git add .;echo git commit --amend -C HEAD; exit 1;;
    esac
fi

export target=${target:=p700}
case "$target" in
    p700 ) export TARGET_PRODUCT=u0_open_eu ;;
    p705 ) export TARGET_PRODUCT=u0_open_cis ;;
    *    ) echo Unknown target; exit 1;;
esac
export target_config="$TARGET_PRODUCT-perf_defconfig"

if [ "$1" = "clean" ]
then
    make clean && make mrproper
fi

make $target_config
make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` zImage modules

if [ -f arch/arm/boot/zImage ]; then
    rm -rf modules/*
    cp arch/arm/boot/zImage modules/

    mkdir modules/volans
    find . -type f -name '*.ko' -exec cp '{}' modules/ \;
    mv modules/cfg80211.ko modules/volans/
    cp proprietary/WCN1314_rf.ko.blob modules/volans/WCN1314_rf.ko
    # patch vermagic
    newmagic=$(modinfo -F vermagic modules/volans/cfg80211.ko | cut -d ':' -f 1)
    offset=$[$(LC_ALL=C grep -a -b -o $'vermagic=' modules/volans/WCN1314_rf.ko | cut -d ':' -f 1)+9]
    printf $newmagic | dd of=modules/volans/WCN1314_rf.ko bs=1 seek=$offset count=${#newmagic} conv=notrunc
    # check module symbols
    proprietary/mod_check.sh
    # create zip
    zip-creator/create-zip.sh
    zipfile="lge-$target-$(date +%Y%m%d).zip"
    mv zip-creator/update_signed.zip $zipfile
    echo Created $zipfile
else
    echo build failed
fi

END=$(date +%s)
BUILDTIME=$((END - START))
B_MIN=$((BUILDTIME / 60))
B_SEC=$((BUILDTIME - E_MIN * 60))
echo -ne "\033[32mBuildtime: "
[ $B_MIN != 0 ] && echo -ne "$B_MIN min(s) "
echo -e "$B_SEC sec(s)\033[0m"
echo Check vermagic string for proprietary module
find modules/ -type f \( -name 'WCN1314_rf.ko' -o -name 'cfg80211.ko' \) -exec modinfo '{}' \; | grep 'filename\|vermagic'
echo -n Kernel version:\ ; cat include/config/kernel.release
