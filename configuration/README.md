# Netronome SmartNIC Configuration

## Index
* [Pre-requisities](https://github.com/deepakc7y/netronome-config/tree/main/configuration#pre-requisites)
  - [Host System Details](https://github.com/deepakc7y/netronome-config/tree/main/configuration#host-system-details)
  - [SmartNIC Details](https://github.com/deepakc7y/netronome-config/tree/main/configuration#smartnic-details)
  - [Enabling SRIOV Support in the Boot Menu](https://github.com/deepakc7y/netronome-config/tree/main/configuration#enabling-the-sriov-support-in-the-boot-menu)
  - [Ensure that the Netronome SmartNIC appears as one of the Ethernet Controllers](https://github.com/deepakc7y/netronome-config/tree/main/configuration#ensure-that-the-netronome-smartnic-appears-as-one-of-the-ethernet-controllers)
  - [Using the Recommended Kernel Version with Netronome](https://github.com/deepakc7y/netronome-config/tree/main/configuration#using-the-recommended-kernel-version-with-netronome)
  - [Installing the Ethernet Driver](https://github.com/deepakc7y/netronome-config/tree/main/configuration#installing-the-ethernet-driver)
* [The Guide to Configuring a Netronome SmartNIC](https://github.com/deepakc7y/netronome-config/tree/main/configuration#the-guide-to-configuring-a-netronome-smartnic)
  - [SDK Installation](https://github.com/deepakc7y/netronome-config/tree/main/configuration#sdk-installation)
  - [Installing the P4 Runtime Environment](https://github.com/deepakc7y/netronome-config/tree/main/configuration#installing-p4-runtime-environment)
  - [Installing SRIOV-supported Firmware](https://github.com/deepakc7y/netronome-config/tree/main/configuration#installing-sriov-supported-firmware)
* [Additional Optional Configurations]()
  - [Creating Virtual Functions (VFs)](https://github.com/deepakc7y/netronome-config/tree/main/configuration#creating-virtual-functions-vfs)
  - [To enable NFP ports for 1G RJ45 Connections](https://github.com/deepakc7y/netronome-config/tree/main/configuration#to-enable-nfp-ports-for-1g-rj45-connections)
  - [To see the Netronome SmartNIC Physical Interfaces](https://github.com/deepakc7y/netronome-config/tree/main/configuration#to-see-the-netronome-smartnic-physical-interfaces)
  - [Verifying the Kernel Patch for Netronome SmartNICs [Optional]](https://github.com/deepakc7y/netronome-config/tree/main/configuration#to-see-the-netronome-smartnic-physical-interfaces)
  - [Changing Netronome Port Link Speed from 10G to 1G](https://github.com/deepakc7y/netronome-config/tree/main/configuration#to-see-the-netronome-smartnic-physical-interfaces)
  - [Configuring Default number of VFs for P4/MicroC Programs](https://github.com/deepakc7y/netronome-config/tree/main/configuration#to-see-the-netronome-smartnic-physical-interfaces)

## Pre-requisites

### Host System Details
- Motherboard - Asus Prime Z690 P D4 [[Link]](https://www.asus.com/in/Motherboards-Components/Motherboards/PRIME/PRIME-Z690-P-D4/)
- Processor - 12th Gen Intel® Core™ i5-12400 × 12
- RAM - 32GB
- Operating System - Ubuntu 18.04

### SmartNIC Details
- Netronome Agilio SmartNIC CX 2x10GbE [[Link]](https://www.netronome.com/products/agilio-cx/)

### Enabling the SRIOV Support in the Boot Menu

SR-IOV is a PCI feature that allows virtual functions (VFs) to be created from a physical function (PF). The VFs thus share the resources of a PF, while VFs remain isolated from each other. The isolated VFs are typically assigned to virtual machines (VMs) on the host. In this way, the VFs allow the VMs to directly access the PCI device, thereby bypassing the host kernel. [[Source]](https://help.netronome.com/support/solutions/articles/36000049975-basic-firmware-user-guide#using-sr-iov)

By default, the SRIOV Support is disabled. To use the Virtual Functions (VFs), you have to enable the SRIOV Support. In the Asus Motherboard, the "SRIOV Support" option can be found under **PCI Subsystem Settings** and can be enabled.

<img src="https://github.com/deepakc7y/netronome-config/blob/main/images/SRIOV-BIOS-Asus.png">

[[Image Source]](https://dlcdnets.asus.com/pub/ASUS/mb/13MANUAL/PRIME_PROART_TUF_GAMING_Intel_600_Series_BIOS_EM_WEB_EN.pdf)

### Ensure that the Netronome SmartNIC appears as one of the Ethernet Controllers

It can be done using the following commands

```sudo lspci -vvv -d 19ee:``` to confirm PCIe configuration of SmartNIC(s)

```sudo dmesg | grep nfp``` to check for system-generated messages the SmartNIC.

### Using the Recommended Kernel Version with Netronome

This section details the process of configuring the Ubuntu 18.04 LTS (Bionic Beaver) system to utilize the kernel version recommended by Netronome.

Based on Netronome's support documentation ([reference](https://help.netronome.com/support/solutions/articles/36000184708-tested-linux-versions)), kernel version 4.18 is officially tested and recommended for compatibility with Netronome solutions. While you may have used a newer kernel version (e.g., 5.4) without encountering issues, adhering to the recommended version will avoid any potential problems.

To boot your OS into a different kernel version, perform the following steps:

- ```sudo apt update``` updates the packages

- Modify GRUB Configuration
  - Edit the GRUB configuration file using nano: ```sudo nano /etc/default/grub```
  - Within the file, locate and modify the following lines:
    - Change ```GRUB_TIMEOUT_STYLE=menu``` (enables a menu for selecting the kernel version)
    - Change ```GRUB_TIMEOUT=10``` (sets the menu display time to 10 seconds)
  - Save the changes and exit the editor (Ctrl+S, then Ctrl+X).
  - ```sudo update-grub``` and reboot the system

- Download Required Kernel Deb Packages: Navigate to the Ubuntu mainline kernel archive for version 4.15 ([source](https://kernel.ubuntu.com/mainline/v4.18/)) and download the following ```.deb``` packages under the ```amd64``` architecture:
  - linux-headers-4.18.0-041800_4.18.0-041800.201808122131_all.deb
  - linux-headers-4.18.0-041800-generic_4.18.0-041800.201808122131_amd64.deb
  - linux-image-unsigned-4.18.0-041800-generic_4.18.0-041800.201808122131_amd64.deb
  - linux-modules-4.18.0-041800-generic_4.18.0-041800.201808122131_amd64.deb
  
- Install Downloaded Packages:
  - Create a new directory to store the downloaded .deb files (e.g., v4.18).
  - Move the downloaded files to the newly created directory.
  - Navigate to the directory using ```cd v4.18/```
  - Install the packages using ```sudo dpkg -i *.deb```

- Reboot your system. During the boot process, you should see a menu with available kernel versions (enabled by modifying GRUB_TIMEOUT_STYLE in step 2). Select the newly installed kernel version (e.g., ```4.18.0-041800-generic```) and boot into your system.

Once booted, you can verify the active kernel version by running ```uname -r```. This command should display 4.18.0-041800-generic or a similar version number indicating kernel 4.18 is now active.

To change the default boot order in the GRUB menu, add ```GRUB_DEFAULT="1>3"``` in the ```/etc/default/grub``` file and run ```sudo update-grub```. Whne you reboot the system, the system will boot in the order you've specified in the GRUB file.

For example, assume that the kernel boot order is the fourth one. 

1 in **1**>3 indicates the second entry of the main menu.

<img src="https://github.com/deepakc7y/netronome-config/blob/main/images/images/ubuntu_grub_main_menu.png">

3 in 1>**3** indicates the fourth entry of the submenu.

<img src="https://github.com/deepakc7y/netronome-config/blob/main/images/images/ubuntu_grub_sub_menu.png">

### Installing the Ethernet Driver

This section details the process of installing the necessary driver for the Realtek ethernet controller commonly found on ASUS motherboards. This driver resolves known compatibility issues with Ubuntu 18.04 and enables functionality of the onboard LAN port.

- Ensure you have an Internet connection (temporary solution like a WiFi card)
- Downloaded driver package ```r8125-9.007.01.tar.bz2``` and extract it
- ```sudo apt update```
- ```sudo apt install make make-guile gcc```
- ```cd r8125-9.007.01/```
- ```sudo chmod +x autorun.sh```
- ```sudo ./autorun.sh```

## The Guide to Configuring a Netronome SmartNIC

This section details the process of installing and configuring the Netronome Software Development Kit (SDK) to enable you to develop and execute programs on your Netronome SmartNIC card. The SDK provides the necessary tools and libraries for interacting with the card's hardware and implementing custom functionalities.

### SDK Installation
- Add Netronome Public Key
  - ```sudo wget https://rpm.netronome.com/gpg/NetronomePublic.key```
  - ```sudo apt-key add NetronomePublic.key```

This downloads the Netronome public key and adds it to your system's trusted keyrings. This key is used to verify the integrity of the software packages you'll install from Netronome repositories.

- Add Netronome Repository
  - ```sudo mkdir -p /etc/apt/sources.list.d/```
  - ```sudo echo "deb https://deb.netronome.com/apt stable main" > /etc/apt/sources.list.d/netronome.list```
  - ```sudo apt update```

These commands create a new directory for custom APT sources and add a new entry for the Netronome repository. Finally, it updates the package list to include packages available from the Netronome repository.

```sudo apt install agilio-naming-policy libftdi1 libjansson4 build-essential linux-headers-`uname -r` dkms git net-tools libelf-dev```

This command installs various dependencies required for building and running the Netronome SDK, including libraries for interfacing with hardware (libftdi1), data serialization (libjansson4), development tools (build-essential), kernel headers for the current kernel version (linux-headers-uname -r), kernel modules support (dkms), version control system (git), network utilities (net-tools), and ELF file handling (libelf-dev).

- Install Netronome SDK Package (Root Privileges Required)
  - ```sudo dpkg -i nfp-sdk_6.1.0.1-preview-3243-2_amd64.deb```

Replace nfp-sdk_6.1.0.1-preview-3243-2_amd64.deb with the actual filename of the downloaded Netronome SDK package. This command installs the core Netronome SDK components and initializes the /opt/netronome directory.

- Configure Environment Variables

```
cat >> ~/.bash_profile << 'EOF'
# Netronome SDK
PATH=$PATH:/opt/netronome/bin
export PATH
EOF
source ~/.bash_profile
```

These commands add the ```/opt/netronome/bin``` directory to your system's PATH environment variable. This allows you to access Netronome SDK tools like ```nfp-sdk6_build``` and ```nfp-sdk6_rte``` from any terminal session without specifying the full path.

Now, reboot and verify installation.


### Installing P4 Runtime Environment

The P4 Runtime environment can be installed using the following three commands (root priviliges required):

- ```tar xvf nfp-sdk-p4-rte-6.1.0.1-preview-3214.ubuntu.x86_64.tgz```
- ```cd nfp-sdk-6-rte-v6.1.0.1-preview-Ubuntu-Release-r2750-2018-10-10-ubuntu.binary/```
- ```sudo ./sdk6_rte_install.sh install```

There's a chance the installation might fail on the first attempt, even if your system meets the requirements. In such cases, where you encounter errors about system compatibility or missing DKMS, simply re-run the same installation command.

One of the ways to access the SmartNIC is using the ```nfp_dev_cpp```. The in-tree version of the NFP Module disables this option, so in order to enable it we have to install the nfp-drv-kmods repository

Download the nfp-drv-kmods repository from [here](https://github.com/Netronome/nfp-drv-kmods), extract it to the ```/home``` directory and run the following commands from the repository.

- ```cd nfp-drv-kmods/```
- ```sudo make``` // compiles the kernel module source code into a loadable module
- ```sudo make install``` // installs the compiled module (nfp.ko) into the appropriate kernel module directory.
- ```sudo depmod -a``` // informs the kernel dependency manager (depmod) about the newly installed module
- ```sudo make clean``` // cleans up any temporary build files
- ```sudo modprobe -r -v nfp``` // unloads any currently loaded nfp module
- ```sudo modprobe nfp nfp_dev_cpp=1 nfp_pf_netdev=0``` // reloads the nfp module

To successfully compile a P4 program, you will have to copy the ```p4c-bm2-ss``` file to the ```/opt/netronome/p4/libexec/``` directory using the following command:

```sudo cp -R /opt/netronome/p4/bin/p4c-bm2-ss /opt/netronome/p4/libexec/```

### Installing SRIOV-supported firmware
Netronome SmartNICs offer the ability to create Virtual Functions (VFs), essentially splitting the physical network interface card (NIC) into multiple logical ones. This enables efficient resource utilization by allowing you to share the capabilities of a single SmartNIC with multiple virtual machines (VMs) or containerized applications.

- Download Basic Firmware with SRIOV support for Ubuntu from [Netronome's support website](https://help.netronome.com/support/solutions/articles/36000052070-agilio-smartnic-basic-firmware-v-2-1-16-1)
- ```sudo dpkg -i agilio-sriov-firmware-2.1.16.1-1.deb``` installs the firmware.
- To verify the installation, use the ```ethtool``` command. Look for the firmware-version field in the output, which should now include ```sriov``` in the version string.

Example:
```
zenlab@zenlab690:~$ ethtool -i enp3s0np0np0 | head -3
driver: nfp
version: no-src-ver (o-o-t)
firmware-version: 0.0.3.5 0.25 sriov-2.1.16.1 nic
```

## Additional Configurations

### Creating Virtual Functions (VFs)

**Check Current VF Count:** Use the ```cat /sys/class/net/enp3s0np0np0/device/sriov_numvfs``` command to determine the number of currently configured VFs on your SmartNIC. Initially, this value will be ```zero```.

**Verify Maximum Supported VFs:** The total number of VFs supported by your SmartNIC can be obtained using the ```cat /sys/class/net/enp3s0np0np0/device/sriov_totalvfs``` command.

**Create VFs:** Specify the desired number of VFs you want to create using the following command, replacing ```<number>``` with the actual number of VFs (up to the maximum supported value):

```
echo <number> > /sys/class/net/enp3s0np0np0/device/sriov_numvfs
```

**Verify VF Creation:** After executing the command, use ```cat /sys/class/net/enp3s0np0np0/device/sriov_numvfs``` again to confirm that the number of VFs has been updated.

**Identify VF Interfaces:** The newly created VFs will appear as separate network interfaces. You can list them using command like ```ip addr``` show. Their names will typically follow a pattern similar to the physical NIC interface name, with additional suffixes to differentiate them (e.g., enp3s0np1np1, enp3s0np2np2).

Example:
```
root@zenlab690:~# lspci -d19ee: -k
03:00.0 Ethernet controller: Netronome Systems, Inc. Device 4000
Subsystem: Netronome Systems, Inc. Device 4000
Kernel driver in use: nfp
Kernel modules: nfp

03:08.0 Ethernet controller: Netronome Systems, Inc. Device 6003
Subsystem: Netronome Systems, Inc. Device 4000
Kernel driver in use: nfp_netvf
Kernel modules: nfp

03:08.1 Ethernet controller: Netronome Systems, Inc. Device 6003
Subsystem: Netronome Systems, Inc. Device 4000
Kernel driver in use: nfp_netvf
Kernel modules: nfp
```

```03:08.0``` and ```03:08.1``` are the PCI addresses of our two VFs and you can also see that they use ```nfp_netvf``` driver instead of ```nfp``` driver used by the PF.

### To enable NFP ports for 1G RJ45 Connections

Plug the SFP to RJ45 media converters by Cisco (Model details: ) to the physical ports of the Netronome smartNIC and run the following commands

```
zenlab@tsn1:~$ sudo /opt/netronome/bin/nfp-media
phy0=10G (unset)
phy1=10G (unset)
```

```
zenlab@tsn1:~$ sudo /opt/netronome/bin/nfp-phymod 
phy0: NBI0.0(1)	"0" SFP+ conn:LC Unknown (0x00)
 "OEM" "SFP-1.25G-T" "21051745012"  oui:0x0 type:0xa len:550m active:1 cc:0
	TX Fault: FAULT(0x1,0x0)
	RX Fault: LOS(0x0,0x1)
  eth0: NBI0.0(1)	"0.0" 00:15:4d:13:5c:5d 10G Down Bootable
	Link Fault: RX_BASE RX_BLOCK
phy1: NBI0.4(1)	"1" SFP+ conn:LC Unknown (0x00)
 "OEM" "SFP-1.25G-T" "21051745013"  oui:0x0 type:0xa len:550m active:1 cc:0
	TX Fault: FAULT(0x1,0x0)
	RX Fault: LOS(0x0,0x1)
  eth4: NBI0.4(1)	"1.0" 00:15:4d:13:5c:5e 10G Down Bootable
	Link Fault: RX_BASE RX_BLOCK

```

```
zenlab@tsn1:~$ sudo bash
root@tsn1:~# sudo chmod a+x /opt/netronome/bin/nfp-media 
root@tsn1:~# cat /sys/module/nfp/parameters/nfp_dev_cpp
1
```

```
root@tsn1:~# sudo /opt/netronome/bin/nfp-media -n0 phy0=1G phy1=1G
 eth0: "0.0" 00:15:4d:13:5c:5d
 eth4: "1.0" 00:15:4d:13:5c:5e
```

```
root@tsn1:~# sudo /opt/netronome/bin/nfp-media 
phy0=1G (1G)
phy1=1G (1G)
```

Additional Reference - [Low cost 10G optical to 1G copper media converter - open nfp groups](https://groups.google.com/g/open-nfp/c/lWdZE4sCMvQ/m/sZ_G_jD8GQAJ)

### To see the Netronome SmartNIC Physical Interfaces

```
sudo modprobe -r -v nfp && sudo modprobe nfp nfp_pf_netdev=1
``` 

### Verifying the Kernel Patch for Netronome SmartNICs [Optional]

Netronome identified an issue in the way Linux kernel handles Peripheral Component Interconnect Express (PCIe) configuration. This issue can lead to undesired behavior when working with Netronome SmartNICs. A fix for this issue, known as the ERR47 kernel patch, has been submitted by Netronome and integrated into the kernel.

```
root@zenlab690:~# if /opt/nfp_pif/scripts/err47_check.sh; then echo "Kernel is good"; else
> echo "Kernel patch needed"; fi

Kernel is good
```

If a kernel patch is needed, refer to [this article](https://help.netronome.com/support/solutions/articles/36000054996-agilio-smartnics-err47-kernel-patch)

### Changing Netronome Port Link Speed from 10G to 1G [[Reference]](https://groups.google.com/g/open-nfp/c/lWdZE4sCMvQ/m/sZ_G_jD8GQAJ)

```
zenlab@tsn1:~$ sudo /opt/netronome/bin/nfp-media
phy0=10G (unset)
phy1=10G (unset)

root@tsn1:~# sudo chmod a+x /opt/netronome/bin/nfp-media 

root@tsn1:~# sudo /opt/netronome/bin/nfp-media -n0 phy0=1G phy1=1G
 eth0: "0.0" 00:15:4d:13:5c:5d
 eth4: "1.0" 00:15:4d:13:5c:5e

root@tsn1:~# sudo /opt/netronome/bin/nfp-media 
phy0=1G (1G)
phy1=1G (1G)
```

### Configuring Default number of VFs for P4/MicroC Programs

By default, when you load a P4/MicroC program onto the smartNIC, 4 VFs are initialized. To change the default number, do the following:

- Go to the directory /lib/systemd/service/nfp-sdk6-rte.service
- The environment variable named ```Environment=NUM_VFS=4``` allows changing the default number of VFs.
- Reboot the host system.