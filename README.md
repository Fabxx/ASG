# Key Features

- Multiple extension parse

- Auto sort roms into folders (Linux only for now)

- Automatic prefix creation and setup (Linux Only, for wine users)

- Automatic application of arguments, overrides and such.

- Can generate XBMC 9.11 compatible runners, made for `XBMC360` in my repo.

# Contributing

- If a game setup is missing in the `game setups.txt`, please create an issue with the appropriate labels.
  I will add the wine configuration and if available, the necessary DLL overrides in the script for the missing game.
  
- If emulator arguments are missing, please report them with a github issue, or contribute by adding them.


# Currently Supported extension detection:

note: emulator names are only for console references, if you have these file extensions it will be supported anyways.

```
PC (.EXE)

PCSX2 (.iso | .chd)

mGBA (.gbc | .gba | .gb)

Xemu (.iso)

Xenia (.xex | .iso | .zar)

Cxbx-Reloaded (.xbe)

MelonDS (.nds | .dsi | .ids | .app)

Citra (.cia | .3ds)

PPSSPP (.iso)

Duckstation (.cue | .iso | .img | .ecm | .chd)  

Yuzu/Ryujinx (.xci | .nsp)

Cemu (.wum | .wux)

Mupen64 (.z64 | .v64 | .n64)

Snes9x (.smc | .sfc)

Dolphin (.wbfs | .wad | .iso | .gcz | .rvz | .dol | .elf)

Rpcs3 (EBOOT.BIN)
```
# Depencies (Linux)

- For PC Parser:        `winetricks` | `wine` 

- Main Depency:         `Zenity` for UI.

  Debian/Ubuntu:        `sudo apt install zenity wine winetricks`

  Arch Linux: 	   	    `sudo pacman -S zenity wine winetricks`

  OpenSUSE Tumbleweed:   should work out of the box

# Initial Setup

- [`PC games - Linux`) setup your games by following the `Game Setups.txt` document.

- the script looks for `.EXE`, rename the extension of your main exe tu run in uppercase. 

- [Linux] If you need to auto sort, put all files and covers in the same folder. The files must have the same names. 

# How to use (shell file)

- Give execution permission: `chmod +x generator.sh`

- Run the script: `./generator.sh >/dev/null 2>&1` (if you want terminal logging, remove the `>/dev/null 2>&1`)

- Choose the parser you need and setup the paths when asked to do so

- The program can sort the rom files and cover images into folders for you if you haven't. More info in the option 5 of the Menu.

# How to use (Powershell file)

open powershell as administrator and type: `Set-ExecutionPolicy Unrestricted` and approve the changes.

then close and open again powershell as normal user 

execute  `.\generator.ps1`, a CLI interface has been provided to select the parsers.

NOTE 1: do NOT write paths with double/single quotes in them.

NOTE 2 (for XBMC users): on windows some applications can restart and change the PID name, and the ps1 script will fail to detect the pid of the launcher app
and will open XBMC again. I can't do much about it. This is not the case for emulators

# [Extra] Integrating with steam rom manager

parser setup:

```
Parser type: glob

Parser title: put name here

Steam directory: usually /home/user/.steam/root or ${steamdirglobal} if on windows

User Accounts: select account from the new interface

ROMs directory: /path/to/your/games

Steam collections: collection name

Executable: /usr/bin/bash if on linux, none if on windows

command line arguments: "${filePath}" if on linux (write this as it is!)

search glob [Linux users]: ${title}/start.sh (write this as it is!)

search glob [Windows users]: ${title}/*@(.lnk)

For portaits it is recommended to use a 500x700 image with an extension you want, each cover must be put in the main game folder
not in subfolders.

Local portraits image: /path/to/games/${title}/*@(.jpg)
```

Detects all `start.sh/.lnk` files, along with jpg covers (change the extension if you use another format)

You can duplicate this parser and change the category, title name and ROM's path since now everything uses a `sh` file as a base to run the games, emulators ecc,

You won't have to make specific configurations for each executable, the arguments are also included in the generated sh files.


# Special Thanks

SSUPII - Bug Fixes, testing and suggestions. https://github.com/SSUPII
