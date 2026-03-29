#!/bin/busybox sh
#echo $0 $*    # for debugging

# Requires ShellectApp=/usr/bin/shellect
if ! command -v shellect > /dev/null; then
	echo "ERROR: Missing dependence! Please install \"shellect\" script in your PATH from https://github.com/huijunchen9260/shellect !"
	sleep 2
	exit
fi

# external (imported) variables:
DEBUG=${DEBUG:="no"}
BOXART_DIR=${BOXART_DIR:=".images"}
HOME=${HOME:="/mnt"}
ROMS=${ROMS:="/roms"}

# internal (exported) variables
export ScraperConfigDirPath=${ScraperConfigDirPath:="${HOME}/.scraper"}
export ScraperConfigFile=${ScraperConfigFile:="scraper.cfg"}
export ScraperApp=${ScraperApp:="$(dirname "$(realpath "$0")")"/scraper_libretro.sh}
export DEBUG

# global functions
## POSIX doesn't allow exporting func. !!
wait_msg() {
	## read is different in POSIX shell (should work on BusyBox)
	read -n 1 -s -r -p "Press START to continue"
	echo
}

echo_psx() {
	#echo within BUSYBOX needs to use `-e` opt for escape operands like \n
	echo -e "$1"
}

if [ -z "$1" ]; then
	echo_psx "\nusage : scraper_menu.sh [ROM_PATH]\nexample : scraper_menu.sh /roms/NES/Battletoads\ \(USA\).nes\n"
	exit
fi

# internal variables
romname=$(basename "$1")
#CurrentSystem=$(echo "$(realpath $1)" | grep -o "/$(basename ${ROMS})/[^/]*" | cut -d'/' -f3)
CurrentSystem=$(basename "$(dirname "$(realpath "$1")")")
romNameNoExtension=${romname%.*}
romimage="${ROMS}/$CurrentSystem/${BOXART_DIR}/$romNameNoExtension.png"

# Check if the configuration file exists
if [ ! -f "${ScraperConfigDirPath}/$ScraperConfigFile" ]; then
	echo "Warning: configuration file not found, creating default in ${ScraperConfigDirPath}/${ScraperConfigFile}"
	! test -d "${ScraperConfigDirPath}" && mkdir -p "${ScraperConfigDirPath}"
	wait_msg
	echo "LibretroMedia_type = \"Named_Boxarts\"" > "${ScraperConfigDirPath}/${ScraperConfigFile}"
fi

if test x"${DEBUG}" = xyes; then
	echo -en "running $0 in debug mode \n"
	echo "ScraperApp : $ScraperApp"
	echo
	echo "CurrentSystem : $CurrentSystem"
	echo "romname : $romname"
	echo "romimage : $romimage"
	echo "romNameNoExtension : $romNameNoExtension"
	wait_msg
fi

##########################################################################################

Menu_Config() {
	Option1="Media preferences"
	Option2="Back to Main Menu"

	top_msg="      --== CONFIGURATION MENU ==--"
	bottom_msg="Press Start/Y/Right to select."

	Mychoice=$( echo_psx "$Option1\n$Option2" | shellect -t "$top_msg" -b "$bottom_msg")

	[ "$Mychoice" = "$Option1" ] && Menu_Config_MediaType
	[ "$Mychoice" = "$Option2" ] && Menu_Main
}

Menu_Config_MediaType() {
	clear
	# retrieve current media settings
	LibretroMediaType="$(sed -n 's:^LibretroMedia_type = ::p' "${ScraperConfigFile}" | tr -d '"')"

	# thumbnails.libretro.com
	Option01="Box Art                    (LR)"
	Option02="Screenshot - Title Screen  (LR)"
	Option03="Screenshot - In Game       (LR)"
	Option04="Back to Configuration Menu"

	top_msg="Current media type : $LibretroMediaType"
	bottom_msg="Press Start/Y/Right to select."

	Mychoice=$( echo_psx "$Option01\n$Option02\n$Option03\n$Option04\n"\
				 | shellect -t\ "$top_msg" -b "$bottom_msg")

	[ "$Mychoice" = "$Option01" ]  && LRmediaType="Named_Boxarts"
	[ "$Mychoice" = "$Option02" ]  && LRmediaType="Named_Titles"
	[ "$Mychoice" = "$Option03" ]  && LRmediaType="Named_Snaps"
	[ "$Mychoice" = "$Option04" ]  && Menu_Config && return

	clear

	sed -i "s:^LibretroMedia_type.*:LibretroMedia_type = \"${LRmediaType}\":g" "${ScraperConfigFile}"
	sync
	Menu_Config
}

##########################################################################################

Launch_Scraping() {
	if [ "$(ip r)" = "" ]; then
		echo "You must have a Network connection to use Scraper"
		wait_msg
		exit
	fi
	if [ "$onerom" = "1" ]; then
		onerom="$romname"
		echo "Launching Scraper for a single ${romname}"
	else
		onerom=""
		echo "Launching Scraper for whole ${CurrentSystem}"
	fi
	wait_msg

	# run the Libretro Scraper script
	${ScraperApp} "$CurrentSystem" "$onerom"

	if [ -f "$romimage" ] && ! [ "$onerom" = "" ] ; then
		echo "exiting $romimage"
		sleep 4
		exit
	fi  # exit if only one rom must be scraped and is already found

	exit
}

Delete_Rom_Cover() {
	clear
	rm "${romimage}"
	echo_psx "$romNameNoExtension.png\nRemoved\n"
	wait_msg
	clear
	Menu_Main
}

##########################################################################################

Menu_Main() {
	clear
	Option1="Scrape all $(basename "$CurrentSystem") roms"
	[ -f "$romimage" ] && Option2="" || Option2="Scrape current rom: $romname"
	[ -f "$romimage" ] && Option3="Delete cover: $romNameNoExtension.png" || Option3=""
	Option4="Configuration"
	Option5="Exit"

	clear

	top_msg="           --== MAIN MENU ==--"
	bottom_msg="   Select(hold): Exit        Start/Y/Right: Choose.  "

	Mychoice=$( echo_psx "$Option1\n$Option2\n$Option3\n$Option4\n$Option5"\
				 | shellect -t "$top_msg" -b "$bottom_msg")
	case "$Mychoice" in
		"$Option1")
			onerom=0
			Launch_Scraping
			;;
		"$Option2")
			test -z "$Option2" && exit # sanity check for Escape press
			onerom=1
			Launch_Scraping
			;;
		"$Option3")
			test -z "$Option3" && exit # sanity check for Escape press
			Delete_Rom_Cover;;
		"$Option4")
			Menu_Config;;
		*) exit;;
	esac
}

Menu_Main
