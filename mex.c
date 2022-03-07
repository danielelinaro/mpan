#include "../include/Machine.h"
#include "../include/Macros.h"
#include "../include/Numbers.h"
#include "../include/Circuit.h"
#include "../include/topology.h"
#include "../include/Device.h"
#include "../include/Error.h"
#include "../include/Analysis.h"
#include "../include/parser.h"
#include "../include/control.h"
#include "../include/raw.h"
#include "../include/ui.h"
#include "../include/bzlib.h"
#include "../include/Globals.h"
#include "../include/utils.h"
#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <errno.h>
#include <stdarg.h>


extern int *gError;

extern int Uiparse();


int
PanMatlabGet( 
    char    *String, 
    double **ppArrayR, 
    double **ppArrayI, 
    char   **ppArrayS, 
    int     *pRows, 
    int     *pCols 
)
{
    struct MemWaveformData *pMemWavItem;
    struct CntrlSymbolData *pCntrVar;
    struct ParamData *pParam;
/*
** Begin of 'PanMatlabGet'
*/
    if( gCircuit->Aborting )
    {
	PrintErrorMessage( ERROR, NULL, 0 );
	LogLong( 4, "The command can not be executed since the simulator "
	            "was not correctly initialised.\n" );
	ResetError( 0 ); // Reset the error level;
        return( NO );
    }

    *ppArrayR = NULL;
    *ppArrayI = NULL;
    *ppArrayS = NULL;

    if( gParser.WaveformTable && 
        st_lookup( gParser.WaveformTable, String, (void **) &(pMemWavItem) ) )
    {
	if( pMemWavItem->Flag & MEMWAV_ANALYSIS )
	{
	    if( pMemWavItem->Type == MEMWAV_R_VECTOR_TYPE )
	    {
		*pRows      = pMemWavItem->I;
		*pCols      = 1;
		(*ppArrayR) = pMemWavItem->U.MemRvector;

		return( YES );
	    }
	    else if( pMemWavItem->Type == MEMWAV_C_VECTOR_TYPE )
	    {
		*pRows      = pMemWavItem->I;
		*pCols      = 1;
		(*ppArrayR) = pMemWavItem->U.MemRvector;
		(*ppArrayI) = pMemWavItem->U.MemIvector;

		return( YES );
	    }
	    else if( pMemWavItem->Type == MEMWAV_R_MATRIX_TYPE )
	    {
		*pRows      = pMemWavItem->Rows;
		*pCols      = pMemWavItem->Cols;
		(*ppArrayR) = (double *) pMemWavItem->U.MemRmtrx;

		return( YES );
	    }
	    else if( pMemWavItem->Type == MEMWAV_C_MATRIX_TYPE )
	    {
		*pRows      = pMemWavItem->Rows;
		*pCols      = pMemWavItem->Cols;
		(*ppArrayR) = (double *) pMemWavItem->U.MemRmtrx;
		(*ppArrayI) = (double *) pMemWavItem->U.MemImtrx;

		return( YES );
	    }
	    if( pMemWavItem->Type == MEMWAV_S_VECTOR_TYPE )
	    {
		*pRows      = pMemWavItem->I;
		*pCols      = 1;
		(*ppArrayS) = (char *) pMemWavItem->U.Svector;

		return( YES );
	    }
	    else if( pMemWavItem->Type == MEMWAV_UNDEF )
	    {
		PrintErrorMessage( ERROR, NULL, 0 );
	        LogLong( 4, "The <%s> variable exists in the waveform "
		    "data-base but its type was not defined. Possibly this "
		    "happened since the waveform was never saved.\n",
		    String );

		ResetError( 0 ); // Reset the error level;
	    }
	    else
	    {
		PrintErrorMessage( ERROR, NULL, 0 );
	        LogLong( 4, "The <%s> variable exists but its type "
		    "can not be handled in matlab/octave.\n", String );

		ResetError( 0 ); // Reset the error level;

		return( NO );
	    }
	}
    }
    else if( gParser.CntrTable &&
             st_lookup( gParser.CntrTable, String, (void **) &(pCntrVar) ) )
    {
	static RealNumber MatRealVarVal;

	switch( pCntrVar->Type & CNTRL_TYPE_MASK )
	{
	    case CNTRL_SCALAR_R_TYPE:
		*pRows      = 1;
		*pCols      = 1;
		(*ppArrayR) = &(pCntrVar->U.CntrlRvalue);
	        break;

	    case CNTRL_MATRIX_R_TYPE:
	        if( pCntrVar->SizeCount == 1 )
		{
		    *pRows      = pCntrVar->Sizes[0];
		    *pCols      = 1;
		    (*ppArrayR) = pCntrVar->U.CntrlRvector;
		}
	        else if( pCntrVar->SizeCount == 2 )
		{
		    if( pCntrVar->Sizes[1] == 1 )
		    {
			CntrConvertMtrxVectorToVector( pCntrVar );
			if( gError[0] >= ERROR )
			{
			    ResetError( 0 ); // Reset the error level;
			    return( NO );
			}
			*pRows      = pCntrVar->Sizes[0];
			*pCols      = 1;
			(*ppArrayR) = pCntrVar->U.CntrlRvector;
		    }
		    else
		    {
			*pRows      = pCntrVar->Sizes[0];
			*pCols      = pCntrVar->Sizes[1];
			(*ppArrayR) = (double *) pCntrVar->U.CntrlRmtrx;
		    }
		}
		else
		{
		    NotYetImplemented( __FILE__, __LINE__, 0 );
		}
	        break;
	    
	    case CNTRL_MATRIX_C_TYPE:
	        if( pCntrVar->SizeCount == 1 )
		{
		    *pRows      = pCntrVar->Sizes[0];
		    *pCols      = 1;
		    (*ppArrayR) = pCntrVar->U.CntrlRvector;
		    (*ppArrayI) = pCntrVar->U.CntrlIvector;
		}
	        else if( pCntrVar->SizeCount == 2 )
		{
		    if( pCntrVar->Sizes[1] == 1 )
		    {
			CntrConvertMtrxVectorToVector( pCntrVar );
			if( gError[0] >= ERROR )
			{
			    ResetError( 0 ); // Reset the error level;
			    return( NO );
			}
			*pRows      = pCntrVar->Sizes[0];
			*pCols      = 1;
			(*ppArrayR) = pCntrVar->U.CntrlRvector;
			(*ppArrayI) = pCntrVar->U.CntrlIvector;
		    }
		    else
		    {
			*pRows      = pCntrVar->Sizes[0];
			*pCols      = pCntrVar->Sizes[1];
			(*ppArrayR) = (double *) pCntrVar->U.CntrlRmtrx;
			(*ppArrayI) = (double *) pCntrVar->U.CntrlImtrx;
		    }
		}
		else
		{
		    NotYetImplemented( __FILE__, __LINE__, 0 );
		}
	        break;

	    default:
		PrintErrorMessage( ERROR, NULL, 0 );
	        LogLong( 4, "The <%s> variable exists but its type "
		    "can not be handled in matlab/octave.\n", String );

		ResetError( 0 ); // Reset the error level;

		return( NO );
	}

	return( YES );
    }
    else if( gParser.ParamTable && 
             st_lookup( gParser.ParamTable, String, (void **) &(pParam) ) )
    {
	if( pParam->Type & IP_COMMAND_LINE )
	{
	    PrintErrorMessage( ERROR, NULL, 0 );
	    LogLong( 4, "Parameter <%s> has been given in the command line "
			"but is not defined in the netlist.\n",
			pParam->Name );

	    ResetError( 0 ); // Reset the error level;

	    return( NO );
	}
	switch( pParam->Type & IP_PARAM_MASK )
	{
	    default:
		PrintErrorMessage( ERROR, NULL, 0 );
		LogLong( 4, "Parameter <%s> exists but its type is not "
		            "handled.\n", pParam->Name );

		ResetError( 0 ); // Reset the error level;

		return( NO );

	    case IP_NUMBER:
		*pRows = 1;
		*pCols = 1;
		(*ppArrayR) = ALLOC( RealNumber, 1 );
		if( NULL == (*ppArrayR) )
		{
		    PrintErrorMessage( NO_MEMORY, NULL, 0 );
		    return( NO );
		}
		(*ppArrayR)[0] = pParam->Value.Number;

		return( YES );
	}
    }
    else
    {
	char *ParamName;

	ParamName = rindex( String, HIER_MARK );

	if( ParamName )
	{
	    CellCallData *pI;

	    ParamName += 1;

	    int   Length   = ParamName - String;
	    char *InstName = ALLOC( char, Length + 10 );

	    if( NULL == InstName )
	    {
		PrintErrorMessage( NO_MEMORY, NULL, 0 );
		return( NO );
	    }
	    strncpy( InstName, String, Length );
	    InstName[Length-1] = (char) 0;

	    struct InstanceParamInfo ParamInfo, *pParamInfo = NULL;

	    if( gParser.GlobalCellCallTable && 
	        st_lookup( gParser.GlobalCellCallTable, InstName, 
		           (void **) &(pI) ) )
	    {
		struct InstanceParamInfo *(*pGetParamInfo)();
		struct InstanceKnot *pInstKnot;

		if( pI->pModel )
		{
		    ModelData *pModel = *(pI->pModel);

		    if( (pModel->Flags & PARSER_BUILTIN) ||
		        (pModel->Flags & PARSER_DEVMODEL) )
		    {
			pInstKnot = (struct InstanceKnot *) pI->pInstKnot;
			pGetParamInfo = 
			    pInstKnot->pDeviceDescriptor->pInstanceParamInfo;

			pParamInfo = (*pGetParamInfo)( pInstKnot, NULL, 
			    ParamName, &(ParamInfo) );
		    }
		}
	    }
	    if( pParamInfo )
	    {
		*pRows = 1;
		*pCols = 1;
		(*ppArrayR) = ALLOC( RealNumber, 1 );
		if( NULL == (*ppArrayR) )
		{
		    PrintErrorMessage( NO_MEMORY, NULL, 0 );
		    return( NO );
		}
		(*ppArrayR)[0] = pParamInfo->Value;

		return( YES );
	    }
	}
    }

    ResetError( 0 ); // Reset the error level;

    return( NO );
}


