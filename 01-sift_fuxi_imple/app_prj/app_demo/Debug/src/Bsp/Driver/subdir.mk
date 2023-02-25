################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/Bsp/Driver/hme_gpio.c \
../src/Bsp/Driver/hme_iic.c \
../src/Bsp/Driver/hme_plic.c \
../src/Bsp/Driver/hme_spi.c \
../src/Bsp/Driver/hme_timer.c \
../src/Bsp/Driver/hme_uart.c \
../src/Bsp/Driver/spi_flash.c \
../src/Bsp/Driver/system.c 

OBJS += \
./src/Bsp/Driver/hme_gpio.o \
./src/Bsp/Driver/hme_iic.o \
./src/Bsp/Driver/hme_plic.o \
./src/Bsp/Driver/hme_spi.o \
./src/Bsp/Driver/hme_timer.o \
./src/Bsp/Driver/hme_uart.o \
./src/Bsp/Driver/spi_flash.o \
./src/Bsp/Driver/system.o 

C_DEPS += \
./src/Bsp/Driver/hme_gpio.d \
./src/Bsp/Driver/hme_iic.d \
./src/Bsp/Driver/hme_plic.d \
./src/Bsp/Driver/hme_spi.d \
./src/Bsp/Driver/hme_timer.d \
./src/Bsp/Driver/hme_uart.d \
./src/Bsp/Driver/spi_flash.d \
./src/Bsp/Driver/system.d 


# Each subdirectory must supply rules for building sources it contributes
src/Bsp/Driver/%.o: ../src/Bsp/Driver/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32im -mabi=ilp32 -mcmodel=medlow -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g -DUSE_FULL_ASSERT -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\Core" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\sys" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\stdlib" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\misc" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\Driver" -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


