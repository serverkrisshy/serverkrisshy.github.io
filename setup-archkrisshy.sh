#!/bin/sh

echo -ne "
---------------------------------------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗██╗  ██╗██████╗ ██╗███████╗███████╗██╗  ██╗██╗   ██╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██║ ██╔╝██╔══██╗██║██╔════╝██╔════╝██║  ██║╚██╗ ██╔╝
  ███████║██████╔╝██║     ███████║█████╔╝ ██████╔╝██║███████╗███████╗███████║ ╚████╔╝ 
  ██╔══██║██╔══██╗██║     ██╔══██║██╔═██╗ ██╔══██╗██║╚════██║╚════██║██╔══██║  ╚██╔╝  
  ██║  ██║██║  ██║╚██████╗██║  ██║██║  ██╗██║  ██║██║███████║███████║██║  ██║   ██║   
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝                                                                                         
---------------------------------------------------------------------------------------
                            Automated Arch Linux Installer
---------------------------------------------------------------------------------------
                Warning!!! This script for dual boot with Windows only
"

#Set Keyboard Layout
keymap () {
echo -ne "
Please select key board layout from this list"
# These are default key maps as presented in official arch repo archinstall
options=(us by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru sg ua uk)

select_option $? 4 "${options[@]}"
keymap=${options[$?]}

echo -ne "Your key boards layout: ${keymap} \n"
set_option KEYMAP $keymap
}


#Set Timezone
timezone () {
# Added this from arch wiki https://wiki.archlinux.org/title/System_time
time_zone="$(curl --fail https://ipapi.co/timezone)"
ip_address="$(curl ipinfo.io)"
echo -ne "
System detected your timezone & public IP address to be '$time_zone $ip_address' \n"
echo -ne "Is this correct?
" 
options=("Yes" "No")
select_option $? 1 "${options[@]}"

case ${options[$?]} in
    y|Y|yes|Yes|YES)
    echo "${time_zone} set as timezone"
    set_option TIMEZONE $time_zone;;
    n|N|no|NO|No)
    echo "Please enter your desired timezone e.g. Asia/Jakarta :" 
    read new_timezone
    echo "${new_timezone} set as timezone"
    set_option TIMEZONE $new_timezone;;
    *) echo "Wrong option. Try again";timezone;;
esac
}

echo "Getting the mirrorlist (Indonesian Users only) from Server Krisshy..."
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -o /etc/pacman.d/mirrorlist https://serverkrisshy.github.io/mirrorlist

echo "Updating keyring for optimize installation..."
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring pacman-mirrorlist git --needed --noconfirm
timedatectl set-ntp true