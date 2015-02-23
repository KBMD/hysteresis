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

// As simple as I can get it, to make it work once ...

	int CurEntry, time_j, cp_j, time_previous, cp_previous, emax_i /* , e0_i */ ;  
		// all these are indices
	double         Ce[*TotalDataValues], ke0,  thalf_effect, nHill, q,            ec50, conc,  /*e0,*/ emax,  dt;
		// units:   ng/ml,              1/min, min,          none,  log10(ng/ml), ng/ml     arbitrary,  min

	ke0   = Params[0];  // effect site rate constant
	nHill = Params[1];  // the Hill coefficient n
	q     = Params[2];  // q := log10(EC50)

	thalf_effect = log(2)/ke0;  // natural logarithm i.e. ln(2)
	Derived[0] = thalf_effect;
	ec50 = pow(10.0, q);
	Derived[1] = ec50;
	
	for (CurEntry = 0; CurEntry < *TotalDataValues; CurEntry++) {
	// this function builds up the vector Ce(0) to Ce(*TotalDataValues) using the current parameters
		time_j = 2*CurEntry;
		cp_j   = 2*CurEntry + 1;
		if ( CurEntry == 0 ){
			dt = Abscissa[time_j];
			Ce[CurEntry] = 0;
		} else {
			time_previous = time_j - *NoOfAbscissaCols;     // i.e. the previous time index
			cp_previous = cp_j - *NoOfAbscissaCols;  // i.e. the previous Cp index   *******
			dt = Abscissa[time_j] - Abscissa[time_previous];  
			Ce[CurEntry] = Ce[CurEntry-1] + dt*ke0*(Abscissa[cp_previous] - Ce[CurEntry-1]);
				// representing dCe(t)/dt = ke0(Cp(t)-Ce(t))
		}

		emax_i           = CurEntry;  // really this is the signal vector that will be multiplied by Emax
		
		conc = Ce[CurEntry] ;  // *******
		Signal[emax_i]   = pow(conc, nHill)/ (pow(ec50, nHill) + pow(conc, nHill)) ;

		}

	return;
}
