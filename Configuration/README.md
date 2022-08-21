# Netronome SmartNIC Configuration

## Index
* [Host System Details](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#system-details)
* [SmartNIC Details](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#smartnic-details)
* [Enabling the SRIOV Support in the boot menu](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#enabling-the-sriov-support-in-the-boot-menu)
* [Ensure that the Netronome Card appears as one of the Ethernet Controllers](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#ensure-that-the-netronome-card-appears-as-one-of-the-ethernet-controllers)
* [Ensure that ERR47 Kernel Patch is already done](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#ensure-that-err47-kernel-patch-is-already-done)
* [Enable ```nfp_dev_cpp```](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#enable-nfp_dev_cpp)
* [Follow the official Basic Firmware Guide](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#follow-the-official-basic-firmware-guide)
* [Creating Virtual Functions (VFs)](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#creating-virtual-functions-vfs)
    - [Installing SRIOV Capable Firmware](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#installing-sriov-capable-firmware)
    - [Configuring the SRIOV and creating two virtual functions](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#configuring-the-sriov-and-creating-two-virtual-functions)
* [Installing the Command line RTE (Run-Time Environment)](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/Configuration/README.md#installing-the-command-line-rte-run-time-environment)

## Initial Configuration

### System Details:
- Motherboard - Asus Prime Z690 P D4 [[Link]](https://www.asus.com/in/Motherboards-Components/Motherboards/PRIME/PRIME-Z690-P-D4/)
- Processor - 12th Gen Intel® Core™ i5-12400 × 12
- RAM - 16GB
- Operating System - Ubuntu 18.04
- Kernel Version - 5.4.0-109-generic

### SmartNIC Details:
- Netronome Agilio SmartNIC CX 2x10GbE [[Link]](https://www.netronome.com/products/agilio-cx/)

### Enabling the SRIOV Support in the boot menu

SR-IOV is a PCI feature that allows virtual functions (VFs) to be created from a physical function (PF). The VFs thus share the resources of a PF, while VFs remain isolated from each other. The isolated VFs are typically assigned to virtual machines (VMs) on the host. In this way, the VFs allow the VMs to directly access the PCI device, thereby bypassing the host kernel. [[Source]](https://help.netronome.com/support/solutions/articles/36000049975-basic-firmware-user-guide#using-sr-iov)

By default, the SRIOV Support is disabled. To use the Virtual Functions (VFs), you have to enable the SRIOV Support. In the Asus Motherboard, the "SRIOV Support" option can be found under **PCI Subsystem Settings** and can be enabled.

<img src="https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/images/SRIOV-BIOS-Asus.png">

[[Image Source]](https://dlcdnets.asus.com/pub/ASUS/mb/13MANUAL/PRIME_PROART_TUF_GAMING_Intel_600_Series_BIOS_EM_WEB_EN.pdf)

### Ensure that the Netronome Card appears as one of the Ethernet Controllers

It can be done using the following commands

```lspci -vvv -d 19ee:``` to confirm PCIe configuration of SmartNIC(s)

```
zenlab@zenlab690:~$ sudo lspci -d19ee:
03:00.0 Ethernet controller: Netronome Systems, Inc. Device 4000
``` 

```dmesg | grep nfp``` to check for system-generated messages the SmartNIC

```
zenlab@zenlab690:~$ dmesg | grep nfp
[    1.011845] nfp: NFP PCIe Driver, Copyright (C) 2014-2017 Netronome Systems
[    1.011947] nfp 0000:03:00.0: Netronome Flow Processor NFP4000/NFP5000/NFP6000 PCIe Card Probe
[    1.011954] nfp 0000:03:00.0: 31.504 Gb/s available PCIe bandwidth, limited by 8 GT/s x4 link at 0000:00:1b.4 (capable of 63.008 	Gb/s with 8 GT/s x8 link)
[    1.011973] nfp 0000:03:00.0: RESERVED BARs: 0.0: General/MSI-X SRAM, 0.1: PCIe XPB/MSI-X PBA, 0.4: Explicit0, 0.5: Explicit1, free: 20/24
[    1.012018] nfp 0000:03:00.0: Model: 0x62000010, SN: 00:15:4d:13:5c:5c, Ifc: 0x10ff
[    1.020159] nfp 0000:03:00.0: Assembly: SMCAMDA0096-000117290565-11 CPLD: 0x1030000
[    1.020474] nfp 0000:03:00.0: nfp_nsp: Service processor busy!
[    1.020478] nfp 0000:03:00.0: Failed to access the NSP: -16
[    1.020549] nfp: probe of 0000:03:00.0 failed with error -16
``` 

### Ensure that ERR47 Kernel Patch is already done
	
Linux kernels exhibit undesired behavior in PCIe configuration code. Netronome submitted a fix to the kernel maintainers for this issue which has been accepted into kernel version 4.5.

You can check for the Kernel patch using this command:

```
root@zenlab690:~# if /opt/nfp_pif/scripts/err47_check.sh; then echo "Kernel is good"; else
> echo "Kernel patch needed"; fi
Kernel is good
```

If Kernel patch is needed, refer to [this article](https://help.netronome.com/support/solutions/articles/36000054996-agilio-smartnics-err47-kernel-patch)

### Enable ```nfp_dev_cpp```

One of the ways to access the SmartNIC is using the ```nfp_dev_cpp```. The in-tree version of the NFP Module disables this option, so in order to enable it we have to install the nfp-drv-kmods repository

Download the nfp-drv-kmods repository from [here](https://github.com/Netronome/nfp-drv-kmods), extract it and run the following commands from the repository.

```
- make
- make install
- depmod -a
- make clean
- cat /sys/module/nfp/parameters/nfp_dev_cpp to check the value of nfp_dev_cpp
- sudo modprobe -r -v nfp && sudo modprobe nfp nfp_dev_cpp=1 to remove and reload the nfp module and set nfp_dev_cpp = 1
```
```
zenlab@zenlab690:~/Downloads/nfp-drv-kmods$ sudo make
make -C /lib/modules/5.4.0-107-generic/build M=`pwd`/src modules
make[1]: Entering directory '/usr/src/linux-headers-5.4.0-107-generic'
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp6000_pcie.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_nsp.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_cppcore.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_cpplib.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_dev.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_em_manager.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_hwinfo.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_mip.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_mutex.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_nbi.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_nffw.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_nsp_cmds.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_nsp_eth.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_platform.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_resource.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_rtsym.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_target.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_nbi_mac_eth.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_net_vnic.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_debugdump.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_plat.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_main.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_hwmon.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_dev_cpp.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfpcore/nfp_export.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfd3/dp.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfd3/rings.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfdk/dp.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfdk/rings.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_app.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/ccm_mbox.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_ctrl.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_common.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_compat.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_dp.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_ethtool.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_debugfs.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_sriov.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_port.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/crypto/tls.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_app_nic.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_ctrl.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_main.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nic/main.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_devlink.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/devlink_param.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_shared_buf.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/ccm.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_asm.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/bpf/cmsg.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/bpf/main.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/bpf/offload.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/bpf/verifier.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/bpf/jit.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_net_repr.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/action.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/cmsg.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/lag_conf.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/match.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/metadata.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/offload.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/main.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/tunnel_conf.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/flower/qos_conf.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/abm/cls.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/abm/ctrl.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/abm/main.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/abm/qdisc.o
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_netvf_main.o
  LD [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp.o
  Building modules, stage 2.
  MODPOST 1 modules
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp.mod.o
  LD [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp.ko
make[1]: Leaving directory '/usr/src/linux-headers-5.4.0-107-generic'
```
```
zenlab@zenlab690:~/Downloads/nfp-drv-kmods$ sudo make install
make -C /lib/modules/5.4.0-107-generic/build M=`pwd`/src modules
make[1]: Entering directory '/usr/src/linux-headers-5.4.0-107-generic'
  CC [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp_main.o
  LD [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp.o
  Building modules, stage 2.
  MODPOST 1 modules
  LD [M]  /home/zenlab/Downloads/nfp-drv-kmods/src/nfp.ko
make[1]: Leaving directory '/usr/src/linux-headers-5.4.0-107-generic'
make -C /lib/modules/5.4.0-107-generic/build M=`pwd`/src modules_install
make[1]: Entering directory '/usr/src/linux-headers-5.4.0-107-generic'
  INSTALL /home/zenlab/Downloads/nfp-drv-kmods/src/nfp.ko
At main.c:160:
- SSL error:02001002:system library:fopen:No such file or directory: ../crypto/bio/bss_file.c:72
- SSL error:2006D080:BIO routines:BIO_new_file:no such file: ../crypto/bio/bss_file.c:79
sign-file: certs/signing_key.pem: No such file or directory
  DEPMOD  5.4.0-107-generic
Warning: modules_install: missing 'System.map' file. Skipping depmod.
make[1]: Leaving directory '/usr/src/linux-headers-5.4.0-107-generic'
```
```
zenlab@zenlab690:~/Downloads/nfp-drv-kmods$ sudo depmod -a
```
```
zenlab@zenlab690:~/Downloads/nfp-drv-kmods$ sudo make clean
make -C /lib/modules/5.4.0-107-generic/build M=`pwd` clean
make[1]: Entering directory '/usr/src/linux-headers-5.4.0-107-generic'
make[1]: Leaving directory '/usr/src/linux-headers-5.4.0-107-generic'
```
```
zenlab@zenlab690:~/Downloads/nfp-drv-kmods$ cat /sys/module/nfp/parameters/nfp_dev_cpp
cat: /sys/module/nfp/parameters/nfp_dev_cpp: No such file or directory
```
```
zenlab@zenlab690:~/Downloads/nfp-drv-kmods$ sudo modprobe -r -v nfp && sudo modprobe nfp nfp_dev_cpp=1
rmmod nfp
rmmod tls
```
```
zenlab@zenlab690:~/Downloads/nfp-drv-kmods$ cat /sys/module/nfp/parameters/nfp_dev_cpp
1
```

### Follow the official Basic Firmware Guide 

Follow the [basic firmware guide](https://help.netronome.com/support/solutions/articles/36000049975-basic-firmware-user-guide) and configure the smartNIC as per your requirements.

### Creating Virtual Functions (VFs)

#### Installing SRIOV Capable Firmware

One of the strengths of a SmartNIC is its ability to create VFs. After enabling SRIOV from BIOS, we must install SRIOV capable firmware onto the SmartNIC. 

```
zenlab@zenlab690:~$ ethtool -i enp3s0np0np0 | head -3
driver: nfp
version: no-src-ver (o-o-t)
firmware-version: 0.0.3.5 0.25 nic-2.1.16 nic
```

From the above output, we can see that the current firmware being used is the one without SRIOV functionality and with basic NIC functionality.
2.1.16 denotes the version of the firmware.

Download the SRIOV capable firmware from this [link](https://help.netronome.com/support/solutions/articles/36000052070-agilio-smartnic-basic-firmware-v-2-1-16-1) and install it using the following steps.

(Note: Ensure that you download the basic firmware **with SRIOV Support**)

```
zenlab@zenlab690:~$ sudo dpkg -i agilio-sriov-firmware-2.1.16.1-1.deb
Selecting previously unselected package agilio-sriov-firmware.
(Reading database ... 174507 files and directories currently installed.)
Preparing to unpack agilio-sriov-firmware-2.1.16.1-1.deb ...
Unpacking agilio-sriov-firmware (2.1.16.1-1) ...
Setting up agilio-sriov-firmware (2.1.16.1-1) ...
update-initramfs: Generating /boot/initrd.img-5.4.0-107-generic
W: Possible missing firmware /lib/firmware/rtl_nic/rtl8125a-3.fw for module r8169
W: Possible missing firmware /lib/firmware/rtl_nic/rtl8168fp-3.fw for module r8169
update-initramfs: Generating /boot/initrd.img-5.3.0-28-generic
```
```
zenlab@zenlab690:~$ ls -og --time-style="+" /lib/firmware/netronome
total 56
drwxr-xr-x 2 4096  flower
drwxr-xr-x 2 4096  nic
lrwxrwxrwx 1   64  nic_AMDA0058-0011_2x40.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0058-0011_2x40.nffw
lrwxrwxrwx 1   64  nic_AMDA0058-0012_2x40.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0058-0012_2x40.nffw
lrwxrwxrwx 1   65  nic_AMDA0078-0011_1x100.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0078-0011_1x100.nffw
lrwxrwxrwx 1   64  nic_AMDA0081-0001_1x40.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0081-0001_1x40.nffw
lrwxrwxrwx 1   64  nic_AMDA0081-0001_4x10.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0081-0001_4x10.nffw
lrwxrwxrwx 1   64  nic_AMDA0096-0001_2x10.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0096-0001_2x10.nffw
lrwxrwxrwx 1   64  nic_AMDA0097-0001_2x40.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0097-0001_2x40.nffw
lrwxrwxrwx 1   69  nic_AMDA0097-0001_4x10_1x40.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0097-0001_4x10_1x40.nffw
lrwxrwxrwx 1   64  nic_AMDA0097-0001_8x10.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0097-0001_8x10.nffw
lrwxrwxrwx 1   69  nic_AMDA0099-0001_1x10_1x25.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0099-0001_1x10_1x25.nffw
lrwxrwxrwx 1   64  nic_AMDA0099-0001_2x10.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0099-0001_2x10.nffw
lrwxrwxrwx 1   64  nic_AMDA0099-0001_2x25.nffw -> /opt/netronome/agilio-sriov-firmware/nic_AMDA0099-0001_2x25.nffw
```

Next, remove the NFP Driver and then reload it again. This will ensure that the firmware with SRIOV Support is installed onto the SmartNIC.

```
zenlab@zenlab690:~$ sudo modprobe -r nfp
zenlab@zenlab690:~$ sudo modprobe nfp
```

We can confirm the SRIOV capable firmware using the following command:

```
zenlab@zenlab690:~$ ethtool -i enp3s0np0np0 | head -3
driver: nfp
version: no-src-ver (o-o-t)
firmware-version: 0.0.3.5 0.25 sriov-2.1.16.1 nic
```

The firmware has been successfully changed from ```nic-2.1.16``` to ```sriov-2.1.16.1```

#### Configuring the SRIOV and creating two virtual functions

Till this point we have ensured that we have all the necessary firmwares and repositories to create virtual functions, but we haven't created any. There are currently zero VFs on our SmartNIC. This can be checked using the following command

```
zenlab@zenlab690:~$ cat  /sys/class/net/enp3s0np0np0/device/sriov_numvfs
0
```

The total number of supported VFs on your smartNIC can be checked using the following command

```
zenlab@zenlab690:~$ cat /sys/class/net/enp3s0np0np0/device/sriov_totalvfs
48
```

The command ```lspci -d19ee: -k``` now returns only one result because have one Physical Function (PF) and zero VFs.

```
root@zenlab690:~# lspci -d19ee: -k
03:00.0 Ethernet controller: Netronome Systems, Inc. Device 4000
	Subsystem: Netronome Systems, Inc. Device 4000
	Kernel driver in use: nfp
	Kernel modules: nfp
```

Although we can create up to 48 VFs in this SmartNIC, we will be creating two VFs as an example.

```
root@zenlab690:~# echo 2 > /sys/class/net/enp3s0np0np0/device/sriov_numvfs
```

```enp3s0np0np0``` is the interface of the SmartNIC's PF.

We get to see the two VFs after the executing above command

```
root@zenlab690:~# cat /sys/class/net/enp3s0np0np0/device/sriov_numvfs
2
```
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

**Note**: You can find the interface of your SmartNIC's PF using ```ifconfig -a``` or ```ip a``` after completing step 5.

```
zenlab@zenlab690:~$ ifconfig -a
enp3s0np0np0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 00:15:4d:13:5c:5d  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp3s0np1np1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 00:15:4d:13:5c:5e  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 781  bytes 78699 (78.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 781  bytes 78699 (78.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlx687f746839ba: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.163  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::f231:3afd:644a:d376  prefixlen 64  scopeid 0x20<link>
        inet6 fd77:2b3d:8de7:0:99c6:d3f7:5a5a:790  prefixlen 64  scopeid 0x0<global>
        inet6 fd77:2b3d:8de7::b1c  prefixlen 128  scopeid 0x0<global>
        inet6 fd77:2b3d:8de7:0:580f:542e:40c6:66ec  prefixlen 64  scopeid 0x0<global>
        ether 68:7f:74:68:39:ba  txqueuelen 1000  (Ethernet)
        RX packets 2197  bytes 1942238 (1.9 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2169  bytes 272453 (272.4 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

### Installing the Command line RTE (Run-Time Environment)

Download the NFP SDK Packages from the official website. You should get the access to all the SDK related files once you have registered the Netronome Card.

Run the following commands:

```
Install the necessary packages
apt-get install libftdi1 libjansson4 build-essential \
 linux-headers-`uname -r` dkms git
```
```sudo dpkg -i nfp-sdk_6.1.0.1-preview-3243-2_amd64.deb``` creates the /opt/netronome directory

```
Add to the path where the binaries will be installed
cat >> ~/.bash_profile << 'EOF'

# Netronome SDK
PATH=$PATH:/opt/netronome/bin
export PATH
EOF
source ~/.bash_profile
```
```
Add the Netronome Public Key and Update
wget https://deb.netronome.com/gpg/NetronomePublic.key
apt-key add NetronomePublic.key
add-apt-repository "deb https://deb.netronome.com/apt stable main"
apt-get update
```

and then **reboot** the system.

Also ensure that ```nfp_dev_cpp = 1```. If you encounter an error, remove and reload the ```nfp``` module using the following command

```
sudo modprobe -r -v nfp && sudo modprobe nfp nfp_dev_cpp=1
```

If you encounter an error even after reloading the module, then repeat step 4 again.

Ensure that ```nfp-hwinfo``` is talking to the card using the following command. Ensure that the output is similar to the one below.

```
sudo /opt/netronome/bin/nfp-hwinfo

zenlab@zenlab690:~$ sudo /opt/netronome/bin/nfp-hwinfo
nfp.interface=pci.0.0
nfp.model=0x62000010
nfp.serial=00:15:4d:13:5c:5c
assembly.revision=11
assembly.model=lithium
assembly.partno=AMDA0096-0001
assembly.serial=17290565
assembly.vendor=SMC
ddr0.spd=spi:1:0:0x3F0F00
ddr1.spd=spi:1:0:0x3F0F00
ddr2.spd=none
ddr3.spd=none
ddr4.spd=none
ddr5.spd=none
emu1.type=cache
emu2.type=cache
ethm.mac=00:15:4d:13:5c:5c
eth.mac=00:15:4d:13:5c:5d
eth.macs=2
pcie0.type=ep
chip.model=NFP4001
chip.revision=B0
chip.model.device=0x62006020
chip.identifier=0xd78f8d460
chip.model.hard=0x5
chip.model.soft=0x40010096
chip.route=0x26843312
chip.island=0x1001f13000112
core.speed=633
me.speed=633
arm.speed=475
nfp-boot.version= ()
bsp.version.primary=01011b
bsp.version.secondary=01011b
flash.data.bus=1
ddr0.mem.size=1024
ddr1.mem.size=1024
ddr0.mem.speed=1600
ddr1.mem.speed=1600
emu0.mem.size=2048
emu0.mem.base=0x2000000000
emu1.mem.size=3
emu1.mem.base=0x9900000000
emu2.mem.size=0
emu2.mem.base=0x0
arm.mem.size=96
arm.mem.base=0x207a000000
cpld.location=spi:2:2:4
pmon.limit=25.0
pmon.12v=cpld:7:I:32_0:0.00249:0
pmon.3v3=static:0.54
phy0.label=0
phy0.nbi=0
phy0.port=0
phy0.lanes=1
phy0.sff=8431
phy0.pin.link=-cpld:2:2:0xd.0
phy0.pin.activity=-cpld:2:2:0xd.3
phy0.SFF-8431=ee1:0:0x50:0x0
phy0.SFF-8472=ee1:0:0x51:0x0
phy0.pin.present=-cpld:2:2:0x9.5
phy0.pin.rate_select_0=cpld:2:2:0x9.2
phy0.pin.rate_select_1=cpld:2:2:0x9.1
phy0.pin.tx_disable=cpld:2:2:0x9.4
phy0.pin.tx_fault=cpld:2:2:0x9.12
phy0.pin.rx_los=cpld:2:2:0x9.0
phy0.type=SFP+
phy0.media=X
eth0.media=X
eth0.label=0.0
eth0.phy=0
eth0.lane=0
eth0.lanes=1
eth0.boot=1
phy1.label=1
phy1.nbi=0
phy1.port=4
phy1.lanes=1
phy1.sff=8431
phy1.pin.link=-cpld:2:2:0xd.4
phy1.pin.activity=-cpld:2:2:0xd.7
phy1.SFF-8431=ee1:1:0x50:0x0
phy1.SFF-8472=ee1:1:0x51:0x0
phy1.pin.present=-cpld:2:2:0x9.11
phy1.pin.rate_select_0=cpld:2:2:0x9.8
phy1.pin.rate_select_1=cpld:2:2:0x9.7
phy1.pin.tx_disable=cpld:2:2:0x9.10
phy1.pin.tx_fault=cpld:2:2:0x9.13
phy1.pin.rx_los=cpld:2:2:0x9.6
phy1.type=SFP+
phy1.media=X
eth4.media=X
eth4.label=1.0
eth4.phy=1
eth4.lane=0
eth4.lanes=1
eth4.boot=1
phy0.ledblink=cpld:2:2:0xd.10
phy1.ledblink=cpld:2:2:0xd.12
cpld.version=0x1030000
eth0.mac=00:15:4d:13:5c:5d
eth4.mac=00:15:4d:13:5c:5e
board.state=15
bootloader.version=default (e3136d5f74c39ed9b039cfccfb53a30b86d60cbb)
bsp.version=01011b.01011b.0100ff
```

Proceed further only if ```nfp_dev_cpp = 1``` and ```nfp-hwinfo``` gives the expected output.

## Host System Setup

### Installing the ethernet driver

The ASUS Motherboard used in the host system for the Netronome SmartNIC has ethernet driver issues with Ubuntu 18.04. The following steps resolve the issue and allows the usage of LAN port.

```
- apt update
- apt install make make-guile gcc
- cd Downloads/r8125-9.007.01/
- chmod +x autorun.sh
- ./autorun.sh
```

### Changing the Linux Kernel Version

According to Netronome support, kernel version 4.15 is the only tested version for Ubuntu 18.04 [(source)](https://help.netronome.com/support/solutions/articles/36000184708-tested-linux-versions). The following steps details the process of changing the kernel version 

```
- apt update
- acquire the kernel version packages
- install the kernel version packages
- sudo nano /etc/default/grub
- GRUB_TIMELINE parameter
- GRUB_TIMELINE parameter
- update-grub2
- reboot
- select the kernel version from the GRUB menu under 'Advanced options for Ubuntu'
```
You can acquire the required kernel version from [here](https://kernel.ubuntu.com/~kernel-ppa/mainline/). Additional Resources that I found helpful - [1](https://support.huaweicloud.com/intl/en-us/trouble-ecs/ecs_trouble_0327.html), [2](https://techadminblog.com/boot-previous-kernel-version-ubuntu-16-04/), [3](https://youtu.be/Oobfg8srQwU).
