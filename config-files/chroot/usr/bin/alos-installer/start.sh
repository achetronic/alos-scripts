#!/bin/bash

## Limpiamos la pantalla
clear
cat /usr/bin/alos-installer/header

## Listamos las funciones
function ListLanguages {
	List=$(ls /usr/bin/alos-installer/languages)
	i=1
	for Item in $List; do
		Language=$(echo $Item | cut -d "." -f 1)
		if [ $# -eq 1 ]; then
			if [ $1 -eq $i ]; then
				echo $Language
			fi
		else
			echo $i")" $Language

		fi
		((i++));
	done
}

## Listamos los idiomas disponibles
ListLanguages

## Leemos la opcion elegida por el usuario y cargamos el instalador correspondiente
read -p "Write a number: " Choice
if [ $Choice ]; then
	if [ -f /usr/bin/alos-installer/languages/$(ListLanguages $Choice).lang  ]; then
		/usr/bin/alos-installer/installer.sh $(ListLanguages $Choice)
	else
		$0
	fi
else
	$0
fi
