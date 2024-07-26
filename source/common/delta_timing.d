module common.delta_timing;

import bindbc.sdl;

private double delta = 0;
private ulong now = 0;
private ulong last = 0;

double get_delta_time()
{
    last = now;
    now = SDL_GetPerformanceCounter();
    delta = (now - last) * 1.0 / SDL_GetPerformanceFrequency();
    return delta;
}