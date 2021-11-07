# Rockchip rk3288
BOARD_NAME="RK3288"
BOARDFAMILY="rk3288"
BOOTCONFIG="miqi-rk3288_defconfig"
#BOOTCONFIG="firefly-rk3288_defconfig"
KERNEL_TARGET="legacy,current,edge"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rk3288-firefly-reload.dtb"
SRC_EXTLINUX="yes"
SRC_CMDLINE="console=ttyS2,115200n8 console=tty0"
OFFSET=16
