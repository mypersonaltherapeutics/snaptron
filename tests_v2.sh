#!/bin/bash
source python/bin/activate
export HOST=stingray.cs.jhu.edu
export PORT=8090
export SRV=srav2

if [ -z $1 ] ; then
    python test_snaptron.py
fi

#system tests (roundtrip)
echo "26" > expected_wc
python ./snaptron.py 'regions=chr11:82970135-82997450&rfilter=samples_count>:100&rfilter=coverage_sum>:1000' 2> /dev/null | wc -l > test_wc
diff test_wc expected_wc

echo "26" > expected_wc
curl "http://$HOST:$PORT/$SRV/snaptron?regions=chr11:82970135-82997450&rfilter=samples_count>:100&rfilter=coverage_sum>:1000" 2> /dev/null | wc -l  > test_wc
diff test_wc expected_wc

echo "26" > expected_wc
curl "http://$HOST:$PORT/$SRV/snaptron?regions=chr11:82970135-82997450&rfilter=samples_count>:100&rfilter=coverage_sum>:1000&fields=snaptron_id" 2> /dev/null | wc -l  > test_wc
diff test_wc expected_wc

echo "27" > expected_wc
curl --data 'fields="[{"intervals":["chr11:82970135-82997450"],"samples_count":[{"op":">:","val":100}],"coverage_sum":[{"op":">:","val":1000}]}]"' http://$HOST:$PORT/$SRV/snaptron 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

echo "32" > expected_wc
curl "http://$HOST:$PORT/$SRV/samples?sfilter=description:cortex" 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

echo "2" > expected_wc
curl "http://$HOST:$PORT/$SRV/samples?sfilter=run_accession:DRR001622" 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

curl "http://$HOST:$PORT/$SRV/snaptron?regions=chr11:82970135-82997450&rfilter=samples_count>:100&rfilter=coverage_sum>:1000&sfilter=description:cortex" 2>/dev/null | cut -f 2 | egrep -v -e 'id' | sort -u > test_15_ids
diff test_s2i_ids_15.snaptron_ids test_15_ids 

echo "4" > expected_wc
curl "http://$HOST:$PORT/$SRV/samples?ids=0,4,10" 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

echo "5" > expected_wc
curl --data 'fields="[{"ids":["33401865","33401867","33401868"]}]"' http://$HOST:$PORT/$SRV/snaptron 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

echo "4" > expected_wc
curl --data 'fields="[{"ids":["0","5","11"]}]"' http://$HOST:$PORT/$SRV/samples 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

#echo "3" > expected_wc
#curl "http://$HOST:$PORT/analysis?ids_a=4&ids_b=5,6&compute=jir&ratio=cov&order=T:5" 2>/dev/null | wc -l > test_wc
#diff test_wc expected_wc

echo "35" > expected_wc
curl "http://$HOST:$PORT/$SRV/annotations?regions=CD99&contains=1" 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

echo "42" > expected_wc
curl "http://$HOST:$PORT/$SRV/annotations?regions=CD99" 2>/dev/null | wc -l > test_wc
diff test_wc expected_wc

rm test_wc expected_wc

echo "all tests run"

#FP comparison test
#tabix /data2/gigatron2/all_SRA_introns_ids_stats.tsv.new2_w_sourcedb2.gz chr11:82970135-82997450 | perl -ne 'chomp; @f=split(/\t/,$_); $scount=$f[14]; next if($scount < 10 || $scount > 10); $avg=$f[16]; $med=$f[17]; next if($avg <= 2.0); print "$_\n";' | wc -l