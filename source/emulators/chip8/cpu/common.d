module emulators.chip8.cpu.common;

import emulators.chip8.memory;
import emulators.chip8.display.common;

enum CHIP8Mode
{
    NORMAL = 0,
    HIRES
}

// This is basically a strategy pattern implementation for the CPU.
class CPU
{
protected:
    int speed;
    CHIP8Mode mode;

public:
    CPU set_speed(int speed)
    {
        this.speed = speed;
        return this;
    }

    CPU set_mode(CHIP8Mode mode)
    {
        this.mode = mode;
        return this;        
    }

    abstract void execute(ref Memory, ref Display, double);
}