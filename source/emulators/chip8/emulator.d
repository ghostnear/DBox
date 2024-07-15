module emulators.chip8.emulator;

import std.file;
import std.stdio;
import std.logger;

import common.emulator;
import emulators.chip8.memory;
import emulators.chip8.cpu.common;
import emulators.chip8.cpu.interpreter;
import emulators.chip8.display.common;

class CHIP8Settings
{
public:
    string romPath;
    Logger logger;
    CPU cpu;

    CHIP8Settings set_rom_path(string romPath)
    {
        this.romPath = romPath;
        return this;
    }

    CHIP8Settings set_logger(Logger logger)
    {
        this.logger = logger;
        return this;
    }

    CHIP8Settings set_CPU(CPU cpu)
    {
        this.cpu = cpu;
        return this;
    }
}

class CHIP8Emulator : Emulator
{
private:
    CPU cpu;
    Memory memory;

public:
    this(ref CHIP8Settings config)
    {
        logger = config.logger;
        cpu = config.cpu;

        memory = new Memory();
        
        auto file = File(config.romPath);
        if(file.size > memory.size - memory.startAddress)
            throw new Exception("ROM file is too large.");

        auto input = new ubyte[file.size];
        file.rawRead(input);
        memory.copy(input, cast(ushort)memory.startAddress);

        logger.info(i"\n\tCHIP8 ROM file with size $(file.size)B loaded into memory.");
    }

    override void run_on_this_thread()
    {
        logger.info("\n\tCHIP8 emulator is running on this thread.");

        memory.running = true;
        while(memory.running)
            cpu.execute(memory);

        logger.info("\n\tCHIP8 emulator has stopped running on this thread.");
    }
}