module emulators.chip8.display.common;


class Display
{
protected:
    ubyte[] data;
    ubyte width, height;
    bool draw_flag;

    ubyte[0x10] keys;

public:
    this(ubyte width = 64, ubyte height = 32) {
        data = new ubyte[width * height];
        this.width = width;
        this.height = height;
        draw_flag = true;
    }

    void clear() {
        data[] = 0;
        draw_flag = true;
    }

    bool get_key(ubyte value) {
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