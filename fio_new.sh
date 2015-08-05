usage()
{
echo -e "\n...USAGE ERROR!!!...\n"
echo -e "\nUsage:$(basename $0) filename start_size end_size"
echo -e "the end_size must be large than the actual block size\n"
echo -e "\ne.g. ./fio_new.sh filename 4096 8193\n\n"
}

if (($# != 3))
then
	usage
	exit 1
fi	


filename=$1
start_size=$2
end_size=$3
linenum="0"

auto_fio_test()
{

	
size=$start_size
mode_index="0"
count="0"
round="0"
test_mode=("read" "write" "randread" "randwrite")

echo "start_size=$start_size"
echo "end_size=$end_size"
	
>result
>bw
>iops
>lat

for ((mode_index = 0;mode_index < 4;mode_index++))
do
	((size = $start_size))
	echo $mode_index
	echo ${test_mode[mode_index]}
	
	((round = 0))
	while ((size < end_size))
	do
		fio -filename=$filename -iodepth 1 -thread -rw=${test_mode[mode_index]} -bs=$size -size=2G -numjobs=4 -name=mytest > $size
		linenum=`cat $size | egrep -n "(read|write) *[:]" | awk -F":" '{print $1}'`
		echo "$linenum"

		sed -n `echo ${linenum}p` $size | awk -F"," '{print $2 $3}' | sed 's/bw=//' | sed 's/MB\/s//' | sed 's/KB\/s//' | sed 's/B\/s//'| sed 's/iops=//' > tmp
		((linenum = $linenum + 2))
		sed -n `echo ${linenum}p` $size | awk -F"," '{print $3}' | sed 's/avg=//' >> tmp
		
		echo -e "`cat tmp | sed -n 1p`\c" >> result
		echo -e "`cat tmp | sed -n 2p`" >> result
		((size = $size * 2))
		((round = $round + 1))
	done
done

((mode_index = 0))
while read bw_val iops_val lat_val
do
	echo -e "${bw_val},\c" >> bw
	echo -e "${iops_val},\c" >> iops
	echo -e "${lat_val},\c" >> lat
	((count = $count + 1))
	if ((count == $round))
	then
		((count = 0))
		echo "${test_mode[mode_index]}" >> bw
		echo "${test_mode[mode_index]}" >> iops
		echo "${test_mode[mode_index]}" >> lat
		((mode_index = $mode_index + 1))
	fi
done < result	

}


progress_dots()
{
while true
do 
	echo -e ".\c"
	sleep 2
done	
}

progress_dots & #start as a background function

progress_dots_pid=$!  #get the last bg process

auto_fio_test

kill -9 $progress_dots_pid

newbwfilename=fio-bw`echo $filename | sed 's/\//-/g'`-s$start_size-e$end_size
newiopsfilename=fio-iops`echo $filename | sed 's/\//-/g'`-s$start_size-e$end_size
newlatfilename=fio-lat`echo $filename | sed 's/\//-/g'`-s$start_size-e$end_size

mv bw $newbwfilename
mv iops $newiopsfilename
mv lat $newlatfilename

exit 0
