#!/usr/bin/python

import copy
import gc
import time
import serial
import random
import struct
import numpy as np
import scipy.io as spio
import datetime
import os
#import chacha_unprotected as chacha

en_oscilloscope = False
check_results = True

def write8(ser, addr, data):
   ser.write(chr( addr & ~0x80) + chr( data ))
   #ser.write()
   
def write32(ser, addr, data):
   ser.write(chr(addr) + chr(byte(data, 3)) +
             chr(addr-1) + chr(byte(data, 2)) +
             chr(addr-2) + chr(byte(data, 1)) +
             chr(addr-3) + chr(byte(data, 0)))
   
def read(ser, addr):
   ser.write(chr( addr | 0x80))
   return ord(ser.read()) 
   
def byte(val, index):
   return ((val>>(8*index)) & 0xff)

if en_oscilloscope == True :
    import Oscilloscope as lecroy

if __name__ == "__main__":

    traces = 2
    traces_per_file = 10
    samples_per_trace = 1250

    if en_oscilloscope == True:
        le = lecroy.Oscilloscope()
        le.connect()
        le.calibrate()
        le.displayOn()
        le.getParameters()
        samples_per_trace = le.Samples
        traces_per_file = le.NumberOfSequence/2
    
    print samples_per_trace
    
    ser = serial.Serial(
        port='COM54',
        baudrate=115200,
        xonxoff=0, 
        rtscts=0,
        bytesize=8, 
        parity='N', 
        stopbits=1)
        
    time.sleep(0.5)
        
    random.seed()    

    if en_oscilloscope == True:
        ts = time.time()
        st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d_%H_%M_%S')  
        
        if not os.path.exists("traces" + st):
            os.makedirs("traces" + st)
        os.chdir("traces" + st)
    
        if not os.path.exists("random"):
            os.makedirs("random")

        if not os.path.exists("fixed"):
            os.makedirs("fixed")

        time.sleep(0.5)

    ts1 = time.time()
    
    #fixed x and y
    fixed_x= int(random.randint(0,0xFFFFFFFF))
    fixed_y = int(random.randint(0,0xFFFFFFFF))
 
    
    for i in range(0,traces) : 
    
        # send random data
        random_x = int(random.randint(0,0xFFFFFFFF))
        x_1_random = int(random.randint(0,0xFFFFFFFF))
        x_2_random = int(random.randint(0,0xFFFFFFFF))
        x_3_random = (x_1_random ^ x_2_random ^ random_x) & 0xFFFFFFFF
        
        write32(ser, 31 , x_3_random)
        write32(ser, 23 , x_1_random)
        write32(ser, 19, x_2_random)
        
        # send random Y      
        random_y = int(random.randint(0,0xFFFFFFFF))
        y_1_random = int(random.randint(0,0xFFFFFFFF))
        y_2_random = int(random.randint(0,0xFFFFFFFF))
        y_3_random = y_1_random ^ y_2_random ^ random_y
        
        write32(ser, 27 , y_3_random)
        write32(ser, 15 , y_1_random)
        write32(ser, 11, y_2_random)
        
        z_random_1 = int(random.randint(0,0xFFFFFFFF))
        z_random_2 = int(random.randint(0,0xFFFFFFFF))
        
        write32(ser, 7 , z_random_1)
        write32(ser, 3 , z_random_2)
                        
        # arm trigger for random nonce
        if en_oscilloscope == True:
            if(i%traces_per_file == 0):
                le.trigger()
            
        write8(ser, 0x25, 1)
        
        if check_results == True:
            s = [0]*5

            for j in xrange(0,5):
                s[j] = read(ser, j)

            
            t = (s[ 0] <<  0) \
                 | (s[ 1] <<  8) \
                 | (s[ 2] << 16) \
                 | (s[ 3] << 24) \
                 | (s[ 4] << 32)

            print "random"
            print hex(random_x) + " + " + hex(random_y)
            print hex(t)
            print hex((random_x + random_y) & 0x1FFFFFFFF)
            

        x_1_random = int(random.randint(0,0xFFFFFFFF))
        x_2_random = int(random.randint(0,0xFFFFFFFF))
        x_3_random = (x_1_random ^ x_2_random ^ fixed_x) & 0xFFFFFFFF
        
        write32(ser, 31 , x_3_random)
        write32(ser, 23 , x_1_random)
        write32(ser, 19, x_2_random)
        
        # make two random number with fixed Y and send
        y_1_random = int(random.randint(0,0xFFFFFFFF))
        y_2_random = int(random.randint(0,0xFFFFFFFF))
        y_3_random = y_1_random ^ y_2_random ^ fixed_y
        
        write32(ser, 27 , y_3_random)
        write32(ser, 15 , y_1_random)
        write32(ser, 11, y_2_random)
        
        z_random_1 = int(random.randint(0,0xFFFFFFFF))
        z_random_2 = int(random.randint(0,0xFFFFFFFF))
        
        write32(ser, 7 , z_random_1)
        write32(ser, 3 , z_random_2)
            
      
        
        write8(ser, 0x25, 1)
        #time.sleep(0.001)
        
        if check_results == True:
            s = [0]*5

            for j in xrange(0,5):
                s[j] = read(ser, j)

            
            t = (s[ 0] <<  0) \
                 | (s[ 1] <<  8) \
                 | (s[ 2] << 16) \
                 | (s[ 3] << 24) \
                 | (s[ 4] << 32)

            print "fixed"
            print hex(fixed_x) + " + " + hex(fixed_y)
            print hex(t)
            print hex((fixed_x + fixed_y) & 0x1FFFFFFFF)
        
            
        # read data from oscilloscope
        # store data after a fixed number of captured traces
        if en_oscilloscope == True:
            if(i%traces_per_file == traces_per_file-1):
                seqtrace = le.getWaveform1()
                
                le.getParameters()
                
                print le.Samples

                
                print seqtrace.shape
                
                seqtrace = seqtrace[0:samples_per_trace*traces_per_file*2]
                
                
                tmp_traces = np.split(seqtrace,seqtrace.shape[0]/samples_per_trace)
                traces = tmp_traces[::2]
                traces_fixed = tmp_traces[1::2]

                os.chdir("random")
                spio.savemat("traces" + str(i+1), 
                             { 'traces': traces
                             },  
                             do_compression=True, 
                             oned_as='row')
                os.chdir("..")

                os.chdir("fixed")
                spio.savemat("traces" + str(i+1), 
                             { 'x': x,
                               'traces': traces_fixed
                              }, 
                             do_compression=True, 
                             oned_as='row')
                os.chdir("..")
            
        # output elapsed time after collecting 100 traces
        if(i%100 == 100-1):
            print("Elapsed time: " + str(time.time() - ts1) + " seconds")
            print("Collected traces: " + str(i+1))        

        totaltraces = i
    
    if en_oscilloscope == True:
        le.displayOn()
