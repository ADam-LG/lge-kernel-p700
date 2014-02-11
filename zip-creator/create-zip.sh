#!/bin/bash
pushd . > /dev/null
cd `dirname ${BASH_SOURCE[0]}` > /dev/null

mkdir -p out/META-INF/com/google/android
cp arm/update-binary updater-script out/META-INF/com/google/android/
sed -i s/\"p700\"/\"$target\"/g out/META-INF/com/google/android/updater-script
mkdir -p out/tmp/modules
cp arm/unpackbootimg arm/mkbootimg copy_kernel.sh out/tmp/
cp -r ../modules/* out/tmp/modules

cd out
jar -cfM ../update.zip META-INF tmp
cd ..
java -jar sign/signapk.jar sign/testkey.x509.pem sign/testkey.pk8 update.zip update_signed.zip

rm -rf out/*
rm update.zip

popd > /dev/null
