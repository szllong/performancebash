usage()
{
echo -e "\n...USAGE ERROR!!!...\n"
echo -e "\nUsage:$(basename $0) filename "
echo -e "\ne.g. ./iozone_multi_process.sh ~/Downloads/iozone3_420/src/current/ /mnt/pramfs \n\n"
exit 1
}

iozone_dir=$1
testpath=$2

(($# == 2)) || usage

iozone_auto_test_multi_process()
{
	test_block_size=("4K" "8K" "16K" "32K" "64K" "128K" "256K" "512K" "1M" "2M" "4M" "8M")
	block_size_index="0"
	num_jobs=("1" "2" "6" "12" "24" "48")
	num_jobs_index="0"
	file_name_option=""
 	
	for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))
	do
		#generate the filename option needed by iozone
		for ((file_name_index = 0;file_name_index < ${num_jobs[num_jobs_index]};file_name_index++))
		do
			file_name_option+=$testpath\/$file_name_index
			file_name_option+=" "
		done
		echo $file_name_option

		iozone_result_file_name=result-T${num_jobs[num_jobs_index]}
		>$iozone_result_file_name
		cp header $iozone_result_file_name
		for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
		do
			data_file_name=iozone`echo $testpath | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-bs${test_block_size[block_size_index]}
			trimed_data_file_name=trim-$data_file_name
			echo $data_file_name
		
            ((per_file_size = 20480 / ${num_jobs[num_jobs_index]}))
			if [ $per_file_size -gt 2048 ]
			then
				per_file_size="2048" # limit the max file size for a single process
			fi
			size=${per_file_size}M
						
			$iozone_dir/iozone -s $size -i 0 -i 1 -i 2 -t ${num_jobs[num_jobs_index]} -r ${test_block_size[block_size_index]} -F $file_name_option > $data_file_name
			cat $data_file_name | grep Children | awk -F"=" '{print $2}' > $trimed_data_file_name
			paste $iozone_result_file_name $trimed_data_file_name > tmp
			cp tmp $iozone_result_file_name
		done
	done	
}

progress_dots()
{
while true
do 
	echo -e ".\c"
	sleep 2
done	
}

#start as a background function
progress_dots &

#get the last bg process
progress_dots_pid=$!

iozone_auto_test_multi_process

kill -9 $progress_dots_pid

exit 0
