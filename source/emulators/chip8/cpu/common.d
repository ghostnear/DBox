module emulators.chip8.cpu.common;

import std.logger;

import emulators.chip8.memory;
import emulators.chip8.display.common;

// This is basically a strategy pattern implementation for the CPU.
class CPU
{
    abstract void execute(Memory, Display, Logger);
}