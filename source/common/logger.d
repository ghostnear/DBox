module common.logger;

import std.stdio;
import std.logger;

private Logger instance = null;

public Logger get_logger()
{
    if(instance is null)
        instance = new FileLogger(stdout);
    return instance;
}

public void set_logger(Logger newLogger)
{
    instance = newLogger;
}