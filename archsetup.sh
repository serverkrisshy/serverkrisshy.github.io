#!/bin/sh
#github-action genshdoc
#
# @file ArchKrisshy
# @brief Entrance script that launches children scripts for each phase of installation.

# Find the name of the folder the scripts are in
set -a
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#SCRIPTS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/scripts
#CONFIGS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
set +a
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
                          Powered by Krisshy Design
"
# @description Detects and sets timezone. 
timezone () {
# Added this from arch wiki https://wiki.archlinux.org/title/System_time
time_zone="$(curl --fail https://ipapi.co/timezone)"
ip_address="$(curl --fail ipinfo.io)"
echo -ne "
System detected your timezone to be '$time_zone $ip_address' \n"
echo -ne "Is this correct?
" 
options=("Yes" "No")
select_option $? 1 "${options[@]}"

case ${options[$?]} in
    y|Y|yes|Yes|YES)
    echo "${time_zone} set as timezone"
    set_option TIMEZONE $time_zone;;
    n|N|no|NO|No)
    echo "Please enter your desired timezone e.g. Europe/London :" 
    read new_timezone
    echo "${new_timezone} set as timezone"
    set_option TIMEZONE $new_timezone;;
    *) echo "Wrong option. Try again";timezone;;
esac
}

#cd $HOME
#mkdir ArchKrisshy
#cd ArchKrisshy
timedatectl set-ntp true
echo "Here we Go...."
echo "Getting the mirrorlist (Indonesian Users only) from Server Krisshy..."
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -o /etc/pacman.d/mirrorlist https://serverkrisshy.github.io/mirrorlist
echo 
echo "Updating keyring for optimize installation..."
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring pacman-mirrorlist git --needed --noconfirm
echo

#echo -ne "Please setting up disk partition for Arch Linux in this Machine"
#echo
#fdisk /dev/sda
