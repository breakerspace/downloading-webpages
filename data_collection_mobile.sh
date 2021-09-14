d=$6
domain=$5
path1='../mobile_deepcrawl_results/trial'
path2='../../mobile_zbrowse_results/trial'
path3='./mobile_tools_results/trial'
trial=$1
run=$3
rank=$4
port=$2
prefix=$7

path=$path3$trial'_run'$run'_deepcrawl_top'
dp=$(timeout 40 python parse_deepcrawl_output.py './mobile_deepcrawl_results/trial'$trial'_run'$run'_deepcrawl_inclusions_top'$rank'.json' $path$rank'_alldetails.txt' $path$rank'_alledges.txt' $path$rank'_allresources.txt' $path$rank'_alldomains.txt')
echo 'parse_deepcrawl' $dp
cat $path$rank'_allresources.txt' | sort | uniq > $path$rank'_resources.txt'
cat $path$rank'_alldomains.txt' | sort | uniq > $path$rank'_domains.txt'
awk '(NF != 1) && ($1 != $2) {print $0}' $path$rank'_alledges.txt' | sort | uniq > $path$rank'_edges.txt'
rm -r $path$rank'_alledges.txt' $path$rank'_allresources.txt' $path$rank'_alldomains.txt'

f=$path3$trial'_run'$run'_zbrowse_top'$rank
zb=$(timeout 40 python parse_zbrowse_output.py './mobile_zbrowse_results/trial'$trial'_run'$run'_zbrowse_top'$rank'.json' $f'_alldetails.txt' $f'_alledges.txt' $f'_allresources.txt' $f'_alldomains.txt')
echo 'parse_zbrowse' $zb
awk '(NF != 1) && ($1 != $2) {print $0}' $f'_alledges.txt' | sort | uniq > $f'_edges.txt'
cat $f'_allresources.txt' | sort | uniq > $f'_resources.txt'
cat $f'_alldomains.txt' | sort | uniq > $f'_domains.txt'
rm -r $f'_alldetails.txt' $f'_alledges.txt' $f'_allresources.txt' $f'_alldomains.txt'

cat $path$rank'_resources.txt' $f'_resources.txt' | sort | uniq > $path3$trial'_run'$run'_top'$rank'_resources.txt'
cat $path$rank'_domains.txt' $f'_domains.txt' | sort | uniq > $path3$trial'_run'$run'_top'$rank'_domains.txt'
cat $path$rank'_edges.txt' $f'_edges.txt' | sort | uniq > $path3$trial'_run'$run'_top'$rank'_edges.txt'
	