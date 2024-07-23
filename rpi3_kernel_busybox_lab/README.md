# iti RPI3 uboot lab



## Install the TFTP Server

1. **Update package lists**:

   ```bash
   sudo apt update
   ```

2. **Install the TFTP server and related packages**:

   ```bash
   sudo apt install tftpd-hpa tftp-hpa
   ```

### Step 1: Configure the TFTP Server

1. **Edit the TFTP server configuration file**:

   ```bash
   sudo nano /etc/default/tftpd-hpa
   ```

2. **Update the configuration to look like this**:

   ```bash
   # /etc/default/tftpd-hpa
   
   TFTP_USERNAME="tftp"
   TFTP_DIRECTORY="/srv/tftp"
   TFTP_ADDRESS="0.0.0.0:69"
   TFTP_OPTIONS="--secure --create"
   ```

   - `TFTP_USERNAME` specifies the username that the TFTP server runs as.
   - `TFTP_DIRECTORY` is the directory where TFTP files are stored.
   - `TFTP_ADDRESS` sets the address and port (default is 69) on which the TFTP server listens.
   - `TFTP_OPTIONS` are additional options; `--secure` confines the TFTP server to the TFTP directory.

### Step 2: Create the TFTP Directory and Set Permissions

1. **Create the TFTP directory**:

   ```bash
   sudo mkdir -p /srv/tftp
   ```

2. **Set permissions for the TFTP directory**:

   ```bash
   sudo chown -R tftp:tftp /srv/tftp
   sudo chmod -R 755 /srv/tftp
   ```

### Step 3: Restart and Enable the TFTP Service

1. **Restart the TFTP service**:

   ```bash
   sudo systemctl restart tftpd-hpa
   ```

2. **Enable the TFTP service to start on boot**:

   ```bash
   sudo systemctl enable tftpd-hpa
   ```

### Step 4: Verify the TFTP Server is Running

1. **Check the status of the TFTP service**:

   ```bash
   sudo systemctl status tftpd-hpa
   ```

   You should see output indicating that the TFTP server is active and running.
   
   

---



## Kernel

```
git clone --depth=1 https://github.com/raspberrypi/linux
cd linux
```

Apply default config for RPi3:

```bash
make bcm2835_defconfig ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-  
```

Set maximum open file descriptors:

```bash
ulimit -n 8192
```

Change configurations:

```bash
make menuconfig ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
# Enable devtmpfs
# CONFIG_BLK_DEV_INITRD to support initramfs
```

Compile kernel, modules and DTBs :

```bash
make -j$(nproc) zImage modules dtbs ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

Install modules:

```bash
export INSTALL_MOD_PATH=/home/eng-tera/linux/
make modules_install ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

Copy to sdcard

```bash
cp arch/arm/boot/zImage /media/boot
cp arch/arm/boot/dts/bcm2710-rpi-3-b.dtb /media/boot
cp arch/arm/boot/dts/overlays/disable-bt.dtbo /media/boot/overlays
```

Or Boot from TFTP Server

Copy zImage and device tree binary to the TFTP server:

```bash
cp linux/arch/arm/boot/zImage /srv/tftp/
```



---



## Downloading BusyBox



Clone the BusyBox repository from the official source:

```bash
git clone git://busybox.net/busybox.git --branch=1_33_0 --depth=1
cd busyBox
```



------

## Configuring BusyBox



Use menuconfig to configure BusyBox according to your requirements:

```bash
export ARCH=arm
make menuconfig
```

- Enable build static binary

- Configure ``` arm-Linux-gnueabihf- ```  as cross compiler prefix

  

Build BusyBox:

```bash
make
```

Generate the rootfs

```bash
make install
```

This will create folder named _install which has all binaries



------

## Creating the Root File System



Set up the root filesystem by copying BusyBox binaries:

```bash
# to go out from busybox directory
cd ..

# create directory rootfs
mkdir rootfs

# copy the content inside the _install into rootfs
cp -rp ./busybox/_install/ ./rootfs

# change directory to rootfs
cd rootfs

mkdir proc
mkdir sys
mkdir dev
mkdir etc

# change rootfs owner to be root
sudo chown -R root:root *

# Create config directory:
mkdir etc/init.d
touch etc/init.d/rcS
chmod +x etc/init.d/rcS

```



## Create `/etc/init.d/rcS` startup script

```bash
#!/bin/sh

# mount a filesystem of type `proc` to /proc
mount -t proc nodev /proc

# mount a filesystem of type `sysfs` to /sys
mount -t sysfs nodev /sys

# mount -t devtmpfs none /dev
exec /bin/sh
```



# Creating initramfs

```bash
# Make sure do not includes kernel modules in the initramfs as it will take much space.
cd ~/rootfs
find . | cpio -H newc -ov --owner root:root > ../initramfs.cpio
cd ..
gzip initramfs.cpio
mkimage -A arm -O linux -T ramdisk -d initramfs.cpio.gz uRamdisk

cp -r /home/eng-tera/linux/lib/ /home/eng-tera/rootfs/
```



## Booting with initramfs

Copy uRamdisk you created earlier in this section to the boot partition on the microSD card, and then use it to boot to point that you get a U-Boot prompt. Then enter these commands:

```bash
# make sure the variable initramfs doesn't overwrite the dtb and zimage variables
setenv initramfs [chose a value depends on bdinfo]

setenv initramfs_addr 0x30000000
setenv kernel_addr_r 0x8000
setenv fdt_addr_r 0x10000

fatload mmc 0:1 $kernel_addr_r zImage
fatload mmc 0:1 $fdt_addr_r bcm2710-rpi-3-b.dtb
fatload mmc 0:1 $initramfs uRamdisk
setenv bootargs console=ttyS0,115200 root=/dev/ram0 init=/linuxrc

bootz $kernel_addr_r $initramfs $fdt_addr
```

