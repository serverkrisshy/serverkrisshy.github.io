#!/bin/sh
curl -o /etc/pacman.d/mirrorlist https://serverkrisshy.github.io/mirrorlist
clear
# @setting-header General Settings
CONFIG_FILE=$HOME/setup.conf
if [ ! -f $CONFIG_FILE ]; then # check if file exists
    touch -f $CONFIG_FILE # create file if not exists
fi

# @description set options in setup.conf
# @arg $1 string Configuration variable.
# @arg $2 string Configuration value.
set_option() {
    if grep -Eq "^${1}.*" $CONFIG_FILE; then # check if option exists
        sed -i -e "/^${1}.*/d" $CONFIG_FILE # delete option if exists
    fi
    echo "${1}=${2}" >>$CONFIG_FILE # add option
}

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

# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
select_option() {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "$2   $1 "; }
    print_selected()   { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    get_cursor_col()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${COL#*[}; }
    key_input()         {
                        local key
                        IFS= read -rsn1 key 2>/dev/null >&2
                        if [[ $key = ""      ]]; then echo enter; fi;
                        if [[ $key = $'\x20' ]]; then echo space; fi;
                        if [[ $key = "k" ]]; then echo up; fi;
                        if [[ $key = "j" ]]; then echo down; fi;
                        if [[ $key = "h" ]]; then echo left; fi;
                        if [[ $key = "l" ]]; then echo right; fi;
                        if [[ $key = "a" ]]; then echo all; fi;
                        if [[ $key = "n" ]]; then echo none; fi;
                        if [[ $key = $'\x1b' ]]; then
                            read -rsn2 key
                            if [[ $key = [A || $key = k ]]]; then echo up;    fi;
                            if [[ $key = [B || $key = j ]]]; then echo down;  fi;
                            if [[ $key = [C || $key = l ]]]; then echo right;  fi;
                            if [[ $key = [D || $key = h ]]]; then echo left;  fi;
                        fi 
    }
    print_options_multicol() {
        # print options by overwriting the last lines
        local curr_col=$1
        local curr_row=$2
        local curr_idx=0

        local idx=0
        local row=0
        local col=0
        
        curr_idx=$(( $curr_col + $curr_row * $colmax ))
        
        for option in "${options[@]}"; do

            row=$(( $idx/$colmax ))
            col=$(( $idx - $row * $colmax ))

            cursor_to $(( $startrow + $row + 1)) $(( $offset * $col + 1))
            if [ $idx -eq $curr_idx ]; then
                print_selected "$option"
            else
                print_option "$option"
            fi
            ((idx++))
        done
    }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local return_value=$1
    local lastrow=`get_cursor_row`
    local lastcol=`get_cursor_col`
    local startrow=$(($lastrow - $#))
    local startcol=1
    local lines=$( tput lines )
    local cols=$( tput cols ) 
    local colmax=$2
    local offset=$(( $cols / $colmax ))

    local size=$4
    shift 4

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local active_row=0
    local active_col=0
    while true; do
        print_options_multicol $active_col $active_row 
        # user key control
        case `key_input` in
            enter)  break;;
            up)     ((active_row--));;
                    if [ $active_row -lt 0 ]; then active_row=0; fi;;
            down)   ((active_row++));;
                    if [ $active_row -ge $(( ${#options[@]} / $colmax ))  ]; then active_row=$(( ${#options[@]} / $colmax )); fi;;
            left)     ((active_col=$active_col - 1));;
                    if [ $active_col -lt 0 ]; then active_col=0; fi;;
            right)     ((active_col=$active_col + 1));
                    if [ $active_col -ge $colmax ]; then active_col=$(( $colmax - 1 )) ; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $(( $active_col + $active_row * $colmax ))
}




logo () {
# This will be shown on every set as user is progressing
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
          Enjoy your Coffee this progress may take a several minutes
------------------------------------------------------------------------------------

"
}
time_zone="$(curl --fail https://ipapi.co/timezone)"

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
pacman -Sy pacman-mirrorlist archlinux-keyring yakuake dolphin okular partitionmanager gwenview hanura plasma-wayland-session egl-wayland fwupd firewalld firefox nano git lsd exa zsh less man-db mlocate gcc cmake extra-cmake-modules make rust python python-pip go devtools dialog zram-generator gdb ttf-roboto neofetch zip unzip unrar ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono ttf-nerd-fonts-symbols-common ttf-firacode-nerd ttf-roboto libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-utils lib32-mesa intel-media-driver intel-ucode
echo
echo -ne "
-------------------------------------------------------------------------
                Setup Language to English and set locale  
-------------------------------------------------------------------------
"
useradd -m -g users -G wheel krisshy
ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
echo -ne "
-------------------------------------------------------------------------
                  Setting up hostname for this Machine 
-------------------------------------------------------------------------
"
echo greenDay-X1 >> /etc/hostname
curl -o /etc/hosts https://serverkrisshy.github.io/hosts
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
mkinitcpio -P linux
mkinitcpio -P linux-lts
clear

logo
echo -ne "
-------------------------------------------------------------------------
                    Installing GRUB Bootloader  
-------------------------------------------------------------------------
"
pacman-key --init
pacman-key --populate archlinux
pacman -Suy --needed --noconfirm dosfstools grub efibootmgr lvm2 os-prober 
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=grub --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg
clear
logo
echo
echo -ne "
-------------------------------------------------------------------------
                    Setting up Network  
-------------------------------------------------------------------------
"
pacman -Sy --noconfirm --needed networkmanager iw iwd alsa-utils bluedevil bluez bluez-utils bluez-libs pipewire coreutils
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
echo -ne "
-------------------------------------------------------------------------
                    Installing Desktop Environment  
-------------------------------------------------------------------------
"
pacman -Sy --noconfirm --needed plasma-desktop plasma-meta sddm kwayland-integration
systemctl enable --now sddm.service
clear
logo
echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"
cd $pwd
echo
echo
echo "Done, Please setup password for root and user and then reboot"
echo "Dont forget to eject the installation media"
