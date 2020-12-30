include chip8


proc setupGraphics(): int =
        return 0

proc setupInput(): int = 
        return 0

proc drawGraphics(): int = 
        var line: string = ""   
        for i in countup(0, 31):
                line = ""
                for j in countup(0, 63):
                        if(myChip8.gfx[(64*i)+j] == 0):
                                line.add(" ")
                        else:
                                line.add("*")
                echo line
        return 0

proc main(): int =
        discard setupGraphics()
        discard setupInput()

        discard myChip8.initialize()
        discard myChip8.loadGame("pong")

        for i in countup(1, 1):
                discard myChip8.emulateCycle()

                if myChip8.drawFlag or true:
                        discard drawGraphics()

                discard myChip8.setKeys()

        return 0

discard main()
