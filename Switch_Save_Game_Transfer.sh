#!/bin/bash

# Backup game saves before overwriting
create_backup_before_overwriting=True

# Backup extension to append to backup directories
backup_extension="__backup"

# Ryujinx Save File Directory
ryujinx_save_file_directory="$HOME/.config/Ryujinx/bis/user/save"

# Yuzu Save File Directory (Replace with your Yuzu user ID)
yuzu_save_file_directory="$HOME/.config/yuzu/nand/user/save/0000000000000000/{your_yuzu_user_id}"

# Declare an associative array for game save directories
declare -A switch_save_directories

# Initialize game index
i=1

# Add games to the array
switch_save_directories[$i.title]="Transfer All Game Saves [Backup Your Save Files First]"
switch_save_directories[$i.ryujinx]=""
switch_save_directories[$i.yuzu]=""
let i+=1

# Animal Crossing: New Horizons
switch_save_directories[$i.title]="Animal Crossing: New Horizons"
switch_save_directories[$i.ryujinx]="${ryujinx_save_file_directory}/00000000000000{xx}/0"
switch_save_directories[$i.yuzu]="${yuzu_save_file_directory}/01006F8002326000"
let i+=1

# Add other games similarly...

# Function to create a backup of a directory
create_backup_of() {
    if [ "$create_backup_before_overwriting" = "True" ]; then
        backup_dir="$1$backup_extension"
        if [ -d "$1" ]; then
            cp -r "$1" "$backup_dir"
            echo "Backup created: $backup_dir"
        else
            echo "Directory not found: $1"
        fi
    fi
}

# Function to transfer save files from one emulator to another for a specific game
transfer_save_files_from() {
    local game_index=$1
    local transfer_from=$2
    if [ "$transfer_from" -eq 1 ]; then
        copy_folder="${switch_save_directories[$game_index.ryujinx]}"
        paste_folder="${switch_save_directories[$game_index.yuzu]}"
    elif [ "$transfer_from" -eq 2 ]; then
        copy_folder="${switch_save_directories[$game_index.yuzu]}"
        paste_folder="${switch_save_directories[$game_index.ryujinx]}"
    else
        echo "Error: Invalid transfer direction."
        return 1
    fi
    create_backup_of "$paste_folder"
    cp -r "$copy_folder"/* "$paste_folder"
    echo "Transfer complete: $copy_folder -> $paste_folder"
}

# Function to transfer save files for all games
transfer_all_save_files_from() {
    local transfer_from=$1
    for ((i=2; i<=${#switch_save_directories[@]}/3; i++)); do
        if [ "$transfer_from" -eq 1 ]; then
            copy_folder="${switch_save_directories[$i.ryujinx]}"
            paste_folder="${switch_save_directories[$i.yuzu]}"
        elif [ "$transfer_from" -eq 2 ]; then
            copy_folder="${switch_save_directories[$i.yuzu]}"
            paste_folder="${switch_save_directories[$i.ryujinx]}"
        else
            echo "Error: Invalid transfer direction."
            continue
        fi
        create_backup_of "$paste_folder"
        cp -r "$copy_folder"/* "$paste_folder"
        echo "Transfer complete: $copy_folder -> $paste_folder"
    done
}

# Main script loop
while true; do
    clear
    echo "Game Save Transfer Script"
    echo "Used to transfer save files between Ryujinx and Yuzu Switch Emulators."
    echo "=============================================================="

    # Display game selection menu
    echo "Select a game to transfer save files:"
    echo "0. Transfer All Game Saves [Backup Your Save Files First]"
    for ((i=2; i<=${#switch_save_directories[@]}/3; i++)); do
        echo "$i. ${switch_save_directories[$i.title]}"
    done
    echo "=============================================================="

    read -p "--> Enter the number of the game: " game
    echo

    if [ "$game" -eq 0 ]; then
        echo "You chose to transfer [All] save game files."
        read -p "--> Have you backed up all your game saves and ready to proceed? [y/n]: " confirm
    else
        echo "You chose to transfer \"${switch_save_directories[$game.title]}\" save game files."
        read -p "--> Is this correct? [y/n]: " confirm
    fi

    case $confirm in
        [Yy])
            if [ "$game" -eq 0 ]; then
                read -p "--> From which emulator do you want to transfer to? [1. Ryujinx to Yuzu, 2. Yuzu to Ryujinx]: " emu
                transfer_all_save_files_from "$emu"
            else
                read -p "--> From which emulator do you want to transfer to? [1. Ryujinx to Yuzu, 2. Yuzu to Ryujinx]: " emu
                transfer_save_files_from "$game" "$emu"
            fi
            ;;
        [Nn])
            echo "Operation canceled."
            ;;
        *)
            echo "Invalid input."
            ;;
    esac

    read -p "Press [Enter] to continue or [Q] to quit: " loop
    if [ "$loop" = "q" ] || [ "$loop" = "Q" ]; then
        echo "Closing..."
        break
    fi
done
