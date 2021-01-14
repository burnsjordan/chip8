include chip8

# 1XXX Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x15
myChip8.memory[0x201] = 0x55
discard myChip8.emulateCycle()
if(myChip8.pc != 0x555):
    echo "1XXX Failed"

# 3XXX Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x3a
myChip8.memory[0x201] = 0x55
myChip8.V[0xa] = 0x00
discard myChip8.emulateCycle()
if(myChip8.pc != 0x200 + 2):
    echo "3XXX Failed 1"
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x3a
myChip8.memory[0x201] = 0x55
myChip8.V[0xa] = 0x55
discard myChip8.emulateCycle()
if(myChip8.pc != 0x200 + 4):
    echo "3XXX Failed 2"

# 4XXX Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x4a
myChip8.memory[0x201] = 0x55
myChip8.V[0xa] = 0x00
discard myChip8.emulateCycle()
if(myChip8.pc != 0x200 + 4):
    echo "4XXX Failed 1"
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x4a
myChip8.memory[0x201] = 0x55
myChip8.V[0xa] = 0x55
discard myChip8.emulateCycle()
if(myChip8.pc != 0x200 + 2):
    echo "4XXX Failed 2"

# 5XX0 Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x5a
myChip8.memory[0x201] = 0x55
myChip8.V[0xa] = 0x00
myChip8.V[0x5] = 0x55
discard myChip8.emulateCycle()
if(myChip8.pc != 0x200 + 2):
    echo "5XX0 Failed 1"
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x5a
myChip8.memory[0x201] = 0x55
myChip8.V[0xa] = 0x55
myChip8.V[0x5] = 0x55
discard myChip8.emulateCycle()
if(myChip8.pc != 0x200 + 4):
    echo "5XX0 Failed 2"

# 6XXX Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x6a
myChip8.memory[0x201] = 0x02
discard myChip8.emulateCycle()
if(myChip8.V[0xa] != 0x02):
    echo "6XXX Failed"

# 7XXX Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x7a
myChip8.memory[0x201] = 0x02
myChip8.V[0xa] = 0
discard myChip8.emulateCycle()
if(myChip8.V[0xa] != 0x02):
    echo "7XXX Failed"

# 8XY4 Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x82
myChip8.memory[0x201] = 0x34
myChip8.V[0x2] = 0
myChip8.V[0x3] = 0xFF
discard myChip8.emulateCycle()
if(myChip8.V[0xF] != 0x00):
    echo "8XY4 Failed 1"
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x82
myChip8.memory[0x201] = 0x34
myChip8.V[0x2] = 0x05
myChip8.V[0x3] = 0xFF
discard myChip8.emulateCycle()
if(myChip8.V[0xF] != 0x01):
    echo "8XY4 Failed 2"
if(myChip8.V[0x2] != 0x04):
    echo "8XY4 Failed 3"

# 8XY5 Check
discard myChip8.initialize()
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x82
myChip8.memory[0x201] = 0x35
myChip8.V[0x2] = 0xFF
myChip8.V[0x3] = 0x05
discard myChip8.emulateCycle()
if(myChip8.V[0xF] != 0x01):
    echo "8XY5 Failed 1"
myChip8.pc= 0x200
myChip8.memory[0x200] = 0x82
myChip8.memory[0x201] = 0x35
myChip8.V[0x2] = 0x05
myChip8.V[0x3] = 0xFF
discard myChip8.emulateCycle()
if(myChip8.V[0xF] != 0x00):
    echo "8XY5 Failed 2"
if(myChip8.V[0x2] != 0x06):
    echo "8XY5 Failed 3"

# AXXX Check
discard myChip8.initialize()
myChip8.pc = 0x200
myChip8.memory[0x200] = 0xa2
myChip8.memory[0x201] = 0xea
discard myChip8.emulateCycle()
if(myChip8.I != 0x2ea):
    echo "2XXX Failed"

# FX33 Check
discard myChip8.initialize()
myChip8.pc = 0x200
myChip8.memory[0x200] = 0xf2
myChip8.memory[0x201] = 0x33
myChip8.V[2] = 0x89
discard myChip8.emulateCycle()
if(myChip8.memory[myChip8.I] != 1):
    echo "FX33 Failed 1"
elif(myChip8.memory[myChip8.I + 1] != 3):
    echo "FX33 Failed 2"
elif(myChip8.memory[myChip8.I + 2] != 7):
    echo "FX33 Failed 3"

# FX55 Check
discard myChip8.initialize()
myChip8.pc = 0x200
myChip8.memory[0x200] = 0xf3
myChip8.memory[0x201] = 0x55
myChip8.V[0] = 0
myChip8.V[1] = 1
myChip8.V[2] = 2
myChip8.V[3] = 3
discard myChip8.emulateCycle()
if(myChip8.memory[myChip8.I] != 0):
    echo "FX55 Failed 1"
elif(myChip8.memory[myChip8.I + 1] != 1):
    echo "FX55 Failed 2"
elif(myChip8.memory[myChip8.I + 2] != 2):
    echo "FX55 Failed 3"
elif(myChip8.memory[myChip8.I + 3] != 3):
    echo "FX55 Failed 4"