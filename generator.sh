#!/bin/bash

# Copyright Fabxx 2023 - Software Distributed under the General Public License V3 WITHOUT ANY GUARANTEE OR WARRANTY.

# Info message for auto sort option

msg="moves roms into folders to generate start.sh per game. 2MB of free space is required.\n
If a game requires multiple files with different extensions (like duckstation with .bin and .cue), 
just rename the files with the same name and keep the extension as is.\n
These emulators don't need sorting and function can be skipped:\n
-Rpcs3 JB folder\n
-Xenia extracted files with default.xex\n
-Cxbx-r extracted files with default.xbe\n "

# Emulator Arguments

xemu_args="-full-screen -dvd_path"
xenia_args="--gpu vulkan"
pcsx2_args="-fullscreen"
mgba_args="-f"
dolphin_args="--config=Dolphin.Display.Fullscreen=True"
mupen_args="--fullscreen"
cemu_args="-f -g"
rpcs3_args="--no-gui"

# Wine DLL Overrides for PC games

# Current games that use the overrides: 

# need for speed most wanted
# need for speed carbon
# splinter cell
# splinter cell Pandora tomorrow
# splinter cell Chaos Theory
# Dirt
# Dirt 2
# Dirt 3
# Dirt Showdown

# Disable Vulkan for these two games to fix crash
NFSC_MW_OVERRIDE="*d3d9,*d3d10,*d3d10_1,*d3d10core,*d3d11,*dxgi=b"

# Extra overrides are for Xbox controller support mod from nexus mods.
SC_OVERRIDE="*xinput1_3, *msacm32, *msvfw32=n,b"

SCPT_OVERRIDE="*msacm32, *msvfw32=n,b"

# dinput8 is for Xbox trigger fix 
SCCT_OVERRIDE="*dinput8, *d3d9, *msacm32, *msvfw32=n,b"

# Fusion Fix for splinter cell conviction
SCC_OVERRIDE="*version=n,b"


# PC Games arguments 

# Colin McRae Rally 2005 

# Kingdom Come Deliverance

# Splinter Cell Chaos Theory

CMR2005_ARGS="FORCEHT WIDESCREENDISPLAY NOVIDEO"

KINGDOMDEV="-devmode"

SCCT_ARGS="-nointro"

isXbmcScript=2

# Rom sorter.

