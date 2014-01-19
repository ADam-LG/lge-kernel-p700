#!/bin/bash
mkdir -p out/META-INF/com/google/android
cp arm/update-binary updater-script out/META-INF/com/google/android/

mkdir -p out/tmp/modules
cp arm/unpackbootimg arm/mkbootimg copy_kernel.sh out/tmp/
cp -r ../modules/* out/tmp/modules

cd out
jar -cfM ../update.zip META-INF tmp
cd ..
java -jar sign/signapk.jar sign/testkey.x509.pem sign/testkey.pk8 update.zip updateP700_20x.zip

rm -rf out/*
rm update.zip


