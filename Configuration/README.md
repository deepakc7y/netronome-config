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

### Ensure that the Netronome Card appears as one of the Ethernet Controllers. It can be done using the following commands

```
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
``` 

lspci -vvv -d 19ee: to confirm PCIe configuration of SmartNIC(s)
zenlab@zenlab690:~$ sudo lspci -d19ee:
03:00.0 Ethernet controller: Netronome Systems, Inc. Device 4000

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
