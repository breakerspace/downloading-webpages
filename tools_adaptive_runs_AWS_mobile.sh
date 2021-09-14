gcc diff_betn_runs.c -o diff_betn_runs.o

fname=$1 # top10k_nonfail_rand.txt # alexa_last_8pt5m.txt
trial=$2
path1='../mobile_deepcrawl_results/trial'
path2='../../mobile_zbrowse_results/trial'
path3='./mobile_tools_results/trial'
port=$3
port1=$3
start=$4
end=$5

nohup google-chrome-stable --headless --remote-debugging-port=$port1 https://chromium.org > "chrome_logs_"$port1".log" 2>&1 &
((port1++));
nohup google-chrome-stable --headless --remote-debugging-port=$port1 https://chromium.org > "chrome_logs_"$port1".log" 2>&1 &

declare -a dom_array
declare -a edg_array
declare -a res_array

i=0;
cat $fname | while read rank domain; 
do
	((++i));

	if (("$i" < $start)); then
		continue;
	fi

	((port1++));
	nohup google-chrome-stable --headless --remote-debugging-port=$port1 https://chromium.org > "chrome_logs_"$port1".log" 2>&1 &

	sleep 0.5
	rm -r $path3$trial'_top'$rank'_resources.txt' $path3$trial'_top'$rank'_domains.txt' $path3$trial'_top'$rank'_edges.txt'

	run=1

	echo "line" $i "run" $run "Alexa" $rank $domain

	for d in {0..3}
	do
		case "$d" in
			0)
				prefix='https://'
				;;
			1)
				prefix='https://www.'
				;;
			2)
				prefix='http://'
				;;
			3)
				prefix='http://www.'
				;;
		esac

		timeout 260 ./tools_dp_zb_mobile.sh $trial $port $run $rank $domain $d $prefix
		#echo "Check if data empty"
		path=$path3$trial'_run'$run'_deepcrawl_top'
		dp=$(python parse_deepcrawl_output.py './mobile_deepcrawl_results/trial'$trial'_run'$run'_deepcrawl_inclusions_top'$rank'.json' $path$rank'_alldetails.txt' $path$rank'_alledges.txt' $path$rank'_allresources.txt' $path$rank'_alldomains.txt')
		echo 'parse_deepcrawl' $dp
		f=$path3$trial'_run'$run'_zbrowse_top'$rank
		zb=$(python parse_zbrowse_output.py './mobile_zbrowse_results/trial'$trial'_run'$run'_zbrowse_top'$rank'.json' $f'_alldetails.txt' $f'_alledges.txt' $f'_allresources.txt' $f'_alldomains.txt')
		echo 'parse_zbrowse' $zb

		if [[ (("$dp" == *"Empty file"*) || ("$dp" == *"Error"*) || ("$dp" == *"File doesn't exist"*)) || (("$zb" == *"Empty file"*) || ("$zb" == *"Error"*) || ("$zb" == *"File doesn't exist"*)) ]]; then
			echo "No data for" $prefix$domain
			if (("$d" == 3)); then
				d=4
			fi
		else
			break;
		fi
	done

	if (("$d" != 4)); then
		echo "Valid domain:" $prefix$domain

		timeout 130 ./data_collection_mobile.sh $trial $port $run $rank $domain $d $prefix

		echo "Finding diff"
		n=$(./diff_betn_runs.o $rank $run $trial ./mobile_tools_results/)

		dom_array[$run]=$(echo $n | cut -d' ' -f1)
		edg_array[$run]=$(echo $n | cut -d' ' -f2)
		res_array[$run]=$(echo $n | cut -d' ' -f3)

		for run in {2..30};
		do

			echo "line" $i "run" $run "Alexa" $rank $domain

			timeout 260 ./tools_dp_zb_mobile.sh $trial $port $run $rank $domain $d $prefix

			timeout 130 ./data_collection_mobile.sh $trial $port $run $rank $domain $d $prefix

			echo "Finding diff"
			n=$(./diff_betn_runs.o $rank $run $trial ./mobile_tools_results/)

			dom_array[$run]=$(echo $n | cut -d' ' -f1)
			edg_array[$run]=$(echo $n | cut -d' ' -f2)
			res_array[$run]=$(echo $n | cut -d' ' -f3)
			
			if (("$run" > 3)); then
				diff=0
				for k in {0..2}
				do
					diff=$(($diff+${dom_array[(($run-$k))]}+${edg_array[(($run-$k))]}))
				done
				#echo $run $diff
				if (("$diff" == 0)); then
					#if (( "$(( $(IFS=+; echo "$((${dom_array[*]}))") + $(IFS=+; echo "$((${edg_array[*]}))")))" == 0 ))
					sum_dom=$(IFS=+; echo "$((${dom_array[*]}))") 
					sum_edg=$(IFS=+; echo "$((${edg_array[*]}))")
					sum=$(($sum_dom+$sum_edg))
					if (( "$sum" == 0 )); then
						echo "No data obtained:" $rank $domain
					else
						echo "Total Domains and Edges for:" $rank $domain "is" $sum_dom $sum_edg
					fi
					break;
				fi
			fi

		done

	else
		echo $domain "has no data for any prefix choice"
	fi

	rm "chrome_logs_"$port".log"
	((port++));

	# echo $i $rank $run ${dom_array[*]}
	# echo $i $rank $run ${edg_array[*]}
	# echo $i $rank $run ${res_array[*]}

	if (("$i" >= $end)); then
		break;
	fi	

done
