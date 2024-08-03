module emulators.chip8.display.stub;

import emulators.chip8.display.common;

class StubDisplay : Display
{
public:
    this(ubyte width = 64, ubyte height = 32)
    {
        super(width, height);
    }

    override void resize(ubyte width, ubyte height)
    {
        data = new ubyte[width * height];
        this.width = width;
        this.height = height;
        draw_flag = true;
    }

    override void draw() const
    {
        // Do nothing.
    }
}