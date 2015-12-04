usage()
{
echo -e "\n...USAGE ERROR!!!...\n"
echo -e "\nUsage:$(basename $0) filename "
echo -e "\ne.g. ./fio_new.sh /tmp/a \n\n"
exit 1
}


testpath=$1

(($# == 1)) || usage

fio_auto_test_multi_process()
{
	test_mode=("read" "write" "randread" "randwrite")
	mode_index="0"
	test_block_size=("1K" "2K" "4K" "8K" "16K" "32K" "64K" "128K" "512K")
	block_size_index="0"
	num_jobs=("1" "2" "4")
	num_jobs_index="0"

	final_write_bw_file_name=bw-10-in-1-write
	final_read_bw_file_name=bw-10-in-1-read
	final_randread_bw_file_name=bw-10-in-1-randread
	final_randwrite_bw_file_name=bw-10-in-1-randwrite
	>$final_write_bw_file_name
	>$final_read_bw_file_name
	>$final_randread_bw_file_name
	>$final_randwrite_bw_file_name
	
	final_write_iops_file_name=iops-10-in-1-write
	final_read_iops_file_name=iops-10-in-1-read
	final_randread_iops_file_name=iops-10-in-1-randread
	final_randwrite_iops_file_name=iops-10-in-1-randwrite
	>$final_write_iops_file_name
	>$final_read_iops_file_name
	>$final_randread_iops_file_name
	>$final_randwrite_iops_file_name

	for ((test_times = 0;test_times < 10;test_times++))
	do
		for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))
		do
			for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
			do
				for ((mode_index = 0;mode_index < ${#test_mode[@]};mode_index++))
				do
					data_file_name=fio`echo $testpath | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-bs${test_block_size[block_size_index]}-${test_mode[mode_index]}-${test_times}
		    		echo $data_file_name

					((per_file_size = 18022 / ${num_jobs[num_jobs_index]}))
					if [ $per_file_size -gt 18022 ]
					then
						per_file_size="18022" # limit the max file size for a single process to 2G
					fi
					size=${per_file_size}M

					fio -filename=$testpath -iodepth 1 -thread -rw=${test_mode[mode_index]} -direct=1 -bs=${test_block_size[block_size_index]} -size=$size -numjobs=${num_jobs[num_jobs_index]} -name=mytest > $data_file_name
					bw_file_name=bw`echo $testpath | sed 's/\//-/g'`-${test_mode[mode_index]}-${test_times}
					iops_file_name=iops`echo $testpath | sed 's/\//-/g'`-${test_mode[mode_index]}-${test_times}

					#get the total bandwidth value of the all the running processes
					cat $data_file_name | grep aggrb | awk -F"," '{print $2}' | sed 's/aggrb=//' >> $bw_file_name
					#get the average iops of all processes
					cat $data_file_name | grep iops | awk -F"," '{print $3}' | awk -F"=" '{print $2}' | awk '{total += $1;count++} END {print total/count}' >> $iops_file_name
				done
			done
		done		
	done

	for ((test_times = 0;test_times < 1;test_times++))
	do
		paste $final_read_bw_file_name bw-*-read-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_read_bw_file_name
		paste $final_write_bw_file_name bw-*-write-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_write_bw_file_name
		paste $final_randread_bw_file_name bw-*-randread-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randread_bw_file_name
		paste $final_randwrite_bw_file_name bw-*-randwrite-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randwrite_bw_file_name

		paste $final_read_iops_file_name iops-*-read-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_read_iops_file_name
		paste $final_write_iops_file_name iops-*-write-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_write_iops_file_name
		paste $final_randread_iops_file_name iops-*-randread-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randread_iops_file_name
		paste $final_randwrite_iops_file_name iops-*-randwrite-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randwrite_iops_file_name		
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
