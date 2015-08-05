usage()
{
	echo  filename blocksize numjobs;
}


if (($# != 3))
then
	usage
	exit 1;
fi
filename=$1
blocksize=$2
numjobs=$3
fio -filename=$filename -iodepth 1 -thread -rw=write -bs=$2 -size=1G -numjobs=$numjobs -name=test
