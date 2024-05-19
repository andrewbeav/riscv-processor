import numpy as np

### Constants ###
RAM_SIZE_BYTES = 1024 * 1024 # 1 MB
npUINT32_MAX = np.uint32(0xFFFF_FFFF)
DEFAULT_VALUE = npUINT32_MAX

class RAM:
    def __init__(self):
        self.memory = [DEFAULT_VALUE for i in range(int(RAM_SIZE_BYTES / 4))]

    def read(self, address):
        """
        Reads data from RAM at given address.

        :param address: Must be aligned for 32 bit values (i.e. divisible by 4).
                        Misaligned addresses will result in a garbage return.
                        Addresses greater than the RAM size will be rolled over.

        :returns: Data stored at address. 0xFFFF_FFFF for misaligned addresses
        """
        # Only allow aligned addresses for now
        # Roll over addresses greater than RAM_SIZE_BYTES
        if address & 0b11 == 0:
            return self.memory[(address & (RAM_SIZE_BYTES - 1)) >> 2]
        
        # Return default value if not aligned
        return DEFAULT_VALUE

    def write(self, address: int, data: np.uint32) -> bool:
        """
        Writes data to RAM at given address.

        :param address: must be aligned for 32 bit values (i.e. divisible by 4).
                        Addresses greater than the RAM size will be rolled over.
        :param data: data to write to RAM. Must be np.uint32 type

        :returns: True if write was successful, else False
        """
        # Only allow writes to aligned addresses for now
        # Roll over addresses greater than RAM_SIZE_BYTES
        if address & 0b11 == 0:
            self.memory[(address & (RAM_SIZE_BYTES - 1)) >> 2] = data
            return True

        return False