module common.emulator;

import std.logger;

class Emulator
{
protected:
    Logger logger;

public:
    abstract void run_on_this_thread();
}