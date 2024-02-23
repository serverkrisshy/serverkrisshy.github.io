#!/bin/sh

# Checking if running in Repo Folder
if [[ "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')" =~ ^scripts$ ]]; then
    echo "You are running this in ArchKrisshy Folder."
    echo "Please use ./archkrisshy.sh instead"
    exit
fi

timedatectl set-ntp true
cd $HOME
clear
echo "...."
echo "Here we Go...."
echo "Getting the mirrorlist (Indonesian Users only) from Server Krisshy..."
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -o /etc/pacman.d/mirrorlist https://serverkrisshy.github.io/mirrorlist
echo "...."
echo "Updating keyring for optimize installation..."
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring pacman-mirrorlist git --needed --noconfirm
#echo "Cloning The ArchKrisshy to this Machine"
#git clone https://github.com/serverkrisshy/ArchKrisshy.git
clear
echo "Please setting your Partitions first!!!"
echo "Use fdisk /dev/your_disk_partitions or cfdisk /dev/your_disk_partition "
fdisk -l
#cd $HOME/ArchKrisshy
#exec ./archkrisshy.sh
