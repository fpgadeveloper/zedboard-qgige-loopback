zedboard-qgige-loopback
=======================

Loopback design for the Ethernet FMC on the ZedBoard using AXI Ethernet

### Description

This project is used for testing the Ethernet FMC (ethernetfmc.com).
The design contains 4 AXI Ethernet blocks in a loopback configuration
such that port 0 loops back to port 1, and port 2 loops back to port 3.
The software application uses lwIP on the ZedBoard Ethernet port.

To test the Ethernet FMC using this project, you will need a PC with one
Gigabit Ethernet port. You must connect the PC to port 0 of the Ethernet
FMC. You must connect Ethernet FMC ports 1 and 2 with an Ethernet cable.
You must connect Ethernet FMC port 3 to ZedBoard Ethernet port with
an Ethernet cable. Using the Python application in this project, you can
send Ethernet packets from the PC which will be passed through all the
ports on the Ethernet FMC, and then go to the ZedBoard Ethernet port.
From the ZedBoard Ethernet port they will be looped back by the lwIP
application and be sent again through the ports of the Ethernet FMC and
back to the PC.

### Requirements

* Vivado 2014.2
* ZedBoard
* PC with Gigabit Ethernet port

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
http://www.fpgadeveloper.com