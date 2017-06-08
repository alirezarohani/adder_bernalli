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

def write(ser, data, addr):
   ser.write(chr( addr & ~0x80) + chr( data ))
   #ser.write()
   
def read(ser, addr):
   ser.write(chr( addr | 0x80))
   return ord(ser.read()) 
   
def byte(val, index):
   return ((val>>(8*index)) & 0xff)

if en_oscilloscope == True :
    import Oscilloscope as lecroy

if __name__ == "__main__":

    traces = 100000
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
        port='COM47',
        baudrate=115200,
        xonxoff=0, 
        rtscts=0,
        bytesize=8, 
        parity='N', 
        stopbits=1)
        
    time.sleep(0.5)
        
    random.seed()    

    # this is the key to attack
    # key = [3399450456,
           # 589472988, 
           # 1817683584, 
           # 1980599320, 
           # 506370484,
           # 3770618530, 
           # 2494332794, 
           # 1040266887]
           
    # constant = [0x61707865,
                # 0x3320646e,
                # 0x79622d32,
                # 0x6b206574]
           
    # cipher = chacha.ChaCha(key)

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
    
    if en_oscilloscope == True:
        y_inputs = np.empty((traces_per_file, 1), np.uint32)
        y_input_fixed = np.empty((traces_per_file, 1), np.uint32)
        
    s_results = np.zeros((traces_per_file, 1), np.uint32)
    s_results_fixed = np.zeros((traces_per_file, 1), np.uint32)
    totaltraces = 0
    #Inputs x and y
    # all the shares are produced by this python script
    x = np.empty((1), np.uint32)
    tvla_y = np.empty((1), np.uint32)
    y = np.empty((1), np.uint32)
    
    #fixed x and y
    x= int(random.randint(0,0xFFFFFFFF))
    tvla_y = int(random.randint(0,0xFFFFFFFF))
    
    # four random numbers to be sent only once
    x_1_random = np.empty((1), np.uint32)
    x_2_random = np.empty((1), np.uint32)
    y_1_random = np.empty((1), np.uint32)
    y_2_random = np.empty((1), np.uint32)
    z_random = np.empty((1), np.uint32)
    
    # x_1_random = int(random.randint(0,0xFFFFFFFF))
    # x_2_random = int(random.randint(0,0xFFFFFFFF))
    # y_1_random = int(random.randint(0,0xFFFFFFFF))
    # y_2_random = int(random.randint(0,0xFFFFFFFF))
    # z_random = int(random.randint(0,0xFFFFFFFF))
    
    #state = [0]*16

       
    # send key
    # for j in xrange(0,8):
        # for k in xrange(0,4):
            # write(ser, byte(key[j], 3-k), 63-(j*4+k+16))
    
    for i in range(0,traces) : 
    
        # send three shares of x (x always fixed)
        x_1_random = int(random.randint(0,0xFFFFFFFF))
        x_2_random = int(random.randint(0,0xFFFFFFFF))
        x_3_random = (x_1_random ^ x_2_random ^ x) & 0xFFFFFFFF
        for k in xrange(0,4):
            write(ser, byte(x_3_random, 3-k), 27-(k))
        for k in xrange(0,4):
            write(ser, byte(x_1_random, 3-k), 27-(k+8))
        for k in xrange(0,4):
            write(ser, byte(x_2_random, 3-k), 27-(k+12))
        
        # send three shares of y (y always varies)      
        y = int(random.randint(0,0xFFFFFFFF))
        y_1_random = int(random.randint(0,0xFFFFFFFF))
        y_2_random = int(random.randint(0,0xFFFFFFFF))
        y_3_random = y_1_random ^ y_2_random ^ y
        for k in xrange(0,4):
            write(ser, byte(y_3_random, 3-k), 27-(k+4))
        for k in xrange(0,4):
            write(ser, byte(y_1_random, 3-k), 27-(k+16))
        for k in xrange(0,4):
            write(ser, byte(y_2_random, 3-k), 27-(k+20))
        
            # send z random number
        z_random = int(random.randint(0,0xFFFFFFFF))
        for k in xrange(0,4):
            write(ser, byte(z_random, 3-k), 27-(k+24))
    
        # save y
        if en_oscilloscope == True:
            y_inputs[i%traces_per_file] = y
                        
        # arm trigger for random nonce
        if en_oscilloscope == True:
            if(i%traces_per_file == 0):
                le.trigger()
        
        # send constants
        #for j in xrange(0,4):
        #    for k in xrange(0,4):
        #        write(ser, byte(constant[j], 3-k), 63-(j*4+k))
                
        # send key
        #for j in xrange(0,8):
        #    for k in xrange(0,4):
        #        write(ser, byte(key[j], 3-k), 63-(j*4+k+16))
            
       
        write(ser, 1, 0x21)
               
        s_results[i%traces_per_file] = (x + y) & 0xFFFFFFFF

        # retrieve result -- disabled for performance optimization
        #keystream_debug = [0]*16
        #for j in xrange(0,16):
        #
        #    for k in xrange(0,4):
        #        keystream_debug[j] |= read(ser, 63-(j*4+k)) << (3-k)*8
        #        
        #    if(keystream[i%traces_per_file, j] != keystream_debug[j]):
        #        print i
        #        print "FPGA: " + hex(keystream_debug[j])
        #        print "SIM:  " + hex(keystream[i%traces_per_file, j])
       
       
        # save y
        if en_oscilloscope == True:
            y_input_fixed[i%traces_per_file] = tvla_y
       
        # send constants
        #for j in xrange(0,4):
        #    for k in xrange(0,4):
        #        write(ser, byte(constant[j], k), j*4+k)
        
        # send key
        #for j in xrange(0,8):
        #    for k in xrange(0,4):
        #        write(ser, byte(key[j], k), j*4+k+16)
        
        #send x again (x is always fixed but the random shares change)
        x_1_random = int(random.randint(0,0xFFFFFFFF))
        x_2_random = int(random.randint(0,0xFFFFFFFF))
        x_3_random = (x_1_random ^ x_2_random ^ x) & 0xFFFFFFFF
        for k in xrange(0,4):
            write(ser, byte(x_3_random, 3-k), 27-(k))
        for k in xrange(0,4):
            write(ser, byte(x_1_random, 3-k), 27-(k+8))
        for k in xrange(0,4):
            write(ser, byte(x_2_random, 3-k), 27-(k+12))
        
        # make two random number with fixed Y and send
        y_1_random = int(random.randint(0,0xFFFFFFFF))
        y_2_random = int(random.randint(0,0xFFFFFFFF))
        y_3_random = y_1_random ^ y_2_random ^ tvla_y
        for k in xrange(0,4):
            write(ser, byte(y_3_random, 3-k), 27-(k+4))
        for k in xrange(0,4):
            write(ser, byte(y_1_random, 3-k), 27-(k+16))
        for k in xrange(0,4):
            write(ser, byte(y_2_random, 3-k), 27-(k+20))    
        
        # make a random Z and send
        z_random = int(random.randint(0,0xFFFFFFFF))
        for k in xrange(0,4):
            write(ser, byte(z_random, 3-k), 27-(k+24))
        
        
        write(ser, 1, 0x21)
        #time.sleep(0.001)
        
        # retrieve result -- disabled for performance optimization
        #if en_oscilloscope == True:
        #for j in xrange(0,16):
        #    keystream[i%traces_per_file, j] = 0
        #            
        #    for k in xrange(0,4):
        #        keystream[i%traces_per_file, j] |= read(ser, j*4+k) << k*8
        
        s_results_fixed[i%traces_per_file] = (x + tvla_y) & 0xFFFFFFFF
            
        # read data from oscilloscope
        # store data after a fixed number of captured traces
        if en_oscilloscope == True:
            if(i%traces_per_file == traces_per_file-1):
                seqtrace = le.getWaveform1()
                seqtrace_t = le.getWaveform4()
                
                le.getParameters()
                
                print le.Samples

                
                print seqtrace.shape
                
                seqtrace = seqtrace[0:samples_per_trace*traces_per_file*2]
                seqtrace_t = seqtrace_t[0:samples_per_trace*traces_per_file*2]
                
                
                tmp_traces = np.split(seqtrace,seqtrace.shape[0]/samples_per_trace)
                traces = tmp_traces[::2]
                traces_fixed = tmp_traces[1::2]
                
                tmp_traces_t = np.split(seqtrace_t,seqtrace_t.shape[0]/samples_per_trace)
                traces_t_random = tmp_traces_t[::2]
                traces_t_fixed = tmp_traces_t[1::2]

                os.chdir("random")
                spio.savemat("traces" + str(i+1), 
                             { 'x': x,
                               'traces': traces,
                               'triger': traces_t_random,
                               'y': y_inputs,
                               's' : s_results },  
                             do_compression=True, 
                             oned_as='row')
                os.chdir("..")

                os.chdir("fixed")
                spio.savemat("traces" + str(i+1), 
                             { 'x': x,
                               'traces': traces_fixed,
                               'triger' : traces_t_fixed,
                               'y': y_input_fixed,
                               's' : s_results_fixed }, 
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
