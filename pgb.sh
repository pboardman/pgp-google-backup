#!/bin/bash

help_dialog()
{
  echo "Usage: $0 directory_to_backup pgp_recipient"
  echo
  echo "Options:"
  echo "-t [directory] change the tmp directory where the encrypted data is placed"
  exit 1
}

dir_exist()
{
  if [ ! -d "$1" ];
  then
    echo "Directory $1 doesn't exist"
    echo "Quitting"
    exit 1
  fi
}

tmp_dir=/tmp/
while getopts "ht:" opt; do
  case $opt in
    h) help_dialog;;
    t) tmp_dir=$OPTARG;;
    ?) help_dialog;;
  esac
done

# Argument verification
if [ $# -eq 0 ];
then
  help_dialog
fi

dir_to_bckp=${*: -2:1}
pgp_recipient=${*: -1:1}


# Adding a / at the end of the tmp folder
len=${#tmp_dir}-1
if [ "${tmp_dir:len}" != "/" ];
then
  tmp_dir=$tmp_dir"/"
fi

# Checking if the directory exist
dir_exist $dir_to_bckp
dir_exist $tmp_dir

# Encrypting the Directory
date=$(date +%Y-%m-%d)
bckp_out_dir=$tmp_dir$$
filename=backup-$$-$date.tar.gz.gpg
gpg_output=$bckp_out_dir/$filename

mkdir $bckp_out_dir

time=$(date +%Y-%m-%d-%H:%M:%S)
echo "[$time]----- Encrypting the directory"
tar zcf - $dir_to_bckp | gpg2 -r $pgp_recipient -e > $gpg_output

# Uploading to google drive
echo "[$time]----- Uploading to Google drive"
drive upload --file $gpg_output &> /dev/null

# Testing if file successfuly uploaded
file_on_drive=$(drive list | grep $filename)
if [ "$file_on_drive" == ""  ];
then
  time=$(date +%Y-%m-%d-%H:%M:%S)
  echo "[$time]----- There was an error uploading the file"
  exit 1
fi

time=$(date +%Y-%m-%d-%H:%M:%S)
echo "[$time]----- Uploaded $filename to Google drive"

# Deleting the local .gpg file
rm -rf $bckp_out_dir

time=$(date +%Y-%m-%d-%H:%M:%S)
echo "[$time]----- Done!"
