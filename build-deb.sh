#!/bin/bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
errlog(){
	echo $1
	exit 1
}

deb_init(){
	debootstrap --include="iputils-ping iproute2 openssh-server init" --arch=loong64 --no-check-gpg --variant=buildd $rootfs https://mirrors.lzu.edu.cn/debian-ports
	rm $rootfs/dev/* -rf
}

create_tar(){
   tar -zcf  $filename -C $rootfs .
}

check_file(){

if [ ! -f "$1" ];then
   errlog "file $1 is no existed!"
fi

}
exec_start(){
	Date=`date +%Y%m%d%M`
	rootfs="/tmp/$osname-$Date"
	filename="$osname-$version-lxc-$Date-`arch`.tar.gz"
	deb_init || errlog "init $osname filesystem failed"
	create_tar || errlog "create tar file"
	md5sum $filename > $filename.md5
}

if [ -z "$1" ];then
	errlog "Usage: ./build.sh build"
fi

if [ "$1" != "build" ];then
	errlog "Usage: ./build.sh build"
fi

osname="debian"
version="sid"
exec_start
