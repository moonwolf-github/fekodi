# Kickstart file to build the appliance operating
# system for fedora.
# This is based on the work at http://www.thincrust.net
lang pl_PL.UTF-8
keyboard pl2
timezone Europe/Warsaw
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
bootloader --timeout=1 #--extlinux #--append="acpi=force console=ttyS0,115200"
network --bootproto=dhcp --device=eth0 --onboot=on
services --enabled=NetworkManager

rootpw --plaintext FeBMC
user --name=feplayer --groups=audio,cdrom --password=febmc --plaintext

#
# Partition Information. Change this as necessary
# This information is used by appliance-tools but
# not by the livecd tools.
#
zerombr
clearpart --all
#part /boot --fstype=ext4 --ondisk=sda --size=500
part / --size=2048 --fstype=ext4 --ondisk=sda

#
# Repositories
#
repo --name=f20 --baseurl=http://upgrades.tech.sp/f20/$basearch/Everything/
repo --name=f20-updates --baseurl=http://upgrades.tech.sp/f20/$basearch/updates/
repo --name=rpmfusion-free --baseurl=http://upgrades.tech.sp/f20/$basearch/rpmfusion/free/os
repo --name=rpmfusion-free-updates --baseurl=http://upgrades.tech.sp/f20/$basearch/rpmfusion/free/updates
repo --name=rpmfusion-nonfree --baseurl=http://upgrades.tech.sp/f20/$basearch/rpmfusion/nonfree/os
repo --name=rpmfusion-nonfree-updates --baseurl=http://upgrades.tech.sp/f20/$basearch/rpmfusion/nonfree/updates

#
# Add all the packages after the base packages
#
%packages --excludedocs --nobase
coreutils
dracut
dracut-config-rescue
shadow-utils
filesystem
firewalld
generic-logos
generic-release
generic-release-notes
setup
rpm
grub2
grub2-tools
grubby
binutils
yum
rpmfusion-free-release
rpmfusion-nonfree-release
alsa-utils
libmad
nfs-utils
chrony
openssh-server
v4l-utils
b43-openfwwf
upower
NetworkManager
net-tools
vim-minimal
passwd
e2fsprogs
mc
vim
kernel
xbmc
xorg-x11-xinit
xorg-x11-server-Xorg
xorg-x11-drivers
polkit
rsyslog
cronie
cronie-anacron
dbus-x11
mesa-dri-drivers
syslinux-extlinux

-fedora-logos
-fedora-release-notes
%end

#
# Add custom post scripts after the base post.
#
%post
cat > /etc/systemd/system/xbmc.service << EOF
[Unit]
Description = Starts instance of XBMC using xinit
After = syslog.target

[Service]
User = feplayer
Group = feplayer
Type = simple
ExecStart = /usr/bin/xinit /usr/bin/xbmc-standalone -- :0

[Install]
WantedBy = default.target
EOF
/usr/bin/systemctl enable xbmc.service

cp -f /etc/skel/{*,.*} /root/

# 'user' directive above doesn't work
#/usr/sbin/useradd -mUp febmc feplayer
#/usr/sbin/usermod -G audio,cdrom feplayer

# media directories
BASE_MEDIA_DIR=/home/media
MEDIA_DIRS=($BASE_MEDIA_DIR $BASE_MEDIA_DIR/local $BASE_MEDIA_DIR/local/movies $BASE_MEDIA_DIR/local/music $BASE_MEDIA_DIR/local/series $BASE_MEDIA_DIR/local/photos $BASE_MEDIA_DIR/network
$BASE_MEDIA_DIR/network/movies $BASE_MEDIA_DIR/network/music $BASE_MEDIA_DIR/network/series $BASE_MEDIA_DIR/network/photos)
for i in ${MEDIA_DIRS[*]}; do
    [ -d $ROOT_DIR/$i ] || mkdir $ROOT_DIR/$i;
done

SERIES=chamber:/mnt/magazyn/series
MUSIC=chamber:/mnt/magazyn/music
PHOTOS=chamber:/mnt/magazyn/photos
MOVIES=chamber:/mnt/magazyn/movies

echo "$MUSIC     ${MEDIA_DIRS[8]}              nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab
echo "$SERIES    ${MEDIA_DIRS[9]}               nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab
echo "$PHOTOS    ${MEDIA_DIRS[10]}               nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab
echo "$MOVIES    ${MEDIA_DIRS[7]}               nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab

# allow reboot and powering off
#cat > /etc/polkit-1/rules.d/80-xbmc.rules << EOF

%end

