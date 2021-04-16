#!/usr/bin/env bash
mkdir data

if [[ ! -f data/ip2region.db ]]; then
	if [[ ! -f ip.merge.txt ]]; then
		curl -kLo ip.merge.txt https://github.com/lionsoul2014/ip2region/raw/master/data/ip.merge.txt
	fi
	java -jar dbMaker.jar -src ./ip.merge.txt -region ./global_region.csv
	mv data/ip2region.db ./
fi
