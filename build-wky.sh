#!/bin/bash
BUILDB=$1

if [ -z ${BUILDB} ]; then
	echo "(buster | focal | bionic ....)??"
	exit 1
fi

./compile.sh  BOARD=aml-s812 BRANCH=current RELEASE=${BUILDB} BUILD_MINIMAL=no BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no COMPRESS_OUTPUTIMAGE=sha,gpg,img DOWNLOAD_MIRROR=china MAINLINE_MIRROR=tuna EXTRAWIFI=no
