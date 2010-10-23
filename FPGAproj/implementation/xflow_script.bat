@ECHO OFF
@REM ###########################################
@REM # Script file to run the flow 
@REM # 
@REM ###########################################
@REM #
@REM # Command line for ngdbuild
@REM #
ngdbuild -p xc5vlx110tff1136-1 -nt timestamp -bm FPGAproj.bmm "C:/Users/fpga10/FPGAproj/implementation/FPGAproj.ngc" -uc FPGAproj.ucf FPGAproj.ngd 

@REM #
@REM # Command line for map
@REM #
map -o FPGAproj_map.ncd -w -pr b -ol high -timing -detail FPGAproj.ngd FPGAproj.pcf 

@REM #
@REM # Command line for par
@REM #
par -w -ol high FPGAproj_map.ncd FPGAproj.ncd FPGAproj.pcf 

@REM #
@REM # Command line for post_par_trce
@REM #
trce -e 3 -xml FPGAproj.twx FPGAproj.ncd FPGAproj.pcf 

