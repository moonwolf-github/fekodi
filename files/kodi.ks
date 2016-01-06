# Kickstart file to build the appliance operating
# system for fedora.
# This is based on the work at http://www.thincrust.net
lang pl_PL.UTF-8
keyboard pl2
timezone Europe/Warsaw
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
bootloader --timeout=10 --extlinux #--append="acpi=force console=ttyS0,115200"
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
part /boot --fstype=ext4 --ondisk=sda --size=500
part / --size=2048 --fstype=ext4 --ondisk=sda

#
# Repositories
#
repo --name=f22 --baseurl=http://upgrades.tech.sp/f22/release/Everything/$basearch/os
repo --name=f22-updates --baseurl=http://upgrades.tech.sp/f22/updates/$basearch/
repo --name=rpmfusion-free --baseurl=http://upgrades.tech.sp/rpmfusion/f22/release/free/Everything/$basearch/os
repo --name=rpmfusion-free-updates --baseurl=http://upgrades.tech.sp/rpmfusion/f22/updates/free/$basearch/
repo --name=rpmfusion-nonfree --baseurl=http://upgrades.tech.sp/rpmfusion/f22/release/nonfree/Everything/$basearch/os
repo --name=rpmfusion-nonfree-updates --baseurl=http://upgrades.tech.sp/rpmfusion/f22/updates/free/$basearch/

#
# Add all the packages after the base packages
#
%packages --excludedocs
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
kodi
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
NetworkManager-wifi

-fedora-logos
-fedora-release-notes
%end

#
# Add custom post scripts after the base post.
#
%post
cat > /etc/systemd/system/kodi.service << EOF
[Unit]
Description = Starts instance of Kodi using xinit
After = syslog.target

[Service]
User = feplayer
Group = feplayer
Type = simple
ExecStart = /usr/bin/xinit /usr/bin/kodi-standalone -- :0

[Install]
WantedBy = default.target
EOF
/usr/bin/systemctl enable kodi.service

cp -f /etc/skel/{*,.*} /root/

/usr/sbin/useradd -mUp febmc feplayer
/usr/sbin/usermod -G audio,cdrom feplayer

# media directories - it belongs to config program not here
BASE_MEDIA_DIR=/home/media
MEDIA_DIRS=($BASE_MEDIA_DIR $BASE_MEDIA_DIR/local $BASE_MEDIA_DIR/local/movies $BASE_MEDIA_DIR/local/music $BASE_MEDIA_DIR/local/series $BASE_MEDIA_DIR/local/photos $BASE_MEDIA_DIR/network
$BASE_MEDIA_DIR/network/movies $BASE_MEDIA_DIR/network/music $BASE_MEDIA_DIR/network/series $BASE_MEDIA_DIR/network/photos)
for i in ${MEDIA_DIRS[*]}; do
    [ -d $ROOT_DIR/$i ] || mkdir $ROOT_DIR/$i;
done

SERIES=chamber.karakkhaz.dwarfs:/mnt/magazyn/series
MUSIC=chamber.karakkhaz.dwarfs:/mnt/magazyn/music
PHOTOS=chamber.karakkhaz.dwarfs:/mnt/magazyn/photos
MOVIES=chamber.karakkhaz.dwarfs:/mnt/magazyn/movies

echo "$MUSIC     ${MEDIA_DIRS[8]}              nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab
echo "$SERIES    ${MEDIA_DIRS[9]}               nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab
echo "$PHOTOS    ${MEDIA_DIRS[10]}               nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab
echo "$MOVIES    ${MEDIA_DIRS[7]}               nfs    defaults,user,auto        0 0" >>  $ROOT_DIR/etc/fstab

# allow reboot and powering off
cat > /etc/polkit-1/rules.d/80-kodi.rules << EOF
polkit.addRule(function(action, subject) {
    if ((action.id.indexOf("power-off") >= 0 || action.id.indexOf("reboot") >= 0 || action.id.indexOf("suspend") >= 0 || action.id.indexOf("hibernate") >= 0) && subject.user == "feplayer") {
        return polkit.Result.YES;
    }
});
EOF

cat > /etc/X11/Xwrapper.config << EOF
allowed_users = anybody
needs_root_rights = yes
EOF
%end

