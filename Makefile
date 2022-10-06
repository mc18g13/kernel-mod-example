obj-m += mod_test.o

MAJOR = 502

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(shell pwd) modules
clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(shell pwd) clean
test:
	# We put a — in front of the rmmod command to tell make to ignore
	# an error in case the module isn’t loaded.
	-sudo rmmod mod_test
	# Clear the kernel log without echo
	sudo dmesg -C
	# Insert the module
	sudo insmod mod_test.ko
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