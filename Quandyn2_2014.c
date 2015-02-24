#include <stdio.h>
#include <math.h>

void model_(int *CurSet,
	int *NoOfParams,
	int *NoOfDerived,
	int *TotalDataValues,
	int *MaxNoOfDataValues,
	int *NoOfDataCols,
	int *NoOfAbscissaCols,
	int *NoOfModelVectors,
	double  Params[],
	double  Derived[],
	double  Abscissa[],
	double  Signal[]){

	int NoOfDoses = 4;
	int Emax_i, Constant_i, LinAmp_i, QuadAmp_i;
	double N = 1.0;
	double D[NoOfDoses];
	D[0] = 1.0;
	D[1] = 1.0;
	D[2] = 1.0;
	D[3] = 1.0;
	double TimeOfDose[NoOfDoses];
	TimeOfDose[0] = 8.0;
	TimeOfDose[1] = 16.0;
	TimeOfDose[2] = 24.0;
	TimeOfDose[3] = 32.0;
	int CurEntry, CurDose;
	double tHalf,EC50,TS,C,U,T;

	EC50  = Params[0];
	TS    = Params[1];
	tHalf = Params[2];
	
	for (CurEntry = 0; CurEntry < *TotalDataValues; CurEntry++){
		C = 0.0;
		for (CurDose = 0; CurDose < NoOfDoses; CurDose++){
			T = Abscissa[CurEntry] - TS - TimeOfDose[CurDose];
			if ( T < 0.0 ){
				U = 0.0;
			} else {
				U = 1.0;
			}
			C = C + (D[CurDose])*(pow(0.5,(T/tHalf)))*U;
		}
		
		Emax_i     = CurEntry;
		Constant_i = CurEntry + 1*(*TotalDataValues);
		LinAmp_i   = CurEntry + 2*(*TotalDataValues);
		QuadAmp_i  = CurEntry + 3*(*TotalDataValues);
		
		Signal[Emax_i]     = pow(C,N)/(pow(EC50,N) + pow(C,N));
		Signal[Constant_i] = 1.0;
		Signal[LinAmp_i]   = Abscissa[CurEntry];
		Signal[QuadAmp_i]  = Abscissa[CurEntry]*Abscissa[CurEntry];		
	}

	return;
}
