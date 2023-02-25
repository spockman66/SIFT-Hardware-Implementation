################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/Bsp/libwrap/stdlib/malloc.c 

OBJS += \
./src/Bsp/libwrap/stdlib/malloc.o 

C_DEPS += \
./src/Bsp/libwrap/stdlib/malloc.d 


# Each subdirectory must supply rules for building sources it contributes
src/Bsp/libwrap/stdlib/%.o: ../src/Bsp/libwrap/stdlib/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32im -mabi=ilp32 -mcmodel=medlow -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g -DUSE_FULL_ASSERT -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\Core" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\sys" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\stdlib" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\misc" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\Driver" -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


