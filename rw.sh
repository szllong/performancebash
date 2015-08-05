if [ -e *-simfs ]
then
	rw_fs=` ls *-simfs `;
	rw=${rw_fs%-*};
	touch $rw;
	> "${rw}";
	cat *-simfs *-ramfs *-tmpfs *-ext4 >> "${rw}";
	cp $rw ../final;
fi
