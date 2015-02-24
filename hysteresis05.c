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

	int CurEntry, time_index, Cp_index, emax_index /* , e0_index */ ;  
	  // all these are indices
	double        ke0,   time,  time_previous, thalf_effect, nHill, q,            dt,     emax,  e0 ;
	  // units:  1/min,  min,   min,                         none,  log10(ng/ml), min,    units of effect
	double        ec50, Cp, Ce, Cp_previous, Ce_previous ;
	  // units:    ng/ml 
	  // Cp is the concentration of drug over time in the plasma, read in from a second abscissa column
	  // Ce represents the concentration of drug [over time] in the modeled effect compartment

	ke0   = Params[0];  // effect site rate constant
	nHill = Params[1];  // the Hill coefficient n that dictates the steepness of the plot of Ce -> effect
	q     = Params[2];  // q := log10(EC50), defined for convenience so that the Bayes Analysis Toolbox will
		// sample the EC50 prior prob. distribution more evenly (as traditionally plotted on a log axis)

	thalf_effect = log(2)/ke0;  // natural logarithm i.e. ln(2)
	Derived[0] = thalf_effect;
	ec50 = pow(10.0, q);
	Derived[1] = ec50;

	for (CurEntry = 0; CurEntry < *TotalDataValues; CurEntry++) {
	// this for loop estimates E(Ce(t)), using the current parameter values
		if ( CurEntry == 0 ){
			time_index = 0; 	// index to time  values to be read from Abscissa 0
			Cp_index   = 1; 	// index to Cp(t) values to be read from Abscissa 1
			time = Abscissa[time_index];
			Cp   = Abscissa[Cp_index  ];
			Ce = 0.0;  	// assumes no drug is in the effect compartment until time = 0
		} else {
			time_previous = time;
			Cp_previous   = Cp;
			Ce_previous   = Ce;
			time_index += *NoOfAbscissaCols;
			time = Abscissa[time_index];
			dt = time - time_previous;
			Cp_index   += *NoOfAbscissaCols;
			Cp = Abscissa[Cp_index];
			Ce = Ce_previous + dt*ke0*(Cp_previous - Ce_previous);
				// discrete version of  dCe(t)/dt = ke0(Cp(t)-Ce(t)), estimated using Euler's method
		}

		// Index the Signal matrix, size *TotalDataValues x *NoOfModelVectors, 
		// putting the values where the calling program expects to find them
		emax_index           = CurEntry;  // + 0*(*TotalDataValues)   // model vector 0
//		e0_index             = CurEntry + 1*(*TotalDataValues);       // model vector 1 
// ... and so on, if more model vectors ...
		Signal[emax_index]   = pow(Ce, nHill) / ( pow(Ce, nHill) + pow(ec50, nHill) ) ;
			// this is the first marginalized signal vector, whose amplitude will be called Emax
//		Signal[e0_index]     = 1.0;  
// this is the second marginalized signal vector, [1 1 1 ... 1], amplitude E0 (i.e. baseline effect)
		
		}

	return;
}

/*
		// I would use the Runge-Kutta method for Ce(t), but we made the test images using Euler's method, 
		// so why bias the results against "success"? Also, RK takes more computational steps, and
		// it probably matters since the for loop that contains it will be executed billions of times
		// for each test image (1,000 voxels x 1,920 time steps x 50^2 samples = 4.8E9).
		
		double rk1, rk2, rk3, rk4;  // temporary storage for Runge-Kutta steps
		double Ce_prime(double Cp_value, double Ce_value) {
			return( ke0*(Cp_value - Ce_value ); 	// dCe(t)/dt = ke0(Cp(t)-Ce(t))
		}
		
		// Estimates next value of Ce from the 4th-order Runge-Kutta method.
		// Interpolates to estimate the midpoint values of Cp(t) used in defining Ce'(t).
		rk1 = Ce_prime(Cp_previous, 		 Ce_previous);
		rk2 = Ce_prime((Cp_previous+Cp)/2.0, Ce_previous+rk1*dt/2);
		rk3 = Ce_prime((Cp_previous+Cp)/2.0, Ce_previous+rk2*dt/2); 
		rk4 = Ce_prime(Cp,                   Ce_previous+rk3*dt);
		Ce = Ce_previous + dt*(rk1+2*rk2+2*rk3+rk4)/6;
 */