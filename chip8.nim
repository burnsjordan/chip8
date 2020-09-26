type
        Chip8 = object
                opcode: int16
                memory: array[0..4096, int8]
                drawFlag: bool
                V: array[0..16, int8]
                I: int16
                pc: int16
                gfx: array[0..2048, int8]
                delay_timer: int8
                sound_timer: int8
                stack: array[0..16, int16]
                sp: int16
                key: array[0..16, int8]

var chip8_fontset: array[0..80, int8]
var bufferSize: int = 80
var buffer: array[0..80, int8]

for i in countup(1, 80):
        chip8_fontset[i] = 1
        buffer[i] = 1

var myChip8 = Chip8(drawFlag: false)

proc initialize(chip8: var Chip8): int =
        # Initialize registers and memory
        chip8.pc = 0x200
        chip8.opcode = 0
        chip8.I = 0
        chip8.sp = 0

        for i in countup(1, 80):
                chip8.memory[i + 0x50] = chip8_fontset[i]

        return 0

proc loadGame(chip8: var Chip8, title: string): int =
        for i in countup(1, bufferSize):
                chip8.memory[i + 0x200] = buffer[i]
        return 0

proc emulateCycle(chip8: var Chip8): int =
        # Fetch Opcode
        chip8.opcode = chip8.memory[chip8.pc] shl (0xff and chip8.memory[chip8.pc + 1])

        # Decode Opcode

        # Execute Opcode

        # Update timers
        if chip8.delay_timer > 0:
                chip8.delay_timer = chip8.delay_timer - 1

        if chip8.sound_timer > 0:
                chip8.sound_timer = chip8.sound_timer - 1

        echo "Cycle"
        return 0

proc setKeys(chip8: var Chip8): int =
        echo "Keys"
        return 0
