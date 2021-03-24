#!/bin/bash

######## LIMPIAMOS E INICIAMOS
clear
cd /usr/bin




######## DECLARAMOS LAS FUNCIONES
function Text {
	case $1 in
		"Y" ) echo -e "\033[40m\033[1;33m$2\033[0m";;
		"R" ) echo -e "\033[40m\033[1;31m$2\033[0m";;
	esac
}

function Sizeof {
	du -s "$1" | cut -f1;
}

function Running {
	ps $1 | grep $1 >> /dev/null;
}

function Header {
	clear;
	cat /usr/bin/alos-installer/header;
}

function Create_Inittab {
	if [ $# -eq 1 ]; then
		Path=$1/inittab
		if [ -f $Path ]; then
			if ! rm $Path >> /dev/null; then
				return 1;
			fi
		fi
		if ! touch $Path >> /dev/null; then
			return 1;
		fi
		if ! echo "init:2:initdefault:" >> $Path; then
			return 1;
		fi
		if ! echo "si::sysinit:/etc/init.d/rcS" >> $Path; then
			return 1;
		fi
		if ! echo "~~:S:wait:/sbin/sulogin" >> $Path; then
			return 1;
		fi
		if ! echo "l0:0:wait:/etc/init.d/rc 0" >> $Path; then
			return 1;
		fi
		if ! echo "l1:1:wait:/etc/init.d/rc 1" >> $Path; then
			return 1;
		fi
		if ! echo "l2:2:wait:/etc/init.d/rc 2" >> $Path; then
			return 1;
		fi
		if ! echo "l3:3:wait:/etc/init.d/rc 3" >> $Path; then
			return 1;
		fi
		if ! echo "l4:4:wait:/etc/init.d/rc 4" >> $Path; then
			return 1;
		fi
		if ! echo "l5:5:wait:/etc/init.d/rc 5" >> $Path; then
			return 1;
		fi
		if ! echo "l6:6:wait:/etc/init.d/rc 6" >> $Path; then
			return 1;
		fi
		if ! echo "z6:6:respawn:/sbin/sulogin" >> $Path; then
			return 1;
		fi
		if ! echo "ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now" >> $Path; then
			return 1;
		fi
		if ! echo "pf::powerwait:/etc/init.d/powerfail start" >> $Path; then
			return 1;
		fi
		if ! echo "pn::powerfailnow:/etc/init.d/powerfail now" >> $Path; then
			return 1;
		fi
		if ! echo "po::powerokwait:/etc/init.d/powerfail stop" >> $Path; then
			return 1;
		fi
		if ! echo "1:2345:respawn:/sbin/agetty tty3" >> $Path; then
			return 1;
		fi
		return 0;
	else
		return 1;
	fi
}

function Create_Extlinux_Conf {
	if [ $# -eq 2 ]; then
		Path=$1/extlinux.conf
		if [ -f $Path ]; then
			if ! rm $Path >> /dev/null; then
				return 1;
			fi
		fi
		if ! touch $Path >> /dev/null; then
			return 1;
		fi
		if ! echo "DEFAULT Alos" >> $Path; then
			return 1;
		fi
		if ! echo "LABEL Alos" >> $Path; then
			return 1;
		fi
		if ! echo "LINUX /boot/vmlinuz-3.2.0-3-686-pae" >> $Path; then
			return 1;
		fi
		if ! echo "APPEND initrd=/boot/initrd.img-3.2.0-3-686-pae root=$2 ro quiet splash">> $Path; then
			return 1;
		fi
		if ! echo "PROMPT 0" >> $Path; then
			return 1;
		fi
		if ! echo "TIMEOUT 0" >> $Path; then
			return 1;
		fi
		if ! echo "NOESCAPE 1" >> $Path; then
			return 1;
		fi
		if ! echo "NOCOMPLETE 1" >> $Path; then
			return 1;
		fi
		return 0;
	else
		return 1;
	fi
}

function Create_Fstab {
	if [ $# -eq 3 ]; then
		Path=$1/fstab;
		if [ -f $Path ]; then
			if ! rm $Path >> /dev/null; then
				return 1;
			fi
		fi
		if ! touch $Path >> /dev/null; then
			return 1;
		fi
		if ! echo "$2	/	ext4	defaults,errors=remount-ro	0	1" >> $Path; then
			return 1;
		fi
		if ! echo "$3	swap	swap	defaults	0	0" >> $Path; then
			return 1;
		fi
		if ! echo "proc	/proc	proc	defaults	0	0" >> $Path; then
			return 1;
		fi
		return 0;
	else
		return 1;
	fi
}




######## HACEMOS COMPROBACIONES
if [ $# -eq 1 ]; then
	if [ -f /usr/bin/alos-installer/languages/$1.lang ]; then
		source /usr/bin/alos-installer/languages/$1.lang
	else
		exit;
	fi
else
	exit;
fi

if [ $(whoami) != "root" ]; then
	Text R "${Text[1]}"
	exit;
fi

info[0]=$(/usr/bin/alos-installer/disks.sh count)
if [ ${info[0]} -eq 0 ]; then
	Text R "${Text[2]}"
	exit;
fi




######## BIENVENIDA Y CONFIRMACION
Header
Text Y "${Text[3]}"
while true; do
	read -p "${Text[4]}" info[1]
	case ${info[1]} in
		[SYsy]* ) echo -e "${Text[5]}"; break;;
		[Nn]* ) echo -e "${Text[6]}"; exit;;
		* ) echo -e "${Text[7]}"
	esac
done
echo -e "\b\n"




######## USUARIOS
Header
Text Y "${Text[8]}"
echo -e "${Text[9]}"
echo -e "\b\n"

## Solicitamos la clave para [ADMIN] y comprobamos
read -p "${Text[15]}" AdminPassTmp
read -p "${Text[16]}" AdminPassTmp2
if [ "$AdminPassTmp" != "$AdminPassTmp2" ]; then
	Text R "${Text[17]}"
	exit;
else
	AdminPass=$AdminPassTmp;
fi



######## ESCOGER DISCO Y PARTICIONAR
Header
Text Y "${Text[18]}"
echo -e "${Text[19]}"
echo -e "\b\n"

## Listamos los discos y pedimos elegir uno
/usr/bin/alos-installer/disks.sh list
while true; do
	read -p "${Text[20]}" info[2]
	if [ ${info[2]} -le ${info[0]} ]; then
		break;
	else
		echo -e "${Text[21]}";
	fi
done

## Desmontamos
echo -e "${Text[22]}"
info[3]=/dev/$(/usr/bin/alos-installer/disks.sh choose ${info[2]})
info[4]=${info[3]}1
info[5]=${info[3]}2
if grep -qs -o "${info[3]}" /etc/mtab ; then
	if ! umount -lf ${info[3]} ; then
		Text R "${Text[23]}"
		exit;
	fi
fi
if grep -qs -o "/mnt" /etc/mtab; then
	if ! umount -lf /mnt ; then
		Text R "${Text[24]}"
		exit;
	fi
fi

## Creamos nueva tabla de particiones, 2 particiones: 1 Swap + 1 Ext4
if ! parted -s ${info[3]} mklabel msdos >> /dev/null; then
	Text R "${Text[29]}"
	exit;
fi

if ! parted -s ${info[3]} mkpart primary 0% 90% >> /dev/null; then
	Text R "${Text[28]}"
	exit;
fi

if ! parted -s ${info[3]} mkpart primary linux-swap 90% 100% >> /dev/null; then
	Text R "${Text[27]}"
	exit;
fi

if ! parted -s ${info[3]} set 1 boot on; then
	Text R "${Text[73]}"
	exit;
fi

if mkfs.ext4 -L "Alos" -q ${info[4]} >> /dev/null; then
	echo -e "${Text[25]}"
	echo -e "\b\n"
else
	Text R "${Text[26]}"
	exit
fi




######## INSTALANDO EL SISTEMA
Header
Text Y "${Text[30]}"
echo -e "${Text[31]}"
if ! mount ${info[4]} /mnt >> /dev/null; then
	Text R "${Text[32]}"
	exit
fi
if mkdir /mnttmp >> /dev/null; then
	if ! mount -t squashfs -o loop /live/image/live/filesystem.squashfs /mnttmp >> /dev/null; then
		Text R "${Text[34]}"
		exit
	fi
else
	Text R "${Text[33]}"
	exit
fi


## Copiamos el nucleo, el initrd y todos los archivos
if mkdir /mnt/boot >> /dev/null; then
	if ! cp /live/image/live/vmlinuz /mnt/boot/vmlinuz-3.2.0-3-686-pae >> /dev/null; then
		Text R "${Text[35]}"
		exit
	fi
	if ! cp /live/image/live/initrd.img /mnt/boot/initrd.img-3.2.0-3-686-pae >> /dev/null; then
		Text R "${Text[36]}"
		exit
	fi
else
	Text R "${Text[37]}"
	exit
fi


## Calculamos el tamaño del sistema LIVE (mnttmp)
SizeofMnttmp=$(Sizeof /mnttmp)

## Copiamos el sistema LIVE (mnttmp) a TARGET (mnt) en segundo plano
cp -dpR /mnttmp/* /mnt/ &

## Almacenamos el PID de lo anterior
Cppid=$!

## Calculamos y mostramos el porcentaje de avance de la copia
trap "kill $Cppid" 2 15
while Running $Cppid; do
	SizeofMnt=$(Sizeof /mnt/)
	PercentageCopied=$(($SizeofMnt*98/$SizeofMnttmp))
	if [ $PercentageCopied -le 100 ]; then
		echo -e "\r$PercentageCopied%\c"
	fi
	sleep 1
done
echo -e "\b\n${Text[38]}"




######## CONFIGURACION DE TARGET
Header
Text Y "${Text[39]}"

## Configurando redes
echo -e "${Text[40]}"
if ! cp /etc/resolv.conf /mnt/etc/ >> /dev/null; then
	Text R "${Text[68]}"
	exit;
fi
if ! cp /etc/hosts /mnt/etc/hosts >> /dev/null; then
	Text R "${Text[69]}"
	exit;
fi
if ! cp /etc/hostname /mnt/etc/hostname >> /dev/null; then
	Text R "${Text[70]}"
	exit;
fi
if ! cp /etc/network/interfaces /mnt/etc/network/interfaces >> /dev/null; then
	Text R "${Text[71]}"
	exit;
fi

## Configurando el reloj
echo -e "${Text[41]}"
if ! cp -a /etc/adjtime /mnt/etc/ >> /dev/null; then
	Text R "${Text[72]}"
fi

## Configurando el fichero fstab
echo -e "${Text[42]}"
if ! Create_Fstab /mnt/etc ${info[4]} ${info[5]} >> /dev/null; then
	Text R "${Text[12]}"
	exit;
fi

## Instalamos y configuramos BOOTLOADER
if ! mkdir -p /mnt/boot/extlinux/ >> /dev/null; then
	Text R "${Text[74]}"
	exit;
fi

if ! extlinux -i /mnt/boot/extlinux/ >> /dev/null; then
	Text R "${Text[49]}"
	exit;
fi

if ! cat /usr/lib/extlinux/mbr.bin >> ${info[3]}; then
	Text R "${Text[49]}"
	exit;
fi

if ! Create_Extlinux_Conf /mnt/boot/extlinux ${info[4]} >> /dev/null; then
	Text R "${Text[61]}"
	exit;
fi

## Configurando Inittab
if ! Create_Inittab /mnt/etc; then
	Text R "${Text[66]}"
	exit;
fi

## Configuramos las cuentas de usuario
echo -e "${Text[58]}"
if ! chroot /mnt usermod -p `mkpasswd -m sha-512 $AdminPass alosalos` root; then
	Text R "${Text[59]}"
	exit;
fi

if ! chroot /mnt touch /etc/alos-installed; then
	Text R "${Text[43]}"
	exit;
fi

## Desmontamos todo lo necesario para reiniciar
echo -e "${Text[51]}"
if ! umount -lf /mnt >> /dev/null; then
	Text R "${Text[53]}"
	exit;
fi
if ! umount -lf /mnttmp >> /dev/null; then
	Text R "${Text[54]}"
	exit;
fi




######## MENSAJE FINAL
Header

## Mensaje de exito al final
Text Y "${Text[67]}"
echo -e "\b\n"

## Preguntamos y reiniciamos
echo -e "${Text[60]}"
while true; do
	read -p "${Text[13]}" Reboot
	case $Reboot in
		[SYsy]* ) init 6; break;;
		[Nn]* ) exit;;
		* )
	esac
done
