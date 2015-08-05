if [ -e *-T6 ]
then
	rw_fs_tn=` ls *-T6 `;
	rw_fs=${rw_fs_tn%-*};
	touch $rw_fs;
	> "${rw_fs}";
	paste *-T1 *-T2 *-T6 *-T12 *-T24 *-T48 >> "${rw_fs}";
	cp $rw_fs ..;
fi
