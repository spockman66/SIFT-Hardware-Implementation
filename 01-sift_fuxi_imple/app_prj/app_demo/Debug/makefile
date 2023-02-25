################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/Bsp/libwrap/sys/subdir.mk
-include src/Bsp/libwrap/stdlib/subdir.mk
-include src/Bsp/libwrap/misc/subdir.mk
-include src/Bsp/Driver/subdir.mk
-include src/Bsp/Core/subdir.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_FLASH += \
app_demo.hex \

SECONDARY_LIST += \
app_demo.lst \

SECONDARY_SIZE += \
app_demo.siz \


# All Target
all: app_demo.elf secondary-outputs

# Tool invocations
app_demo.elf: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv-none-embed-gcc -march=rv32im -mabi=ilp32 -mcmodel=medlow -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g -T "D:\CreateIC\01_CPIPC\riscv\RISCV_ENC_20220421\Firmware_true\app_prj\app_demo\app.ld" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"app_demo.map" --specs=nano.specs -o "app_demo.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

app_demo.hex: app_demo.elf
	@echo 'Invoking: GNU RISC-V Cross Create Flash Image'
	riscv-none-embed-objcopy -O ihex "app_demo.elf"  "app_demo.hex"
	@echo 'Finished building: $@'
	@echo ' '

app_demo.lst: app_demo.elf
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv-none-embed-objdump --source --all-headers --demangle --line-numbers --wide "app_demo.elf" > "app_demo.lst"
	@echo 'Finished building: $@'
	@echo ' '

app_demo.siz: app_demo.elf
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv-none-embed-size --format=berkeley "app_demo.elf"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(SECONDARY_FLASH)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS) app_demo.elf
	-@echo ' '

secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

.PHONY: all clean dependents

-include ../makefile.targets
