module emulators.chip8.cpu.common;

import emulators.chip8.memory;

// This is basically a strategy pattern implementation for the CPU.
class CPU
{
    abstract void execute(Memory);
}