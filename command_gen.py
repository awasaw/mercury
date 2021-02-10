#!/usr/bin/env python3

# [ADDR+CMD+DATA+CRC16]
#addr = [0x00, 0x0B, 0x63, 0xC0] # possible

addr =746432 # the last 6 digit of the serial number
cmd = [0x32]
data =[0x01] # when empty just set []

########################################
#              It's a guess            #
#   naladchik="123456" #serial number  #
#   addr=4194304000+3+(8*naladchik)    #
#   print(addr)                        #
########################################

# ===============================================================
def CalCRC16(data, length):
    #print(data, length) #Print data, length
    crc=0xFFFF
    if length == 0:
       length = 1
    j = 0
    while length != 0:
        crc ^= list.__getitem__(data, j)
        #print('j=0x%02x, length=0x%02x, crc=0x%04x' %(j,length,crc))
        for i in range(0,8):
            if crc & 1:
                crc >>= 1
                crc ^= 0xA001
            else:
                crc >>= 1
        length -= 1
        j += 1
    return crc
# ===============================================================
def CRCBuffer(buffer):     
    crc_transformation = CalCRC16(buffer,len(buffer))    
    #crc_calculation = hex(crc_transformation)
    #print('crc_calculation:',crc_calculation)
    tasd = [0x00,0x00]
    tasd[0] = crc_transformation & 0xFF
    tasd[1] = (crc_transformation >> 8) & 0xFF
    H =hex(tasd[0])
    L =hex(tasd[1])
    H_value = int(H,16)
    L_value = int(L,16)
    buffer.append(H_value)
    buffer.append(L_value)
    return buffer
# ===============================================================
 
 
if __name__ == '__main__':
    if isinstance(addr, int):
        addr =  [(addr >> i & 0xff) for i in (24,16,8,0)]
    addr.extend(cmd)
    addr.extend(data)
    for i in CRCBuffer(addr):
        print("\\x", '{:02x}'.format(i).upper(), sep='', end='')
    print()