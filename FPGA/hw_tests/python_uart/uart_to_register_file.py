import serial

# constants
write_op_code = 0x20
read_op_code = 0x21
uart_ack = 0x6B

write_op_code_bytes = write_op_code.to_bytes()
read_op_code_bytes = read_op_code.to_bytes()
uart_ack_bytes = uart_ack.to_bytes()

class uart_to_register_file():
    def __init__(self, com_port, baud=50000, timeout=0.1):
        self.uart = serial.Serial(port=com_port, baudrate=baud, timeout=timeout)
        self.uart.readall()

    def close(self):
        self.uart.close()
    
    def write_to_register_file(self, address: int, data: int):
        """
        Write to particular address in register file
        :param address: Must be in range [0,31] - some addresses cannot be overwritten (see RISC-V spec)
        :param data: 32 bit integer to write
        """
        address_bytes = address.to_bytes()
        data_bytes_array = [((data >> i*8) & 0xFF).to_bytes() for i in range(4)]

        """ Write Op:
            Send:
                Byte 0: write_op_code
                Byte 1: Address to write
                Byte 2,3,4,5: Data to write to address
            Receive:
                uart_ack
        """
        self.uart.write(write_op_code_bytes)
        self.uart.write(address_bytes)
        for i in range(4):
            self.uart.write(data_bytes_array[i])
        # rx = self.uart.read()
        # if rx != uart_ack_bytes:
        #     print('did not receive write acknowledgement from FPGA. Data may not be written')

    def read_from_register_file(self, address: int):
        """
        Read from particular address in register file
        :param address: Must be in range [0,31]
        """
        address_bytes = address.to_bytes()

        """ Read Op:
            Send:
                Byte 0: read_op_code
                Byte 1: Address to read
            Receive:
                Bytes 0,1,2,3: Data at address (LSB first)
            Send:
                Ack
        """
        self.uart.write(read_op_code_bytes)
        self.uart.write(address_bytes)
        s = self.uart.readall()
        self.uart.write(uart_ack_bytes)

        return int.from_bytes(s, byteorder='little')
    
    def send_ack(self):
        """
        Send ack byte. May be useful if the FPGA is hung up because it's stuck in a read op
        """
        self.uart.write(uart_ack_bytes)