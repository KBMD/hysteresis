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

	int CurEntry, time_j, cp_j, time_previous, cp_previous, emax_i, e0_i;  
		// all these are indices
	double         Ce[*TotalDataValues], ke0,   thalf_effect,  nHill,  q,             ec50 ,  e0, emax,  dt;
		// units:   ng/ml,              1/min,  min,           none,   log10(ng/ml),  ng/ml,  arbitrary, min

	ke0   = Params[0];  // effect site rate constant
	nHill = Params[1];  // the Hill coefficient n
	q     = Params[2];  // q := log10(EC50)
	e0    = Params[3];  // E(C=0) (marginalized; for the 2/2015 simulations, = 0)
	emax  = Params[4];  // Emax   (marginalized)

	thalf_effect = log(2)/ke0;  // natural logarithm i.e. ln(2)
	Derived[0] = thalf_effect;
	ec50 = pow(10.0, q);
	Derived[1] = ec50;
	
	double pct_effect(double conc) {
		// return ( e0 + emax * conc**nHill/ (ec50**nHill + conc**nHill) );
		return ( pow(conc, nHill)/ (pow(ec50, nHill) + pow(conc, nHill)) );
	}
	
	for (CurEntry = 0; CurEntry < *TotalDataValues; CurEntry++) {
	// this function builds up the vector Ce(0) to Ce(*TotalDataValues) using the current parameters
		time_j = 2*CurEntry;
		cp_j   = 2*CurEntry + 1;
		// when ( 2 == *NoOfAbscissaCols ), 
		//   Abscissa[2j]   = j'th row of the first  column in the abscissa input file =    t_j
		//   Abscissa[2j+1] = j'th row of the second column in the abscissa input file = Cp(t_j)
		if ( CurEntry == 0 ){
			dt = Abscissa[time_j];
			Ce[CurEntry] = 0;
		} else {
			time_previous = time_j - *NoOfAbscissaCols;     // i.e. the previous time index
			cp_previous = cp_previous - *NoOfAbscissaCols;  // i.e. the previous Cp index
			dt = Abscissa[time_j] - Abscissa[time_previous];  
			Ce[CurEntry] = Ce[CurEntry-1] + dt*ke0*(Abscissa[cp_previous] - Ce[CurEntry-1]);
				// representing dCe(t)/dt = ke0(Cp(t)-Ce(t))
		}

		emax_i           = CurEntry;  // really this is the signal vector that will be multiplied by Emax
		e0_i             = CurEntry + 1*(*TotalDataValues);  // and a vector of 1's to be multiplied by e0 and added to the above
		
		Signal[emax_i]   = pct_effect(Abscissa[cp_j]);
		Signal[e0_i]     = 1.0;

		}

	return;
}

// in case I want to do the full PK-PD modeling later:

/* 
	double    body_mass, loading_duration, loading_dose,  maintenance_rate;
		// units:   kg,  min,              ng = mg/1E6,   ng/min = (mg/1E6)/min
	double         ke0,    VOD,  thalf_effect;
		// units:  1/min,  ml/(70kg),   min
*/

/*
	body_mass = Params[0];
	loading_duration = Params[1];
	loading_dose = Params[2];
	maintenance_rate = Params[3];
	VOD = Params[5];  // units = ml, default 70,000/(70kg)
	Vp  = Params[6];  // units = ml, default  2,800/(70kg)
*/

/*
		if ( Abscissa[time_j] < loading_duration ){
			dose = loading_dose;
		} else {
			dose = maintenance_rate;
		}
*/
