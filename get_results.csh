#!/bin/csh

set log = /data/nil-bluearc/black/quandyn/BayesResults/model_select_2014/model_select_QuanDyn2_params.txt

set evals = ( 0 1 2 3 4 5 )
set nvals = (           5 6 7 8 9 10 11 12 )

# Prob_QuanDyn2 thresholds
set threshvals =  ( 0.5 0.9 )
set threshnames = ( 0p5 0p9 )

echo "eval nval EC50_0p5 TS_0p5 EC50_0p9 TS_0p9" >! $log

# loop over e and n values
foreach e ( $evals )
	foreach n ( $nvals )
		pushd "e"$e"_n"$n"_model_select"/images
		
		set outline = ( $e $n )
		
		# check to see if prob_QuanDyn2 image exists
		if ( -e BMIP_Prob_QuanDyn2.4dfp.img ) then
			@ i = 1
			while ( $i <= ${#threshvals} )
				# make a mask based on the probability of picking the QuanDyn model
				maskimg_4dfp -t$threshvals[$i] BMIP_Prob_QuanDyn2 BMIP_Prob_QuanDyn2 BMIP_Prob_QuanDyn2_t$threshnames[$i]
				
				# get average parameter values over different threshold values
				foreach param ( Ec50 Ts )
					set val = `qnt_4dfp -s "BMIP_QuanDyn2_"$param"_Peak" BMIP_Prob_QuanDyn2_t$threshnames[$i] | tail -1 | awk '{print $2}'`
					if ( $val =~ "q*" ) set val = "N/A"					
					set outline = ( $outline $val )
				end
				@ i++
			end
		else
			set outline = ( $outline "N/A" "N/A" "N/A" "N/A" )
		endif
		
		echo $outline >> $log
		
		popd
	end
end

exit 0

		

			
