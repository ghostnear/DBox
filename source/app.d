module app;

import std.stdio;
import std.logger;

import argparser;
import common.logger;
import common.emulator;
import common.exceptions;
import emulators.chip8.emulator;

version(unittest){}
else {
    int main(string[] arguments)
    {
        try
        {
            // Parse command line arguments and set everything up.
            ArgParser parser = new ArgParser(arguments);
            set_logger(parser.system.logPath);
            Logger logger = get_logger();
            
            try
            {
                Emulator emulator;
                switch(parser.emulatorType)
                {
                case Emulators.CHIP8:
                    emulator = new CHIP8Emulator(new CHIP8Settings().from_json(parser.emulatorConfig));
                    break;
                default:
                    throw new Exception("No / invalid emulator type specified.");
                    break;
                }
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
        catch(ExitException status)
            return status.code;
    }
}
