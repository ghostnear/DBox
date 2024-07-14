module app;

import std.file;
import std.stdio;
import std.logger;

import common.emulator;
import emulators.chip8.emulator;

immutable romPath = "roms/chip8/timendus/1-chip8-logo.ch8";

void main(string[] arguments)
{
    if(std.file.exists("./last.log"))
        std.file.remove("./last.log");
    Logger logger = new FileLogger("./last.log");

    try {
        auto settings = new CHIP8Settings().from_rom_path(romPath).setLogger(logger);
        Emulator emulator = new CHIP8Emulator(settings);
        emulator.run_on_this_thread();
    }
    catch(Exception e) {
        writeln(e.msg);
    }
}
