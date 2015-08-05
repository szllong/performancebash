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
# 	test_mode=("read" "write" "randread" "randwrite")
# #	test_mode=("randread" "randwrite")
# 	mode_index="0"
# #	test_block_size=("4k" "8k" "16k" "32k" "64k" "128k" "256k" "512k" "1M" "2M" "4M" "8M")	
# #	test_block_size=("4k" "64k" "128k" "512k" "2M")
# 	test_block_size=("512B" "1k" "2k")
# 	block_size_index="0"
# 	num_jobs=("1" "2" "6" "12" "24" "48")
# 	num_jobs_index="0"


	test_mode=("read" "randread")
	mode_index="0"
	test_block_size=("4k" "64k" "2M")
	block_size_index="0"
	num_jobs=("1" "2" "6" "12" "24" "48")
	num_jobs_index="0"


	for ((i = 0;i < 4;i++))
	do
		cd /run/shm/fio-ramfs-with-nvmmfs/ramfs-${i}
		for ((mode_index = 0;mode_index < ${#test_mode[@]};mode_index++))
		do
			result_file_mode_iops=result`echo $filename | sed 's/\//-/g'`-${test_mode[mode_index]}-iops-i${i}
			result_file_mode_bw=result`echo $filename | sed 's/\//-/g'`-${test_mode[mode_index]}-bw-i${i}
			>$result_file_mode_bw
			>$result_file_mode_iops
			for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))	
			do
				for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
				do
					bw_result_file_name=bw-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}-i${i}
					iops_result_file_name=iops-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}-i${i}
					cat $bw_result_file_name >> $result_file_mode_bw
					cat $iops_result_file_name >> $result_file_mode_iops
				done
			done
		done
	done
}

fio_many_times_test_pre_processing()
{
	
	for ((i = 0;i < 4;i++))
	do
		cd /run/shm/fio-ramfs-with-nvmmfs/ramfs-$i
		#ls | grep "i${i}" | xargs -i cp {} /run/shm/fio-ramfs-with-nvmmfs/ramfs-${i}
		cp result-mnt* /run/shm/fio-ramfs-with-nvmmfs/fio-result-ramfs-with-nvmmfs/
	done
}

fio_paste_data()
{
	for((i = 0;i < 10;i++))
	do
		cd /run/shm/ramfs-${i}
		for test_mode in "read" "randread"
		do
			bw_file_name=result-${test_mode}-bw-i${i}
			iops_file_name=result-${test_mode}-iops-i${i}
			>$bw_file_name
			>$iops_file_name

			for filename in "/mnt/ramfs/a"
			do
				paste $iops_file_name result`echo $filename | sed 's/\//-/g'`-${test_mode}-iops-i${i} > /tmp/iops-tmp
				cp /tmp/iops-tmp $iops_file_name
				paste $bw_file_name result`echo $filename | sed 's/\//-/g'`-${test_mode}-bw-i${i} > /tmp/bw-tmp
				cp /tmp/bw-tmp $bw_file_name
			done
			cat $iops_file_name -n
			cat $bw_file_name -n
		done
	done
}

fio_paste_data_cjx()
{
    test_mode=("read" "write" "randread" "randwrite")
	mode_index="0"
	test_block_size=("4k" "8k" "16k" "32k" "64k" "128k" "256k" "512k" "1M" "2M" "4M" "8M")	
	block_size_index="0"
	num_jobs=("2" "6" "12" "24" "48" "1")
	num_jobs_index="0"

	cd /run/shm/pramfs/fio/
	for ((mode_index = 0;mode_index < ${#test_mode[@]};mode_index++))
	do
		result_file_mode_iops=result`echo $filename | sed 's/\//-/g'`-${test_mode[mode_index]}-iops
		result_file_mode_bw=result`echo $filename | sed 's/\//-/g'`-${test_mode[mode_index]}-bw
		>$result_file_mode_bw
		>$result_file_mode_iops
		for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))	
		do
			for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
			do
				bw_result_file_name=bw-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				iops_result_file_name=iops-${test_mode[mode_index]}`echo $filename | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-${test_block_size[block_size_index]}
				echo -e "`cat $bw_result_file_name` \c" >> $result_file_mode_bw
				echo -e "`cat $iops_result_file_name` \c" >> $result_file_mode_iops
			done
			echo -e ",,\c" >> $result_file_mode_bw
			echo -e ",,\c" >> $result_file_mode_iops
		done
	done
}

transpose_file()
{
	lines_of_file=`wc -l < "$1"`
	result_file_name="result-ramfs"
	>$result_file_name
	
	for ((line_index = 1;line_index < $lines_of_file + 1;line_index++))
	do
		sed -n ${line_index}p "$1" | sed 's/KB\/sec//g' | tr ' ' '\n' | awk '$1' > /tmp/a
#		sed -n ${line_index}p "$1" | tr ' ' '\n'  > /tmp/a
		paste $result_file_name /tmp/a > /tmp/b
		cp /tmp/b $result_file_name
	done
	cat $result_file_name

}


iozone_paste_data_zk()
{
	cd /run/shm/iozone-ramfs/

	for ((i = 0;i < 10;i++))
	do
		file_name=ramfs-iozone-i${i}
		>$file_name
		for num_jobs in  "1" "2" "6" "12" "24" "48"
		do
			#		cat result-T${num_jobs} | awk -F" " '{print $2,$10,$12,$16,$20}' > /tmp/c
			#		cat result-T${num_jobs} | awk -F" " '{print $6,$14,$16,$18,$22}' > /tmp/c
			cat result-T${num_jobs}-i${i} | awk -F" " '{print $2,$4,$6}' > /tmp/c
			cat -n /tmp/c
			transpose_file /tmp/c >> $file_name
		done
		cat -n $file_name
	done
}

fio_ramfs_paste_data()
{
	cd /run/shm/ramfs-fio/
	file_name="ramfs"
	>$file_name
	for num_jobs in "1" "2" "6" "12" "24" "48"
	do
		cat result-T${num_jobs} | awk -F" " '{print $2,$6,$7,$9,$11}' > /tmp/c
		cat -n /tmp/c
		transpose_file /tmp/c >> $file_name
	done
}

#fio_auto_test_multi_process
#fio_paste_data
#fio_paste_data_cjx

#iozone_paste_data_zk
#fio_ramfs_paste_data

fio_many_times_test_pre_processing

exit 0
