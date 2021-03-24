#!/bin/bash

######## ARCHIVO A PARSEAR
FILE=/proc/partitions
case $1 in
	"list")
		## LISTA TODOS LOS VOLÚMENES
		TotDisks=$(/usr/bin/alos-installer/disks.sh count)
		for (( c=1; c<=$TotDisks; c++ ))
		do
			Hdd=$(/usr/bin/alos-installer/disks.sh choose $c)
			FirstChar=$(expr substr $Hdd 1 1)
			if [ $FirstChar = "s" ]; then
				HddType="SATA"
			elif [ $FirstChar = "h" ]; then
				HddType="IDE"
			fi
			echo "$c) $HddType [/dev/$Hdd]"
		done
		;;
	"choose")
		## MUESTRA EL VOLUMEN ESCOGIDO
		if [ $2 ]; then
			egrep '[sh]d[a-z]+$' $FILE | grep -o '[sh]d[a-z]' | head -$2 | tail -1
		fi
	;;
	"count")
		egrep '[sh]d[a-z]+$' $FILE | grep -o '[sh]d[a-z]' | wc -l
	;;
	*)
		echo "You can use this command as follows:"
		echo "alos-disks list    -Get a list of volumes"
		echo "alos-disks choose NUMBER    -Get the [NUMBER] item of the list"
		echo "alos-disks count    -Return many HDD you have connected"
	;;
esac