int PanMatlabExecuteCommand( char *String )
{
    if( gCircuit->Aborting )
    {
	PrintErrorMessage( ERROR, NULL, 0 );
	LogLong( 4, "The <%s> command can not be executed since the simulator "
	            "was not correctly initialised.\n", String );
	ResetError( 0 ); // Reset the error level;
        return( NO );
    }

    struct UiData *pUi;
    int Error;

    pUi = (struct UiData *) gGlobals.pUi;

    pUi->Mode = UI_MODE_MEX;

    UiResetInputBuffer();
    UiFillInputBuffer( String );
    Error = Uiparse();

    if( Error <= 0 || gError[0] >= ERROR || gGlobals.ExitStatus > 0 )
	Error = YES;
    else
        Error = NO;

    ResetError( 0 ); // Reset the error level;

    UiResetInputBuffer();

    return( Error );
}


int PanMatReadRawFile( 
    char *Path, 
    char *VariableName, 
    unsigned long *pSize,
    RealNumber **ppReal,
    RealNumber **ppImag )
{
    struct RawFileData *pRaw;

    CALLOC( pRaw, struct RawFileData, 1 );
    if( ! pRaw )
    {
	PrintErrorMessage( NO_MEMORY, NULL, 0 );
	return( NO );
    }

    char *FullPath;

    pRaw->Fd = PathfOpen( Path, &(FullPath) );
    if( ! pRaw->Fd )
    {
	PrintErrorMessage( ERROR, NULL, 0 );
	LogLong( 4, "Unable to open the <%s> rawfile.\n", Path );
	ResetError( 0 ); // Reset the error level;
	return( NO );
    }
    pRaw->Name = STRDUP( FullPath );
    RawReadFileHeader( pRaw );
    if( gError[0] >= ERROR )
    {
	ResetError( 0 ); // Reset the error level;
	return( NO );
    }

    if( pRaw->Flags & REAL_RAWFILE )
    {
	register int J;

	for( J = 0; J < pRaw->NoVariables; J++ )
	{
	    if( ! strcmp( pRaw->pVariables[J].Name, VariableName ) )
	    {
		RawReadVariableByIndex( pRaw, J );
		if( gError[0] >= ERROR )
		    return( NO );

		(*pSize)  = pRaw->NoPoints;
		(*ppReal) = pRaw->pVariables[J].U.pReal;
		pRaw->pVariables[J].U.pReal = NULL;

		(*ppImag) = NULL;

		break;
	    }
	}
	if( J >= pRaw->NoVariables )
	{
	    PrintErrorMessage( ERROR, NULL, 0 );
	    LogLong( 4, "The <%s> variable does not exist in the "
			"<%s> raw filename.\n", VariableName,
			Path );
	    ResetError( 0 ); // Reset the error level;
	    return( NO );
	}
    }
    else
	NotYetImplemented( __FILE__, __LINE__, 0 );

    ResetError( 0 ); // Reset the error level;

    fclose( pRaw->Fd );

    return( YES );
}

