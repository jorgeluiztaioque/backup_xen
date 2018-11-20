#!/bin/bash

#Destino onde ficara guardado o backup
dir="/mnt/usb/";

#Pegando nomes das maquinas
uuids=$(xe vm-list is-control-domain=false is-a-snapshot=false power-state=running | grep "uuid" | awk '{ print $'5'}');
labels=$(xe vm-list is-control-domain=false is-a-snapshot=false power-state=running | grep "name-label" | awk '{ print $'4' $'5' $'6' $'7' $'8' $'9' $'10'}');
qvms=$(echo "$uuids" | wc -l);

#Loop para backup de cada VM
for i in `seq 1 $qvms`
do
uuid=$(echo $uuids | awk '{ print $'$i'}');
label=$(echo $labels | awk '{ print $'$i'}');

# creating a snapshot
snuuid=$(xe vm-snapshot uuid=$uuid new-name-label=$label-backup)

# Turn snapshot in a template
xe template-param-set is-a-template=false ha-always-run=false uuid=$snuuid

# export template as a backup to remote server
xe vm-export vm=$snuuid filename=$dir$label-backup.xva

#remove a template
xe vm-uninstall uuid=$snuuid force=true

done
