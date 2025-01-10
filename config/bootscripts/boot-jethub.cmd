# DO NOT EDIT THIS FILE
#
# Please edit /boot/armbianEnv.txt to set supported parameters
#

setenv scriptaddr      "0x12000000"
setenv kernel_addr_r  "0x14000000"
setenv ramdisk_addr_r "0x1A000000"
setenv fdt_addr_r     "0x10800000"
setenv overlay_error "false"
# default values
setenv rootdev "/dev/mmcblk0p1"
setenv verbosity "1"
setenv console "serial"
setenv rootfstype "ext4"
setenv docker_optimizations "on"
setenv prefix "boot/"

# Show what uboot default fdtfile is
echo "U-boot default fdtfile: ${fdtfile}"
echo "Current variant: ${variant}"

# legacy kernel values from armbianEnv.txt
if test -e ${devtype} ${devnum} ${prefix}armbianEnv.txt; then
	load ${devtype} ${devnum} ${scriptaddr} ${prefix}armbianEnv.txt
	env import -t ${scriptaddr} ${filesize}
fi

# get PARTUUID of first partition on SD/eMMC it was loaded from
# mmc 0 is always mapped to device u-boot (2016.09+) was loaded from
if test "${devtype}" = "mmc"; then part uuid mmc ${devnum}:1 partuuid; fi

echo "Current fdtfile after armbianEnv: ${fdtfile}"

if test "${console}" = "serial"; then setenv consoleargs "console=ttyAML0,115200n8"; fi

setenv bootargs "root=${rootdev} rootwait rootflags=data=writeback rootfstype=${rootfstype} ${consoleargs} no_console_suspend consoleblank=0 coherent_pool=2M loglevel=${verbosity} fsck.fix=yes fsck.repair=yes net.ifnames=0 ${extraargs} ${extraboardargs}"

if test -n "${board_name}"; then setenv bootargs "${bootargs} board=${board}"; fi

if test -n "${ethaddr}"; then setenv bootargs "${bootargs} mac=${ethaddr}";
else if test -n "${mac}"; then setenv bootargs "${bootargs} mac=${mac}" ; fi
fi

if test -n "${serial}"; then setenv bootargs "${bootargs} serial=${serial}"; fi
if test -n "${usid}"; then setenv bootargs "${bootargs} usid=${usid}"; fi

if test "${docker_optimizations}" = "on"; then setenv bootargs "${bootargs} cgroup_enable=memory"; fi
echo "Mainline bootargs: ${bootargs}"


echo "Checking board setup"
if test "$board" = "jethub-j100"; then
    if test "$perev" = "02"; then
    # D1P + RTL8822CS
        echo "Applying DT kernel file for JetHub D1/P RTL8822CS device"
        setenv fdtfile "amlogic/meson-axg-jethome-jethub-j110-rev-2.dtb"
    fi;
    if test "$perev" = "03"; then
    # D1P + W155S1
        echo "Applying DT kernel file for JetHub D1/P W155S1 device"
        setenv fdtfile "amlogic/meson-axg-jethome-jethub-j110-rev-3.dtb"
    fi;
fi;


load ${devtype} ${devnum} ${ramdisk_addr_r} ${prefix}uInitrd
load ${devtype} ${devnum} ${kernel_addr_r} ${prefix}Image
load ${devtype} ${devnum} ${fdt_addr_r} ${prefix}dtb/${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536


for overlay_file in ${overlays}; do
	if load ${devtype} ${devnum} ${scriptaddr} ${prefix}dtb/amlogic/overlay/${overlay_prefix}-${overlay_file}.dtbo; then
		echo "Applying kernel provided DT overlay ${overlay_prefix}-${overlay_file}.dtbo"
		fdt apply ${scriptaddr} || setenv overlay_error "true"
	fi
done

for overlay_file in ${user_overlays}; do
	if load ${devtype} ${devnum} ${scriptaddr} ${prefix}overlay-user/${overlay_file}.dtbo; then
		echo "Applying user provided DT overlay ${overlay_file}.dtbo"
		fdt apply ${scriptaddr} || setenv overlay_error "true"
	fi
done

if test "${overlay_error}" = "true"; then
	echo "Error applying DT overlays, restoring original DT"
	load ${devtype} ${devnum} ${fdt_addr_r} ${prefix}dtb/${fdtfile}
else
	if load ${devtype} ${devnum} ${scriptaddr} ${prefix}dtb/amlogic/overlay/${overlay_prefix}-fixup.scr; then
		echo "Applying kernel provided DT fixup script (${overlay_prefix}-fixup.scr)"
		source ${scriptaddr}
	fi
	if test -e ${devtype} ${devnum} ${prefix}fixup.scr; then
		load ${devtype} ${devnum} ${scriptaddr} ${prefix}fixup.scr
		echo "Applying user provided fixup script (fixup.scr)"
		source ${scriptaddr}
	fi
fi

booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
