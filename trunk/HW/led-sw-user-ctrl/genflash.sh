#!/bin/sh

# -Run from xygwin shell-
#
# This script generates the download_flash.bin file for download to board via loadb command.
# It assumes that a valid build (s/w and h/w) has already been performed (make init_bram).

set -x

echo "****************************************************"
echo "Regenerating system.bit using CCLK as startup clock"
echo "****************************************************"
(cd implementation; bitgen -w -f ../etc/bitgen_flash.ut system.ncd system_flash.bit)

echo "*********************************************"
echo "Initializing BRAM contents of the bitstream"
echo "*********************************************"
bitinit system.mhs -pe ppc405_i ppc405_i/code/executable.elf -bt implementation/system_flash.bit -o implementation/download_flash.bit

echo "**************************************"
echo "Creating .bin file for loadb to Flash "
echo "**************************************"
(cd implementation; promgen -c -u 0 download_flash.bit -p bin -w -o download_flash.bin -s 16384 -b)
