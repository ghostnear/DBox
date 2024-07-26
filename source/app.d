module app;

import std.file;
import std.stdio;
import std.logger;

import common.logger;
import common.emulator;
import common.exceptions;
import emulators.chip8.cpu.common;
import emulators.chip8.cpu.interpreter;
import emulators.chip8.display.sdl;
import emulators.chip8.emulator;

immutable romPath = "roms/chip8/hires/Hires Particle Demo [zeroZshadow, 2008].ch8";

int main(string[] arguments)
{
    if(std.file.exists("./last.log"))
        std.file.remove("./last.log");
    Logger logger = new FileLogger("./last.log");
    set_logger(logger);

    try
    {
        // TODO: replace this with a CLI parser, maybe? If nothing is passed, put maybe some sensible defaults.
        auto settings = new CHIP8Settings()
            .set_CPU(
                new Interpreter()
                .set_speed(500)
                .set_mode(CHIP8Mode.HIRES)
            )
            .set_rom_path(romPath)
            .set_display(new SDLDisplay());
        
        Emulator emulator = new CHIP8Emulator(settings);
        emulator.run_on_this_thread();
    }
    catch(ExitException status)
    {
        logger.info("\n\tApp close event has been registered. Quitting...");
        return status.code;
    }
    catch(Exception error)
    {
        logger.critical("\n\tAn error has occured while running the app:\n\t\t" ~ error.msg);
        write("\nAn error has occured while running the app:\n\t" ~ error.msg ~ "\n\n");
        return -1;
    }

    logger.info("\n\tExiting app...");
    return 0;
}
