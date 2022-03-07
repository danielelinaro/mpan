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
	mexErrMsgTxt( "Error: missed simulator command. Usage: "
	              "pansimc('command')");
	return;
    }

    if( ! mxIsChar(prhs[0]))
    {
        mexErrMsgTxt( "Error: 'command' must be a string. "
	              "Usage: pansimc('command')" );
	return;
    }
    if( nlhs != 0 )
    {
	mexErrMsgTxt( "Error: output variable is not required. "
	              "Usage: pansimc('command')");
	return;
    }

    char *ShlPath = (char *) getenv( "PAN_MAT_SHL_PATH" );
    char *Path;

    if( ShlPath )
    {
        Path = (char *) malloc((strlen(ShlPath)+strlen(PAN_MAT_SHL_NAME)+20) *
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
        Path = (char *) malloc( (strlen(PAN_MAT_SHL_NAME) + 20)*sizeof(char) );
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

	Length = strlen( Path ) + 100;
	MexErrBuffer = mxCalloc( Length, sizeof( char ) );
	if( ! MexErrBuffer )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return;
	}

	Count = sprintf( MexErrBuffer, "The <%s> shared libray can not be "
	    "loaded. Run \"pannet('command')\" command to read a circuit "
	    "netlist.\n", Path );

	if( Count >= Length )
	    abort();

	mexErrMsgTxt( MexErrBuffer );

	return;
    }

    int (*Entry)( char * );
    char *EntryName = "PanMatlabExecuteCommand";

    Entry = dlsym( Module, EntryName );
    if( ! Entry )
    {
	dlclose( Module );

	int Count, Length;
	char *MexErrBuffer;

	Length = strlen( Path ) + strlen( EntryName ) + 100;
	MexErrBuffer = mxCalloc( Length, sizeof( char ) );
	if( NULL == MexErrBuffer )
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

    char   *Command;
    size_t  CharNum;

    CharNum = mxGetN( prhs[0]);

    Command = mxMalloc( 2 + CharNum );
    if( NULL == Command )
    {
	mexErrMsgTxt( "No more memory.\n" );
	return;
    }

    mxGetString( prhs[0], Command, 1 + CharNum );

    errno = 0;

    int Error = (Entry)( Command );

    mxFree( Command );

    mxArray *pAnaError = mexGetVariable( "global", "MPanerror" );

    if( pAnaError )
    {
	mwSize Nelem = mxGetNumberOfElements( pAnaError );
	double *pDoubleData = (double *) mxGetData( pAnaError );

	if( Nelem == 1 )
	{
	    if( pDoubleData[0] < (double) Error )
	    {
		pDoubleData[0] = (double) Error;
		mexPutVariable( "global", "MPanerror", pAnaError );
	    }
	}

	mxDestroyArray( pAnaError );
    }
    else if( Error )
    {
	dlclose( Module );
        mexErrMsgTxt( "An error blocked the command execution." );
	return;
    }

    dlclose( Module );
    return;
}
