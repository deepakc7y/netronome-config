The ```basic.p4``` is a simple P4 program performing IP forwarding. For every incoming packet, it looks at the destination IP address, modifies the source and destination IP address, decrements the TTL field and sends the packet out on the port specified in the ```user_config.json``` file. The ```user_config.json``` file in this example forwards a packet from port p0 to p1 and vice versa.

For this example, I'm using the ```Netronome Agilio 2x10GbE smartNIC```. To run the above program on your Netronome SmartNIC, run the following commands:

#### Compile the P4 program to a firmware file
```
sudo /opt/netronome/p4/bin/nfp4build -o basic.nffw -p out_dir -4 basic.p4 -l lithium --nfp4c_I /opt/netronome/p4/include/16/p4include/ --nfp4c_p4_version 16
```

#### Start the NFP SDK Service
```
systemctl start nfp-sdk6-rte.service
systemctl status nfp-sdk6-rte.service
```

#### Unload previous firmware and design files
```
/opt/netronome/p4/bin/rtecli design-unload
/opt/netronome/bin/nfp-nffw unload
```

#### Load the firmware and configuration file

```
/opt/netronome/p4/bin/rtecli design-load -f basic.nffw -p out/pif_design.json
/opt/netronome/p4/bin/rtecli config-reload -c user_config.json
```

#### To check RTE Log
```
tail -f /var/log/nfp-sdk6-rte.log
```
