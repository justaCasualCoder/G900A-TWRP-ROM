# Samsung Galaxy S5 AT&T Tethered Exploit

# What does this do?

It allows booting TWRP/AOSP ROM  by using [SVE-2016-7930](https://github.com/frederic/SVE-2016-7930) (Which uses buffer overflows) to run unsigned recovery/boot images from a uSD card. Read the [Full article](https://www.sstic.org/media/SSTIC2017/SSTIC-actes/attacking_samsung_secure_boot/SSTIC2017-Article-attacking_samsung_secure_boot-basse.pdf) for how it works in more detail.

# :warning:This will  prevent your phone from booting unless you have a computer! This is a TETHERED Exploit! :warning:

# Requirements

- AT&T S5 on firmware version G900AUCS4DQB1

- Micro SD card ( :warning: This will be erased :warning: )

- Heimdall with [This patch](https://github.com/frederic/SVE-2016-7930/blob/master/heimdall-increase_fileTransferSequenceMaxLength.patch) applied (a x64 pre-patched binary is in this repo)

- A computer running Linux

- TWRP image ([Download twrp-3.7.0_9-0-klte.img](https://dl.twrp.me/klte/twrp-3.7.0_9-0-klte.img.html)) named twrp.img in the repo dir (`wget --referer https://dl.twrp.me/klte/twrp-3.7.0_9-0-klte.img.html https://dl.twrp.me/klte/twrp-3.7.0_9-0-klte.img -O twrp.img`)

# Getting started

## Getting to the right firmware

- Download [G900AUCS4DPH4](https://androidfilehost.com/?fid=312968873555011029) and flash it in odin

- Download [PH4-QA1.zip](https://www.androidfilehost.com/?fid=745425885120714574) and [QA1-QB1.zip](https://www.androidfilehost.com/?fid=673368273298937968)

- Flash both in recovery (Use ADB sideload from a computer or flash from uSD card)

## Running it

Get a Linux system to continue (Eg. a Ubuntu Desktop Live CD)

- [Download this repo](https://github.com/justaCasualCoder/G900A-TWRP-ROM/archive/refs/heads/main.zip)

- Extract it

- Open a terminal in the folder you extracted it into

- Install ADB (`sudo apt-get install android-sdk-platform-tools` on Ubuntu)

- Put your uSD card into your phone

- Run the script (`bash main.sh -p && bash main.sh -t` and follow the instructions to partition your uSD card and boot into TWRP)

- When you poweroff the phone, boot it back into your ROM by running  `bash main.sh -b` and follow the instructions.

# Script Usage

```bash
Usage: main.sh [-h] [-v] [-z ROM.zip] [-i boot.img]

Bash script to boot AOSP ROM/TWRP on G900A

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-t, --twrp       Flash/Boot TWRP
-b, --boot      Do normal boot to LineageOS
-z, --zip       Boot into TWRP and flash zip/boot image
-i, --image     Flash custom boot image
-p, --partition Partition uSD card. Run this once to set up your uSD card

Example Usage:
main.sh -z lineage-21.0-20240202-UNOFFICIAL-klte.zip
main.sh -i boot.img
```

# Installing a ROM

- Download your ROM of choice for `klte`

- Move it into folder where you extracted the repo

- Run `bash main.sh -z YOURROM.zip`
  
  - This will reboot into TWRP, Sideload the ZIP, and then reboot to Download mode to flash the new boot image.

## Flash Magisk

- Install Magisk

- Copy the resulting `.img` to your computer (`adb pull /storage/emulated/0/Download/*.img .`)

- Flash the new image (`bash main.sh -i magisk_patched.img`)


