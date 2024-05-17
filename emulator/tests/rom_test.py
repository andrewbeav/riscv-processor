import numpy as np

import sys
sys.path.insert(1, '../system_interface')
from rom import *

def rom_test1():
    data_to_load = [np.uint32(0) for i in range(int(ROM_SIZE_BYTES / 4))]
    rom = ROM(data_to_load)

    for i in range(0, int(ROM_SIZE_BYTES / 4)):
        u32 = rom.read(i)
        if i % 4 == 0:
            assert \
                u32 == np.uint32(0), \
                "read at aligned address {} should be 0x0000_0000. Is actually 0x{:08X}".format(i, u32)
        else:
            assert \
                u32 == np.uint32(0xFFFF_FFFF), \
                "read at misaligned address {} should be 0xFFFF_FFFF. Is actually 0x{:08X}".format(
                    i, u32
                )
            assert rom.read(i) == np.uint32(0xFFFF_FFFF)

def rom_test2():
    data_to_load = [np.uint32(i) for i in range(int(ROM_SIZE_BYTES / 4))]
    rom = ROM(data_to_load)

    for i in range(0, int(ROM_SIZE_BYTES / 4)):
        u32 = rom.read(i)
        print('i = {}, read = 0x{:08X}, exp val = 0x{:08X}'.format(i, u32, data_to_load[i]))
        if i % 4 == 0:
            assert \
                u32 == data_to_load[i], \
                "read at aligned address {} should be 0x{:08X}. Is actually 0x{:08X}".format(
                    i, data_to_load[i], u32
                )
        else:
            assert \
                u32 == np.uint32(0xFFFF_FFFF), \
                "read at misaligned address {} should be 0xFFFF_FFFF. Is actually 0x{:08X}".format(
                    i, u32
                )
            assert rom.read(i) == np.uint32(0xFFFF_FFFF)
if __name__ == '__main__':
    rom_test1()
    rom_test2()
