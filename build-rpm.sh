#!/bin/bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
errlog(){
	echo $1
	exit 1
}

rpm_init(){
  rm $rootfs -rf
  mkdir $rootfs -p
  mkdir -p $rootfs/var/lib/rpm
  rpm --root $rootfs --initdb
  rpm -ivh --nodeps --root $rootfs $rpmfile
  mkdir $rootfs/etc/yum.repos.d
  cp $SCRIPT_DIR/$repofile  $rootfs/etc/yum.repos.d
  dnf --installroot=$rootfs install dnf --nogpgcheck -y
  dnf --installroot=$rootfs makecache
  dnf --installroot=$rootfs install -y  yum systemd-pam net-tools iproute iputils  hostname nano passwd \
  nano curl NetworkManager openssh-server || errlog "pkg download failed"
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
	rpm_init || errlog "init $osname filesystem failed"
	create_tar || errlog "create tar file"
	md5sum $filename > $filename.md5
}

if [ -z "$1" ];then
	errlog "Usage: ./build.sh build"
fi

if [ "$1" != "build" ];then
	errlog "Usage: ./build.sh build"
fi

check_file "$SCRIPT_DIR/repo/os.json"

jq -c '.[]' $SCRIPT_DIR/repo/os.json | while read os; do
    osname=$(echo "$os" | jq -r '.osname')
    version=$(echo "$os" | jq -r '.version')
    rpmfile=$(echo "$os" | jq -r '.rpmfile')
    repofile=$(echo "$os" | jq -r '.repofile')
    exec_start
done
