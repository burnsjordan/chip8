import strformat
import streams

type
        Chip8 = object
                opcode: uint16
                memory: array[0..4095, uint8]
                drawFlag: bool
                V: array[0..16, uint8]
                I: uint16
                pc: uint16
                gfx: array[0..2047, uint8]
                delay_timer: uint8
                sound_timer: uint8
                stack: array[0..16, uint16]
                sp: uint16
                key: array[0..16, uint8]

var chip8_fontset: array[0..79, uint8]

for i in countup(0, 79):
        chip8_fontset[i] = 1

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
        var programStrm = newFileStream("tetris.c8", fmRead)

        var i: int = 0
        while not programStrm.atEnd():
                chip8.memory[i + 0x200] = programStrm.readUint8()
                i += 1

        programStrm.close()
        return 0

proc emulateCycle(chip8: var Chip8): int =

        # Fetch Opcode
        chip8.opcode = (uint16(chip8.memory[chip8.pc]) shl 8) or chip8.memory[chip8.pc + 1]

        # Decode and Execute Opcode
        case chip8.opcode and 0xF000
        of 0x2000:
                chip8.stack[chip8.sp] = chip8.pc
                chip8.sp = chip8.sp + 1
                chip8.pc = chip8.opcode and 0x0FFF
        of 0x8000:
                case chip8.opcode and 0x000F
                of 0x0004:
                        if(chip8.V[(chip8.opcode and 0x00F0) shr 4] > (uint8(0xFF) - chip8.V[(chip8.opcode and 0x0F00) shr 8])):
                                chip8.V[0xF] = 1
                        else:
                                chip8.V[0xF] = 0
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] += chip8.V[(chip8.opcode and 0x00F0) shr 4]
                        chip8.pc += 2
                        echo fmt("Opcode needs testing: {chip8.opcode:#x}")
                else:
                        echo fmt("Unknown opcode {chip8.opcode:#x}")
        of 0xA000:
                chip8.I = chip8.opcode and 0x0FFF
                chip8.pc += 2
                echo fmt("Opcode needs testing: {chip8.opcode:#x}")
        of 0xD000:
                var x: uint16 = chip8.V[(chip8.opcode and 0x0F00) shr 8]
                var y: uint16 = chip8.V[(chip8.opcode and 0x00F0) shr 4]
                var height: uint16 = chip8.opcode and 0x00F
                var pixel: uint16

                chip8.V[0xF] = 0
                for yline in countup(0, int(height)):
                        pixel = chip8.memory[chip8.I + uint16(yline)]
                        for xline in countup(0, 7):
                                if((pixel and uint16(0x80 shr xline)) != 0):
                                        if(chip8.gfx[(int(x) + xline + ((int(y) + yline) * 64))] == uint8(1)):
                                                chip8.V[0xF] = 1
                                        chip8.gfx[int(x) + xline + (int(y) + yline) * 64] = chip8.gfx[int(x) + xline + (int(y) + yline) * 64] xor 1

                chip8.drawFlag = true
                chip8.pc += 2
                echo fmt("Opcode needs testing: {chip8.opcode:#x}")
        of 0xF000:
                case chip8.opcode and 0x00FF
                of 0x0033:
                        chip8.memory[chip8.I] = uint8(int(chip8.V[(chip8.opcode and 0x0F00) shr 8]) / 100)
                        chip8.memory[chip8.I + 1] = uint8(int(int(chip8.V[(chip8.opcode and 0x0F00) shr 8]) / 10) mod 10)
                        chip8.memory[chip8.I + 2] = uint8((int(chip8.V[(chip8.opcode and 0x0F00) shr 8]) mod 100) mod 10)
                        chip8.pc += 2
                        echo fmt("Opcode needs testing: {chip8.opcode:#x}")
                else:
                        echo fmt("Unknown opcode {chip8.opcode:#x}")
        else:
                echo fmt("Unknown opcode {chip8.opcode:#x}")


        # Update timers
        if chip8.delay_timer > uint8(0):
                chip8.delay_timer = chip8.delay_timer - 1

        if chip8.sound_timer > uint8(0):
                chip8.sound_timer = chip8.sound_timer - 1

        echo "Cycle"
        return 0

proc setKeys(chip8: var Chip8): int =
        echo "Keys"
        return 0
