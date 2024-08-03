module common.emulator;

enum Emulators
{
    None = 0,
    CHIP8
}

class Emulator
{
public:
    abstract void run_on_this_thread();
}