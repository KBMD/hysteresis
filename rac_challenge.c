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

	int CurEntry, tindex, cindex;
	double T, R, K2sum, K2diff, K2, k2a, v, gamma, tau, dt, DVR;

	T = Params[0];
	R = Params[1];
	K2 = Params[2];
	k2a = Params[3];
	gamma = Params[4];
	tau = Params[5];

	DVR = K2/k2a;
	
	Derived[0] = DVR;

	//K2 = (K2sum + K2diff)/2;
	//k2a = (K2sum - K2diff)/2;
	for (CurEntry = 0; CurEntry < *TotalDataValues; CurEntry++)
	{
		tindex = 2*CurEntry;
		cindex = 2*CurEntry + 1;
		if ( Abscissa[tindex] > T ){
			v = 1.0;
		} else {
			v = 0.0;
		}
		
		if ( CurEntry < 1 ){
			dt = Abscissa[tindex];
			Signal[CurEntry] = R*(Abscissa[cindex]);
		} else {
			dt = Abscissa[tindex] - Abscissa[tindex-2];
			Signal[CurEntry] = Signal[CurEntry-1] + R*(Abscissa[cindex] - Abscissa[cindex-2]) + K2*dt*Abscissa[cindex-2]-dt*Signal[CurEntry-1]*(k2a + gamma*v*exp(-tau*(Abscissa[tindex] - T)));
		}
	}

	return;
}
