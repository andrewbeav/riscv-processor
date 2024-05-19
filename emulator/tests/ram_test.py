import numpy as np

import sys
sys.path.insert(1, '../system_interface')
from ram import *

def ram_test0():
    ram = RAM()

    # Read from RAM and verify it is all 0xFFFF_FFFF (for both misaligned and aligned reads)
    # Read past range to verify it wraps around
    for i in range(2 * RAM_SIZE_BYTES):
        u32 = ram.read(i)
        # print("Result of read from RAM address 0x{:08X} = 0x{:08X}".format(i, u32))
        assert \
            u32 == npUINT32_MAX, \
            "RAM Read at address 0x{:08X} did not return 0xFFFF_FFFF".format(i)
    
    print("Ram Test 0 (Uninitialized ram returns all Fs) Complete")

def ram_test1():
    ram = RAM()

    # Write increasing numbers to RAM. Verify all valid calls are successful
    # Verify misaligned addresses results are not successful
    for i in range(RAM_SIZE_BYTES):
        b_write_successful = ram.write(i, np.uint32(i))
        # print("Write data 0x{:08X} to address 0x{:08X} was {}successful".format(
        #     i, np.uint32(i), '' if b_write_successful else 'not '
        # ))

        if i % 4 == 0:
            assert b_write_successful, \
                'write not successful for aligned address 0x{:08X}'.format(i)
        else:
            assert not b_write_successful, \
                'write successful for aligned address 0x{:08X}'.format(i)

    # Read the numbers back from RAM and verify
    for i in range(RAM_SIZE_BYTES):
        u32 = ram.read(i)
        # print("Result of read from address 0x{:08X} = 0x{:08X}".format(i, u32))
        if i % 4 == 0:
            assert u32 == i, \
                'Read from address 0x{:08X} = 0x{:08X}. Expected = 0x{:08}'.format(i, u32, i)
        else:
            assert u32 == npUINT32_MAX, \
                'Read from misaligned address 0x{:08X} = 0x{:08X}. Expected = 0x{:08X}'.format(
                    i, u32, npUINT32_MAX
                )

    print("RAM Test 1 (Write and read increasing values test) Complete")

def ram_test2():
    ram = RAM()

    # Write increasing numbers to RAM. Verify all valid calls are successful
    # Verify misaligned addresses results are not successful
    for i in range(RAM_SIZE_BYTES, 2*RAM_SIZE_BYTES):
        b_write_successful = ram.write(i, np.uint32(i))
        # print("Write data 0x{:08X} to address 0x{:08X} was {}successful".format(
        #     i, np.uint32(i), '' if b_write_successful else 'not '
        # ))

        if i % 4 == 0:
            assert b_write_successful, \
                'write not successful for aligned address 0x{:08X}'.format(i)
        else:
            assert not b_write_successful, \
                'write successful for aligned address 0x{:08X}'.format(i)

    # Read the numbers back from RAM and verify
    for i in range(RAM_SIZE_BYTES, 2*RAM_SIZE_BYTES):
        u32 = ram.read(i)
        # print("Result of read from address 0x{:08X} = 0x{:08X}".format(i, u32))
        if i % 4 == 0:
            assert u32 == i, \
                'Read from address 0x{:08X} = 0x{:08X}. Expected = 0x{:08}'.format(i, u32, i)
        else:
            assert u32 == npUINT32_MAX, \
                'Read from misaligned address 0x{:08X} = 0x{:08X}. Expected = 0x{:08X}'.format(
                    i, u32, npUINT32_MAX
                )

    print("RAM Test 2 (Write and read increasing values at rolled over addresses test) Complete")
    
if __name__ == '__main__':
    ram_test0()
    ram_test1()
    ram_test2()
