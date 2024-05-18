import numpy as np

### Constants ###
ROM_SIZE_BYTES = 1024 * 1024 # 1 MB
npUINT32_MAX = np.uint32(0xFFFF_FFFF)
DEFAULT_VALUE = npUINT32_MAX

class ROM:
    def __init__(self, data_to_load):
        self.memory = [npUINT32_MAX for i in range(int(ROM_SIZE_BYTES / 4))]

        for i, u32 in enumerate(data_to_load):
            if i > int(ROM_SIZE_BYTES / 4):
                break

            self.memory[i] = u32

    def read(self, address: np.uint32):
        # Only allow aligned addresses for now
        # Roll over addresses greater than ROM_SIZE_BYTES
        if address & 0b11 == 0:
            return self.memory[address & (int(ROM_SIZE_BYTES / 4) - 1)]

        # Return all 1s  if not aligned
        return np.uint32(0xFFFF_FFFF)