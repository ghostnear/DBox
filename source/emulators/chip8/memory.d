module emulators.chip8.memory;

class Memory
{
private:
    ubyte[size] memory;
    
public:
    const int size = 0x10000;
    const ushort startAddress = 0x200;

    ushort PC, I, SP;
    ubyte sound_timer, delta_timer;
    ubyte[0x10] registers;
    ushort[0x10] stack;
    bool running;

    double timer_accumulator;

    this()
    {
        memory[] = 0;
        registers[] = 0;
        stack[] = 0;
        SP = 0;
        running = false;
        PC = startAddress;
        I = 0;
        timer_accumulator = 0;
        delta_timer = 0;
        sound_timer = 0;

        // Load default font into memory.
        ubyte[] font = [
            0xF0, 0x90, 0x90, 0x90, 0xF0,		// 0
            0x20, 0x60, 0x20, 0x20, 0x70,		// 1
            0xF0, 0x10, 0xF0, 0x80, 0xF0,		// 2
            0xF0, 0x10, 0xF0, 0x10, 0xF0,		// 3
            0x90, 0x90, 0xF0, 0x10, 0x10,		// 4
            0xF0, 0x80, 0xF0, 0x10, 0xF0,		// 5
            0xF0, 0x80, 0xF0, 0x90, 0xF0,		// 6
            0xF0, 0x10, 0x20, 0x40, 0x40,		// 7
            0xF0, 0x90, 0xF0, 0x90, 0xF0,		// 8
            0xF0, 0x90, 0xF0, 0x10, 0xF0,		// 9
            0xF0, 0x90, 0xF0, 0x90, 0x90,		// A
            0xE0, 0x90, 0xE0, 0x90, 0xE0,		// B
            0xF0, 0x80, 0x80, 0x80, 0xF0,		// C
            0xE0, 0x90, 0x90, 0x90, 0xE0,		// D
            0xF0, 0x80, 0xF0, 0x80, 0xF0,		// E
            0xF0, 0x80, 0xF0, 0x80, 0x80		// F
        ];
        copy(font, 0);
    }

    void copy(ubyte[] data, ushort startAddress)
    {
        // This feels highly illegal coming from cpp.
        memory[startAddress .. startAddress + data.length] = data;
    }

    ubyte get_byte(ushort address) const
    {
        return memory[address];
    }

    ushort get_word(ushort address) const
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

    void set_slice(ushort start, ushort end, ubyte[] newData)
    {
        memory[start .. start + end] = newData;
    }
}