/*
** <input>  double * : the array storing values of instance parameters.
** <input>  int      : number of ports of this N port;
** <input>  double * : the array "v" of the port voltages;
** <input>  double * : the array "i" of the port currents;
** <output> double * : the array of the 'f(v,i)' values;
** <output> double **: the 'C' square matrix storing the derivatives of
**                     'f(v,i)' with respect to the 'v' port voltages;
** <output> double * : the 'R' square matrix storing the derivetives of
**                     'f(v,i)' with respect to the 'i' port currents;
** <input>  double   : the value of simulation time. It has meaning only in
**                     time domain analyses
*/


int
PanMatlabEvaluateNport(
    double *pParams,
    int     PortNumber,
    double *PortV,
    double *PortI,
    double *Rhs,
    double **CMtrx,
    double **RMtrx,
    double   Time,
    int      StVarNumber,
    char    *FuncName,
    void    *pF,
    int      MaxParams,
    char   **Keywords
)
{
    mxArray **RhsArg, **LhsArg;

    RhsArg = (mxArray **) mxMalloc( sizeof( mxArray *) * 8 );
    LhsArg = (mxArray **) mxMalloc( sizeof( mxArray *) * 4 );
    if( (! RhsArg) || (! LhsArg) )
    {
        PrintErrorMessage( NO_MEMORY, NULL, 0 );
	return( NO );
    }

    mwSize Dims[2];

    Dims[0] = MaxParams;
    Dims[1] = 1;

    RhsArg[0] = mxCreateStructArray(2,Dims,MaxParams, (const char **)Keywords);
    RhsArg[1] = mxCreateDoubleScalar( (double) PortNumber ); 
    RhsArg[2] = mxCreateDoubleMatrix( PortNumber, 1, mxREAL ); // PortV
    RhsArg[3] = mxCreateDoubleMatrix( PortNumber, 1, mxREAL ); // PortI
    RhsArg[4] = mxCreateDoubleScalar( (double) StVarNumber );
    RhsArg[5] = mxCreateDoubleMatrix( StVarNumber, 1, mxREAL ); // X
    RhsArg[6] = mxCreateDoubleMatrix( StVarNumber, 1, mxREAL ); // dX
    RhsArg[7] = mxCreateDoubleScalar( Time ); // Time

    double *RhsVPtr   = mxGetPr( RhsArg[2] );
    double *RhsIPtr   = mxGetPr( RhsArg[3] );
    double *RhsX      = mxGetPr( RhsArg[5] );
    double *RhsdX     = mxGetPr( RhsArg[6] );

    register int I;
    mxArray *pValue;

    for( I = 0; I < MaxParams; I++ )
    {
	pValue = mxCreateDoubleScalar( pParams[I] );
	mxSetField( RhsArg[0], I, Keywords[I], pValue );
    }

    for( I = 0; I < PortNumber; I++ )
    {
	RhsVPtr[I] = PortV[I];
	RhsIPtr[I] = PortI[I];
    }

    for( I = 0; I < StVarNumber; I++ )
    {
	RhsX[I]  = 0.0;
	RhsdX[I] = 0.0;
    }

    mexCallMATLAB( 3, LhsArg, 8, RhsArg, FuncName );

    if( mxGetClassID( LhsArg[0] ) != mxDOUBLE_CLASS )
    {
	PrintErrorMessage( ERROR, NULL, 0 );
	LogLong( 4, "The first returned variable of the <%s> control function "
	            "must be an array of real numbers.\n", FuncName );
	return( NO );
    }

    if( mxGetClassID( LhsArg[1] ) != mxDOUBLE_CLASS )
    {
	PrintErrorMessage( ERROR, NULL, 0 );
	LogLong( 4, "The second returned variable of the <%s> control function "
	            "must be an array of real numbers.\n", FuncName );
	return( NO );
    }

    if( mxGetClassID( LhsArg[2] ) != mxDOUBLE_CLASS )
    {
	PrintErrorMessage( ERROR, NULL, 0 );
	LogLong( 4, "The third returned variable of the <%s> control function "
	            "must be an array of real numbers.\n", FuncName );
	return( NO );
    }

    double *LhsRhsPtr   = mxGetPr( LhsArg[0] );
    double *LhsCMtrxPtr = mxGetPr( LhsArg[1] );
    double *LhsRMtrxPtr = mxGetPr( LhsArg[2] );

    register int J;
    register int ColIdx;

    for( I = 0; I < PortNumber; I++ )
    {
        Rhs[I] = LhsRhsPtr[I];

	ColIdx = I * PortNumber;

	for( J = 0; J < PortNumber; J++ )
	{
	    CMtrx[J][I] = LhsCMtrxPtr[ColIdx + J];
	    RMtrx[J][I] = LhsRMtrxPtr[ColIdx + J];
	}
    }

    mxDestroyArray(RhsArg[0]);
    mxDestroyArray(RhsArg[1]);
    mxDestroyArray(RhsArg[2]);
    mxDestroyArray(RhsArg[3]);
    mxDestroyArray(RhsArg[4]);
    mxDestroyArray(RhsArg[5]);
    mxDestroyArray(RhsArg[6]);
    mxDestroyArray(RhsArg[7]);

    mxDestroyArray(LhsArg[0]);
    mxDestroyArray(LhsArg[1]);
    mxDestroyArray(LhsArg[2]);

    mxFree( RhsArg );
    mxFree( LhsArg );

    return( YES );
}





