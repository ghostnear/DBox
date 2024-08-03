module argparser;

import std.file;
import std.json;
import std.getopt;

import common.emulator;
import common.exceptions;

struct SystemSettings
{
    string logPath = "./last.log";
}

class ArgParser
{
public:
    string emulatorConfig;
    Emulators emulatorType;
    SystemSettings system;

    this(string[] arguments)
    {
        string systemConfigPath = null;
        string emulatorConfigPath = null;
        Emulators emulatorType = Emulators.None;

        auto parameters = getopt(
            arguments,
            std.getopt.config.passThrough,
            "systemConfig|sc", "System configuration path. (optional)", &systemConfigPath,
            "emulatorConfig|ec", "Emulator configuration path.", &emulatorConfigPath,
            "type|t", "Emulator type.", &emulatorType,
        );

        // Show info about the program if help is asked.
        if(parameters.helpWanted)
        {
            defaultGetoptPrinter(
                "DBox - Simple multiplatform emulator.\nSee https://github.com/ghostnear/DBox for sample configurations.\n\nOptions:",
                parameters.options,
            );
            throw new ExitException(0);
        }

        // If not, parse the data.
        if(systemConfigPath != null)
        {
            string content = readText(systemConfigPath);
            JSONValue systemConfig = parseJSON(content);
            system.logPath = systemConfig["logPath"].str;
        }

        this.emulatorType = emulatorType;
        this.emulatorConfig = emulatorConfigPath;
    }
}