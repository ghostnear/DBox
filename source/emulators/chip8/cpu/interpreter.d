module emulators.chip8.cpu.interpreter;

import std.stdio;
import std.format;
import std.random;
import std.logger;

import common.logger;
import emulators.chip8.memory;
import emulators.chip8.cpu.common;
import emulators.chip8.display.common;

class Interpreter : CPU
{
private:
    Random random_generator;
    double delta_timer;

    void unknown_opcode(Memory memory, ushort opcode)
    {
        throw new Exception(format(
            "(CHIP8): Unknown opcode found at address 0x%04X: %04X",
            memory.PC - 2, opcode
        ));
    }

    void step(ref Memory memory, ref Display display, double delta_time)
    {
        Logger logger = get_logger();

        memory.timer_accumulator += delta_time;
        while(memory.timer_accumulator >= 1.0 / 60)
        {
            if(memory.delta_timer > 0)
                memory.delta_timer -= 1;
            if(memory.sound_timer > 0)
                memory.sound_timer -= 1;
            memory.timer_accumulator -= 1.0 / 60;
        }

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
            switch(nnn)
            {
            case 0x0E0:
                display.clear();
                break;
            case 0x0EE:
                memory.PC = memory.stack[memory.SP--];
                break;
            case 0x230:
                if(mode == CHIP8Mode.HIRES)
                    display.clear();
                else
                    unknown_opcode(memory, opcode);
                break;
            default:
                unknown_opcode(memory, opcode);
                break;
            }
            break;

        case 0x1:
            // HIRES mode init.
            if(mode == CHIP8Mode.HIRES && nnn == 0x260 && memory.PC == 0x202)
            {
                display.resize(64, 64);
                memory.PC = 0x2C0;
                break;
            }

            if(nnn == memory.PC - 2)
            {
                memory.running = false;
                logger.info(format("\n\t(CHIP8): Emulator will stop as an infinite jump to address 0x%04X has been found.", memory.PC - 2));
            }
            memory.PC = nnn;
            break;

        case 0x2:
            memory.stack[++memory.SP] = memory.PC;
            memory.PC = nnn;
            break;

        case 0x3:
            if(memory.registers[x] == nn)
                memory.PC += 2;
            break;

        case 0x4:
            if(memory.registers[x] != nn)
                memory.PC += 2;
            break;

        case 0x5:
            if(memory.registers[x] == memory.registers[y])
                memory.PC += 2;
            break;

        case 0x6:
            memory.registers[x] = nn;
            break;

        case 0x7:
            memory.registers[x] += nn;
            break;

        case 0x8:
            switch(n)
            {
            case 0x0:
                memory.registers[x] = memory.registers[y];
                break;

            case 0x1:
                memory.registers[x] |= memory.registers[y];
                memory.registers[0xF] = 0;
                break;

            case 0x2:
                memory.registers[x] &= memory.registers[y];
                memory.registers[0xF] = 0;
                break;
    
            case 0x3:
                memory.registers[x] ^= memory.registers[y];
                memory.registers[0xF] = 0;
                break;

            case 0x4:
                const ubyte carry = ((255 - memory.registers[x]) > memory.registers[y]) ? 0 : 1;
                memory.registers[x] += memory.registers[y];
                memory.registers[0xF] = carry;
                break;

            case 0x5:
                const ubyte carry = (memory.registers[x] >= memory.registers[y]) ? 1 : 0;
                memory.registers[x] -= memory.registers[y];
                memory.registers[0xF] = carry;
                break;

            case 0x6:
                const ubyte carry = memory.registers[y] & 1;
                memory.registers[x] = memory.registers[y] >> 1;
                memory.registers[0xF] = carry;
                break;

            case 0x7:
                const ubyte carry = (memory.registers[y] >= memory.registers[x]) ? 1 : 0;
                memory.registers[x] = cast(ubyte)(memory.registers[y] - memory.registers[x]);
                memory.registers[0xF] = carry;
                break;

            case 0xE:
                const ubyte carry = (memory.registers[y] & (1 << 7)) ? 1 : 0;
                memory.registers[x] = cast(ubyte)(memory.registers[y] << 1);
                memory.registers[0xF] = carry;
                break;

            default:
                unknown_opcode(memory, opcode);
                break;
            }
            break;

        case 0x9:
            if(memory.registers[x] != memory.registers[y])
                memory.PC += 2;
            break;

        case 0xA:
            memory.I = nnn;
            break;

        case 0xB:
            memory.PC = nnn + memory.registers[0];
            break;

        case 0xC:
            memory.registers[x] = cast(int)random_generator.front & nn;
            random_generator.popFront();
            break;

        case 0xD:
            memory.registers[0xF] = display.draw_sprite(memory.registers[x], memory.registers[y], memory.get_slice(memory.I, n));
            break;

        case 0xE:
            switch(nn)
            {
            case 0x9E:
                if(display.get_key(memory.registers[x]))
                    memory.PC += 2;
                break;

            case 0XA1:
                if(!display.get_key(memory.registers[x]))
                    memory.PC += 2;
                break;

            default:
                unknown_opcode(memory, opcode);
                break;
            }
            break;

        case 0xF:
            switch(nn)
            {
            case 0x07:
                memory.registers[x] = memory.delta_timer;
                break;

            case 0x0A:
                static byte key = -1;
                // No key has been pressed
                if(key == -1)
                {
                    memory.PC -= 2;
                    for(byte index = 0; index < 0x10; index++)
                        if(display.get_key(index))
                            key = index;
                }
                // Key has been pressed
                else if(key != -2)
                {
                    memory.PC -= 2;
                    memory.registers[x] = key;
                    key = -2;
                }
                // Wait for release
                else
                {
                    if(display.get_key(memory.registers[x]))
                        memory.PC -= 2;
                    else
                        key = -1;
                }
                break;

            case 0x15:
                memory.delta_timer = memory.registers[x];
                break;

            case 0x18:
                memory.sound_timer = memory.registers[x];
                break;

            case 0x1E:
                memory.I += memory.registers[x];
                break;

            case 0x29:
                memory.I = 5 * memory.registers[x];
                break;

            case 0x33:
                memory.set_byte(cast(ushort)(memory.I), cast(ubyte)((memory.registers[x] / 100) % 10));
                memory.set_byte(cast(ushort)(memory.I + 1), cast(ubyte)((memory.registers[x] / 10) % 10));
                memory.set_byte(cast(ushort)(memory.I + 2), cast(ubyte)(memory.registers[x]  % 10));
                break;

            case 0x55:
                for(ushort index = 0; index <= x; index++)
                    memory.set_byte(cast(ushort)(memory.I + index), memory.registers[index]);
                memory.I += x + 1;
                break;

            case 0x65:
                for(ushort index = 0; index <= x; index++)
                    memory.registers[index] = memory.get_byte(cast(ushort)(memory.I + index));
                memory.I += x + 1;
                break;

            default:
                unknown_opcode(memory, opcode);
                break;
            }
            break;

        default:
            unknown_opcode(memory, opcode);
            break;
        }
    }

public:
    this() {
        random_generator = Random(unpredictableSeed);
        delta_timer = 0;
    }

    override void execute(ref Memory memory, ref Display display, double delta_time)
    {
        if(!memory.running)
            return;

        if(delta_time > 1)
            return;

        delta_timer += delta_time;
        while(delta_timer > 1.0 / speed && memory.running)
        {
            step(memory, display, 1.0 / speed);
            delta_timer -= 1.0 / speed;
        }
    }
}