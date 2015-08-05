if [ -e *-bs4K ]
then
	rw_fs_tn_bs=` ls *-bs4K `;
	rw_fs_tn=${rw_fs_tn_bs%-*};
	touch $rw_fs_tn;
	> "${rw_fs_tn}";
	paste *bs1K *bs2K *bs4K *bs8K *bs16K *bs32K *bs64K *bs128K *bs256K *bs512K *bs1M *bs2M *bs4M *bs8M >> "${rw_fs_tn}";
	cp $rw_fs_tn ..;
fi
