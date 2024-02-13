#!/bin/bash
# JustaCasualCoder 2024
# Thanks so much to Frederic for making the PoC
# https://github.com/frederic/SVE-2016-7930
# Define variables to not break program
TWRP=0
BOOT=0
LINEAGE=0
FLASHZIP=0
FLASHIMAGE=0
PARTITION=0
HEIMDALL_PATH="$(pwd)/heimdall"
FILE=""
REQFILE=("boot_sdcard.img" "boot_usb.img" "heimdall" "KLTE_USA_ATT.pit" "twrp.img")
for file in "${REQFILE[@]}"; do
    if [[ ! -f "$file" ]]; then
        if [ "$file" == "boot_usb.img" ]; then
        	echo "Extracting USB boot file..."
        	gunzip boot_usb.img.gz
        else
        	echo "Failed to find needed file: $file"
        	exit 1
        fi
    fi
done
usage() {
cat <<EOF 
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-z ROM.zip] [-i boot.img]

Bash script to boot AOSP ROM/TWRP on G900A

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-t, --twrp   		Flash/Boot TWRP
-b, --boot      Do normal boot to LineageOS
-z, --zip       Boot into TWRP and flash zip/boot image
-i, --image     Flash custom boot image
-p, --partition Partition uSD card. Run this once to set up your uSD card

Example Usage:
$(basename "${BASH_SOURCE[0]}") -z lineage-21.0-20240202-UNOFFICIAL-klte.zip
$(basename "${BASH_SOURCE[0]}") -i magisk_patched_boot.img
EOF
  exit
}
while :; do
  case "${1-}" in
  -h | --help) usage ;;
  -v | --verbose) set -x ;;
  -t | --twrp) TWRP=1 ;;
  -b | --boot) BOOT=1 ;;
	-p | --partition) PARTITION=1 ;;
  -l | --lineage) LINEAGE=1 ;; 
	-i | --image) FLASHIMAGE=1 
	IMG_FILE=${2}
	;;
  -z | --zip) FLASHZIP=1 
	FILE=${2}
	;;
  -?*) echo "Unknown option: $1" ;;
  *) break ;;
  esac
  shift
done
heimdall() {
	"$HEIMDALL_PATH" ${@#}
}
echo "Using $HEIMDALL_PATH"
echo "Thanks so much to Frederic for making the PoC"
echo "https://github.com/frederic/SVE-2016-7930"
echo -e "\033[31mThis will wipe ALL DATA off your uSD card!\033[0m"
echo -e "\033[31mPress enter to continue...\033[0m"
read
echo "Checking for files..."
download_mode() {
echo "Reboot to Download mode"
echo "- Poweroff"
echo "- Press and hold volume down, home, and power"
echo "- Press volume up to accept"
echo "Waiting for device..."
heimdall detect &> /dev/null
while [ $? -ne 0 ]; do
	sleep 0.5
	heimdall detect &> /dev/null
done
echo "Device detected"
}
TWRP_FLASH() {
	download_mode
	echo "Press and hold volume down and home"
	echo "Press enter when ready"
	read
	heimdall flash --tflash --RECOVERY twrp.img --BOOT boot_sdcard.img
	echo "Waiting for device to reboot to Download mode..."
	sleep 2
	heimdall detect &> /dev/null
	while [ $? -ne 0 ]; do
		sleep 0.5
		heimdall detect &> /dev/null
	done
	echo "Device detected"
	echo "Triggering Exploit..."
	heimdall flash --tflash --no-reboot --BOOT boot_usb.img
	echo "Device should now boot to TWRP"
	echo "Done"
}
if [ ${PARTITION} = 1 ]; then
	download_mode
	heimdall flash --tflash --repartition --pit KLTE_USA_ATT.pit --BOOT boot_sdcard.img
fi
if [ ${TWRP} = 1 ]; then
	TWRP_FLASH
fi
if [ ${BOOT} = 1 ]; then
	download_mode
	echo "Device detected"
	echo "Triggering Exploit..."
	heimdall flash --tflash  --no-reboot --BOOT boot_usb.img
	echo "Booting"
	echo "Done"
fi
if [ ${FLASHZIP} = 1 ]; then
	unzip -d /tmp/ ${FILE} boot.img 
	TWRP_FLASH
	echo "Waiting for TWRP..."
	sleep 20 # TODO: Use adb wait-for-device
	echo "Turning on ADB sideload"
	adb shell twrp sideload
	sleep 5 # It take a while to go from shell to sideload
	echo "Sideloading ROM"
	adb sideload ${FILE}
	sleep 5 # It take a while to go from sideload to shell
 	adb shell twrp reboot download
	echo "Waiting for device..."
	heimdall detect &> /dev/null
	while [ $? -ne 0 ]; do
		sleep 0.5
		heimdall detect &> /dev/null
	done
	echo "Device detected"
	echo "Press and hold volume down and home"
	echo "Press enter when ready"
	read
	heimdall flash --tflash  --RECOVERY /tmp/boot.img --BOOT boot_sdcard.img
 	sleep 2
	echo "Waiting for device to reboot to Download mode..."
	heimdall detect &> /dev/null
	while [ $? -ne 0 ]; do
		sleep 0.5
		heimdall detect &> /dev/null
	done
	echo "Device detected"
	echo "Triggering Exploit..."
	heimdall flash --tflash  --no-reboot --BOOT boot_usb.img
	echo "Booting ROM"
	echo "Device should now boot to ROM"
	echo "Done"
fi
if [ ${FLASHIMAGE} = 1 ]; then
	download_mode
	echo "Device detected"
	echo "Press and hold volume down and home"
	echo "Press enter when ready"
	read
	heimdall flash --tflash  --RECOVERY ${IMG_FILE} --BOOT boot_sdcard.img
	echo "Waiting for device to reboot to Download mode..."
	sleep 2
	heimdall detect &> /dev/null
	while [ $? -ne 0 ]; do
		sleep 0.5
		heimdall detect &> /dev/null
	done
	echo "Device detected"
	echo "Triggering Exploit..."
	heimdall flash --tflash  --no-reboot --BOOT boot_usb.img
	echo "Booting ROM"
	echo "Done"
fi
