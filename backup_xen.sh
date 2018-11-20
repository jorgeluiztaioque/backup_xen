#!/bin/bash

# Connecting to remote NFS storage
localdir="/mnt/nasstorage";
nfsserver="200.200.200.200"
nfsremotedir="/home/backupxen/vms"

# mount remove nfs server
mount $nfsserver:$nfsremotedir $localdir

# Pool dump Backup
xe pool-dump-database file-name=$localdir/backup-dump-database
# Backup host
xe host-backup host=host file-name=$localdir/host-backup

# Geting VM informations
uuids=$(xe vm-list is-control-domain=false is-a-snapshot=false power-state=running | grep "uuid" | awk '{ print $'5'}');
labels=$(xe vm-list is-control-domain=false is-a-snapshot=false power-state=running | grep "name-label" | awk '{ print $'4' $'5' $'6' $'7' $'8' $'9' $'10'}');
qvms=$(echo "$uuids" | wc -l);

#Loop to get id and vm labels
for i in `seq 1 $qvms`; do
  uuid=$(echo $uuids | awk '{ print $'$i'}');
  label=$(echo $labels | awk '{ print $'$i'}');

  # creating a snapshot
  snuuid=$(xe vm-snapshot uuid=$uuid new-name-label=$label-backup)

  # Turn snapshot in a template
  xe template-param-set is-a-template=false ha-always-run=false uuid=$snuuid

  # export template as a backup to remote server
  xe vm-export vm=$snuuid filename=$localdir$label-backup.xva

  #remove a template
  xe vm-uninstall uuid=$snuuid force=true

  # packing vm
  tar czvf $localdir$label-backup.tar.gz $localdir$label-backup.xva
  rm -r $localdir$label-backup.xva

  sleep 10

done
