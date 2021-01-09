include chip8
import nimgl/[glfw]
import opengl

proc `+`[T](a: ptr T, b: int): ptr T =
    if b >= 0:
        cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
    else:
        cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

template `-`[T](a: ptr T, b: int): ptr T = `+`(a, -b)

proc framebuffer_callback(window: GLFWWindow, width: int32, height: int32) =
        glViewport(0, 0, width, height)

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
        glVertexAttribPointer(0, 3, cGL_FLOAT, false, 3 * sizeof(GLfloat), nil)
        glEnableVertexAttribArray(0)

        # Create Vertex Shader
        # var vertexShaderSource: cstring = "#version 330 core\nlayout (location = 0) in vec3 aPos;\nvoid main()\n{\n   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n}\0"
        var vertexShader: GLuint
        var vertexShaderArray = allocCStringArray(["#version 330 core\nlayout (location = 0) in vec3 aPos;\nvoid main()\n{\n   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);}\0"])
        vertexShader = glCreateShader(GL_VERTEX_SHADER)
        glShaderSource(vertexShader, GLsizei(1), vertexShaderArray, nil)
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
        # var fragmentShaderSource: cstring = "#version 330 core\nout vec4 FragColor;\nvoid main()\n{\nFragColor = vec4(1.0f, 0.5f, 0.5f, 1.0f);\n}\n\0"
        var fragmentShader: GLuint
        var fragmentShaderArray = allocCStringArray(["#version 330 core\nout vec4 FragColor;\nvoid main()\n{\nFragColor = vec4(1.0f, 0.5f, 0.5f, 1.0f);\n}\n\0"])
        fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
        glShaderSource(fragmentShader, GLsizei(1), fragmentShaderArray, nil)
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

        deallocCStringArray(vertexShaderArray)
        deallocCStringArray(fragmentShaderArray)

        return 0

proc setupInput(): int = 
        return 0

proc drawGraphics(w: GLFWWindow): int =  
        var vertices: array[0..(2048*18)-1, GLfloat]
        for i in countup(0, 31):
                for j in countup(0, 63):
                        if(myChip8.gfx[(64*i)+j] != 0):
                                # vertices[0+i*64*9+j*9] = GLfloat(1.0)
                                vertices[0+i*64*18+j*18] = GLfloat(-1.0+float(j)*(2.0/64))
                                vertices[1+i*64*18+j*18] = GLfloat(1.0-float(i)*(2.0/32))
                                vertices[2+i*64*18+j*18] = GLfloat(0.0)
                                vertices[3+i*64*18+j*18] = GLfloat(-1.0+float(j)*(2.0/64)+(2.0/64))
                                vertices[4+i*64*18+j*18] = GLfloat(1.0-float(i)*(2.0/32))
                                vertices[5+i*64*18+j*18] = GLfloat(0.0)
                                vertices[6+i*64*18+j*18] = GLfloat(-1.0+float(j)*(2.0/64)+(2.0/64))
                                vertices[7+i*64*18+j*18] = GLfloat(1.0-float(i)*(2.0/32)-(2.0/32))
                                vertices[8+i*64*18+j*18] = GLfloat(0.0)
                                vertices[9+i*64*18+j*18] = GLfloat(-1.0+float(j)*(2.0/64))
                                vertices[10+i*64*18+j*18] = GLfloat(1.0-float(i)*(2.0/32))
                                vertices[11+i*64*18+j*18] = GLfloat(0.0)
                                vertices[12+i*64*18+j*18] = GLfloat(-1.0+float(j)*(2.0/64))
                                vertices[13+i*64*18+j*18] = GLfloat(1.0-float(i)*(2.0/32)-(2.0/32))
                                vertices[14+i*64*18+j*18] = GLfloat(0.0)
                                vertices[15+i*64*18+j*18] = GLfloat(-1.0+float(j)*(2.0/64)+(2.0/64))
                                vertices[16+i*64*18+j*18] = GLfloat(1.0-float(i)*(2.0/32)-(2.0/32))
                                vertices[17+i*64*18+j*18] = GLfloat(0.0)
                        else:
                                # vertices[0+i*64*9+j*9] = GLfloat(0.0)
                                vertices[0+i*64*18+j*18] = GLfloat(0.0)
                                vertices[1+i*64*18+j*18] = GLfloat(0.0)
                                vertices[2+i*64*18+j*18] = GLfloat(0.0)
                                vertices[3+i*64*18+j*18] = GLfloat(0.0)
                                vertices[4+i*64*18+j*18] = GLfloat(0.0)
                                vertices[5+i*64*18+j*18] = GLfloat(0.0)
                                vertices[6+i*64*18+j*18] = GLfloat(0.0)
                                vertices[7+i*64*18+j*18] = GLfloat(0.0)
                                vertices[8+i*64*18+j*18] = GLfloat(0.0)
                                vertices[9+i*64*18+j*18] = GLfloat(0.0)
                                vertices[10+i*64*18+j*18] = GLfloat(0.0)
                                vertices[11+i*64*18+j*18] = GLfloat(0.0)
                                vertices[12+i*64*18+j*18] = GLfloat(0.0)
                                vertices[13+i*64*18+j*18] = GLfloat(0.0)
                                vertices[14+i*64*18+j*18] = GLfloat(0.0)
                                vertices[15+i*64*18+j*18] = GLfloat(0.0)
                                vertices[16+i*64*18+j*18] = GLfloat(0.0)
                                vertices[17+i*64*18+j*18] = GLfloat(0.0)
        glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(sizeof(vertices)), addr vertices, GL_STATIC_DRAW)
        glClearColor(0f, 0f, 0f, 0f)
        glClear(GL_COLOR_BUFFER_BIT)
        glDrawArrays(GL_TRIANGLES, 0, GLsizei(sizeof(vertices)/3));

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

        let w: GLFWWindow = glfwCreateWindow(800, 600, "Chip-8 Emulator", nil, nil)
        if w == nil:
                glfwTerminate()
                quit(-1)

        discard w.setKeyCallback(keyProc)
        # w.setFramebufferSizeCallback(GLFWFramebuffersizeFun)
        w.makeContextCurrent()
        loadExtensions()
        glViewport(0, 0, 800, 600)

        assert glfwInit()
        discard myChip8.initialize()
        discard myChip8.loadGame("TETRIS.ch8")
        discard setupGraphics()
        discard setupInput()

        var gameRunning: bool = true
        while not w.windowShouldClose and gameRunning:
                discard processInput(w)

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
