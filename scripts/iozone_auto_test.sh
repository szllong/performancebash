usage()
{
echo -e "\n...USAGE ERROR!!!...\n"
echo -e "\nUsage:$(basename $0) iozone_dir test_file_path start_size end_size"
echo -e "the end_size must be large than the actual block size\n"
echo -e "\ne.g. ./iozone_auto_test.sh  ~/Downloads/iozone3_420/src/current/ /mnt/pramfs/test 1024 2049\n\n"
}

if (($# != 4))
then
	usage
	exit 1
fi	


progress_dots()
{
while true
do 
	echo -e ".\c"
	sleep 2
done	
}

#~/Downloads/iozone3_420/src/current/
iozone_dir=$1
test_file_path=$2
start_size=$3
end_size=$4

auto_iozone_test()
{
# cd /dev/shm/
# pwd
size=$start_size

echo "start_size=$start_size"
echo "end_size=$end_size"

>result
while ((size < end_size))
do
	echo "The current testing blocksize:$size"
	$iozone_dir/iozone -s 1M -i 0 -i 1 -i 2 -t 1 -r $size -F $test_file_path | grep Avg | awk -F"=" '{print $2}' | sed 's/sec/&,/' > $size
	paste result $size > tmp
	cp tmp result
	((size = $size * 2))
done

}


count()
{
	for ((i = 0;i < 10;i++))
	do
		for ((j = 0;j < 4;j++))
		do
			echo "$i,$j"
			sleep 1
		done 
	done
}

progress_dots & #start as a background function

progress_dots_pid=$!  #get the last bg process

auto_iozone_test

kill -9 $progress_dots_pid

newfilename=iozone-result`echo $test_file_path | sed 's/\//-/g'`-s$start_size-e$end_size

mv result $newfilename

exit 0
