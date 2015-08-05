if [ ! -e dirbw ]
then
	mkdir dirbw;
	cd dirbw;
	mkdir simfs tmpfs ramfs ext4;
	cd ..;
fi

if [ ! -e diriops ]
then
	mkdir diriops;
	cd diriops;
	mkdir simfs tmpfs ramfs ext4;
	cd ..;
fi

if [ ! -e backup ]
then
	mkdir backup;
fi

find -maxdepth 1 -type f -name "data*" -exec rm {} \;
find -maxdepth 1 -type f -exec cp {} backup \;

find -maxdepth 1 -type f -name "bw*nvm*" -exec mv {} dirbw/simfs \;
find -maxdepth 1 -type f -name "bw*tmp*" -exec mv {} dirbw/tmpfs \;
find -maxdepth 1 -type f -name "bw*ram*" -exec mv {} dirbw/ramfs \;
find -maxdepth 1 -type f -name "bw*hom*" -exec mv {} dirbw/ext4 \;

find -maxdepth 1 -type f -name "iops*nvm*" -exec mv {} diriops/simfs \;
find -maxdepth 1 -type f -name "iops*tmp*" -exec mv {} diriops/tmpfs \;
find -maxdepth 1 -type f -name "iops*ram*" -exec mv {} diriops/ramfs \;
find -maxdepth 1 -type f -name "iops*hom*" -exec mv {} diriops/ext4 \;

for dir1 in ` ls -F | grep '/' `
do
	cd $dir1;
	for dir2 in ` ls -F | grep '/' `
	do
		cd $dir2;
		for filename in ` ls . `
		do
			new_filename=` echo $filename | grep bw | grep tmp | sed 's/bw-//g' | sed 's/tmp*-a/tmpfs/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi
			new_filename=` echo $filename | grep bw | grep nvmmfs | sed 's/bw-//g' | sed 's/mnt-nvmmfs-a/simfs/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi
			new_filename=` echo $filename | grep bw | grep hom | sed 's/bw-//g' | sed 's/home-wujing-a/ext4/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi
			new_filename=` echo $filename | grep bw | grep ram | sed 's/bw-//g' | sed 's/mnt-ramfs-a/ramfs/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi


			new_filename=` echo $filename | grep iops | grep tmp | sed 's/iops-//g' | sed 's/tmp*-a/tmpfs/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi
			new_filename=` echo $filename | grep iops | grep nvmmfs | sed 's/iops-//g' | sed 's/mnt-nvmmfs-a/simfs/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi
			new_filename=` echo $filename | grep iops | grep hom | sed 's/iops-//g' | sed 's/home-wujing-a/ext4/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi
			new_filename=` echo $filename | grep iops | grep ram | sed 's/iops-//g' | sed 's/mnt-ramfs-a/ramfs/g' `;
			if [ $new_filename ]
			then
				mv $filename $new_filename;
				continue;
			fi
		done
		cd ..;
	done
	cd ..;
done
