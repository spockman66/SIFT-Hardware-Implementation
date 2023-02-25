################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/Bsp/libwrap/sys/_exit.c \
../src/Bsp/libwrap/sys/close.c \
../src/Bsp/libwrap/sys/execve.c \
../src/Bsp/libwrap/sys/fork.c \
../src/Bsp/libwrap/sys/fstat.c \
../src/Bsp/libwrap/sys/getpid.c \
../src/Bsp/libwrap/sys/isatty.c \
../src/Bsp/libwrap/sys/kill.c \
../src/Bsp/libwrap/sys/link.c \
../src/Bsp/libwrap/sys/lseek.c \
../src/Bsp/libwrap/sys/open.c \
../src/Bsp/libwrap/sys/openat.c \
../src/Bsp/libwrap/sys/read.c \
../src/Bsp/libwrap/sys/sbrk.c \
../src/Bsp/libwrap/sys/stat.c \
../src/Bsp/libwrap/sys/times.c \
../src/Bsp/libwrap/sys/unlink.c \
../src/Bsp/libwrap/sys/wait.c \
../src/Bsp/libwrap/sys/write.c 

OBJS += \
./src/Bsp/libwrap/sys/_exit.o \
./src/Bsp/libwrap/sys/close.o \
./src/Bsp/libwrap/sys/execve.o \
./src/Bsp/libwrap/sys/fork.o \
./src/Bsp/libwrap/sys/fstat.o \
./src/Bsp/libwrap/sys/getpid.o \
./src/Bsp/libwrap/sys/isatty.o \
./src/Bsp/libwrap/sys/kill.o \
./src/Bsp/libwrap/sys/link.o \
./src/Bsp/libwrap/sys/lseek.o \
./src/Bsp/libwrap/sys/open.o \
./src/Bsp/libwrap/sys/openat.o \
./src/Bsp/libwrap/sys/read.o \
./src/Bsp/libwrap/sys/sbrk.o \
./src/Bsp/libwrap/sys/stat.o \
./src/Bsp/libwrap/sys/times.o \
./src/Bsp/libwrap/sys/unlink.o \
./src/Bsp/libwrap/sys/wait.o \
./src/Bsp/libwrap/sys/write.o 

C_DEPS += \
./src/Bsp/libwrap/sys/_exit.d \
./src/Bsp/libwrap/sys/close.d \
./src/Bsp/libwrap/sys/execve.d \
./src/Bsp/libwrap/sys/fork.d \
./src/Bsp/libwrap/sys/fstat.d \
./src/Bsp/libwrap/sys/getpid.d \
./src/Bsp/libwrap/sys/isatty.d \
./src/Bsp/libwrap/sys/kill.d \
./src/Bsp/libwrap/sys/link.d \
./src/Bsp/libwrap/sys/lseek.d \
./src/Bsp/libwrap/sys/open.d \
./src/Bsp/libwrap/sys/openat.d \
./src/Bsp/libwrap/sys/read.d \
./src/Bsp/libwrap/sys/sbrk.d \
./src/Bsp/libwrap/sys/stat.d \
./src/Bsp/libwrap/sys/times.d \
./src/Bsp/libwrap/sys/unlink.d \
./src/Bsp/libwrap/sys/wait.d \
./src/Bsp/libwrap/sys/write.d 


# Each subdirectory must supply rules for building sources it contributes
src/Bsp/libwrap/sys/%.o: ../src/Bsp/libwrap/sys/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32im -mabi=ilp32 -mcmodel=medlow -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g -DUSE_FULL_ASSERT -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\Core" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\sys" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\stdlib" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\libwrap\misc" -I"D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\src\Bsp\Driver" -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


