module emulators.chip8.cpu.interpreter;

import std.stdio;
import std.format;
import std.logger;

import emulators.chip8.memory;
import emulators.chip8.cpu.common;
import emulators.chip8.display.common;

class Interpreter : CPU
{
private:
    void unknown_opcode(Memory memory, ushort opcode)
    {
        throw new Exception(format(
            "(CHIP8): Unknown opcode found at address 0x%04X: %04X",
            memory.PC - 2, opcode
        ));
    }

public:
    override void execute(Memory memory, Display display, Logger logger)
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
                display.clear();
                break;
            default:
                unknown_opcode(memory, opcode);
                break;
            }
            break;

        case 0x1:
            memory.PC -= 2;
            if(nnn == memory.PC)
            {
                memory.running = false;
                logger.info(format("\n\t(CHIP8): Emulator will stop as an infinite jump to address 0x%04X has been found.", memory.PC));
            }
            memory.PC = nnn;
            break;

        case 0x6:
            memory.registers[x] = nn;
            break;

        case 0xA:
            memory.I = nnn;
            break;

        case 0xD:
            display.draw_sprite(memory.registers[x], memory.registers[y], memory.get_slice(memory.I, n));
            break;

        default:
            unknown_opcode(memory, opcode);
            break;
        }
    }
}