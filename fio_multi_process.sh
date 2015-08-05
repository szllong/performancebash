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
	mode_index="0"
	test_block_size=("4k" "8k" "16k" "32k" "64k" "128k" "256k" "512k" "1M" "2M" "4M" "8M")
	block_size_index="0"
	num_jobs=("1" "2" "6" "12" "24" "48")
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

				((per_file_size = 20480 / ${num_jobs[num_jobs_index]}))
				if [ $per_file_size -gt 1024 ]
				then
					per_file_size="1024"
				fi
				size=${per_file_size}M
				
				fio -filename=$filename -iodepth 1 -thread -rw=${test_mode[mode_index]} -bs=${test_block_size[block_size_index]} -size=$size -numjobs=${num_jobs[num_jobs_index]} -name=mytest > $data_file_name

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
