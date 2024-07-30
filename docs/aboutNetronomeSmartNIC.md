Author: Deepak Choudhary \
Date: 04 July 2022 \
Description: Notes about Netronome SmartNIC.

## Peripherals
* **CTM** - Cluster Target Memory
* **NBI** - Network Block Interface - ingress NBI, egress NBI - the packet comes inside and goes outside the netronome via the NBI

## Notes about Timestamps in Netronome SmartNIC

#### me_tsc_read() - flowenv library

Return the current 64bit ME timestamp counter value.
The timestamp counter is maintained in two adjacent CSRs. This function reads these CSRs in a safe fashion and combines the values. The timestamp counter increments every 16 ME clock cycles.

```
__intrinsic unsigned long long int me_tsc_read(void);
    #include <nfp/me.h>
    uint64_t timeval = me_tsc_read()
```

### Miscellaneous Information
- The packets into the microengines are split between the "close" CTM and the "far" memory unit (MU)
- Running the RTE in debug mode which makes the packet processing very slow, since the debug mode is supposed to use only one thread on one microengine. After using the correct RTE, the performance issue vanishes.
