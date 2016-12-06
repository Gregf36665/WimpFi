from __future__ import print_function
#  Allow to work with 2.6

def LFSR(val):
    tmp = [0, 0, 0, 0, 0, 0];
    tmp[5] = val[0]
    tmp[4] = val[0] ^ val[5]
    tmp[3] = val[4]
    tmp[2] = val[3]
    tmp[1] = val[2]
    tmp[0] = val[1]
    return tmp

def toHex(val):
    out = 0
    for i in range(6):
        out |= val[i] << i
    return out

def main():
    val = 6*[1] # 0x3F bitwise
    for i in range(1999):
        for i in range(5000):
            print(toHex(val),end=" ") # Seperate by space
            val = LFSR(val)
        print() # newline
        

main()
