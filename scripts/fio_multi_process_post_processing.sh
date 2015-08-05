usage()
{
echo -e "\n...USAGE ERROR!!!...\n"
echo -e "\nUsage:$(basename $0) filename "
echo -e "\ne.g. ./fio_new.sh /tmp/a \n\n"
exit 1
}


filename=$1

(($# == 1)) || usage

fio_auto_test_multi_process()
{
	test_mode=("read" "write" "randread" "randwrite")
#	test_mode=("randread" "randwrite")
	mode_index="0"
	test_block_size=("4k" "8k" "16k" "32k" "64k" "128k" "256k" "512k" "1M" "2M" "4M" "8M")
	block_size_index="0"
	num_jobs=("1" "2" "6" "12" "24" "48")
	num_jobs_index="0"

	cd /run/shm/pramfs/fio
	
	for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))
	do
		result_file_T=result-T${num_jobs[num_jobs_index]}-iops
		for ((mode_index = 0;mode_index < ${#test_mode[@]};mode_index++))
		do
			result_file_mode=result-${test_mode[mode_index]}
			>$result_file_mode
			for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
			do
				bw_result_file_name=bw-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				iops_result_file_name=iops-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				data_file_name=data-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				echo $data_file_name
				paste $result_file_mode $iops_result_file_name > /tmp/bw_tmp
				cp /tmp/bw_tmp $result_file_mode
			done
			echo ${test_mode[mode_index]}`cat $result_file_mode` >> $result_file_T
			cat $result_file_T
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

fio_auto_test_multi_process

kill -9 $progress_dots_pid

exit 0
