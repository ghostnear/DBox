module app;

import std.file;
import std.stdio;
import std.logger;

import common.emulator;
import emulators.chip8.cpu.interpreter;
import emulators.chip8.emulator;

immutable romPath = "roms/chip8/timendus/1-chip8-logo.ch8";

void main(string[] arguments)
{
    if(std.file.exists("./last.log"))
        std.file.remove("./last.log");
    Logger logger = new FileLogger("./last.log");

    try {
        auto settings = new CHIP8Settings()
            .set_CPU(new Interpreter())
            .set_rom_path(romPath)
            .set_logger(logger);
        
        Emulator emulator = new CHIP8Emulator(settings);
        emulator.run_on_this_thread();
    }
    catch(Exception error) {
        logger.error(i"\n\tAn error has occured while running the emulator:\n\t\t$(error.msg)");
    }
}