int
PanMatlabSetUpNport(
    double **ppInstParams,
    char   ***ppKeywords,
    int    *pMaxParams,
    char   *FuncName,
    void   *pF,
    char   *ModelName,
    BOOLEAN ExportParams,
    double **ppModParams
)
{
    if( ExportParams )
    {
	if( *ppModParams )
	{
	    (*ppInstParams) = (*ppModParams);
	    return( YES );
	}
    }

    mxArray **LhsArg;

    LhsArg = (mxArray **) mxMalloc( sizeof( mxArray *) * 2 );
    if( (! LhsArg) )
    {
        PrintErrorMessage( NO_MEMORY, NULL, 0 );
	return( NO );
    }

    mexCallMATLAB( 1, LhsArg, 0, NULL, FuncName );

    if( ! mxIsStruct( LhsArg[0] ) )
    {
	PrintErrorMessage( ERROR, NULL, 0 );
	LogLong( 4, "The returned variable of the <%s> control function "
	            "must be a 'struct'.\n", FuncName );
	return( NO );
    }

    *pMaxParams = mxGetNumberOfFields( LhsArg[0] );

    register int I;

    if( ! ((*ppKeywords) ) )
    {

	(*ppKeywords) = ALLOC( char *, *pMaxParams + 1 );
	if( ! (*ppKeywords) )
	{
	    PrintErrorMessage( NO_MEMORY, NULL, 0 );
	    return( NO );
	}

	char *String;

	for( I = (*pMaxParams) - 1; I >= 0; I-- )
	{
	    String = (char *) mxGetFieldNameByNumber( LhsArg[0], I );

	    (*ppKeywords)[I] = STRDUP( String );
	    if( ! (*ppKeywords)[I] )
	    {
		PrintErrorMessage( NO_MEMORY, NULL, 0 );
		return( NO );
	    }
	}
    }

    if( ExportParams )
    {
	ASSERT( ! (*ppModParams) )

	(*ppModParams) = ALLOC( RealNumber, *pMaxParams + 1 );
	if( ! (*ppModParams) )
	{
	    PrintErrorMessage( NO_MEMORY, NULL, 0 );
	    return( NO );
	}
	(*ppInstParams) = (*ppModParams);

	if( mexPutVariable( "caller" , ModelName, LhsArg[0] ) )
	{
	    PrintErrorMessage( ERROR, NULL, 0 );
	    LogLong( 4, "Unable to export the parameter 'struct' of the "
			"<%s> control function.\n", FuncName );
	}
    }
    else
    {
	(*ppInstParams) = ALLOC( RealNumber, *pMaxParams + 1 );
	if( ! (*ppInstParams) )
	{
	    PrintErrorMessage( NO_MEMORY, NULL, 0 );
	    return( NO );
	}
    }

    mxArray *pItem;
    double *pValue;
    int NumberOfElements;

    for( I = (*pMaxParams) - 1; I >= 0; I-- )
    {
	pItem = mxGetFieldByNumber( LhsArg[0], 0, I );

	if( (!pItem) || (mxGetClassID( pItem ) != mxDOUBLE_CLASS) )
	{
	    char *String = (char *) mxGetFieldNameByNumber( LhsArg[0], I );

	    PrintErrorMessage( ERROR, NULL, 0 );
	    LogLong( 4, "The <%s> item of the 'struct' of the <%s> control "
		"function must be a real number.\n", String, FuncName );
	    return( NO );
	}

	NumberOfElements = mxGetNumberOfElements( pItem );
	if( NumberOfElements != 1 )
	{
	    char *String = (char *) mxGetFieldNameByNumber( LhsArg[0], I );

	    PrintErrorMessage( ERROR, NULL, 0 );
	    LogLong( 4, "The <%s> item of the 'struct' of the <%s> control "
		"function must be a real number.\n", String, FuncName );
	    return( NO );
	}

	pValue = mxGetPr( pItem );
	if( ! pValue )
	{
	    char *String = (char *) mxGetFieldNameByNumber( LhsArg[0], I );

	    PrintErrorMessage( ERROR, NULL, 0 );
	    LogLong( 4, "Unable to get value of the <%s> item of the 'struct' "
	        "of the <%s> control function.\n", String, FuncName );
	    return( NO );
	}
	(*ppInstParams)[I] = *pValue;
    }

    mxDestroyArray(LhsArg[0]);

    mxFree( LhsArg );

    return( YES );
}



