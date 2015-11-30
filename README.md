zedboard-qgige-loopback
=======================

Loopback design for the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") on the [ZedBoard](http://zedboard.org "ZedBoard") using AXI Ethernet

### Description

This project is used for testing the [Quad Gigabit Ethernet FMC](http://ethernetfmc.com "Ethernet FMC").
The design contains 4 AXI Ethernet blocks in a loopback configuration
such that port 0 loops back to port 1, and port 2 loops back to port 3.
The software application uses lwIP on the [ZedBoard](http://zedboard.org "ZedBoard") Ethernet port.

![Ethernet FMC Loopback](http://ethernetfmc.com/wp-content/uploads/2014/10/qgige_loopback.png "Zynq Quad Gig Ethernet Loopback")

To test the [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") using this project, you will need a PC with one
Gigabit Ethernet port. You must connect the PC to port 0 of the [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC").
You must connect [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") ports 1 and 2 with an Ethernet cable.
You must connect [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") port 3 to [ZedBoard](http://zedboard.org "ZedBoard") Ethernet port with
an Ethernet cable. Using the Python application in this project, you can
send Ethernet packets from the PC which will be passed through all the
ports on the [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC"), and then go to the [ZedBoard](http://zedboard.org "ZedBoard") Ethernet port.
From the [ZedBoard](http://zedboard.org "ZedBoard") Ethernet port they will be looped back by the lwIP
application and be sent again through the ports of the [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC") and
back to the PC.

### Requirements

* Vivado 2015.4
* [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
* [ZedBoard](http://zedboard.org "ZedBoard")
* PC with Gigabit Ethernet port
* [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

### Notes on Regenerating lwIP Echo Server

Ignore the following notes if you are importing the SDK application as is, in which case no modifications are necessary.
This repository contains an SDK application which relies on lwIP sources provided with Vivado 2015.4. If you are porting this
design to another version of Vivado, you can regenerate your own lwIP application from the lwIP template in SDK
(New->Application Project->lwIP Echo Server). If you do this, the first compile will fail because by default it is configured
to use AXI Ethernet. This design contains AXI Ethernet IPs but they are not configured with DMAs which is why the error occurs.
We want to instead use the lwIP Echo Server with the Zynq GEM 0 (the Ethernet port of the ZedBoard).
You must modify part of the generated code and the BSP settings to fix this.

#### BSP modification

We must make sure that the BSP is configured NOT to use AXI Ethernet.

* Right-clicking on the BSP and select "Board Support Package Settings"
* Click Overview->Standalone->lwip141
* Set "use_axieth_on_zynq" and "use_emaclite_on_zynq" both to 0
* Click OK and the SDK should rebuild the BSP and echo server application for you

#### Code modification

Add the following files to your `echo_server/src` folder:

https://github.com/fpgadeveloper/zedboard-qgige-loopback/blob/master/SDK/echo_server/src/ethfmc_axie.c
https://github.com/fpgadeveloper/zedboard-qgige-loopback/blob/master/SDK/echo_server/src/ethfmc_axie.h

Open the file `platform_config.h`. Replace the first two lines:

```c
#define USE_SOFTETH_ON_ZYNQ 1
#define PLATFORM_EMAC_BASEADDR XPAR_AXI_ETHERNET_0_BASEADDR
```

with this one line:

```c
#define PLATFORM_EMAC_BASEADDR XPAR_XEMACPS_0_BASEADDR
```

Open the file `main.c`. Add this include:

```c
#include "ethfmc_axie.h"
```

Then find the line `start_application();` and add the following code just below it:

```c
	xil_printf("Ethernet Port 0:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_0_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 1:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_1_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 2:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_2_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 3:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_3_BASEADDR,mac_ethernet_address);
```

### License

Feel free to modify the code for your specific application.

### Fork and share

If you port this project to another hardware platform, please send me the
code or push it onto GitHub and send me the link so I can post it on my
website. The more people that benefit, the better.

### About the author

I'm an FPGA consultant and I provide FPGA design services to innovative
companies around the world. I believe in sharing knowledge and
I regularly contribute to the open source community.

Jeff Johnson
[FPGA Developer](http://www.fpgadeveloper.com "FPGA Developer")