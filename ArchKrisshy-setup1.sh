#!/bin/sh
#github-action genshdoc
#
# @file Startup
# @brief This script will ask users about their prefrences like disk, file system, timezone, keyboard layout, user name, password, etc.
# @stdout Output routed to startup.log
# @stderror Output routed to startup.log
setfont ter-v22n
time_zone="$(curl -f -s https://ipapi.co/timezone)"
ip_address=$(curl -f -s ifconfig.io)
# @setting-header General Settings
root_check() {
    if [[ "$(id -u)" != "0" ]]; then
        echo -ne "ERROR! This script must be run under the 'root' user!\n"
        exit 0
    fi
}

docker_check() {
    if awk -F/ '$2 == "docker"' /proc/self/cgroup | read -r; then
        echo -ne "ERROR! Docker container is not supported (at the moment)\n"
        exit 0
    elif [[ -f /.dockerenv ]]; then
        echo -ne "ERROR! Docker container is not supported (at the moment)\n"
        exit 0
    fi
}

arch_check() {
    if [[ ! -e /etc/arch-release ]]; then
        echo -ne "ERROR! This script must be run in Arch Linux!\n"
        exit 0
    fi
}

pacman_check() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        echo "ERROR! Pacman is blocked."
        echo -ne "If not running remove /var/lib/pacman/db.lck.\n"
        exit 0
    fi
}

background_checks() {
    root_check
    arch_check
    pacman_check
    docker_check
}


logo () {
#
echo -ne "
------------------------------------------------------------------------------------
 █████╗ ██████╗  ██████╗██╗  ██╗██╗  ██╗██████╗ ██╗███████╗███████╗██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║██║ ██╔╝██╔══██╗██║██╔════╝██╔════╝██║  ██║╚██╗ ██╔╝
███████║██████╔╝██║     ███████║█████╔╝ ██████╔╝██║███████╗███████╗███████║ ╚████╔╝
██╔══██║██╔══██╗██║     ██╔══██║██╔═██╗ ██╔══██╗██║╚════██║╚════██║██╔══██║  ╚██╔╝
██║  ██║██║  ██║╚██████╗██║  ██║██║  ██╗██║  ██║██║███████║███████║██║  ██║   ██║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝
------------------------------------------------------------------------------------
                          Automated Arch Linux Installer
------------------------------------------------------------------------------------
                         Code by KrisshyDesign @Indonesia
------------------------------------------------------------------------------------
             Enjoy your Coffee this progress may take a several minutes
------------------------------------------------------------------------------------
"
echo
#
}

# @description Detects and sets timezone.
timezone () {
# Added this from arch wiki https://wiki.archlinux.org/title/System_time
echo -ne "
System detected your Timezone & IP Adrress to be : \n \n '$time_zone' \n '$ip_address' \n \n"
echo "Prepared the Installation ..." && sleep 5
echo "continue in 10 Seconds ..." && sleep 1
echo "Continue in 9 Seconds ..." && sleep 1
echo "Continue in 8 Seconds ..." && sleep 1
echo "Continue in 7 Seconds ..." && sleep 1
echo "continue in 6 Seconds ..." && sleep 1
echo "continue in 5 Seconds ..." && sleep 1
echo "Continue in 4 Seconds ..." && sleep 1
echo "Continue in 3 Seconds ..." && sleep 1
echo "Continue in 2 Seconds ..." && sleep 1
echo "Continue in 1 Second ..." && sleep 1
}



# Starting functions
clear
clear
echo -ne "Are you has setting up the partition? \n
press Enter to continue \n
press Ctrl + c to setting the partition"
read
clear
echo -ne "
------------------------------------------------------------------------------------
 █████╗ ██████╗  ██████╗██╗  ██╗██╗  ██╗██████╗ ██╗███████╗███████╗██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║██║ ██╔╝██╔══██╗██║██╔════╝██╔════╝██║  ██║╚██╗ ██╔╝
███████║██████╔╝██║     ███████║█████╔╝ ██████╔╝██║███████╗███████╗███████║ ╚████╔╝
██╔══██║██╔══██╗██║     ██╔══██║██╔═██╗ ██╔══██╗██║╚════██║╚════██║██╔══██║  ╚██╔╝
██║  ██║██║  ██║╚██████╗██║  ██║██║  ██╗██║  ██║██║███████║███████║██║  ██║   ██║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝
------------------------------------------------------------------------------------
                            Automated Arch Linux Installer
------------------------------------------------------------------------------------
                           Code by KrisshyDesign @Indonesia
------------------------------------------------------------------------------------
"
echo
background_checks
clear
logo
timezone
timedatectl set-timezone $time_zone
timedatectl set-ntp true
clear
logo
echo
echo "Here we Go ...."
echo
echo -ne "
------------------------------------------------------------------------------------
          Getting mirrorlist (Indonesian Users only) from Server Krisshy
------------------------------------------------------------------------------------
"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -o /etc/pacman.d/mirrorlist https://serverkrisshy.github.io/mirrorlist
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
echo
echo -ne "
------------------------------------------------------------------------------------
                     Updating keyring for optimize installation
------------------------------------------------------------------------------------
"
echo
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring pacman-mirrorlist --noconfirm --needed
clear
logo
echo
echo -ne "
------------------------------------------------------------------------------------
                        Format & Mounting selected partition
------------------------------------------------------------------------------------
"
echo
umount -R /mnt
echo
echo -ne "This prgoress will destroy all data on this Machine, make sure you has setting up the partition for this installation. \n
for continue installation press Enter \n
for exit installation press Ctrl + c"
read
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
mkdir -p /mnt/home
mount /dev/nvme0n1p3 /mnt/home
lsblk
echo
echo
echo -ne "Is this correct? \ne
if not correct please press Ctrl + c"
read
echo
clear
logo
echo -ne "
------------------------------------------------------------------------------------
                        Installing base system to this Machine
------------------------------------------------------------------------------------
"
echo
pacstrap /mnt base base-devel linux-firmware linux linux-headers --noconfirm --needed
curl -o /mnt/root/ArchKrisshy-setup2.sh https://serverkrisshy.github.io/ArchKrisshy-setup2.sh
chmod +x /mnt/root/ArchKrisshy-setup2.sh
echo
genfstab -U /mnt >> /mnt/etc/fstab
echo "
  Generated fstab file:
"
cat /mnt/etc/fstab
echo
echo "Is this correct? \n
if not correct please press Ctrl + c
if correct press enter and then exec the ArchKrisshy-setup.sh like this : \n
\n sh /root/ArchKrisshy-setup2.sh"
echo
read
arch-chroot /mnt
