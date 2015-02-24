
# coding: utf-8
# See hysteresis_plotting iPython notebook file for more details and explanations.
import numpy as np
import matplotlib.pyplot as plt

# ### Definitions: plotting parameters
figure_size = (5,6)  # figsize=(w,h) in inches
dots_per_inch = 600  # dpi for figures

# ### Definitions: time axis
time_step = 0.25
start_time = 0.0
duration = 480.0
n_rows = int(1+duration/time_step)

# ### Definitions: PKPD parameters   
# From Contin et al 2001, Table 4
# See table in effect_compartment_modeling_20141025.xlsx
ke0s = ( 0.002502336, 0.005211633, 0.008886502, 0.024755256, 0.034657359, 0.138629436)
nHills = ( 1, 2, 5, 7, 18, 49 )
ec50s = ( 100, 200, 290, 600, 940, 1200 )

Ce = np.zeros( n_rows )
effect = np.zeros( n_rows )

#### Open and read data file in CSV format
# ```python
# !xcopy C:\Users\kevin\Desktop\sync\hysteresis_phMRI\hysteresis_mapping_time_courses_20150218.csv .
# ```
# or ... later, just move the Excel formula for Cp(t) here (and for C2(t)), and forget the CSV altogether

HY_name = ( 'best', 'HY1', 'HY2', 'HY3', 'HY4', 'worst' )

for maint in ( 'maint', 'no' ):
	Cpcode = 'Cp_'+maint
	with open('hysteresis_mapping_time_courses_20150218.csv', 'rb') as datafile:
		data = np.genfromtxt(datafile, delimiter=",", names=True, skip_header=3)
	Cp = data[Cpcode]
	times = data['time_min']  # time, in minutes, from data file
	# **WARNING  This assumes data file time axis matches definitions above.** 
	# **Alternatively, generate it from the definitions above:**
	#         times = np.arange(start_time, duration+time_step, time_step)
	# or use times.size in place of n_rows

	for HY_num in ( 0, 1, 2, 3, 4 ,5 ):
	
		figure_name = HY_name[HY_num] + '_' + maint + '_2plots.png'
		ke0 = ke0s[HY_num]
		t_half_effect = np.log(2)/ke0
		nHill = nHills[HY_num]
		ec50 = ec50s[HY_num]

		# ### Calculate Ce(t)
		# For now, try just our fake little Newton's method iteration.
		for i in range(0,times.size-1) :
			Ce[i+1] = Ce[i] + (times[i+1]-times[i])*ke0*(Cp[i]-Ce[i])

		# ### Calculate effect(t)
		# _Ignores scaling by Emax and shifting by e0._
		effect = Ce**nHill/(ec50**nHill + Ce**nHill)

		# ### Plot Cp(t) and Ce(t), vs. EC50, and effect(t).
		figure = plt.figure(figsize=figure_size) 
		figure.clear

		ax1 = figure.add_subplot(2,1,1)
		ax1.plot(times,Cp,'black',linewidth=2)
		ax1.plot(times,Ce,'black',linestyle='--',linewidth=2)
		ax1.axhline(ec50,color='gray',linewidth=1)
		ax1.axis((start_time,duration,0,3200))
		# ax1.set_xlabel('time (min)', fontsize=12)
		ax1.set_ylabel('concentration (ng/ml)')
		ax1.legend(['plasma','effect site','EC50'],fontsize=10)

		ax2 = figure.add_subplot(2,1,2)
		ax2.plot(times,effect, 'red',linewidth=2)
		ax2.axis((start_time,duration,0,1))
		ax2.set_xlabel('time (min)', fontsize=12)
		ax2.set_ylabel('effect (fraction of Emax)')
		ax2.legend(['effect'],fontsize=10)

		figure.savefig(figure_name, dpi=dots_per_inch)  
		print('')
		print(figure_name + ' uses the following parameters:')
		print('ke0, t_half_effect, ec50, nHill')
		print(ke0, t_half_effect, ec50, nHill)
		print('Units: 1/min, min, ng/ml, unitless')
	
