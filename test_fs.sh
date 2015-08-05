if [ -e fs_test ]
then
	echo Dir  fs_test exits
else	
	mkdir fs_test;
	cp rw.sh rw_fs.sh rw_fs_tn.sh fs_test;

	cd fs_test;
	mkdir read write randread randwrite rewrite reread;

	for rw in  ` ls -F | grep '/' `
	do
		cd $rw;
		mkdir simfs ramfs tmpfs ext4;

		for fs in ` ls . `
		do
			cd $fs;
			mkdir T1 T2 T6 T12 T24 T48;
			cd ..;
		done

		cd ..;

	done

	mkdir final;

	cd ..;
fi

cp ./seconddata/* fs_test;

cd fs_test;

for filename in ` find -maxdepth 1 -type f -name "*T*" `
do
	path=`echo $filename | sed 's/-/\//g'`;
	newpath=${path%\/*};
	mv $filename $newpath;
done


for dir1 in ` find -maxdepth 1 -type d `
do
	if [ '.' != $dir1 ]
	then
		cd $dir1;

		for dir2 in ` find -maxdepth 1 -type d `
		do
			if [ '.' != $dir2 ]
			then
				cd $dir2;

				for dir3 in ` find -maxdepth 1 -type d `
				do
					if [ '.' != $dir3 ]
					then
						cd $dir3;
						cp ~/workspace/bash/fs_test/rw_fs_tn.sh .;
						./rw_fs_tn.sh;
						cd ..
					fi
				done
				cp ~/workspace/bash/fs_test/rw_fs.sh .;
				./rw_fs.sh;
				cd ..		
			fi
		done
		cp ~/workspace/bash/fs_test/rw.sh .;
		./rw.sh;
		cd ..;
	fi
done	
