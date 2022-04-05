#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "mex.h"

#define MEX_ERROR_BUFFER_SIZE 1000
#define PAN_MAT_SHL_NAME      "panMat.so"

static void *Module = (void *) 0;

static void *GetEntry( char *Path, void *Module, const char *EntryName )
{
    void (*Entry)();
    Entry = dlsym( Module, EntryName );
    if( ! Entry )
    {
	dlclose( Module );

	int Count, Length;
	char *MexErrBuffer;
	char *Format = "The <%s> evaluate routine is not found in <%s> shared "
	               "module.\n";

	Length = strlen( Path ) + strlen( EntryName ) + 100;
	MexErrBuffer = mxCalloc( Length, sizeof( char ) );
	if( ! MexErrBuffer )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return( 0 );
	}

	Count = sprintf( MexErrBuffer, Format, EntryName, Path );
	if( Count >= Length )
	    abort();

	mexErrMsgTxt( MexErrBuffer );
	return( 0 );
    }
    return( Entry );
}




void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    static void *Module = NULL;
    size_t  CharNum;
    int (*Entry)();
    char *CommandLine;

    if( nrhs != 1 )
    {
	mexErrMsgTxt( "Error: missing filename. Usage: pannet('filename')");
	return;
    }

    if( ! mxIsChar(prhs[0]))
    {
        mexErrMsgTxt( "Error: filename must be a string. "
	              "Usage: pannet('filename')" );
	return;
    }
    if( nlhs != 0 )
    {
	mexErrMsgTxt( "Error: output variable is not required. "
	              "Usage: pannet('filename')");
	return;
    }

    char *ShlPath = (char *) getenv( "PAN_MAT_SHL_PATH" );
    char *Path;

    if( ShlPath )
    {
        Path = (char *) malloc( (strlen(ShlPath) + strlen(PAN_MAT_SHL_NAME) + 20) *
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
        Path = (char *) malloc((strlen(PAN_MAT_SHL_NAME)+20) * sizeof( char ) );
	if( ! Path )
	{
	     mexErrMsgTxt( "Unable to allocate memory.\n" );
	     return;
	}

	sprintf( Path, "%s", PAN_MAT_SHL_NAME );
    }

    if( Module )
        dlclose( Module );

    Module = dlopen( Path, RTLD_LAZY | RTLD_DEEPBIND | RTLD_GLOBAL );
    if( ! Module )
    {
	char *String = dlerror();
	if( String )
	{
	    mexPrintf( "Reason for loading failure is \"%s\"\n", String );
	}

	int Count, Length;
	char *MexErrBuffer;
	char *Format = "The <%s> shared library can not be loaded.\n";

	Length = strlen( Path ) + strlen( Format ) + 10;
	MexErrBuffer = mxCalloc( Length, sizeof( char ) );
	if( ! MexErrBuffer )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return;
	}
	
	Count = sprintf( MexErrBuffer, Format, Path );
	if( Count >= Length )
	    abort();

	mexErrMsgTxt( MexErrBuffer );
	return;
    }
/*
*/
    if( ! (Entry = GetEntry( Path, Module, "InitialiseGlobals" ) ) )
        return;
    (Entry)();
/*
*/
    if( ! (Entry = GetEntry( Path, Module, "MatlabPanInit" ) ) )
        return;
/*
*/
    free( Path );

    CharNum = mxGetN( prhs[0]);

    CommandLine = mxMalloc( 2 + CharNum );
    if( NULL == CommandLine )
    {
	mexErrMsgTxt( "No more memory.\n" );
	return;
    }

    mxGetString( prhs[0], CommandLine, 1 + CharNum  );

    register char *pCr;
    char **ppArgs, *pCl;
    int ArgCount = 1;

    ppArgs = (char **) malloc( sizeof( char * ) );
    if( ! ppArgs )
    {
	mexErrMsgTxt( "No more memory.\n" );
	return;
    }
    ppArgs[0] = (char *) malloc( sizeof( char ) );
    if( ! ppArgs )
    {
	mexErrMsgTxt( "No more memory.\n" );
	return;
    }
    ppArgs[0] = (char) 0;

    for( pCr = CommandLine; *pCr && (*pCr == ' ' || *pCr == '\t'); pCr++ );
    pCl = pCr;

    while( *pCr )
    {
        if( *pCr == ' ' || *pCr == '\t' )
	{
	    *pCr = 0;

	    ppArgs = (char **) realloc( ppArgs, sizeof(char *) * (ArgCount+1) );
	    if( ! ppArgs )
	    {
		mexErrMsgTxt( "No more memory.\n" );
		return;
	    }

	    ppArgs[ ArgCount ] = (char *) malloc(sizeof(char)*(strlen(pCl)+10));
	    if( ! ppArgs[ ArgCount ] )
	    {
		mexErrMsgTxt( "No more memory.\n" );
		return;
	    }

	    strcpy( ppArgs[ ArgCount ], pCl );

	    ArgCount += 1;

	    for( pCr++; *pCr && (*pCr == ' ' || *pCr == '\t'); pCr++ );

	    pCl = pCr;
	}
	else
	    pCr += 1;
    }

    if( *pCl )
    {
	ppArgs = (char **) realloc( ppArgs, sizeof(char *) * (ArgCount+1) );
	if( ! ppArgs )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return;
	}

	ppArgs[ ArgCount ] = (char *) malloc(sizeof(char)*(strlen(pCl)+10));
	if( ! ppArgs[ ArgCount ] )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return;
	}

	strcpy( ppArgs[ ArgCount ], pCl );

	ArgCount += 1;
    }

    mxFree( CommandLine );

    int Error = (Entry)( ArgCount, ppArgs );

    mxArray *pAnaError = mexGetVariable( "global", "MPanerror" );

    if( pAnaError )
    {
	mwSize Nelem = mxGetNumberOfElements( pAnaError );
	double *pDoubleData = (double *) mxGetData( pAnaError );

	if( Nelem == 1 )
	{
	    pDoubleData[0] = (double) Error;
	    mexPutVariable( "global", "MPanerror", pAnaError );
	}

	mxDestroyArray( pAnaError );
    }
    else if( Error )
	mexErrMsgTxt( "A severe error blocked the command execution." );
}
