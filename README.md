# Netronome SmartNIC

This README file is structured as following:
- [Configuration of Netronome SmartNICs](https://github.com/deepakc7y/Netronome-SmartNIC-Projects/tree/main/Configuration#netronome-smartnic-configuration)
- Running a MicroC Program on Netronome SmartNIC
- Setting up Windows and Linux Development Workflow
- Running a P4 Program on Netronome SmartNIC

### To change the link speed of Netronome ports from 10G to 1G

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
[Reference](https://groups.google.com/g/open-nfp/c/lWdZE4sCMvQ/m/sZ_G_jD8GQAJ)
