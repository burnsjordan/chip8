import strformat
import streams
import random
import rdstdin

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

chip8_fontset = [uint8(0xF0), uint8(0x90), uint8(0x90), uint8(0x90), uint8(0xF0),
  uint8(0x20), uint8(0x60), uint8(0x20), uint8(0x20), uint8(0x70),
  uint8(0xF0), uint8(0x10), uint8(0xF0), uint8(0x80), uint8(0xF0),
  uint8(0xF0), uint8(0x10), uint8(0xF0), uint8(0x10), uint8(0xF0),
  uint8(0x90), uint8(0x90), uint8(0xF0), uint8(0x10), uint8(0x10),
  uint8(0xF0), uint8(0x80), uint8(0xF0), uint8(0x10), uint8(0xF0),
  uint8(0xF0), uint8(0x80), uint8(0xF0), uint8(0x90), uint8(0xF0),
  uint8(0xF0), uint8(0x10), uint8(0x20), uint8(0x40), uint8(0x40),
  uint8(0xF0), uint8(0x90), uint8(0xF0), uint8(0x90), uint8(0xF0),
  uint8(0xF0), uint8(0x90), uint8(0xF0), uint8(0x10), uint8(0xF0),
  uint8(0xF0), uint8(0x90), uint8(0xF0), uint8(0x90), uint8(0x90),
  uint8(0xE0), uint8(0x90), uint8(0xE0), uint8(0x90), uint8(0xE0),
  uint8(0xF0), uint8(0x80), uint8(0x80), uint8(0x80), uint8(0xF0),
  uint8(0xE0), uint8(0x90), uint8(0x90), uint8(0x90), uint8(0xE0),
  uint8(0xF0), uint8(0x80), uint8(0xF0), uint8(0x80), uint8(0xF0),
  uint8(0xF0), uint8(0x80), uint8(0xF0), uint8(0x80), uint8(0x80)]

randomize()

var myChip8 = Chip8(drawFlag: false)

proc initialize(chip8: var Chip8): int =
        # Initialize registers and memory
        chip8.pc = 0x200
        chip8.opcode = 0
        chip8.I = 0
        chip8.sp = 0

        # Some references say that the fontset should be stored starting at 0x50 == 80
        # But most roms seem to look starting at 0x00?
        for i in countup(0, 79):
                chip8.memory[i] = chip8_fontset[i]

        return 0

proc loadGame(chip8: var Chip8, title: string): int =
        var programStrm = newFileStream(title, fmRead)

        var i: int = 0
        while not programStrm.atEnd():
                chip8.memory[i + 0x200] = programStrm.readUint8()
                i += 1

        programStrm.close()
        return 0

