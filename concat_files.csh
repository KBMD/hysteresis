#!/bin/csh

set resultsdir = $cwd
echo Results will appear in: $resultsdir 
set imagedir = NNNNNNNNNNNNNN  C:\Users\kevin\Desktop\sync\hysteresis_from_B
set image_prefix = "hysteresis_mapping_20141007"
set noises = ( "0p01" "0p05" "0p1" )
set maints = ( "maint_false" "maint_true" )
set stages = ( "best" "HY1" "HY2" "HY3" "HY4" "worst" )

set timestring = `date -Iseconds`
set log = $dir/concat_files.log.$timestring
touch $log

cd $imagedir
foreach noise ( $noises )
	set fileroot = $image_prefix"_3noises.4dfp"
	foreach ext ( ifh hdr img img.rec )
		if ( -e $fileroot.$ext ) then 
			/bin/rm $fileroot.$ext 
			touch   $fileroot.$ext
		endif
		echo "= = = Building " $fileroot.img " = = =" >> $log
	end
	@ slice = 0
	foreach maint ( $maints )
		foreach stage ( $stages )
			set name_start = $image_prefix"_"$maint"_"$stage
			cat $name_start.4dfp.img >> $fileroot.4dfp.img
			echo copied $name_start.4dfp.img into slice $slice of $fileroot.4dfp.img >> $log
			@ slice++
		end  # foreach stage
	end  # foreach maint
	echo = = = Created $fileroot.img with $slice slices  = = = >> $log
	echo * * * WARNING: $fileroot still >> $log
	echo " 	"has no .img.rec, .ifh, or .hdr files * * * >> $log
end # foreach noises

exit 0

# hysteresis_mapping_20141007_abscissa.txt
# hysteresis_mapping_20141007_maint_false_best.txt
# hysteresis_mapping_20141007_maint_false_HY1_n0p01.4dfp.img
#   etc. ...
# awk '{print $1}'
