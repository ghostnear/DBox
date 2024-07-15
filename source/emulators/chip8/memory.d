module emulators.chip8.memory;

class Memory
{
private:
    ubyte[size] memory;
    
public:
    const int size = 0x10000;
    const ushort startAddress = 0x200;

    ushort PC, I;
    ubyte[0x10] registers;
    bool running;

    this()
    {
        memory[] = 0;
        registers[] = 0;
        running = false;
        PC = startAddress;
        I = 0;
    }

    void copy(ubyte[] data, ushort startAddress)
    {
        // This feels highly illegal coming from cpp.
        memory[startAddress .. startAddress + data.length] = data;
    }

    ubyte get_byte(ushort address)
    {
        return memory[address];
    }

    ushort get_word(ushort address)
    {
        return memory[address] << 8 | memory[address + 1];
    }

    void set_byte(ushort address, ubyte value)
    {
        memory[address] = value;
    }

    void set_word(ushort address, ushort value)
    {
        memory[address] = cast(ubyte)(value >> 8);
        memory[address + 1] = cast(ubyte)value;
    }

    ubyte[] get_slice(ushort start, ushort end)
    {
        return memory[start .. start + end];
    }
}