proc emulateCycle(chip8: var Chip8): int =

        # Fetch Opcode
        chip8.opcode = (uint16(chip8.memory[chip8.pc]) shl 8) or chip8.memory[chip8.pc + 1]
        
        # Set draw flag to false so the screen isn't drawn when it doesn't need to
        chip8.drawFlag = false

        # Decode and Execute Opcode
        case chip8.opcode and 0xF000
        of 0x0000:
                case chip8.opcode and 0x00FF:
                of 0x00E0:
                        for i in countup(0, len(chip8.gfx)-1):
                                chip8.gfx[i] = 0
                        chip8.drawFlag = true
                        chip8.pc += 2
                of 0x00EE:
                        chip8.sp = chip8.sp - 1
                        chip8.pc = chip8.stack[chip8.sp]
                        chip8.pc += 2
                else:
                        echo fmt("Not implemented opcode: {chip8.opcode:#x}")
        of 0x1000:
                chip8.pc = chip8.opcode and 0x0FFF
        of 0x2000:
                chip8.stack[chip8.sp] = chip8.pc
                chip8.sp = chip8.sp + 1
                chip8.pc = chip8.opcode and 0x0FFF
        of 0x3000:
                if(chip8.V[(chip8.opcode and 0x0F00) shr 8] == uint8(chip8.opcode and 0x00FF)):
                        chip8.pc += 2
                chip8.pc += 2
        of 0x4000:
                if(chip8.V[(chip8.opcode and 0x0F00) shr 8] != uint8(chip8.opcode and 0x00FF)):
                        chip8.pc += 2
                chip8.pc += 2
        of 0x5000:
                if(chip8.V[(chip8.opcode and 0x0F00) shr 8] == chip8.V[(chip8.opcode and 0x00F0) shr 4]):
                        chip8.pc += 2
                chip8.pc += 2
        of 0x6000:
                chip8.V[(chip8.opcode and 0x0F00) shr 8] = uint8(chip8.opcode and 0x00FF)
                chip8.pc += 2
        of 0x7000:
                chip8.V[(chip8.opcode and 0x0F00) shr 8] += uint8(chip8.opcode and 0x00FF)
                chip8.pc += 2
        of 0x8000:
                case chip8.opcode and 0x000F
                of 0x0000:
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.V[(chip8.opcode and 0x00F0) shr 4]
                        chip8.pc += 2
                of 0x0001:
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.V[(chip8.opcode and 0x0F00) shr 8] or chip8.V[(chip8.opcode and 0x00F0) shr 4]
                        chip8.pc += 2
                of 0x0002:
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.V[(chip8.opcode and 0x0F00) shr 8] and chip8.V[(chip8.opcode and 0x00F0) shr 4]
                        chip8.pc += 2
                of 0x0003:
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.V[(chip8.opcode and 0x0F00) shr 8] xor chip8.V[(chip8.opcode and 0x00F0) shr 4]
                        chip8.pc += 2
                of 0x0004:
                        if(chip8.V[(chip8.opcode and 0x00F0) shr 4] > (uint8(0xFF) - chip8.V[(chip8.opcode and 0x0F00) shr 8])):
                                chip8.V[0xF] = 1
                        else:
                                chip8.V[0xF] = 0
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] += chip8.V[(chip8.opcode and 0x00F0) shr 4]
                        chip8.pc += 2
                of 0x0005:
                        if(chip8.V[(chip8.opcode and 0x00F0) shr 4] > chip8.V[(chip8.opcode and 0x0F00) shr 8]):
                                chip8.V[0xF] = 0
                        else:
                                chip8.V[0xF] = 1
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] -= chip8.V[(chip8.opcode and 0x00F0) shr 4]
                        chip8.pc += 2
                of 0x0006:
                        chip8.V[0xF] = chip8.V[(chip8.opcode and 0x0F00) shr 8] and 0x000F
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.V[(chip8.opcode and 0x0F00) shr 8] shr 1
                        chip8.pc += 2
                of 0x0007:
                        if(chip8.V[(chip8.opcode and 0x0F00) shr 8] > chip8.V[(chip8.opcode and 0x00F0) shr 4]):
                                chip8.V[0xF] = 0
                        else:
                                chip8.V[0xF] = 1
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.V[(chip8.opcode and 0x00F0) shr 4] - chip8.V[(chip8.opcode and 0x0F00) shr 8]
                        chip8.pc += 2
                of 0x000E:
                        chip8.V[0xF] = chip8.V[(chip8.opcode and 0x0F00) shr 8] shr 15
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.V[(chip8.opcode and 0x0F00) shr 8] shl 1
                        chip8.pc += 2
                else:
                        echo fmt("Unknown opcode {chip8.opcode:#x}")
        of 0x9000:
                if(chip8.V[(chip8.opcode and 0x0F00) shr 8] != chip8.V[(chip8.opcode and 0x00F0) shr 4]):
                        chip8.pc += 2
                chip8.pc += 2
        of 0xA000:
                chip8.I = chip8.opcode and 0x0FFF
                chip8.pc += 2
        of 0xB000:
                chip8.pc = (chip8.opcode and 0x0FFF) + chip8.V[0]
        of 0xC000:
                let r = rand(255)
                chip8.V[(chip8.opcode and 0x0F00) shr 8] = uint8(uint8(r) and uint8(chip8.opcode and 0x00FF))
                chip8.pc += 2
        of 0xD000:
                var x: uint16 = chip8.V[(chip8.opcode and 0x0F00) shr 8]
                var y: uint16 = chip8.V[(chip8.opcode and 0x00F0) shr 4]
                var height: uint16 = chip8.opcode and 0x00F
                var pixel: uint16

                var maxW: int = 7
                if(int(int(x) + maxW) > 63):
                        maxW = int(63 - x)

                var maxH: int = int(height - 1)
                if(int(int(y) + maxH) > 31):
                        maxH = int(31 - y)

                chip8.V[0xF] = 0
                for yline in countup(0, maxH):
                        pixel = chip8.memory[chip8.I + uint16(yline)]
                        for xline in countup(0, maxW):
                                if((pixel and uint16(0x80 shr xline)) != 0):
                                        if(chip8.gfx[(int(x) + xline + ((int(y) + yline) * 64))] == uint8(1)):
                                                chip8.V[0xF] = 1
                                        chip8.gfx[int(x) + xline + (int(y) + yline) * 64] = chip8.gfx[int(x) + xline + (int(y) + yline) * 64] xor 1

                chip8.drawFlag = true
                chip8.pc += 2
        of 0xE000:
                case chip8.opcode and 0x00FF:
                of 0x009E:
                        if(chip8.key[chip8.V[(chip8.opcode and 0x0F00) shr 8]] == uint8(0)):
                                chip8.pc += 2
                        chip8.pc += 2
                of 0x00A1:
                        if(chip8.key[chip8.V[(chip8.opcode and 0x0F00) shr 8]] != uint8(0)):
                                chip8.pc += 2
                        chip8.pc += 2
                else:
                        echo fmt("Unknown opcode {chip8.opcode:#x}")
        of 0xF000:
                case chip8.opcode and 0x00FF
                of 0x0007:
                        chip8.V[(chip8.opcode and 0x0F00) shr 8] = chip8.delay_timer
                        chip8.pc += 2
                of 0x000A:
                        block keyLoop:
                                for i in countup(0, len(myChip8.key)-1):
                                        if(chip8.key[i] == 1):
                                                chip8.V[(chip8.opcode and 0x0F00) shr 8] = uint8(i)
                                                chip8.pc += 2
                                                break
                                        
                of 0x0015:
                        chip8.delay_timer = chip8.V[(chip8.opcode and 0x0F00) shr 8]
                        chip8.pc += 2
                of 0x0018:
                        chip8.sound_timer = chip8.V[(chip8.opcode and 0x0F00) shr 8]
                        chip8.pc += 2
                of 0x001E:
                        chip8.I += chip8.V[(chip8.opcode and 0x0F00) shr 8]
                        chip8.pc += 2
                of 0x0029:
                        chip8.I = chip8.V[(chip8.opcode and 0x0F00) shr 8] * 5
                        chip8.pc += 2
                of 0x0033:
                        chip8.memory[chip8.I] = uint8(int(chip8.V[(chip8.opcode and 0x0F00) shr 8]) / 100)
                        chip8.memory[chip8.I + 1] = uint8(int(int(chip8.V[(chip8.opcode and 0x0F00) shr 8]) / 10) mod 10)
                        chip8.memory[chip8.I + 2] = uint8((int(chip8.V[(chip8.opcode and 0x0F00) shr 8]) mod 100) mod 10)
                        chip8.pc += 2
                of 0x0055:
                        var i: int = int((chip8.opcode and 0x0F00) shr 8)
                        for j in countup(0, i):
                                chip8.memory[chip8.I + uint16(j)] = chip8.V[uint8(j)]
                        chip8.pc += 2
                of 0x0065:
                        var i: int = int((chip8.opcode and 0x0F00) shr 8)
                        for j in countup(0, i):
                                chip8.V[uint8(j)] = chip8.memory[chip8.I + uint16(j)]
                        chip8.pc += 2
                else:
                        echo fmt("Unknown opcode {chip8.opcode:#x}")
        else:
                echo fmt("Unknown opcode {chip8.opcode:#x}")
        # echo fmt("Opcode: {chip8.opcode:#x}")


        # Update timers
        if chip8.delay_timer > uint8(0):
                chip8.delay_timer = chip8.delay_timer - 1

        if chip8.sound_timer > uint8(0):
                chip8.sound_timer = chip8.sound_timer - 1

        return 0

proc setKeys(chip8: var Chip8): int =
        return 0
