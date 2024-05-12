# Classic 5 stage RISC pipeline
# Instruction Fetch -> Instruction Decode -> Execute -> Memory -> Writeback

# Idea is to create function for each stage

class RISCPipeline:
    def __init__(self):
        # self.program_memory = [0xFFFFFFFF for i in range(64e3)]
        self.program_memory = [i for i in range(64000)]
        self.program_counter = 0

        self.current_instr = 0xFFFFFFFF

    def instruction_fetch(self):
        self.current_instr = self.program_memory[self.program_counter]
        self.program_counter += 1

    def instruction_decode(self):
        pass

    def execute(self):
        pass

    def memory(self):
        pass

    def writeback(self):
        pass

    def clock(self):
        self.instruction_fetch()
        self.instruction_decode()
        self.execute()
        self.writeback()

cpu = RISCPipeline()
print("Start --------  Program Counter = {}, Current Instruction = {}".format(cpu.program_counter, cpu.current_instr))
for i in range(10):
    cpu.clock()
    print("After clock {} - Program Counter = {}, Current Instruction = {}".format(
        i, cpu.program_counter, cpu.current_instr
    ))
        