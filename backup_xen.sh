#!/bin/bash

#Destino onde ficara guardado o backup
dir="/mnt/usb/";
#Quantidade de cópias diárias que o backup deve permanecer na unidade.
dias=5;
 
#Pegando nomes das maquinas
uuids=$(xe vm-list is-control-domain=false is-a-snapshot=false power-state=running | grep "uuid" | awk '{ print $'5'}');
labels=$(xe vm-list is-control-domain=false is-a-snapshot=false power-state=running | grep "name-label" | awk '{ print $'4' $'5' $'6' $'7' $'8' $'9' $'10'}');
qvms=$(echo "$uuids" | wc -l);
 
#Loop para backup de cada VM
for i in `seq 1 $qvms`
do
uid=$(echo $uuids | awk '{ print $'$i'}');
label=$(echo $labels | awk '{ print $'$i'}');
 
nuid=$(xe vm-snapshot uuid=$uid new-name-label=$label-backup)
xe template-param-set is-a-template=false ha-always-run=false uuid=$nuid
xe vm-export vm=$nuid filename=$dir$label-backup.xva
xe vm-uninstall uuid=$nuid force=true
 
done
 
#Apagando arquivos mais antigos que a variável (dias)
find /mnt/usb/ -ctime +$dias -name "*.xva" -exec rm -rvf {} \;
