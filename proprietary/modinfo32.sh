#!/bin/bash

function modinfo32 (){
instring=$1
part_1=`echo -e $instring | cut -f 1`
part_2=`echo -e $instring | cut -f 2`

addr=${part_1:${#part_1}-8:8}

#remove last 8 symbols and first 2
part_1chars=${part_1%%$addr}
part_1chars2=${part_1chars:2:99}

case "${#part_1chars2}" in
2) modname=`echo 0x$part_1chars2 | xxd -r`$part_2
    ;;
4) modname=`echo $part_1chars2 | sed -E 's/(..)(..)/0x\2\1/' | xxd -r`$part_2
    ;;
6) modname=`echo $part_1chars2 | sed -E 's/(..)(..)(..)/0x\3\2\1/' | xxd -r`$part_2
    ;;
8) modname=`echo $part_1chars2 | sed -E 's/(..)(..)(..)(..)/0x\4\3\2\1/' | xxd -r`$part_2
   ;;
*) echo "error"
   modname="error"
   ;;
esac

echo -e "0x$addr\t$modname"
}

if [ `getconf LONG_BIT` = "64" ]
then
    modprobe --dump-modversions $1 | while read x y; do modinfo32 "$x\t$y" ; done
else
    modprobe --dump-modversions $1
fi
