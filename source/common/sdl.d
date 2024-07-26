module common.sdl;

import std.conv;
import std.string;
import std.logger;
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import common.logger;

public void logSDLErrors()
{
    Logger logger = get_logger();

    string errors = "";
    foreach(info; loader.errors)
        errors = errors ~ "\t\t" ~ to!string(info.error) ~ ": " ~ to!string(info.message) ~ "\n";

    if(errors == "")
        return;
    
    logger.error("\n\tErrors have occured while trying to load SDL:\n" ~ errors);
}

public bool injectSDL(string path = "")
{
    Logger logger = get_logger();

    // First prefer system path, only afterwards local path.
    SDLSupport status = loadSDL();
	if(status == sdlSupport)
        return true;

    // Default path has not been found, try specified path if it exists.
    if(path != "")
    {
        status = loadSDL(toStringz(path));
        return (status == sdlSupport);
    }
	return false;
}