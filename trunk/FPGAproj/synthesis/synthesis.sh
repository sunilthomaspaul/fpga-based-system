#!/bin/bash

rm -rf xst

echo "xst -ifn "FPGAproj_xst.scr" -intstyle silent"

echo "Running XST synthesis ..."

xst -ifn "FPGAproj_xst.scr" -intstyle silent
if [ $? -ne 0 ]; then
  exit 1
fi

echo "XST completed"

rm -rf xst

mv ../implementation/FPGAproj.ngc .
ngcbuild ./FPGAproj.ngc ../implementation/FPGAproj.ngc -sd ../implementation -i
if [ $? -ne 0 ]; then
  exit 1
fi
