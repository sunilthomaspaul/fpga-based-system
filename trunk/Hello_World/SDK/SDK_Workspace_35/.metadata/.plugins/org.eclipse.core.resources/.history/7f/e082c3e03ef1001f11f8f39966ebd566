################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/bsp.c \
../src/helloworld.c 

OBJS += \
./src/bsp.o \
./src/helloworld.o 

C_DEPS += \
./src/bsp.d \
./src/helloworld.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -I../../uCOS-II_bsp_0/microblaze_0/include -mxl-barrel-shift -mxl-pattern-compare -mcpu=v8.00.a -mno-xl-soft-mul -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


