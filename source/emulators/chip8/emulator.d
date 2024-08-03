module emulators.chip8.emulator;

import std.file;
import std.json;
import std.stdio;
import std.logger;
import core.thread;

import common.logger;
import common.emulator;
import common.delta_timing;
import emulators.chip8.memory;
import emulators.chip8.cpu.common;
import emulators.chip8.cpu.interpreter;
import emulators.chip8.display.sdl;
import emulators.chip8.display.common;

class CHIP8Settings
{
public:
    string romPath;
    Display display;
    CPU cpu;

    CHIP8Settings set_rom_path(string romPath)
    {
        this.romPath = romPath;
        return this;
    }

    CHIP8Settings set_display(Display display)
    {
        this.display = display;
        return this;
    }

    CHIP8Settings set_CPU(CPU cpu)
    {
        this.cpu = cpu;
        return this;
    }

    CHIP8Settings from_json(string path)
    {
        string content = readText(path);
        JSONValue config = parseJSON(content);
        return this
            .set_rom_path(config["romPath"].str)
            .set_CPU(new Interpreter().from_json(config["cpu"]))
            .set_display(new SDLDisplay().from_json(config["display"]));
    }
}

class CHIP8Emulator : Emulator
{
private:
    CPU cpu;
    Memory memory;
    Display display;

public:
    this(CHIP8Settings config)
    {
        Logger logger = get_logger();

        display = config.display;
        cpu = config.cpu;

        memory = new Memory();
        
        auto file = File(config.romPath);
        if(file.size > memory.size - memory.startAddress)
            throw new Exception("(CHIP8): ROM file is too large.");

        auto input = new ubyte[file.size];
        file.rawRead(input);
        memory.copy(input, cast(ushort)memory.startAddress);

        logger.info(i"\n\t(CHIP8): ROM file with size $(file.size)B from path '$(config.romPath)' was loaded into memory.");
    }

    override void run_on_this_thread()
    {
        Logger logger = get_logger();

        logger.info("\n\t(CHIP8): Emulator is running on this thread.");

        memory.running = true;
        while(true)
        {
            cpu.execute(memory, display, common.delta_timing.get_delta_time());
            display.draw();
            Thread.sleep(dur!("msecs")(10));
        }

        logger.info("\n\t(CHIP8): Emulator has stopped running on this thread.");
    }
}