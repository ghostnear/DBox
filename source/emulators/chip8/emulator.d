module emulators.chip8.emulator;

import std.file;
import std.stdio;
import std.logger;

import common.emulator;
import emulators.chip8.memory;
import emulators.chip8.display.common;

class CHIP8Settings
{
public:
    string romPath;
    Logger logger;

    // TODO: replace this maybe with command line argument parsing.
    CHIP8Settings from_rom_path(string romPath)
    {
        this.romPath = romPath;
        return this;
    }

    CHIP8Settings setLogger(Logger logger)
    {
        this.logger = logger;
        return this;
    }
}

class CHIP8Emulator : Emulator
{
private:
    Memory memory;

public:
    this(ref CHIP8Settings config)
    {
        this.logger = config.logger;

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
        // Stub.
    }
}