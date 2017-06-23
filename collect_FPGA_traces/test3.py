#!/usr/bin/env python
import random
import serial
import time
import numpy as np
import scipy.io as sp

ser = serial.Serial('COM54',115200,xonxoff=0, rtscts=0,bytesize=8, parity='N', stopbits=1)


#ser = serial.Serial('/dev/ttyS0',115200,xonxoff=0, rtscts=0,bytesize=8, parity='N', stopbits=1)
#ser.isOpen()
# ser.isOpen() pour tester s'il est vraiment ouvert

# register mapping
import regs

def write (data, addr):
   ser.write(chr( addr & ~0x80))
   ser.write(chr( data ))

def read (addr):
   ser.write(chr( addr | 0x80))
   return ord(ser.read()) 

def byte (val, index):
   return ((val>>(8*index)) & 0xff)



def encrypt(data_in, trace_number,sum):
    
    
    write(byte(data_in , 0), regs.REG_INPUT_00)
    write(byte(data_in , 1), regs.REG_INPUT_01)
    write(byte(data_in , 2), regs.REG_INPUT_02)
    write(byte(data_in , 3), regs.REG_INPUT_03)
    write(byte(data_in , 4), regs.REG_INPUT_04)
    write(byte(data_in , 5), regs.REG_INPUT_05)
    write(byte(data_in , 6), regs.REG_INPUT_06)
    write(byte(data_in , 7), regs.REG_INPUT_07)
    write(byte(data_in , 8), regs.REG_INPUT_08)
    write(byte(data_in , 9), regs.REG_INPUT_09)
    write(byte(data_in , 10), regs.REG_INPUT_10)
    write(byte(data_in , 11), regs.REG_INPUT_11)
    write(byte(data_in , 12), regs.REG_INPUT_12)
    write(byte(data_in , 12), regs.REG_INPUT_12)
    write(byte(data_in , 13), regs.REG_INPUT_13)
    write(byte(data_in , 14), regs.REG_INPUT_14)
    write(byte(data_in , 15), regs.REG_INPUT_15)
    write(byte(data_in , 16), regs.REG_INPUT_16)
    write(byte(data_in , 17), regs.REG_INPUT_17)
    write(byte(data_in , 18), regs.REG_INPUT_18)
    write(byte(data_in , 19), regs.REG_INPUT_19)
    write(byte(data_in , 20), regs.REG_INPUT_20)
    write(byte(data_in , 21), regs.REG_INPUT_21)
    write(byte(data_in , 22), regs.REG_INPUT_22)
    write(byte(data_in , 23), regs.REG_INPUT_23)
    write(byte(data_in , 24), regs.REG_INPUT_24)
    write(byte(data_in , 25), regs.REG_INPUT_25)
    write(byte(data_in , 26), regs.REG_INPUT_26)
    write(byte(data_in , 27), regs.REG_INPUT_27)
    write(byte(data_in , 28), regs.REG_INPUT_28)
    write(byte(data_in , 29), regs.REG_INPUT_29)
    write(byte(data_in , 30), regs.REG_INPUT_30)
    write(byte(data_in , 31), regs.REG_INPUT_31)
    
    
    write(1 , regs.REG_START)
    # time.sleep(5)
    
    data_out = read(regs.REG_OUTPUT_00)
    data_out = read(regs.REG_OUTPUT_01) << 8| data_out
    data_out = read(regs.REG_OUTPUT_02) << 16| data_out
    data_out = read(regs.REG_OUTPUT_03) << 24| data_out
    data_out = read(regs.REG_OUTPUT_04) << 32| data_out

    
    
    print "data_in -->" + hex(data_in) + "->>" + hex(data_out)
    #print hex(sum)
    if data_out==sum:
        print "OK"
    else:
        print "OoOpS!"
    # cypher = int(T_keystream[m,0]) << 480 | int(T_keystream[m,1]) << 448 | int(T_keystream[m,2]) << 416 | int(T_keystream[m,3]) << 384 | int(T_keystream[m,4]) << 352 | int(T_keystream[m,5]) << 320 | int(T_keystream[m,6]) << 288 | int(T_keystream[m,7]) << 256 | int(T_keystream[m,8]) << 224 | int(T_keystream[m,9]) << 192 | int(T_keystream[m,10]) << 160 | int(T_keystream[m,11]) << 128 | int(T_keystream[m,12]) << 96 | int(T_keystream[m,13]) << 64 | int(T_keystream[m,14]) << 32 | int(T_keystream[m,15])
    # if hex(data_out) == hex(cypher):
        # print "encryption %s is OK" % str(m)
    # else:
        # print "encryption %s is faulty" % str(m)


##########################################################################
numberOfTraces = 100
#T_main = sp.loadmat('C:\\alireza\\simple_uart_chacha_v3\\soft\\measured_traces\\traces1250')
##########################################################################

#T_nounces = T_main['nonces']
#T_keystream = T_main['keystreams']


for m in range(0,numberOfTraces):
    data_in = int(random.randint(0,0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
    #print hex(data_in  >> 192)
    #print hex(data_in >> 160 & 0xFFFFFFFF )
    x= (data_in  >> 224 & 0xFFFFFFFF) ^ (data_in  >> 160 & 0xFFFFFFFF) ^ (data_in  >> 128 & 0xFFFFFFFF)
    y= (data_in  >> 192 & 0xFFFFFFFF) ^ (data_in  >> 96 & 0xFFFFFFFF) ^ (data_in  >> 64 & 0xFFFFFFFF)
    print "x:" + hex(x)
    print "y:" + hex(y)
    results = x + y
    print "results:" + hex(results)
    
    #data_in = (cons<< 384) | (key<<128) | nonce
    encrypt(data_in, m,results)
    
#ser.close()
# key=0x03020100070605040b0a09080f0e0d0c13121110171615141b1a19181f1e1d1c
# cons=0x617078653320646e79622d326b206574
# nonce1=0x090000004a00000000000000
# ctr=0x00000001
# nonce=gen_hex_code()
# data_in = (cons<< 384) | (key<<128) | (ctr<<96) | nonce1
# encrypt(data_in)
