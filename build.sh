#!/bin/sh

set -e

rm -rf build
mkdir build

SRCDIR="kernel"
BLDDIR="build/kernel"
LDSCRIPT="kernel.ld"
TARGET="kernel.bin"
mkdir -p ${BLDDIR}
for SFILE in `ls kernel | grep -e '\.s$'`
do
  OFILE=`echo $SFILE | sed -e 's/\.s$/\.o/'`
  as ${SRCDIR}/${SFILE} -o ${BLDDIR}/${OFILE}
done
ld -T ${SRCDIR}/${LDSCRIPT} -o ${BLDDIR}/${TARGET} ${BLDDIR}/*.o

mkdir -p build/boot
as boot/boot.s -o build/boot/boot.o
ld -T boot/boot.ld -o build/boot/boot.efi build/boot/*.o

mkdir -p build/image
cp build/boot/boot.efi build/image/serapis.efi

mkdir -p build/disk/efi/boot
cp build/image/serapis.efi build/disk/serapis.efi
ln -s `pwd`/build/disk/serapis.efi `pwd`/build/disk/efi/boot/bootx64.efi
