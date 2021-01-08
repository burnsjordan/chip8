include chip8
import nimgl/[glfw, opengl]


proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.ESCAPE and action == GLFWPress:
    window.setWindowShouldClose(true)

proc setupGraphics(): int =
        var VBO: GLuint
        var VAO: GLuint
        glGenBuffers(1, addr VBO)
        glGenVertexArrays(GLsizei(1), addr VAO)
        glBindBuffer(GL_ARRAY_BUFFER, VBO)
        glBindVertexArray(VAO)
        var vertices: array[0..8, float]
        vertices = [-0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.0, 0.5, 0.0]
        glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(sizeof(vertices)), addr vertices, GL_STATIC_DRAW)
        glVertexAttribPointer(GLuint(0), GLint(3), EGL_FLOAT, GLboolean(false), GLsizei(3 * sizeof(GLfloat)), nil)
        glEnableVertexAttribArray(0)

        # Create Vertex Shader
        var vertexShaderSource: cstring = "#version 330 core\nlayout (location = 0) in vec3 aPos;\nvoid main()\n{\n   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n}\0"
        var vertexShader: GLuint
        vertexShader = glCreateShader(GL_VERTEX_SHADER)
        glShaderSource(vertexShader, GLsizei(1), addr vertexShaderSource, nil)
        glCompileShader(vertexShader)
        var success: GLint
        var infoLog: array[512, cstring]

        # Check that compilation works
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, addr success)
        # if success == 0:
        #         glGetShaderInfoLog(vertexShader, GLsizei(512), infoLog)
        #         echo "Vertex Shader Compilation Failure"
        #         echo infoLog

        # Create Fragment Shader
        var fragmentShaderSource: cstring = "#version 330 core\nout vec4 FragColor;\nvoid main()\n{\nFragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n}\n\0"
        var fragmentShader: GLuint
        fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
        glShaderSource(fragmentShader, GLsizei(1), addr fragmentShaderSource, nil)
        glCompileShader(fragmentShader)

        # Check that compilation works
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, addr success)
        # if success == 0:
        #         glGetShaderInfoLog(fragmentShader, GLsizei(512), infoLog)
        #         echo "Fragment Shader Compilation Failure"
        #         echo infoLog

        # Create the shader program
        var shaderProgram: GLuint
        shaderProgram = glCreateProgram()
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragmentShader)
        glLinkProgram(shaderProgram)

        # Check if program linking works
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, addr success)
        # if success == 0:
        #         glGetProgramInfoLog(shaderProgram, GLsizei(512), infoLog)
        #         echo "Shader Program Linking Failure"
        #         echo infoLog

        glUseProgram(shaderProgram)
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)

        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);

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

proc processInput(w: GLFWWindow): int =
        if(getKey(w, GLFWKey.Escape) == GLFW_PRESS):
                setWindowShouldClose(w, true)
        return 0

proc main(): int =

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
        glViewport(0, 0, 256, 128)

        assert glfwInit()
        discard myChip8.initialize()
        discard myChip8.loadGame("Pong.ch8")
        discard setupGraphics()
        discard setupInput()

        var gameRunning: bool = true
        while not w.windowShouldClose and gameRunning:
                discard processInput(w)
                glClearColor(0f, 0f, 0f, 0f)
                glClear(GL_COLOR_BUFFER_BIT)
                glDrawArrays(GL_TRIANGLES, 0, 3);

                if(myChip8.emulateCycle() != 0):
                        gameRunning = false

                if myChip8.drawFlag:
                        discard drawGraphics(w)

                w.swapBuffers()
                glfwPollEvents()

                discard myChip8.setKeys()

        w.destroyWindow()
        glfwTerminate()

        return 0

discard main()
