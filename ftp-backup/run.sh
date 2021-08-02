#!/bin/bash
set -e

echo "[Info] Starting FTP Backup!"

CONFIG_PATH=/data/options.json
ftpprotocol=$(jq --raw-output ".ftpprotocol" $CONFIG_PATH)
ftpserver=$(jq --raw-output ".ftpserver" $CONFIG_PATH)
ftpport=$(jq --raw-output ".ftpport" $CONFIG_PATH)
ftpbackupfolder=$(jq --raw-output ".ftpbackupfolder" $CONFIG_PATH)
ftpusername=$(jq --raw-output ".ftpusername" $CONFIG_PATH)
ftppassword=$(jq --raw-output ".ftppassword" $CONFIG_PATH)
addftpflags=$(jq --raw-output ".addftpflags" $CONFIG_PATH)
zippassword=$(jq --raw-output ".zippassword" $CONFIG_PATH)
deleteolderthan=$(jq --raw-output ".deleteolderthan" $CONFIG_PATH)

ftpurl="$ftpprotocol://$ftpserver:$ftpport/$ftpbackupfolder/"
credentials=""
if [ "${#ftppassword}" -gt "0" ]; then
	credentials="-u $ftpusername:$ftppassword"
fi

hassbackup="/backup"

echo "[Info] trying to upload backup files to $ftpurl"
cd $hassbackup
curl $addftpflags $credentials -T "{$(echo *.tar | tr ' ' ',')}" $ftpurl
cd -

if [ "${#deleteolderthan}" -gt "0" ]; then
	echo "[Info] Deleting files older than $deleteolderthan days"
	find $hassbackup/*.tar -mtime +$deleteolderthan -exec rm {} \;
fi

echo "[Info] Finished ftp backup"
