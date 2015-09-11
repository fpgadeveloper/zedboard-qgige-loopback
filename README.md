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

* Vivado 2015.2
* [Ethernet FMC](http://ethernetfmc.com "Ethernet FMC")
* [ZedBoard](http://zedboard.org "ZedBoard")
* PC with Gigabit Ethernet port
* [Xilinx Soft TEMAC license](http://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

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