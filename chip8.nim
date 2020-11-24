import strformat

type
        Chip8 = object
                opcode: int
                memory: array[0..4095, int]
                drawFlag: bool
                V: array[0..16, int8]
                I: int16
                pc: int16
                gfx: array[0..2047, int8]
                delay_timer: int8
                sound_timer: int8
                stack: array[0..16, int16]
                sp: int16
                key: array[0..16, int8]

var chip8_fontset: array[0..79, int8]
var bufferSize: int = 80
var buffer: array[0..79, int8]

for i in countup(0, 79):
        chip8_fontset[i] = 1
        buffer[i] = int8(i + 1)

var myChip8 = Chip8(drawFlag: false)

proc initialize(chip8: var Chip8): int =
        # Initialize registers and memory
        chip8.pc = 0x200
        chip8.opcode = 0
        chip8.I = 0
        chip8.sp = 0

        for i in countup(0, 79):
                chip8.memory[i + 0x50] = chip8_fontset[i]

        return 0

proc loadGame(chip8: var Chip8, title: string): int =
        for i in countup(0, bufferSize-1):
                chip8.memory[i + 0x200] = buffer[i]
        return 0

proc emulateCycle(chip8: var Chip8): int =

        chip8.memory[chip8.pc] = 0xA2
        chip8.memory[chip8.pc + 1] = 0xF0

        # Fetch Opcode
        chip8.opcode = (chip8.memory[chip8.pc] shl 8) or chip8.memory[chip8.pc + 1]
        echo fmt("Unknown opcode {chip8.opcode:#b}")

        # Decode Opcode
        case chip8.opcode and 0xF000
        of 0x0099:
                echo "Not implemented"
        else:
                echo fmt("Unknown opcode {chip8.opcode:#16b}")

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
