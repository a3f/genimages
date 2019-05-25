# Makefile wrapper for genimage adapted from
# https://github.com/pengutronix/meta-ptx/blob/master/classes/genimage.bbclass

FAKEROOT ?= fakeroot
GENIMAGE ?= genimage

export GENIMAGE_LOGLEVEL ?= 2
export GENIMAGE_TUNE2FS ?= /sbin/tune2fs
export GENIMAGE_E2FSCK ?= /sbin/e2fsck

default: default.config
	@if [ -e default.config ]; then \
		${MAKE} -s $(basename $(shell readlink default.config)).hdimage; \
	fi

.hdimage:
	@echo No default.config symlink found
	@exit 2

%: %.hdimage ;

%.hdimage: %.config images/*
	@mkdir -p build/$@
	@rm -rf build/$@/genimage-tmp
	@mkdir build/$@/genimage-tmp
	@cp -f $< build/$@/genimage.config
	@sed -i s:@IMAGE@:$@:g build/$@/genimage.config
	@mkdir -p build/$@/root
	@if [ "x${GENIMAGE_ROOTFS_IMAGE}" != "x" ]; then 			\
		echo "Unpacking ${GENIMAGE_ROOTFS_IMAGE} to build/$@/root"; 	\
		${FAKEROOT} tar -xf ${GENIMAGE_ROOTFS_IMAGE} -C build/$@/root; 	\
	fi
	@${FAKEROOT} cp -Lfr rootfs/$@/* build/$@/root || true
	@${FAKEROOT} ${GENIMAGE} 				\
	    --config            build/$@/genimage.config 	\
	    --tmppath           build/$@/genimage-tmp 		\
	    --inputpath         images 				\
	    --outputpath        images 				\
	    --rootpath          build/$@/root

.PHONY: clean
clean:
	@readlink -f images/*.hdimage | xargs rm
