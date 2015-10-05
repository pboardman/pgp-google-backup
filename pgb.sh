#!/bin/bash

# Argument verification
if [ "$#" -ne 2 ];
then
  echo "Usage: $0 directory_to_backup pgp_recipient"
  exit 1
fi

dir_to_bckp=$1
pgp_recipient=$2
tmp_dir=/tmp/

# Checking if the directory exist
if [ ! -d $dir_to_bckp ];
then
  echo "Directory doesn't exist."
  echo "Quitting."
  exit 1
fi

# Encrypting the Directory
date=$(date +%Y-%m-%d)
bckp_out_dir=$tmp_dir$$
gpg_output=$bckp_out_dir/backup-$$-$date.tar.gz.gpg

mkdir $bckp_out_dir

echo "Encrypting the directory"
tar zcf - $dir_to_bckp | gpg -r $pgp_recipient -e > $gpg_output

# Uploading to google drive
echo "Uploading to Google drive"
drive upload --file $gpg_output

# Deleting the local .gpg file
rm -rf $bckp_out_dir

echo "Done!"