static void MatlabFlushOutput()
{
    if( gGlobals.MatlabRedraw )
	mexEvalString( "drawnow;" );

    fflush( stdout );

    if( errno == EAGAIN )
	errno = 0;
}





BOOLEAN
MatlabGetArray( 
    char           *Name, 
    unsigned int   *pType, 
    unsigned int   *pNDims, 
    unsigned long **pDims, 
    unsigned int   *pElem, 
    GenericPtr     *pGR, 
    GenericPtr     *pGI,
    GenericPtr     *pMemory
)
{
    static RealNumber RealScalar;

    mxArray *pA = mexGetVariable( "caller", Name );

    if( pA )
    {
	mwSize NDims, Nelem, Cmplx;
	RealNumber *pMatR;

	NDims  = mxGetNumberOfDimensions( pA );
	*pDims = (unsigned long *) mxGetDimensions( pA );
        Nelem  = mxGetNumberOfElements( pA );
	Cmplx  = mxIsComplex( pA );

	switch( mxGetClassID( pA ) )  
	{
	    case mxINT8_CLASS:   
	    case mxUINT8_CLASS: 
	    case mxINT16_CLASS:
	    case mxUINT16_CLASS:
	    case mxINT32_CLASS: 
	    case mxUINT32_CLASS:
	    case mxINT64_CLASS: 
	    case mxUINT64_CLASS:
	        NotYetImplemented( __FILE__, __LINE__, 0 );
	        
	    case mxSINGLE_CLASS:
	        NotYetImplemented( __FILE__, __LINE__, 0 );

	    case mxDOUBLE_CLASS:
	    {
		if( Nelem == 1 )
		{
		    if( Cmplx )
			NotYetImplemented( __FILE__, __LINE__, 0 );
		    else
		    {
			RealNumber *pR;

			*pType = CNTRL_SCALAR_R_TYPE;

			pMatR = mxGetPr( pA );

			RealScalar = *pMatR;

			*pGR = (GenericPtr) &(RealScalar);

			mxDestroyArray( pA );
			return( YES );
		    }
		}
		else if( NDims == 1 )
		{
		    if( Cmplx )
			NotYetImplemented( __FILE__, __LINE__, 0 );
		    else
		    {
			RealVector pR;

			*pType  = CNTRL_MATRIX_R_TYPE;
			*pNDims = 1;
			*pElem  = Nelem;

			pMatR = mxGetPr( pA );

			pR = ALLOC( RealNumber, Nelem );
			if( NULL == pR )
			{
			    PrintErrorMessage( NO_MEMORY, NULL, 0 );
			    mxDestroyArray( pA );
			    return( NO );
			}
			if( pMemory )
			    RecordAllocation( pMemory, pR );

			COPY( RealNumber, pR, pMatR, Nelem );

			*pGR = (GenericPtr) pR;

			mxDestroyArray( pA );
			return( YES );
		    }
		}
		else if( NDims == 2 && 1 == (*pDims)[0] )
		{
		    if( Cmplx )
			NotYetImplemented( __FILE__, __LINE__, 0 );
		    else
		    {
			RealMatrix pMtrx;
			unsigned int I, J;

			*pType  = CNTRL_MATRIX_R_TYPE;
			*pNDims = 2;
			*pElem  = Nelem;

			pMatR = mxGetPr( pA );

			pMtrx = ALLOC( RealVector, 1 );
			if( NULL == pMtrx )
			{
			    PrintErrorMessage( NO_MEMORY, NULL, 0 );
			    mxDestroyArray( pA );
			    return( NO );
			}
			if( pMemory )
			    RecordAllocation( pMemory, pMtrx );

			pMtrx[0] = ALLOC( RealNumber, (*pDims)[1] + 1 );
			if( NULL == pMtrx[0] )
			{
			    PrintErrorMessage( NO_MEMORY, NULL, 0 );
			    mxDestroyArray( pA );
			    return( NO );
			}
			if( pMemory )
			    RecordAllocation( pMemory, pMtrx[0] );

			COPY( RealNumber, pMtrx[0], pMatR, (*pDims)[1] );

			*pGR = (GenericPtr) pMtrx;

			mxDestroyArray( pA );

			return( YES );
		    }
		}
		else if( NDims == 2 && 1 == (*pDims)[1] )
		{
		    NotYetImplemented( __FILE__, __LINE__, 0 );
		}
		else if( NDims == 2 )
		{
		    RealMatrix pMtrx;
		    unsigned int I, J;

		    *pType  = CNTRL_MATRIX_R_TYPE;
		    *pNDims = 2;
		    *pElem  = Nelem;

		    pMatR = mxGetPr( pA );

		    pMtrx = ALLOC( RealVector, (*pDims)[1] + 1 );
		    if( NULL == pMtrx )
		    {
			PrintErrorMessage( NO_MEMORY, NULL, 0 );
			mxDestroyArray( pA );
			return( NO );
		    }
		    if( pMemory )
			RecordAllocation( pMemory, pMtrx );

		    for( I = 0; I < (*pDims)[1]; I++ )
		    {
			pMtrx[I] = ALLOC( RealNumber, (*pDims)[0] + 1 );
			if( NULL == pMtrx[I] )
			{
			    PrintErrorMessage( NO_MEMORY, NULL, 0 );
			    mxDestroyArray( pA );
			    return( NO );
			}
			if( pMemory )
			    RecordAllocation( pMemory, pMtrx[I] );

			COPY( RealNumber, pMtrx[I], &(pMatR[(*pDims)[0]*I]), 
			                  (*pDims)[0] );
		    }

		    *pGR = (GenericPtr) pMtrx;

		    mxDestroyArray( pA );

		    return( YES );
		}
		else
		{
		    mxDestroyArray( pA );
		    return( NO );
		}
	    }

	    default: 
		mxDestroyArray( pA );
	        return( NO );
	}
    }

    mxDestroyArray( pA );

    return( NO );
}


