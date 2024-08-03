module emulators.chip8.display.common;

import std.json;

class Display
{
protected:
    ubyte[] data;
    ubyte width, height;
    bool draw_flag;

    ubyte[0x10] keys;

    ubyte foreground_r, foreground_g, foreground_b;
    ubyte background_r, background_g, background_b;

public:
    this(ubyte width = 64, ubyte height = 32) {
        data = new ubyte[width * height];
        this.width = width;
        this.height = height;
        draw_flag = true;
    }

    Display from_json(JSONValue value)
    {
        JSONValue foreground = value["foreground"];
        foreground_r = cast(byte)foreground["r"].integer;
        foreground_g = cast(byte)foreground["g"].integer;
        foreground_b = cast(byte)foreground["b"].integer;
    
        JSONValue background = value["background"];
        background_r = cast(byte)background["r"].integer;
        background_g = cast(byte)background["g"].integer;
        background_b = cast(byte)background["b"].integer;

        return this;
    }

    void clear() {
        data[] = 0;
        draw_flag = true;
    }

    bool get_key(ubyte value) const {
        return keys[value] ? true : false;
    }

    bool draw_sprite(ubyte x, ubyte y, ubyte[] sprite) {
        draw_flag = true;

        bool return_value = false;

        for(ubyte currentByte = 0; currentByte < sprite.length; currentByte++)
        {
            for(ubyte currentBit = 0; currentBit < 8; currentBit++)
            {
                const ubyte currentValue = (sprite[currentByte] & (1 << 7 - currentBit)) ? 1 : 0;
                const uint currentX = x % width + currentBit;
                const uint currentY = y % height + currentByte;
                if(currentX < width && currentY < height)
                {
                    if(currentValue == 1 && data[currentY * width + currentX] == 1)
                        return_value = true;

                    data[currentY * width + currentX] ^= currentValue;
                }
            }
        }

        return return_value;
    }
    
    abstract void resize(ubyte width, ubyte height);
    abstract void draw();
}