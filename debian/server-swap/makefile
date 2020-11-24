default: build

.PHONY: clean

clean:
	rm -rf isofiles
	rm -rf isohdpfx.bin
	rm -rf *.iso

build: clean
	apt-get install xorriso -y
	xorriso -osirrox on -indev /mnt/isos/debian-10.6.0-amd64-netinst.iso -extract / isofiles
	chmod +w -R isofiles/install.*/
	gunzip isofiles/install.*/initrd.gz
	echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.*/initrd
	gzip isofiles/install.*/initrd
	chmod -w -R isofiles/install.*/
	chmod +w isofiles/md5sum.txt
	cd isofiles && find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
	chmod -w isofiles/md5sum.txt
	
	# The example names get mapped to their roles here
	dd if=/mnt/isos/debian-10.6.0-amd64-netinst.iso bs=1 count=432 of=isohdpfx.bin
	
	# Create the new ISO image
	xorriso -as mkisofs -r -V 'Debian' -o debian-10.6.0.amd64-netinst-swap.iso -J -J -joliet-long -cache-inodes -isohybrid-mbr isohdpfx.bin -b isolinux/isolinux.bin -c isolinux/boot.cat -boot-load-size 4 -boot-info-table -no-emul-boot -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus isofiles