static int MyMexPrintf( const char *Format, ... ) 
{
    va_list Args;
    int Length;

    if( gGlobals.MexStringSize <= 0 )
    {
	gGlobals.MexStringSize += 100;
	gGlobals.pMexString = ALLOC( char, gGlobals.MexStringSize + 1 );
	if( NULL == gGlobals.pMexString )
	{
	    RECORD_ERROR( NO_MEMORY, 0 );
	    return( 0 );
	}
    }

    while( YES )
    {
	va_start( Args, Format );
	Length = vsnprintf( gGlobals.pMexString, gGlobals.MexStringSize - 1,
			    Format, Args );
	va_end( Args );
	if( Length + 1 < gGlobals.MexStringSize && Length > 0 )
	    break;

	gGlobals.MexStringSize += 100;
	REALLOC( gGlobals.pMexString, char, gGlobals.MexStringSize + 1 );
	if( NULL == gGlobals.pMexString )
	{
	    PrintErrorMessage( NO_MEMORY, NULL, 0 );
	    return( 0 );
	}
    }
    return( mexPrintf( gGlobals.pMexString ) );
}


void MatlabInit()
{
    extern void GlobalSetPrintMessage();

    GlobalSetPrintMessage( MyMexPrintf, MatlabFlushOutput );

    gGlobals.MatlabNportEval  = (void *) PanMatlabEvaluateNport;
    gGlobals.MatlabNportSetUp = (void *) PanMatlabSetUpNport;

    if( gCircuit && gCircuit->LogFileFd )
    {
	fclose( gCircuit->LogFileFd );
	gCircuit->LogFileFd = NULL;
    }
    RawCloseFolder();

    struct UiData *pUi = (struct UiData *) gGlobals.pUi;

    pUi->GetArray = MatlabGetArray;
}



void PanMatlabRedraw( char Flag )
{
    gGlobals.MatlabRedraw = (BOOLEAN) Flag;
}
