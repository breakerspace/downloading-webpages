d=$6
domain=$5
path1='../desktop_deepcrawl_results/trial'
path2='../../desktop_zbrowse_results/trial'
path3='./desktop_tools_results/trial'
trial=$1
run=$3
rank=$4
port=$2
prefix=$7

cd DeepCrawling-master/
echo "deepcrawl"
timeout 130 node "crawler"$d".js" --site $domain --count 1 --headless --output-logs $path1$trial'_run'$run'_deepcrawl_top'$rank'.json' --port $port --output-cookies 'cookies'$rank'.json' 
rm -r 'cookies'$rank'.json' 
./inclusion_tree.py $path1$trial'_run'$run'_deepcrawl_top'$rank'.json' > $path1$trial'_run'$run'_deepcrawl_inclusions_top'$rank'.json'
cd ..

cd zbrowse-master/js
echo 'zbrowse'
timeout 130 node index.js $prefix$domain $port > $path2$trial'_run'$run'_zbrowse_top'$rank'.json'
cd ../../
