usage()
{
echo -e "\n...USAGE ERROR!!!...\n"
echo -e "\nUsage:$(basename $0) filename "
echo -e "\ne.g. ./$(basename $0) ~/Downloads/iozone3_420/src/current/ /mnt/pramfs \n\n"
exit 1
}

iozone_dir=$1
testpath=$2

(($# == 2)) || usage

iozone_auto_test_multi_process()
{
	test_block_size=("1k" "2k" "4K" "8K" "16K" "32K" "64K" "128K" "256K" "512K" "1M" "2M" "4M" "8M" "16M")
	block_size_index="0"
	num_jobs=("1" "2" "4" "8")
	num_jobs_index="0"
	file_name_option=""

	final_write_file_name=result-10-in-1-write
	final_read_file_name=result-10-in-1-read
	final_reread_file_name=result-10-in-1-reread
	final_rewrite_file_name=result-10-in-1-rewrite
	final_randread_file_name=result-10-in-1-randread
	final_randwrite_file_name=result-10-in-1-randwrite
	>$final_write_file_name
	>$final_read_file_name
	>$final_reread_file_name
	>$final_rewrite_file_name
	>$final_randread_file_name
	>$final_randwrite_file_name

	for ((test_times = 0;test_times < 10;test_times++))
	do
		write_result_file_name=result`echo $testpath | sed 's/\//-/g'`-write-${test_times}
		>$write_result_file_name
		read_result_file_name=result`echo $testpath | sed 's/\//-/g'`-read-${test_times}
		>$read_result_file_name
		re_read_result_file_name=result`echo $testpath | sed 's/\//-/g'`-reread-${test_times}
		>$re_read_result_file_name
		re_write_result_file_name=result`echo $testpath | sed 's/\//-/g'`-rewrite-${test_times}
		>$re_write_result_file_name
		rand_read_result_file_name=result`echo $testpath | sed 's/\//-/g'`-randread-${test_times}
		>$rand_read_result_file_name
		rand_write_result_file_name=result`echo $testpath | sed 's/\//-/g'`-randwrite-${test_times}
		>$rand_write_result_file_name
		
		for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))
		do
			#generate the filename option needed by iozone
			for ((file_name_index = 0;file_name_index < ${num_jobs[num_jobs_index]};file_name_index++))
			do
				file_name_option+=$testpath\/$file_name_index
				file_name_option+=" "
			done
			echo $file_name_option

			for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
			do
				data_file_name=iozone`echo $testpath | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-bs${test_block_size[block_size_index]}-${test_times}
		    	echo $data_file_name

				((per_file_size = 2048 / ${num_jobs[num_jobs_index]}))
				if [ $per_file_size -gt 1024 ]
				then
					per_file_size="1024" # limit the max file size for a single process to 2G
				fi
				size=${per_file_size}M
				
				$iozone_dir/iozone -s $size -i 0 -i 1 -i 2 -t ${num_jobs[num_jobs_index]} -r ${test_block_size[block_size_index]} -F $file_name_option > $data_file_name
			   	rm -rf $testpath/*
				 echo `cat $data_file_name | grep Parent | grep "initial writers" | awk -F"=" '{print $2}' | awk -F"KB/sec" '{print $1}'` >> $write_result_file_name
				echo `cat $data_file_name | grep Parent | grep "rewriters" | awk -F"=" '{print $2}' | awk -F"KB/sec" '{print $1}'` >> $re_write_result_file_name
				echo `cat $data_file_name | grep Parent | grep "readers"   | awk -F"=" '{print $2}' | awk -F"KB/sec" '{print $1}'` >> $read_result_file_name
				echo `cat $data_file_name | grep Parent | grep "re-readers" | awk -F"=" '{print $2}'| awk -F"KB/sec" '{print $1}'` >> $re_read_result_file_name
				echo `cat $data_file_name | grep Parent | grep "random readers" | awk -F"=" '{print $2}' | awk -F"KB/sec" '{print $1}'` >> $rand_read_result_file_name
				echo `cat $data_file_name | grep Parent | grep "random writers" | awk -F"=" '{print $2}' | awk -F"KB/sec" '{print $1}'` >> $rand_write_result_file_name
			done
		done
		paste $final_write_file_name $write_result_file_name > /tmp/write.tmp
		cp /tmp/write.tmp $final_write_file_name
		paste $final_read_file_name $read_result_file_name > /tmp/read.tmp
		cp /tmp/read.tmp $final_read_file_name
		paste $final_reread_file_name $re_read_result_file_name > /tmp/reread.tmp
		cp /tmp/reread.tmp $final_reread_file_name
		paste $final_rewrite_file_name $re_write_result_file_name > /tmp/rewrite.tmp
		cp /tmp/rewrite.tmp $final_rewrite_file_name
		paste $final_randread_file_name $rand_read_result_file_name > /tmp/randread.tmp
		cp /tmp/randread.tmp $final_randread_file_name
		paste $final_randwrite_file_name $rand_write_result_file_name > /tmp/randwrite.tmp
		cp /tmp/randwrite.tmp $final_randwrite_file_name
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
