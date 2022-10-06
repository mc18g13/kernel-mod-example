obj-m += mod_test.o

MAJOR = 502

INCLUDE=include
SOURCE=src
TARGET=mod_test
EXPORT=package
WORK_DIR=$(shell pwd)
OUTPUT=bin

SOURCES=$(wildcard $(SOURCE)/*.c)

# Depends on bin/include bin/*.c and bin/Makefile
all: $(OUTPUT)/$(INCLUDE) $(subst $(SOURCE),$(OUTPUT),$(SOURCES)) $(OUTPUT)/Makefile
	make -C /lib/modules/$(shell uname -r)/build M=${WORK_DIR}/$(OUTPUT) modules

# Create a symlink from src to bin
$(OUTPUT)/%: $(SOURCE)/%
	ln -s ../$< $@

# Generate a Makefile with the needed obj-m and mymodule-objs set
$(OUTPUT)/Makefile:
	echo "obj-m += $(TARGET).o\n$(TARGET)-objs := $(subst $(TARGET).o,, $(subst .c,.o,$(subst $(SOURCE)/,,$(SOURCES))))" > $@

clean:
	sudo rm -rf $(OUTPUT)
	mkdir $(OUTPUT)

test:
	# We put a — in front of the rmmod command to tell make to ignore
	# an error in case the module isn’t loaded.
	-sudo rmmod mod_test
	# Clear the kernel log without echo
	sudo dmesg -C
	# Insert the module
	sudo insmod ${OUTPUT}/mod_test.ko
	# Display the kernel log
	dmesg
	@echo "Copy major number into makefile"

create:
	sudo mknod /dev/mod_test c ${MAJOR} 0

print:
	sudo cat /dev/mod_test

remove:
	sudo rm /dev/mod_test
	sudo rmmod mod_test