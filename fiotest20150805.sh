usage()
{
	echo  filename blocksize numjobs directflag;
}


if (($# != 4))
then
	usage
	exit 1;
fi
filename=$1
blocksize=$2
numjobs=$3
directflag=$4
fio -filename=$filename -iodepth=1 --direct=$directflag -thread -rw=write -bs=$blocksize -size=10G -numjobs=$numjobs -name=test -runtime=600 -group_reporting
