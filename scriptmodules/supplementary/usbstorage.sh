#!/usr/bin/env bash

# Script made by Riccardo Bux as part of RetroPie project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="usbstorage"
rp_module_desc="Configure usb"
rp_module_section="config"

function install_usbstorage() {
apt-get update
apt-get install -y ntfs-3g exfat-fuse usbmount
mkdir /mnt/usb
}

function remove_fstab(){
if grep -q "/mnt/usb" "/etc/fstab"; then
sed -i "s/UUID=.*/ /g" /etc/fstab
systemctl disable bind.service
printMsgs "dialog" "Usb removed"
else
printMsgs "dialog" "Nothing to remove"
fi
}

function usb_share(){
local options=(
1 "Set usb for samba shares"
2 "No thanks, I will use it without network sharing"
)
local cmd=(dialog --backtitle "$__backtitle" --menu "Do you want to share usb in your local network? (Need Samba installed)" 22 86 16)
local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
[[ "$choice" -eq 1 ]] && cp /etc/samba/smb.conf /etc/samba/smb.conf.usbbak && write_shares 
[[ "$choice" -eq 2 ]] && return
}
function write_shares(){
if grep -q "/mnt/usb" "/etc/samba/smb.conf"; then
printMsgs "dialog" "Usb already setted in /etc/samba/smb.conf, if doesn't work as you expect: restore backup from previous menu, or remove manually part from [usb] to force user=pi in your /etc/smb/smb.conf file and try again"
else
cat >>/etc/samba/smb.conf <<_EOF_
[usb]
comment = usb share
path = /mnt/usb
writable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = pi
_EOF_
fi
/etc/init.d/smbd restart
} 
function write_fstab(){
mount -t $fs /dev/$usb_path1 /mnt/usb
chown -R -h pi:pi /mnt/usb/retropie/*
cp /home/pi/RetroPie-Setup/scriptmodules/supplementary/usbstorage/bind.sh /etc/init.d/bind.sh
chmod +x /etc/init.d/bind.sh
cp /home/pi/RetroPie-Setup/scriptmodules/supplementary/usbstorage/bind.service /etc/systemd/system/bind.service
systemctl enable bind.service
if grep -q "/mnt/usb" "/etc/fstab"; then
sed -i "s/UUID=.*/UUID=$uuid \/mnt\/usb $fs noauto/g" /etc/fstab
else
echo "UUID=$uuid /mnt/usb $fs noauto" >> /etc/fstab
fi
}
function set_usb(){
usb_path_from_rp="$usb_path/configs/from_retropie"
usb_path_to_rp="$usb_path/configs/to_retropie"
local usb_path
    usb_path1="$(choose_usb)"
if [[ "$usb_path1" == "" ]]; then
printMsgs "dialog" "No usb drive detected"
return
fi
	fs=$(eval $(blkid /dev/$usb_path1 | awk '{print $3}'); echo $TYPE)
	umount /dev/$usb_path1
	umount /mnt/usb
	mount -t $fs -o nonempty /dev/$usb_path1 /mnt/usb
	uuid=$(blkid /dev/$usb_path1 -sUUID | cut -d'"' -f2)
    usb_path=/mnt/usb
if [[ -d $usb_path/retropie ]]; then
local options=(
1 "Continue and use this usb anyway"
2 "Exit"
)

local cmd=(dialog --backtitle "$__backtitle" --menu "It seems that this usb was already used with retrorangepi" 22 86 16)
local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
[[ "$choice" -eq 1 ]] && mkdir -p "$usb_path/retropie/"{roms,BIOS} "$usb_path_from_rp" "$usb_path_to_rp" && mkdir -p "$usb_path/retropie/roms/"{amiga,amstradcpc,apple2,arcade,atari2600,atari5200,atari7800,atari800,atarilynx,atarist,c64,coco,coleco,crvision,daphne,dragon32,dreamcast,fba,fds,gameandwatch,gamegear,gb,gba,gbc,genesis,intellivision,kodi,love,macintosh,mame-advmame,mame-libretro,mame-mame4all,mastersystem,megadrive,msx,n64,neogeo,nes,ngp,ngpc,pc,pcengine,ports,psp,psx,scummvm,sega32x,segacd,sg-1000,snes,vectrex,videopac,virtualboy,wonderswan,wonderswancolor,zmachine,zxspectrum} && umount -a > /dev/null 2>&1 || /bin/true && rm -rf /home/$user/RetroPie/roms/amiga/usb && rm -rf /home/$user/RetroPie/roms/nes/usb && rm -rf /home/$user/RetroPie/roms/amstradcpc/usb && rm -rf /home/$user/RetroPie/roms/apple2/usb && rm -rf /home/$user/RetroPie/roms/arcade/usb && rm -rf /home/$user/RetroPie/roms/atari2600/usb && rm -rf /home/$user/RetroPie/roms/atari5200/usb && rm -rf /home/$user/RetroPie/roms/atari7800/usb && rm -rf /home/$user/RetroPie/roms/atari800/usb && rm -rf /home/$user/RetroPie/roms/atarilynx/usb && rm -rf /home/$user/RetroPie/roms/atarist/usb && rm -rf /home/$user/RetroPie/roms/c64/usb && rm -rf /home/$user/RetroPie/roms/coco/usb && rm -rf /home/$user/RetroPie/roms/coleco/usb && rm -rf /home/$user/RetroPie/roms/crvision/usb && rm -rf /home/$user/RetroPie/roms/daphne/usb && rm -rf /home/$user/RetroPie/roms/dragon32/usb && rm -rf /home/$user/RetroPie/roms/dreamcast/usb && rm -rf /home/$user/RetroPie/roms/fba/usb && rm -rf /home/$user/RetroPie/roms/fds/usb && rm -rf /home/$user/RetroPie/roms/gameandwatch/usb && rm -rf /home/$user/RetroPie/roms/gamegear/usb && rm -rf /home/$user/RetroPie/roms/gb/usb && rm -rf /home/$user/RetroPie/roms/gba/usb && rm -rf /home/$user/RetroPie/roms/gbc/usb && rm -rf /home/$user/RetroPie/roms/genesis/usb && rm -rf /home/$user/RetroPie/roms/intellivision/usb && rm -rf /home/$user/RetroPie/roms/kodi/usb && rm -rf /home/$user/RetroPie/roms/love/usb && rm -rf /home/$user/RetroPie/roms/macintosh/usb && rm -rf /home/$user/RetroPie/roms/mame-advmame/usb && rm -rf /home/$user/RetroPie/roms/mame-libretro/usb && rm -rf /home/$user/RetroPie/roms/mame-mame4all/usb && rm -rf /home/$user/RetroPie/roms/mastersystem/usb && rm -rf /home/$user/RetroPie/roms/megadrive/usb && rm -rf /home/$user/RetroPie/roms/msx/usb && rm -rf /home/$user/RetroPie/roms/n64/usb && rm -rf /home/$user/RetroPie/roms/neogeo/usb && rm -rf /home/$user/RetroPie/roms/ngp/usb && rm -rf /home/$user/RetroPie/roms/ngpc/usb && rm -rf /home/$user/RetroPie/roms/pc/usb && rm -rf /home/$user/RetroPie/roms/pcengine/usb && rm -rf /home/$user/RetroPie/roms/ports/usb && rm -rf /home/$user/RetroPie/roms/psp/usb && rm -rf /home/$user/RetroPie/roms/psx/usb && rm -rf /home/$user/RetroPie/roms/scummvm/usb && rm -rf /home/$user/RetroPie/roms/sega32x/usb && rm -rf /home/$user/RetroPie/roms/segacd/usb && rm -rf /home/$user/RetroPie/roms/sg-1000/usb && rm -rf /home/$user/RetroPie/roms/snes/usb && rm -rf /home/$user/RetroPie/roms/vectrex/usb && rm -rf /home/$user/RetroPie/roms/videopac/usb && rm -rf /home/$user/RetroPie/roms/virtualboy/usb && rm -rf /home/$user/RetroPie/roms/wonderswan/usb && rm -rf /home/$user/RetroPie/roms/wonderswancolor/usb && rm -rf /home/$user/RetroPie/roms/zmachine/usb && rm -rf /home/$user/RetroPie/roms/zxspectrum/usb && mkdir /home/$user/RetroPie/roms/amiga/usb && mkdir /home/$user/RetroPie/roms/nes/usb && mkdir /home/$user/RetroPie/roms/amstradcpc/usb && mkdir /home/$user/RetroPie/roms/apple2/usb && mkdir /home/$user/RetroPie/roms/arcade/usb && mkdir /home/$user/RetroPie/roms/atari2600/usb && mkdir /home/$user/RetroPie/roms/atari5200/usb && mkdir /home/$user/RetroPie/roms/atari7800/usb && mkdir /home/$user/RetroPie/roms/atari800/usb && mkdir /home/$user/RetroPie/roms/atarilynx/usb && mkdir /home/$user/RetroPie/roms/atarist/usb && mkdir /home/$user/RetroPie/roms/c64/usb && mkdir /home/$user/RetroPie/roms/coco/usb && mkdir /home/$user/RetroPie/roms/coleco/usb && mkdir /home/$user/RetroPie/roms/crvision/usb && mkdir /home/$user/RetroPie/roms/daphne/usb && mkdir /home/$user/RetroPie/roms/dragon32/usb && mkdir /home/$user/RetroPie/roms/dreamcast/usb && mkdir /home/$user/RetroPie/roms/fba/usb && mkdir /home/$user/RetroPie/roms/fds/usb && mkdir /home/$user/RetroPie/roms/gameandwatch/usb && mkdir /home/$user/RetroPie/roms/gamegear/usb && mkdir /home/$user/RetroPie/roms/gb/usb && mkdir /home/$user/RetroPie/roms/gba/usb && mkdir /home/$user/RetroPie/roms/gbc/usb && mkdir /home/$user/RetroPie/roms/genesis/usb && mkdir /home/$user/RetroPie/roms/intellivision/usb && mkdir /home/$user/RetroPie/roms/kodi/usb && mkdir /home/$user/RetroPie/roms/love/usb && mkdir /home/$user/RetroPie/roms/macintosh/usb && mkdir /home/$user/RetroPie/roms/mame-advmame/usb && mkdir /home/$user/RetroPie/roms/mame-libretro/usb && mkdir /home/$user/RetroPie/roms/mame-mame4all/usb && mkdir /home/$user/RetroPie/roms/mastersystem/usb && mkdir /home/$user/RetroPie/roms/megadrive/usb && mkdir /home/$user/RetroPie/roms/msx/usb && mkdir /home/$user/RetroPie/roms/n64/usb && mkdir /home/$user/RetroPie/roms/neogeo/usb && mkdir /home/$user/RetroPie/roms/ngp/usb && mkdir /home/$user/RetroPie/roms/ngpc/usb && mkdir /home/$user/RetroPie/roms/pc/usb && mkdir /home/$user/RetroPie/roms/pcengine/usb && mkdir /home/$user/RetroPie/roms/ports/usb && mkdir /home/$user/RetroPie/roms/psp/usb && mkdir /home/$user/RetroPie/roms/psx/usb && mkdir /home/$user/RetroPie/roms/scummvm/usb && mkdir /home/$user/RetroPie/roms/sega32x/usb && mkdir /home/$user/RetroPie/roms/segacd/usb && mkdir /home/$user/RetroPie/roms/sg-1000/usb && mkdir /home/$user/RetroPie/roms/snes/usb && mkdir /home/$user/RetroPie/roms/vectrex/usb && mkdir /home/$user/RetroPie/roms/videopac/usb && mkdir /home/$user/RetroPie/roms/virtualboy/usb && mkdir /home/$user/RetroPie/roms/wonderswan/usb && mkdir /home/$user/RetroPie/roms/wonderswancolor/usb && mkdir /home/$user/RetroPie/roms/zmachine/usb && mkdir /home/$user/RetroPie/roms/zxspectrum/usb && write_fstab && usb_share

[[ "$choice" -eq 2 ]] && return
else
usb_path=/mnt/usb
umount -a > /dev/null 2>&1 || /bin/true
mkdir -p "$usb_path/retropie/"{roms,BIOS} "$usb_path_from_rp" "$usb_path_to_rp"
mkdir -p "$usb_path/retropie/roms/"{amiga,amstradcpc,apple2,arcade,atari2600,atari5200,atari7800,atari800,atarilynx,atarist,c64,coco,coleco,crvision,daphne,dragon32,dreamcast,fba,fds,gameandwatch,gamegear,gb,gba,gbc,genesis,intellivision,kodi,love,macintosh,mame-advmame,mame-libretro,mame-mame4all,mastersystem,megadrive,msx,n64,neogeo,nes,ngp,ngpc,pc,pcengine,ports,psp,psx,scummvm,sega32x,segacd,sg-1000,snes,vectrex,videopac,virtualboy,wonderswan,wonderswancolor,zmachine,zxspectrum} && rm -rf /home/$user/RetroPie/roms/amiga/usb && rm -rf /home/$user/RetroPie/roms/nes/usb && rm -rf /home/$user/RetroPie/roms/amstradcpc/usb && rm -rf /home/$user/RetroPie/roms/apple2/usb && rm -rf /home/$user/RetroPie/roms/arcade/usb && rm -rf /home/$user/RetroPie/roms/atari2600/usb && rm -rf /home/$user/RetroPie/roms/atari5200/usb && rm -rf /home/$user/RetroPie/roms/atari7800/usb && rm -rf /home/$user/RetroPie/roms/atari800/usb && rm -rf /home/$user/RetroPie/roms/atarilynx/usb && rm -rf /home/$user/RetroPie/roms/atarist/usb && rm -rf /home/$user/RetroPie/roms/c64/usb && rm -rf /home/$user/RetroPie/roms/coco/usb && rm -rf /home/$user/RetroPie/roms/coleco/usb && rm -rf /home/$user/RetroPie/roms/crvision/usb && rm -rf /home/$user/RetroPie/roms/daphne/usb && rm -rf /home/$user/RetroPie/roms/dragon32/usb && rm -rf /home/$user/RetroPie/roms/dreamcast/usb && rm -rf /home/$user/RetroPie/roms/fba/usb && rm -rf /home/$user/RetroPie/roms/fds/usb && rm -rf /home/$user/RetroPie/roms/gameandwatch/usb && rm -rf /home/$user/RetroPie/roms/gamegear/usb && rm -rf /home/$user/RetroPie/roms/gb/usb && rm -rf /home/$user/RetroPie/roms/gba/usb && rm -rf /home/$user/RetroPie/roms/gbc/usb && rm -rf /home/$user/RetroPie/roms/genesis/usb && rm -rf /home/$user/RetroPie/roms/intellivision/usb && rm -rf /home/$user/RetroPie/roms/kodi/usb && rm -rf /home/$user/RetroPie/roms/love/usb && rm -rf /home/$user/RetroPie/roms/macintosh/usb && rm -rf /home/$user/RetroPie/roms/mame-advmame/usb && rm -rf /home/$user/RetroPie/roms/mame-libretro/usb && rm -rf /home/$user/RetroPie/roms/mame-mame4all/usb && rm -rf /home/$user/RetroPie/roms/mastersystem/usb && rm -rf /home/$user/RetroPie/roms/megadrive/usb && rm -rf /home/$user/RetroPie/roms/msx/usb && rm -rf /home/$user/RetroPie/roms/n64/usb && rm -rf /home/$user/RetroPie/roms/neogeo/usb && rm -rf /home/$user/RetroPie/roms/ngp/usb && rm -rf /home/$user/RetroPie/roms/ngpc/usb && rm -rf /home/$user/RetroPie/roms/pc/usb && rm -rf /home/$user/RetroPie/roms/pcengine/usb && rm -rf /home/$user/RetroPie/roms/ports/usb && rm -rf /home/$user/RetroPie/roms/psp/usb && rm -rf /home/$user/RetroPie/roms/psx/usb && rm -rf /home/$user/RetroPie/roms/scummvm/usb && rm -rf /home/$user/RetroPie/roms/sega32x/usb && rm -rf /home/$user/RetroPie/roms/segacd/usb && rm -rf /home/$user/RetroPie/roms/sg-1000/usb && rm -rf /home/$user/RetroPie/roms/snes/usb && rm -rf /home/$user/RetroPie/roms/vectrex/usb && rm -rf /home/$user/RetroPie/roms/videopac/usb && rm -rf /home/$user/RetroPie/roms/virtualboy/usb && rm -rf /home/$user/RetroPie/roms/wonderswan/usb && rm -rf /home/$user/RetroPie/roms/wonderswancolor/usb && rm -rf /home/$user/RetroPie/roms/zmachine/usb && rm -rf /home/$user/RetroPie/roms/zxspectrum/usb && mkdir /home/$user/RetroPie/roms/amiga/usb && mkdir /home/$user/RetroPie/roms/nes/usb && mkdir /home/$user/RetroPie/roms/amstradcpc/usb && mkdir /home/$user/RetroPie/roms/apple2/usb && mkdir /home/$user/RetroPie/roms/arcade/usb && mkdir /home/$user/RetroPie/roms/atari2600/usb && mkdir /home/$user/RetroPie/roms/atari5200/usb && mkdir /home/$user/RetroPie/roms/atari7800/usb && mkdir /home/$user/RetroPie/roms/atari800/usb && mkdir /home/$user/RetroPie/roms/atarilynx/usb && mkdir /home/$user/RetroPie/roms/atarist/usb && mkdir /home/$user/RetroPie/roms/c64/usb && mkdir /home/$user/RetroPie/roms/coco/usb && mkdir /home/$user/RetroPie/roms/coleco/usb && mkdir /home/$user/RetroPie/roms/crvision/usb && mkdir /home/$user/RetroPie/roms/daphne/usb && mkdir /home/$user/RetroPie/roms/dragon32/usb && mkdir /home/$user/RetroPie/roms/dreamcast/usb && mkdir /home/$user/RetroPie/roms/fba/usb && mkdir /home/$user/RetroPie/roms/fds/usb && mkdir /home/$user/RetroPie/roms/gameandwatch/usb && mkdir /home/$user/RetroPie/roms/gamegear/usb && mkdir /home/$user/RetroPie/roms/gb/usb && mkdir /home/$user/RetroPie/roms/gba/usb && mkdir /home/$user/RetroPie/roms/gbc/usb && mkdir /home/$user/RetroPie/roms/genesis/usb && mkdir /home/$user/RetroPie/roms/intellivision/usb && mkdir /home/$user/RetroPie/roms/kodi/usb && mkdir /home/$user/RetroPie/roms/love/usb && mkdir /home/$user/RetroPie/roms/macintosh/usb && mkdir /home/$user/RetroPie/roms/mame-advmame/usb && mkdir /home/$user/RetroPie/roms/mame-libretro/usb && mkdir /home/$user/RetroPie/roms/mame-mame4all/usb && mkdir /home/$user/RetroPie/roms/mastersystem/usb && mkdir /home/$user/RetroPie/roms/megadrive/usb && mkdir /home/$user/RetroPie/roms/msx/usb && mkdir /home/$user/RetroPie/roms/n64/usb && mkdir /home/$user/RetroPie/roms/neogeo/usb && mkdir /home/$user/RetroPie/roms/ngp/usb && mkdir /home/$user/RetroPie/roms/ngpc/usb && mkdir /home/$user/RetroPie/roms/pc/usb && mkdir /home/$user/RetroPie/roms/pcengine/usb && mkdir /home/$user/RetroPie/roms/ports/usb && mkdir /home/$user/RetroPie/roms/psp/usb && mkdir /home/$user/RetroPie/roms/psx/usb && mkdir /home/$user/RetroPie/roms/scummvm/usb && mkdir /home/$user/RetroPie/roms/sega32x/usb && mkdir /home/$user/RetroPie/roms/segacd/usb && mkdir /home/$user/RetroPie/roms/sg-1000/usb && mkdir /home/$user/RetroPie/roms/snes/usb && mkdir /home/$user/RetroPie/roms/vectrex/usb && mkdir /home/$user/RetroPie/roms/videopac/usb && mkdir /home/$user/RetroPie/roms/virtualboy/usb && mkdir /home/$user/RetroPie/roms/wonderswan/usb && mkdir /home/$user/RetroPie/roms/wonderswancolor/usb && mkdir /home/$user/RetroPie/roms/zmachine/usb && mkdir /home/$user/RetroPie/roms/zxspectrum/usb 
write_fstab
usb_share
fi

}

function choose_usb(){

local options=()
    local i=0

devs=`ls -al /dev/disk/by-path/*usb*part* 2>/dev/null | awk '{print($11)}'`; 
for dev in $devs; 
do dev=${dev##*\/};
mount /dev/$dev /media/usb$i
dim=$(df -Ph /dev/$dev | tail -1 | awk '{print $4}')
options+=("$dev" "Usb$i Size $dim")
((i++)) 
done



#if [[ $i != 0 ]]; then
local cmd=(dialog --backtitle "$__backtitle" --menu "Choose Usb." 22 76 16)
   local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    	[[ -n "$choice" ]] && echo "${options[choice]}"

}

function gui_usbstorage(){
while true; do
local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option. $user" 22 76 16)
local options=(
1 "Install usb filesystems (exfat, ntfs)"
2 "Choose your usb drive"
3 "Remove setted usb"
)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
		install_usbstorage
                    ;;
		2)
		set_usb
		   ;;
		3)
		remove_fstab
		;;
esac
else
break
fi
done
}
