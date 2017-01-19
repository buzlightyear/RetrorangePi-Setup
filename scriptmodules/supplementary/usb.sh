#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="usb storage"
rp_module_desc="Configure usb"
rp_module_section="main"
rp_module_flags="!x86 !osmc"

function set_usb(){
local path="/media"
local options=()
    local i=0
    while read usbdir; do
        usbdir=/media/
options+=("$i" "$usbdir")
            ((i++))
done < <(sort)
local cmd=(dialog --backtitle "$__backtitle" --menu "Choose Usb." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -n "$choice" ]] && echo "$path/${options[choice*2+1]}"
}

function gui_usb(){
local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    while true; do
local options=(1 "Choose usb")

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    set_usb set
                    ;;
