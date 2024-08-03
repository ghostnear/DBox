module emulators.chip8.tests;

import std.conv;
import emulators.chip8.cpu.interpreter;
import emulators.chip8.memory;
import emulators.chip8.display.stub;
import emulators.chip8.display.common;

struct OutputState
{
    Memory memory;
    Display display;
    Interpreter interpreter;
}

OutputState* run_test(ubyte[] data)
{
    auto result = new OutputState();
    result.memory = new Memory();
    result.display = new StubDisplay();
    result.interpreter = new Interpreter();

    result.memory.copy(
        data,
        cast(ushort)result.memory.startAddress
    );

    int steps = cast(int)(data.length / 2);
    while(steps--)
        result.interpreter.step(result.memory, result.display, 0);

    return result;
}

@("1NNN - JP NNN") unittest {
    auto result = run_test([0x12, 0x46]);
    assert(result.memory.PC == 0x246, "Wrong PC value: " ~ to!string(result.memory.PC));
}

@("2NNN - CALL NNN") unittest {
    auto result = run_test([0x22, 0x46]);
    assert(result.memory.PC == 0x246, "Wrong PC value: " ~ to!string(result.memory.PC));
    assert(result.memory.stack[0] == 0x202, "Wrong stack value: " ~ to!string(result.memory.stack[0]));
    assert(result.memory.SP == 0x1, "Wrong SP value: " ~ to!string(result.memory.SP));
}

@("6XKK - LD Vx, KK") unittest {
    auto result = run_test([0x62, 0x46]);
    assert(result.memory.registers[0x2] == 0x46, "Wrong register value: " ~ to!string(result.memory.registers[0x2]));
}