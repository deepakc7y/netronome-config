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

SR-IOV is a PCI feature that allows virtual functions (VFs) to be created from a physical function (PF). The VFs thus share the resources of a PF, while VFs remain isolated from each other. The isolated VFs are typically assigned to virtual machines (VMs) on the host. In this way, the VFs allow the VMs to directly access the PCI device, thereby bypassing the host kernel. [Source](https://help.netronome.com/support/solutions/articles/36000049975-basic-firmware-user-guide#using-sr-iov)

By default, the SRIOV Support is disabled. To use the Virtual Functions (VFs), you have to enable the SRIOV Support. In the Asus Motherboard, the 'SRIOV Support' option can be found under 'PCI Subsystem Settings' and can be enabled.

<img src="https://github.com/deepakc7y/Netronome-SmartNIC-Projects/blob/main/images/SRIOV-BIOS-Asus.png">
[Image Source](https://dlcdnets.asus.com/pub/ASUS/mb/13MANUAL/PRIME_PROART_TUF_GAMING_Intel_600_Series_BIOS_EM_WEB_EN.pdf)
