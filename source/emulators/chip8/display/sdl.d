module emulators.chip8.display.sdl;

import std.conv;
import std.logger;
import bindbc.sdl;

import common.sdl;
import common.logger;
import common.exceptions;
import emulators.chip8.display.common;

class SDLDisplay : Display
{
private:
    SDL_Window* window = null;
    SDL_Renderer* renderer = null;

    SDL_Keycode[] keybinds = [
        SDLK_x,
        SDLK_1, SDLK_2, SDLK_3,
        SDLK_q, SDLK_w, SDLK_e,
        SDLK_a, SDLK_s, SDLK_d,
        SDLK_z, SDLK_c,
        SDLK_4, SDLK_r, SDLK_f, SDLK_v
    ];

public:
    this(ubyte width = 64, ubyte height = 32)
    {
        super(width, height);

        if(injectSDL("lib/SDL2.dll") == false)
        {
            logSDLErrors();
            throw new Exception("Could not load SD2 libraries.");
        }

        Logger logger = get_logger();
        logger.info("\n\tFound and loaded SDL libraries.");

        SDL_Init(SDL_INIT_VIDEO);

        window = SDL_CreateWindow(
            "CHIP8",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            640, 320,
            SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE
        );

        if(window == null)
            throw new Exception("Could not create SDL window: " ~ to!string(SDL_GetError()));

        renderer = SDL_CreateRenderer(
            window, -1,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
        );
        if(renderer == null)
            throw new Exception("Could not create SDL renderer: " ~ to!string(SDL_GetError()));
        SDL_RenderSetLogicalSize(renderer, width, height);
    }

    ~this()
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
    }

    override void resize(ubyte width, ubyte height)
    {
        data = new ubyte[width * height];
        this.width = width;
        this.height = height;
        SDL_RenderSetLogicalSize(renderer, width, height);
        draw_flag = true;
    }

    override void draw()
    {
        static SDL_Event event;
        while(SDL_PollEvent(&event))
        {
            switch(event.type)
            {
            case SDL_QUIT:
                throw new ExitException(0);
                break;
            case SDL_WINDOWEVENT:
                switch(event.window.event)
                {
                case SDL_WINDOWEVENT_CLOSE:
                    throw new ExitException(0);
                    break;
                case SDL_WINDOWEVENT_SIZE_CHANGED:
                    draw_flag = true;
                    break;
                default:
                    break;
                }
                break;
            case SDL_KEYUP:
                for(int index = 0; index < 0x10; index++)
                    if(keybinds[index] == event.key.keysym.sym)
                        keys[index] = false;
                break;
            case SDL_KEYDOWN:
                for(int index = 0; index < 0x10; index++)
                    if(keybinds[index] == event.key.keysym.sym)
                        keys[index] = true;
                break;
            default:
                break;
            }
        }

        if(draw_flag == false)
            return;
    
        draw_flag = false;

        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        for(uint y = 0; y < height; y++)
        {
            for(uint x = 0; x < width; x++)
                if(data[y * width + x] == 1)
                    SDL_RenderDrawPoint(renderer, x, y);
        }
        SDL_RenderPresent(renderer);
    }
}