SortRoms()
{
	zenity --question --text="sort roms into folders? If you don't know how it works please check AutoSort info in the main menu."
	
	if [[ $? == 1 ]]; then Parser
	fi

	# Check disk space, remove the final char "M" from the space number.
	minDiskSpace=2
	freeDiskSpaceRaw=$(df --output=avail -BM "$path_games" | tail -n 1)
	freeDiskSpace=${freeDiskSpaceRaw::-1}

	if [[ $freeDiskSpace -lt $minDiskSpace ]]; then 
	zenity --error --text="Not enough space on disk to create folders! The Parser cannot sort the files"
	ZenityUI
	fi

	# Find all files that can match the extension in the folder. Create folders with those strings and move the files into the matching folder name
	cd "$path_games"
	
	files=()
       
	readarray -t files < <(ls *.3ds *.app *.bin *.cia *.cue *.chd *.dsi *.dol *.ecm *.elf *.gb *.gba \
		       *.gbc *.gcz *.ids *.img *.iso *.jpeg *.jpg *.n64 *.nds *.nsp *.png \
		       *.rvz *.sav *.sbi *.sfc *.smc *.v64 *.wad *.wbfs *.wud *.wux *.xci *.z64 *.zar \
			)

	for i in "${files[@]%.*}"; do mkdir "$i"; done

	subdirs=(*/)

	# Move those files that have the same name as the created folder. If the matches are done for that folder, go to the next folder.
	# Example: CTR is the folder, then CTR.bin CTR.cue CTR.jpg are the files.
	# remove the extension one by one and if it matches CTR, move the file into the folder.
	# After the last file, go to the next folder and find the matching names.

	indexdirs=0 indexfiles=0

	while [[ $indexfiles -lt ${#files[@]} ]]

		do
			if [[ "${files[$indexfiles]%.*}" == "${subdirs[$indexdirs]%/*}" ]]; then
				mv "${files[$indexfiles]}" "${subdirs[$indexdirs]}";
				((indexfiles++))
				indexdirs=0
			else
				((indexdirs++))
			fi	
	done
}

# Parser

Parser()
{
	# If the user is generating runners to launch through XBMC Python scripts, the start.sh must kill
	# XBMC to avoid input priority over the UI. then if the PID of the exe doesn't exist anymore
	# the sh file re-runs XBMC executable again. Extra echos are at the end before the cd ..
	
	if [[ $isXbmcScript -ne 0 && $isXbmcScript -ne 1 ]]; then
	zenity --question --text="Will you use these scripts with XBMC? Will ask only once."

	if [[ $? == 1 ]]; then
		isXbmcScript=0
	else
		isXbmcScript=1
		zenity --info --text="Select XBMC.exe file"
		xmbcExecutable=$(zenity --title="select XBMC executable" --file-selection)
	fi
	fi

	for folder in "$path_games"/*; do cd "$folder";

	echo -e "#!/bin/bash" "\n" > start.sh

	echo -e "cd \"$(pwd)\"\n" >> start.sh

	case $parserList in

	1) 
		case $parser_ID in

		1) #duckstation
		echo -e \""$path_executable"\" "" \""$(ls *.cue *.iso *.img *.ecm *.chd)"\" "\n" >> start.sh
		;;
		
		2) #pcsx2
		echo -e \""$path_executable"\" "" \""$(ls *.iso *.chd)"\" "" "$pcsx2_args" "\n" >> start.sh
		;;
		
		3) #ppsspp
		echo -e \""$path_executable"\" "" \""$(ls *.iso)"\" "\n" >> start.sh
		;;

		4) #rpcs3 JB format
		echo -e \""$path_executable"\" "" "$rpcs3_args" \""$(find ~+ -name 'EBOOT.BIN')"\" "\n" >> start.sh
		;;

		esac
		;;

	
	2)
		case $parser_ID in
	
		1) #citra
		echo -e \""$path_executable"\" "" \""$(ls *.3ds *.cia)"\" "\n" >> start.sh
		;;
		
		2) #melonDS
		echo -e \""$path_executable"\" "" \""$(ls *.nds *.dsi *.ids *.app)"\" "\n" >> start.sh
		;;
		
		3) #Yuzu/Ryujinx
		echo -e \""$path_executable"\" "" \""$(ls *.nsp *.xci)"\" "\n" >> start.sh
		;;
		
		4) #mGBA
		echo -e \""$path_executable"\" "" "$mgba_args" "" \""$(ls *.gba *.gbc *.gb)"\" "\n" >> start.sh
		;;

		5) #mupen64
		echo -e \""$path_executable"\" "" \""$(ls *.z64 *.v64 *.n64)"\" "$mupen_args" "\n" >> start.sh
		;;
		
		6) #snes9x
		echo -e \""$path_executable"\" "" \""$(ls *.smc *.sfc)"\" "\n" >> start.sh
		;;

		7) #Cemu
		echo -e \""$path_executable"\" "" "$cemu_args" \""$(ls *.wud *.wux)"\" "\n" >> start.sh
		;;

		8) #Dolphin
		echo -e \""$path_executable"\" "" --exec=\""$(ls *.wbfs *.wad *.iso *.gcz *.rvz *.dol *.elf)"\" "$dolphin_args" "\n" >> start.sh
		;;

		esac
		;;
		
	3)
		case $parser_ID in

	
		1) #Xemu
		echo -e \""$path_executable"\" "" "$xemu_args" "" \""$(ls *.iso)"\" "\n" >> start.sh
		;;
		
		2) #Xenia
	    echo -e wine \""$path_executable"\" "" \""$(ls *.xex *.iso *.zar)"\" "\n" >> start.sh
		;;

		3) #cxbx-r
		echo -e wine \""$path_executable"\" "" \""$(ls *.xbe)"\" "\n" >> start.sh
		;;

		esac
		;;

	
	4)
		case $parser_ID in

		1) #Wine games that use the DLLOVERRIDES in the script or dedicated prefixes with specific packages

		#Get executable name with extension, excluding the absolute path

		exeFile="$(find ~+ -name '*.EXE')"

		if [ "$(basename "$exeFile")" == "SplinterCell.EXE" ]; then

			echo -n WINEDLLOVERRIDES=\""$SC_OVERRIDE"\" wine \""$exeFile"\" >> start.sh 

		elif [ "$(basename "$exeFile")" == "SplinterCell2.EXE" ]; then 

			echo -n WINEDLLOVERRIDES=\""$SCPT_OVERRIDE"\" wine \""$exeFile"\" >> start.sh

		elif [ "$(basename "$exeFile")" == "NFSC.EXE" ]; then 
		
			echo -n WINEDLLOVERRIDES=\""$NFSC_MW_OVERRIDE"\" wine \""$exeFile"\" >> start.sh

		elif [ "$(basename "$exeFile")" == "speed.EXE" ]; then 
		
			echo -n WINEDLLOVERRIDES=\""$NFSC_MW_OVERRIDE"\" wine \""$exeFile"\" >> start.sh 
		
		elif [ "$(basename "$exeFile")" == "gta3.EXE" ]; then 
		
			echo -n WINEDLLOVERRIDES=\""$GTA3_OVERRIDE"\" wine \""$exeFile"\" >> start.sh 
		
		elif [ "$(basename "$exeFile")" == "CMR5.EXE" ]; then 
		
			echo -n wine \""$exeFile"\" \""$CMR2005_ARGS"\" >> start.sh 
	
	    elif [ "$(basename "$exeFile")" == "Conviction_game.EXE" ]; then 
		
			echo -n WINEDLLOVERRIDES=\""$SCC_OVERRIDE"\" wine \""$exeFile"\" >> start.sh 

		elif [ "$(basename "$exeFile")" == "splintercell3.EXE" ]; then
			scctPrefix="/home/$(whoami)/scctpfx"
			WINEPREFIX="$scctPrefix" wineboot
			WINEPREFIX="$scctPrefix" winetricks -q dxvk1103
			echo -n WINEDLLOVERRIDES=\""$SCCT_OVERRIDE"\" WINEPREFIX=\""$scctPrefix"\" wine \""$exeFile"\" \""$SCCT_ARGS"\" >> start.sh


		elif [ "$(basename "$exeFile")" == "Blur.EXE" ]; then

			blurPrefix="/home/$(whoami)/blurpfx"
			WINEPREFIX="$blurPrefix" wineboot
			WINEPREFIX="$blurPrefix" winetricks -q vcrun2019 dxvk1030
			echo -n WINEPREFIX=\""$blurPrefix"\" wine \""$exeFile"\" >> start.sh
		
		elif [ "$(basename "$exeFile")" == "SR2_pc.EXE" ]; then
			
			sr2Prefix="/home/$(whoami)/sr2pfx"
			WINEPREFIX="$sr2Prefix" wineboot
			WINEPREFIX="$sr2Prefix" winetricks -q vcrun2019 dxvk xact
			echo -n WINEPREFIX=\""$sr2Prefix"\" wine \""$exeFile"\" >> start.sh
		
		elif [ "$(basename "$exeFile")" == "REDRIVER2_dev.EXE" ]; then
		
			drv2Prefix="/home/$(whoami)/d2pfx"

			WINEPREFIX="$drv2Prefix" WINEARCH=win32 wineboot
			
			echo -n WINEPREFIX=\""$drv2Prefix"\" WINEARCH=win32 wine \""$exeFile"\" >> start.sh
		
		# NOTE: For Test Drive Unlimited 2 you need the Offline Launcher.

		elif [ "$(basename "$exeFile")" == "Launcher.EXE" ]; then
			
			tdu2Prefix="/home/$(whoami)/tdu2pfx"
			WINEPREFIX="$tdu2Prefix" WINEARCH=win32 wineboot
			WINEPREFIX="$tdu2Prefix" WINEARCH=win32 winetricks ie7 dotnet40 dxvk1103 dinput8 directplay
			echo -n WINEPREFIX=\""$tdu2Prefix"\" WINEARCH=win32 wine \""$exeFile"\" >> start.sh
		
		elif [ "$(basename "$exeFile")" == "acc.EXE" ]; then
			
			accPrefix="/home/$(whoami)/accpfx"
			WINEPREFIX="$accPrefix" wineboot
			WINEPREFIX="$accPrefix" winetricks -q vcrun2019 dxvk
			echo -n WINEPREFIX=\""$accPrefix"\" wine \""$exeFile"\" >> start.sh

		else echo wine \""$exeFile"\" >> start.sh

		fi
		;;

		esac
		;;
	
	*)

   esac

	# Write the script that runs XBMC once executable or emulator is closed
   if [[ $isXbmcScript -eq 1 ]]; then
	echo -e "while true ; do\n" >> start.sh
	
	if [[ $parserList -eq 4 ]]; then
		echo -e "if [[ \"\$(pidof "$exeFile")\" == \"""\" ]]; then\n" >> start.sh
	else 
		emulatorExecutable=$(basename -z "$path_executable")
		echo -e "if [[ \"\$(pidof "$emulatorExecutable")\" == \"""\" ]]; then\n" >> start.sh 
	fi
	
	echo -e "wine \""$xmbcExecutable"\"" "\n" >> start.sh
	echo -e "break\n" >> start.sh
	echo -e "fi\n" >> start.sh
	echo -e "sleep 3\n" >> start.sh
	echo -e "done" >> start.sh

   fi
	
   cd ..;
   done
   zenity --info --text="Script generation complete"
   ZenityUI
}

ZenityUI()
{
	# Categories

	parserList=$(zenity --list --text="Select a category" --column="ID" --column="Name" --column="Description" --width=800 --height=600 \
	1 "Sony"   	        "Emulators" \
	2 "Nintendo" 	    "Emulators" \
	3 "Microsoft"       "Emulators" \
	4 "PC Games"   		"Wine" \
	5 "Information"      "Show autoSort info")

	if [ $? == 1 ]; then exit;
	fi

	case $parserList in

		1)
			parser_ID=$(zenity --list --text="Select a Parser" --column="ID" --column="Name" --column="Description" --width=800 --height=600 \
			1 Duckstation  "PS1 Emulator" \
			2 Pcsx2   	   "PS2 Emulator" \
			3 Ppsspp  	   "PSP Emulator" \
			4 Rpcs3		   "PS3 Emulator" )

			if [ $? == 1 ]; then ZenityUI;
			fi
			;;

		2)
			parser_ID=$(zenity --list --text="Select a Parser" --column="ID" --column="Name" --column="Description" --width=800 --height=600 \
			1 Citra   	   "Nintendo 3DS Emulator" \
			2 melonDS 	   "Nintendo DS Emulator" \
			3 Yuzu/Ryujinx "Nintendo Switch Emulator" \
			4 mGBA    	   "Gameboy Advance Emulator" \
			5 mupen64	   "Nintendo 64 Emulator" \
			6 snes9x	   "Super nintendo emulator" \
			7 Cemu		   "Nintendo Wii U emulator" \
			8 dolphin      "Nintendo Wii/Gamecube emulator" )

			if [ $? == 1 ]; then ZenityUI;
			fi
			;;
		
		3)
			parser_ID=$(zenity --list --text="Select a Parser" --column="ID" --column="Name" --column="Description" --width=800 --height=600 \
			1 Xemu    	   "Original Xbox Emulator" \
			2 Xenia   	   "Xbox 360 Emulator" \
			3 Cxbx-r	   "Original Xbox Emulator" )

			if [ $? == 1 ]; then ZenityUI;
			fi
			;;
	
		4)
			parser_ID=$(zenity --list --text="Select a Parser" --column="ID" --column="Name" --column="Description" --width=800 --height=600 \
			1 Wine 	   		 				"Windows .exe games (default prefix)" \ )

			if [ $? == 1 ]; then ZenityUI;
			fi
			;;
		5)
			zenity --info --ellipsize --text="$msg" --width=800 --height=600
			ZenityUI
			;;
	esac

	if [ $? == 1 ]; then ZenityUI
	fi

	# Wine uses default prefix.
	if [[ $parserList == 4 && $parser_ID == 1 ]]; then


	if [[ $winePresent != 0 || $winetricksPresent != 0 ]]; then 
	zenity --error --text="You must install wine and winetricks to run this parser!"
	ZenityUI
	
	else
	zenity --info --text="Using default prefix, executing wineboot and winetricks commands"
	wineboot
	winetricks -q dxvk vkd3d
	fi
	fi

	
	# Xenia canary requires wine. (until linux build works)

	if [[ $parserList == 3 && $parser_ID == 2 ]]; then
	
	zenity --info --text="Using default prefix, executing wineboot and winetricks commands"
	wineboot
	winetricks -q dxvk vkd3d
	
	fi

	# Always ask for emulator executable if not using wine
	if [[ $parserList != 4 ]]; then
	zenity --info --text="Select the emulator executable"
	path_executable=$(zenity --title="Select emulator executable" --file-selection)

	if [ $? == 1 ]; then ZenityUI
	fi
	fi


	#Always ask for ROM directory
	zenity --info --text="Select the ROM's directory"
	path_games=$(zenity --title="Select ROM's path" --directory --file-selection)
	if [ $? == 1 ]; then ZenityUI
	fi

	SortRoms
 	Parser
	
}

# Detect available UI selection interfaces. type returns 0 if command is available, 1 if not.

type zenity >> /dev/null
zenityPresent=$?

type winetricks >> /dev/null
winetricksPresent=$?

type wine >> /dev/null
winePresent=$?

# Check if needed components are available

if [ $zenityPresent != 0 ]; then

echo "Zenity must be installed in your system to display UI." 
exit

elif [[ $winePresent != 0 || $winetricksPresent != 0 ]]; then 

zenity --info --text="Consider installing wine and winetricks to use PC parser"

fi

ZenityUI
