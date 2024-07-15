module emulators.chip8.display.cli;

import terminal;
import emulators.chip8.display.common;

class CLIDisplay : Display
{
private:
    Terminal terminal;

public:
    this()
    {
        terminal = new Terminal();
        terminal.title = "CHIP8 Emulator";  // (Windows only)
    }

    ~this()
    {
        terminal.reset();
    }

    override void draw()
    {
    }
}