# chip8

![Pong running on the chip8 emulator](https://raw.githubusercontent.com/burnsjordan/chip8/master/images/chip8.png)

This project is a [Chip-8](https://en.wikipedia.org/wiki/CHIP-8) emulator written in [Nim](https://nim-lang.org/). It can be used to run roms designed for the chip-8 virtual machine.

I built this to learn about emulator design and to get experience with the nim programming language, feel free to use it but don't expect too much out of it :).

## Summary

  - [Getting Started](#getting-started)
  - [Runing the tests](#running-the-tests)
  - [Deployment](#deployment)
  - [Built With](#built-with)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)

## Getting Started

These steps should help you get the emulator running. I've used the emulator and mac and linux but it should be pretty similar to run it on windows.

### Prerequisites

Before running you'll need [nim](https://nim-lang.org/install.html), [nimgl/glfw](https://github.com/nimgl/nimgl), and opengl.

### Installing

Open a terminal and download this repo to your local machine

    git clone https://github.com/burnsjordan/chip8.git

cd into the project directory

    cd ./chip8
    
Change discard myChip8.loadGame("Pong.ch8") to look for whichever rom you want to run and then compile and run with
    
    nim c -r main.nim

## Tests

There are some very basic tests located in test.nim to help debug some of the opcodes. Not all the opcodes have tests. You can run the tests with

    nim c -r test.nim

## Built With

  - [Nim](https://nim-lang.org/) - Programming language used
  - [OpenGL](https://www.opengl.org/) - API used to draw the graphics
  - [GLFW](https://www.glfw.org/) - Library to help with OpenGL setup
  - [nimgl](https://github.com/nimgl/nimgl) - Nim bindings for glfw

## License

This project is licensed under the [CC0 1.0 Universal](LICENSE.md)
Creative Commons License - see the [LICENSE.md](LICENSE.md) file for
details

## Acknowledgments

  - Laurence Muller for a great chip8 emulator [intro](https://web.archive.org/web/20200307053152/https://www.multigesture.net/articles/how-to-write-an-emulator-chip-8-interpreter/) I used to get familiar with emulating chip8
  - [learnopengl](https://learnopengl.com/Getting-started/OpenGL) for a tutorial explaining how to get a basic opengl setup going
  - PurpleBooth for the [template](https://github.com/PurpleBooth/a-good-readme-template) used for this readme
