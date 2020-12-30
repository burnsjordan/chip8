include chip8
import nimgl/[glfw, opengl]


proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.ESCAPE and action == GLFWPress:
    window.setWindowShouldClose(true)

proc setupGraphics(): int =
        return 0

proc setupInput(): int = 
        return 0

proc drawGraphics(w: GLFWWindow): int = 
        
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

        assert glfwInit()

        glfwWindowHint(GLFWContextVersionMajor, 3)
        glfwWindowHint(GLFWContextVersionMinor, 3)
        glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
        glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
        glfwWindowHint(GLFWResizable, GLFW_FALSE)

        let w: GLFWWindow = glfwCreateWindow(256, 128, "Chip-8 Emulator")
        if w == nil:
                quit(-1)

        discard w.setKeyCallback(keyProc)
        w.makeContextCurrent()

        assert glInit()
        discard myChip8.initialize()
        discard myChip8.loadGame("Pong.ch8")

        var gameRunning: bool = true
        while not w.windowShouldClose and gameRunning:
                glfwPollEvents()
                glClearColor(0f, 0f, 0f, 0f)
                glClear(GL_COLOR_BUFFER_BIT)
                glMatrixMode( GL_PROJECTION )
                glLoadIdentity()
                # gluOrtho2D( 0.0, 500.0, 500.0,0.0 )

                glBegin(GL_POINTS)
                glColor3f(1,1,1)
                glVertex2i(100,100)
                glEnd()
                w.swapBuffers()
                if(myChip8.emulateCycle() != 0):
                        gameRunning = false

                if myChip8.drawFlag:
                        discard drawGraphics(w)

                discard myChip8.setKeys()

        w.destroyWindow()
        glfwTerminate()

        return 0

discard main()
