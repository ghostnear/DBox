module common.exceptions;

class ExitException : Exception
{
public:
    int code;
    this(int rc)
    {
        code = rc;    
        super("Exit has been requested from the app.");
    }
}