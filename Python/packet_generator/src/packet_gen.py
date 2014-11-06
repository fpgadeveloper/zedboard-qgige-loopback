'''
Copyright (C) 2014 Opsero Electronic Design Inc.

This code was designed for testing the Ethernet FMC 
(http://ethernetfmc.com). It will generate TCP packets
filled with PRBS data and wait for them to be returned
by the lwIP application running on the ZedBoard.
The received packets are compared with the sent
packets and any differences are counted as errors.

The program continues sending packets until either an
error is received or a timeout occurs.

To use this code, your machine's Ethernet port must be
configured with a fixed IP address of 192.168.1.x.

'''
import socket
import numpy
import time


if __name__ == "__main__":
    print('Start of program')
    TCP_IP = '192.168.1.10'
    TCP_PORT = 7
    BUFFER_SIZE = 1024
    WORDS_PER_PKT = 50
    
    # Open the socket
    s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.connect((TCP_IP,TCP_PORT))
    # Receive timeout set to 1 second
    s.settimeout(1)
    
    # Send packets until a timeout or an error occurs
    while True:
        # Add a delay in between packets to slow down
        # the rate of data being sent, if required
        time.sleep(0)
        # create a message from random numbers
        words = numpy.random.bytes(4 * WORDS_PER_PKT)
        msg = numpy.fromstring(words,dtype='uint32')
        # send the message
        s.send(msg)
        # wait for a response
        try:
            data = s.recv(BUFFER_SIZE)
        except socket.timeout:
            print('ERROR: Timeout occurred while waiting for reply')
            break
        buffer = numpy.fromstring(data,dtype='uint32')
        # verify the received data
        if not (msg == buffer).all():
            print('ERROR: Received message contained errors')
            print('       Sent    :', msg)
            print('       Received:', [hex(d) for d in buffer])
            break
    print('Program ended')
    s.close()
    
    
    