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
	mexErrMsgTxt( "Error: missing waveform. Usage: panget('waveform')");
	return;
    }

    if( ! mxIsChar(prhs[0]))
    {
        mexErrMsgTxt( "Error: waveform must be a string. "
	              "Usage: y = panget('waveform')" );
	return;
    }
    if( nlhs != 1 )
    {
	mexErrMsgTxt( "Error: output variable is required. "
	              "Usage: y = panget('waveform')");
	return;
    }

    char *ShlPath = (char *) getenv( "PAN_MAT_SHL_PATH" );
    char *Path;

    if( ShlPath )
    {
        Path = (char *) malloc((strlen(ShlPath)+strlen(PAN_MAT_SHL_NAME)+20) *
	                        sizeof( char ) );
	if( NULL == Path )
	{
	     mexErrMsgTxt( "Unable to allocate memory.\n" );
	     return;
	}

	sprintf( Path, "%s/%s", ShlPath, PAN_MAT_SHL_NAME );
    }
    else
    {
        Path = (char *) malloc((strlen(PAN_MAT_SHL_NAME)+20) * sizeof(char));
	if( NULL == Path )
	{
	     mexErrMsgTxt( "Unable to allocate memory.\n" );
	     return;
	}

	sprintf( Path, "%s", PAN_MAT_SHL_NAME );
    }

    Module = dlopen( Path, RTLD_LAZY | RTLD_DEEPBIND | RTLD_NOLOAD );
    if( NULL == Module )
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

    int (*Entry)( char *, double **, double **, char **, int *, int *);
    char *EntryName = "PanMatlabGet";

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

    size_t CharNum;
    char *MemWaveformName;

    CharNum = mxGetN( prhs[0]);

    MemWaveformName = mxMalloc( 2 + CharNum );
    if( NULL == MemWaveformName )
    {
	mexErrMsgTxt( "No more memory.\n" );
	return;
    }

    mxGetString( prhs[0], MemWaveformName, 1 + CharNum );

    int Rows, Cols;
    double *pWavArrayR, *pWavArrayI;
    char   *pWavArrayS;

    pWavArrayR = pWavArrayI = 0;

    if( ! (Entry)( MemWaveformName, &(pWavArrayR), &(pWavArrayI), &(pWavArrayS),
                   &(Rows), &(Cols) ) )
    {
	dlclose( Module );

	int Count, Length;
	char *MexErrBuffer;

	Length = strlen( MemWaveformName ) + 300;
	MexErrBuffer = mxCalloc( Length, sizeof( char ) );
	if( NULL == MexErrBuffer )
	{
	    mexErrMsgTxt( "No more memory.\n" );
	    return;
	}

	Count = sprintf( MexErrBuffer, "The <%s> variable can not be found in "
	    "the simulator data-bases.\n\n", MemWaveformName );

	if( Count >= Length )
	    abort();

	mexErrMsgTxt( MexErrBuffer );

	mxFree( MemWaveformName );

        return;
    }

    mxFree( MemWaveformName );

    if( pWavArrayI )
    {
	plhs[0] = mxCreateDoubleMatrix( Rows, Cols, mxCOMPLEX );

	double *pMexArrayR = mxGetPr( plhs[0] );
	double *pMexArrayI = mxGetPi( plhs[0] );

	if( 1 == Cols )
	{
	    memcpy( (void *) pMexArrayR, (const void *) pWavArrayR, 
		    sizeof(double) * (Rows * Cols) );

	    memcpy( (void *) pMexArrayI, (const void *) pWavArrayI, 
		    sizeof(double) * (Rows * Cols) );
	}
	else
	{
	    register unsigned int I, J;

	    for( J = 0; J < Cols; J++ )
	    {
		for( I = 0; I < Rows; I++ )
		{
		    *pMexArrayR = ((double **) pWavArrayR)[I][J];
		    *pMexArrayI = ((double **) pWavArrayI)[I][J];
		    pMexArrayR++;
		    pMexArrayI++;
		}
	    }
	}
    }
    else if( pWavArrayR )
    {
	plhs[0] = mxCreateDoubleMatrix( Rows, Cols, mxREAL );

	double *pMexArrayR = mxGetPr( plhs[0] );

	if( 1 == Cols )
	{
	    memcpy( (void *) pMexArrayR, (const void *) pWavArrayR,
		    sizeof(double) * (Rows * Cols) );
	}
	else
	{
	    register unsigned int I, J;

	    for( J = 0; J < Cols; J++ )
	    {
		for( I = 0; I < Rows; I++ )
		{
		    *pMexArrayR = ((double **) pWavArrayR)[I][J];
		    pMexArrayR++;
		}
	    }
	}
    }
    else if( pWavArrayS )
    {
        if( 1 == Cols )
	{
	    register unsigned int I;
	    mxArray *pMexArrayS;
	    char    **pArrayS;

	    plhs[0] = mxCreateCellMatrix( 1, Rows );

	    pArrayS = (char **) pWavArrayS;

	    for( I = 0; I < Rows; I++ )
	    {
		pMexArrayS = mxCreateString( pArrayS[I] );
		if( NULL == pMexArrayS )
		{
		    mexErrMsgTxt( "No more memory.\n" );
		    return;
		}
		mxSetCell( plhs[0], I, pMexArrayS );
	    }
	}
	else
	{
	    register unsigned int I, J;
	    mxArray   *pMexArrayS;
	    char    ***pArrayS;

	    plhs[0] = mxCreateCellMatrix( Rows, Cols );

	    pArrayS = (char ***) pWavArrayS;

	    for( I = 0; I < Cols; I++ )
	    {
		for( J = 0; J < Rows; J++ )
		{
		    pMexArrayS = mxCreateString( pArrayS[J][I] );
		    if( NULL == pMexArrayS )
		    {
			mexErrMsgTxt( "No more memory.\n" );
			return;
		    }
		    mxSetCell( plhs[0], I*Rows + J, pMexArrayS );
		}
	    }
	}
    }

    dlclose( Module );
    return;
}
