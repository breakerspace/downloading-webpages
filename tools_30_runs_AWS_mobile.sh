gcc diff_betn_runs.c -o diff_betn_runs.o

fname=$1 # top10k_nonfail_rand.txt # alexa_last_8pt5m.txt
trial=$2
path1='../deepcrawl_results/trial'
path2='../../zbrowse_results/trial'
path3='./tools_results/trial'
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

		cd DeepCrawling-master/
		echo "deepcrawl"
		timeout 300 node "crawler"$d"_mobile.js" --site $domain --count 1 --headless --output-logs $path1$trial'_run'$run'_deepcrawl_top'$rank'.json' --port $port --output-cookies 'cookies'$rank'.json' 
		rm -r 'cookies'$rank'.json' 
		./inclusion_tree.py $path1$trial'_run'$run'_deepcrawl_top'$rank'.json' > $path1$trial'_run'$run'_deepcrawl_inclusions_top'$rank'.json'
		cd ..

		cd zbrowse-master/js
		echo 'zbrowse'
		timeout 300 node index_mobile.js $prefix$domain $port > $path2$trial'_run'$run'_zbrowse_top'$rank'.json'
		cd ../../
		
		#echo "Check if data empty"
		path=$path3$trial'_run'$run'_deepcrawl_top'
		dp=$(python parse_deepcrawl_output.py './deepcrawl_results/trial'$trial'_run'$run'_deepcrawl_inclusions_top'$rank'.json' $path$rank'_alldetails.txt' $path$rank'_alledges.txt' $path$rank'_allresources.txt' $path$rank'_alldomains.txt')
		echo 'parse_deepcrawl' $dp
		f=$path3$trial'_run'$run'_zbrowse_top'$rank
		zb=$(python parse_zbrowse_output.py './zbrowse_results/trial'$trial'_run'$run'_zbrowse_top'$rank'.json' $f'_alldetails.txt' $f'_alledges.txt' $f'_allresources.txt' $f'_alldomains.txt')
		echo 'parse_zbrowse' $zb

		if [[ (("$dp" == *"Empty file"*) || ("$dp" == *"Error"*) || ("$dp" == *"File doesn't exist"*)) && (("$zb" == *"Empty file"*) || ("$zb" == *"Error"*) || ("$zb" == *"File doesn't exist"*)) ]]; then
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

		for run in {2..30};
		do

			echo "line" $i "run" $run "Alexa" $rank $domain

			cd DeepCrawling-master/
			echo "deepcrawl"
			timeout 130 node "crawler"$d"_mobile.js" --site $domain --count 1 --headless --output-logs $path1$trial'_run'$run'_deepcrawl_top'$rank'.json' --port $port --output-cookies 'cookies'$rank'.json' 
			rm -r 'cookies'$rank'.json' 
			./inclusion_tree.py $path1$trial'_run'$run'_deepcrawl_top'$rank'.json' > $path1$trial'_run'$run'_deepcrawl_inclusions_top'$rank'.json'
			cd ..

			cd zbrowse-master/js
			echo 'zbrowse'
			timeout 180 node index_mobile.js $prefix$domain $port > $path2$trial'_run'$run'_zbrowse_top'$rank'.json'
			cd ../../

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
