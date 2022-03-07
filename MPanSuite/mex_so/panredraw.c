#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "mex.h"

#define PAN_MAT_SHL_NAME      "panMat.so"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    void *Module;

    if( nrhs != 1 )
    {
	mexErrMsgTxt( "Error: missing argument. Usage: panredraw('on/off')");
	return;
    }

    if( ! mxIsChar(prhs[0]))
    {
        mexErrMsgTxt( "Error: argument must be a string. "
	              "Usage: panredraw('on/off')" );
	return;
    }
    if( nlhs != 0 )
    {
	mexErrMsgTxt( "Error: no output variable is required. "
	              "Usage: panredraw('on/off')");
	return;
    }

    char *ShlPath = (char *) getenv( "PAN_MAT_SHL_PATH" );
    char *Path;

    if( ShlPath )
    {
        Path = (char *) malloc((strlen(ShlPath)+strlen(PAN_MAT_SHL_NAME) + 20) *
	                        sizeof( char ) );
	if( ! Path )
	{
	     mexErrMsgTxt( "Unable to allocate memory.\n" );
	     return;
	}

	sprintf( Path, "%s/%s", ShlPath, PAN_MAT_SHL_NAME );
    }
    else
    {
        Path = (char *) malloc((strlen(PAN_MAT_SHL_NAME)+20) * sizeof( char ));
	if( ! Path )
	{
	     mexErrMsgTxt( "Unable to allocate memory.\n" );
	     return;
	}

	sprintf( Path, "%s", PAN_MAT_SHL_NAME );
    }

    Module = dlopen( Path, RTLD_LAZY | RTLD_DEEPBIND | RTLD_NOLOAD );
    if( ! Module )
    {
	int Count, Length;
	char *MexErrBuffer;

	Length = strlen( Path ) + 150;
	MexErrBuffer = mxCalloc( Length, sizeof( char ) );
	if( ! MexErrBuffer )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return;
	}

	Count = sprintf( MexErrBuffer, "The <%s> shared libray can not be "
	    "loaded.\n"
	    "Run \"pannet('filename')\" command before reading simulation "
	    "results.\n", Path );

	if( Count >= Length )
	    abort();

	mexErrMsgTxt( MexErrBuffer );

	return;
    }

    errno = 0;

    void (*Entry)( char );
    char *EntryName = "PanMatlabRedraw";

    Entry = dlsym( Module, EntryName );
    if( NULL == Entry )
    {
	dlclose( Module );

	int Count, Length;
	char *MexErrBuffer;

	Length = strlen( Path ) + strlen( EntryName ) + 100;
	MexErrBuffer = mxCalloc( Length, sizeof( char ) );
	if( ! MexErrBuffer )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return;
	}

	Count = sprintf( MexErrBuffer, "The <%s> evaluate routine is not "
	        "found in <%s> shared module.\n\n", EntryName, Path );
	if( Count >= Length )
	    abort();

	mexErrMsgTxt( MexErrBuffer );

	return;
    }

    free( Path );

    size_t  CharNum;
    char *Argument;
    char Flag;

    CharNum = mxGetN( prhs[0]);

    Argument = mxMalloc( 2 + CharNum );
    if( NULL == Argument )
    {
	mexErrMsgTxt( "No more memory.\n" );
	return;
    }

    mxGetString( prhs[0], Argument, 1 + CharNum );

    if( ! strcasecmp( Argument, "on" ) )
        Flag = 1;
    else if( ! strcasecmp( Argument, "off" ) )
        Flag = 0;
    else
    {
	mxFree( Argument );
        mexErrMsgTxt( "Error: argument must be the 'on' or 'off' string." );
	dlclose( Module );
        return;
    }

    mxFree( Argument );

    (Entry)( Flag );

    dlclose( Module );
    return;
}
