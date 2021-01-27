ROOTFS_DIR ?= multistrap-debian-buster

.multistrap: debian-config-buster debian-debconf
	# Generation multistrap
	rm -f $(ROOTFS_DIR)/var/lib/dpkg/status
	multistrap -f $< -d $(ROOTFS_DIR)
	
	# Copy custom files
	cp -R files/* $(ROOTFS_DIR)
	touch $@

.multistrap-config: multistrap.configscript .multistrap
	# Configuring multistrap
	cp /usr/bin/qemu-arm-static $(ROOTFS_DIR)/usr/bin
	cp multistrap.configscript $(ROOTFS_DIR)/multistrap.configscript
	mount -o bind /dev $(ROOTFS_DIR)/dev
	chroot $(ROOTFS_DIR) /usr/bin/qemu-arm-static /bin/sh -c ./$<
	umount $(ROOTFS_DIR)/dev
	rm -f $(ROOTFS_DIR)/usr/bin/qemu-arm-static
	rm -f $(ROOTFS_DIR)/multistrap.configscript
	touch $@

clean:
	rm -f .multistrap-config .multistrap

all: .multistrap .multistrap-config

