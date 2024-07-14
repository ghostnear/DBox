module emulators.chip8.memory;

class Memory
{
private:
    ubyte[size] memory;

public:
    const int size = 0x10000;
    const int startAddress = 0x200;

    this()
    {
        memory[] = 0;
    }

    void copy(ubyte[] data, ushort startAddress)
    {
        // This feels highly illegal coming from cpp.
        memory[startAddress .. startAddress + data.length] = data;
    }

    ubyte read(ushort address)
    {
        return memory[address];
    }

    void write(ushort address, ubyte value)
    {
        memory[address] = value;
    }
}