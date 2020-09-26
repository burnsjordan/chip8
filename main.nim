include chip8


proc setupGraphics(): int =
        return 0

proc setupInput(): int = 
        return 0

proc drawGraphics(): int = 
        return 0

proc main(): int =
        discard setupGraphics()
        discard setupInput()

        discard myChip8.initialize()
        discard myChip8.loadGame("pong")

        for i in countup(1, 1):
                discard myChip8.emulateCycle()

                if myChip8.drawFlag:
                        discard drawGraphics()

                discard myChip8.setKeys()

        return 0

discard main()
