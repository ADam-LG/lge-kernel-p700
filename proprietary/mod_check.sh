#!/bin/bash

cd "$(dirname "$0")"

module_syms=WCN1314_rf.sym
kernel_syms=../$output/Module.symvers
module_file=../modules/volans/WCN1314_rf.ko

symbols_written=0
symbols_skipped=0
symbols_notfound=0
while read mod_addr mod_name; do
    kernel_addr=`grep -P "\t$mod_name\t" $kernel_syms | cut -f 1`
    if [ ${#kernel_addr} == 0 ]; then
	echo -e "$mod_addr\t$mod_name\t not found"
	symbols_notfound=$(( $symbols_notfound + 1 ))
    else
        if [ "$kernel_addr" != "$mod_addr" ]; then
	    echo $mod_addr $kernel_addr $mod_name
	    symbols_written=$(( $symbols_written + 1 ))
	else
	    symbols_skipped=$(( $symbols_skipped + 1 ))
        fi
    fi
done < $module_syms
echo -ne "\033[31m$symbols_written\033[0m kernel symbols wrong in ${module_syms/%sym/ko}, "
echo -ne "\033[32m$symbols_skipped\033[0m symbols good, "
echo -e  "\033[35m$symbols_notfound\033[0m not found"
