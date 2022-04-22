# Netronome SmartNIC Configuration

## System Details:
- Motherboard - Asus Prime Z690 P D4 [[Link]](https://www.asus.com/in/Motherboards-Components/Motherboards/PRIME/PRIME-Z690-P-D4/)
- Processor - 12th Gen Intel® Core™ i5-12400 × 12
- RAM - 16GB
- Operating System - Ubuntu 18.04
- Kernel Version - 5.4.0-107-generic

## SmartNIC Details:
- Netronome Agilio SmartNIC CX 2x10GbE [[Link]](https://www.netronome.com/products/agilio-cx/)

## Initial Configuration

### Enabling the SRIOV Support in the boot menu

SR-IOV is a PCI feature that allows virtual functions (VFs) to be created from a physical function (PF). The VFs thus share the resources of a PF, while VFs remain isolated from each other. The isolated VFs are typically assigned to virtual machines (VMs) on the host. In this way, the VFs allow the VMs to directly access the PCI device, thereby bypassing the host kernel. [[Source]](https://help.netronome.com/support/solutions/articles/36000049975-basic-firmware-user-guide#using-sr-iov)

By default, the SRIOV Support is disabled. To use the Virtual Functions (VFs), you have to enable the SRIOV Support. In the Asus Motherboard, the 'SRIOV Support' option can be found under 'PCI Subsystem Settings' and can be enabled.

<img src="https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/images/SRIOV-BIOS-Asus.png">

[[Image Source]](https://dlcdnets.asus.com/pub/ASUS/mb/13MANUAL/PRIME_PROART_TUF_GAMING_Intel_600_Series_BIOS_EM_WEB_EN.pdf)

### Ensure that the Netronome Card appears as one of the Ethernet Controllers

It can be done using the following commands

```
lspci -vvv -d 19ee: to confirm PCIe configuration of SmartNIC(s)

zenlab@zenlab690:~$ sudo lspci -d19ee:
03:00.0 Ethernet controller: Netronome Systems, Inc. Device 4000
``` 

```
dmesg | grep nfp to check for system-generated messages the SmartNIC

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

If Kernel patch is needed, refer to this article [[Link]](https://help.netronome.com/support/solutions/articles/36000054996-agilio-smartnics-err47-kernel-patch)

### Enable nfp_dev_cpp

One of the ways to access the SmartNIC is using the nfp_dev_cpp. The in-tree version of the NFP Module disables this option, so in order to enable it we have to install the nfp-drv-kmods repository

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
