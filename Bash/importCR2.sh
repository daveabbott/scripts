#!/bin/sh

for f in $(find -name '*.CR2') ; do
	library=/mnt/kabbalah/library/Photos

	year=$(date -r ./$f "+%Y");
	month=$(date -r ./$f "+%m");
	day=$(date -r ./$f "+%d");

	rsync -a --mkpath $f $library/$year/$month/$day/
done

exit 0	