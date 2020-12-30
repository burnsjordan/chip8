include chip8
import nimgl/[glfw, opengl]


proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.ESCAPE and action == GLFWPress:
    window.setWindowShouldClose(true)

proc setupGraphics(): int =
        assert glfwInit()

        glfwWindowHint(GLFWContextVersionMajor, 3)
        glfwWindowHint(GLFWContextVersionMinor, 3)
        glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
        glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
        glfwWindowHint(GLFWResizable, GLFW_FALSE)

        let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
        if w == nil:
                quit(-1)

        discard w.setKeyCallback(keyProc)
        w.makeContextCurrent()

        assert glInit()

        while not w.windowShouldClose:
                glfwPollEvents()
                glClearColor(0.68f, 1f, 0.34f, 1f)
                glClear(GL_COLOR_BUFFER_BIT)
                w.swapBuffers()

        w.destroyWindow()
        glfwTerminate()
        return 0

proc setupInput(): int = 
        return 0

proc drawGraphics(): int = 
        echo "\e[2J"
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

        var gameRunning: bool = true
        while gameRunning:
                if(myChip8.emulateCycle() != 0):
                        gameRunning = false

                if myChip8.drawFlag:
                        discard drawGraphics()

                discard myChip8.setKeys()

        return 0

discard main()
