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
	cd /run/shm/fio
	test_mode=("read" "write" "randread" "randwrite")
	mode_index="0"
	test_block_size=("4k" "64k" "512k" "2M" "8M")
	block_size_index="0"
	num_jobs=("2" "6" "12" "24" "48")
	num_jobs_index="0"

	for ((mode_index = 0;mode_index < ${#test_mode[@]};mode_index++))
	do
		for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))
		do
			for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
			do
				bw_result_file_name=bw-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				iops_result_file_name=iops-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				data_file_name=data-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				echo $data_file_name
				
				#get the total bandwidth value of the all the running processes
				cat $data_file_name | grep aggrb | awk -F"," '{print $2}' | sed 's/aggrb=//' > $bw_result_file_name
				#get the average iops of all processes
				cat $data_file_name | grep iops | awk -F"," '{print $3}' | awk -F"=" '{print $2}' | awk '{total += $1;count++} END {print total/count}' > $iops_result_file_name
			done
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
