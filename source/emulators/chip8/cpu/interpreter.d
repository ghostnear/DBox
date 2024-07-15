module emulators.chip8.cpu.interpreter;

import std.stdio;
import std.format;

import emulators.chip8.memory;
import emulators.chip8.cpu.common;

class Interpreter : CPU
{
private:
    void unknown_opcode(Memory memory, ushort opcode)
    {
        throw new Exception(format(
            "Unknown CHIP8 opcode found at address 0x%04X: %04X",
            memory.PC - 2, opcode
        ));
    }

public:
    override void execute(Memory memory)
    {
        if(!memory.running)
            return;

        const ushort opcode = memory.get_word(memory.PC);
        memory.PC += 2;

        const ushort x = (opcode & 0x0F00) >> 8;
        const ushort y = (opcode & 0x00F0) >> 4;
        const ushort n = opcode & 0x000F;
        const ushort nn = opcode & 0x00FF;
        const ushort nnn = opcode & 0x0FFF;

        switch((opcode & 0xF000) >> 12)
        {
        case 0x0:
            switch(nn)
            {
            case 0x00E0:
                memory.clear_display();
                break;
            default:
                unknown_opcode(memory, opcode);
                break;
            }
            break;

        case 0x6:
            memory.registers[x] = nn;
            break;

        case 0xA:
            memory.I = nnn;
            break;

        default:
            unknown_opcode(memory, opcode);
            break;
        }
    }
}