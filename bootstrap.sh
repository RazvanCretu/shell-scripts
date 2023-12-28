#!/bin/bash

usr=/home/ubuntu

##### UPDATE SYSTEM #####

add-apt-repository ppa:git-core/ppa -y # required for latest github releases
apt update -y
apt upgrade -y
apt install unzip -y
apt install git -y

##### AWS #####

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$usr/awscliv2.zip"
unzip $usr/awscliv2.zip
$usr/aws/install
rm -rf $usr/aws $usr/awscliv2.zip

##### CONDA #####

mkdir $usr/.miniconda3

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $usr/.miniconda3/miniconda.sh
bash $usr/.miniconda3/miniconda.sh -b -u -p $usr/.miniconda3
rm -rf $usr/.miniconda3/miniconda.sh
su - ubuntu -c "$usr/.miniconda3/bin/conda init bash"

chown -R 1000:1000 $usr/.miniconda3
chmod 755 $usr/.miniconda3

##### S3FS #####

mkdir $usr/data

apt install automake autotools-dev fuse g++ libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config -y
git clone https://github.com/s3fs-fuse/s3fs-fuse.git $usr/s3fs-fuse
cd $usr/s3fs-fuse
./autogen.sh
./configure
make
make install
cd /
rm -rf $usr/s3fs-fuse

chown -R 1000:1000 $usr/data
chmod 755 $usr/data

if grep -q s3fs /etc/fstab; then :
        echo "s3fs initialized."
    else
        echo "s3fs#general-cr3tu:/master /home/ubuntu/data fuse _netdev,allow_other,iam_role=auto,uid=1000,gid=1000  0  0" >> /etc/fstab
        mount -a
fi

##### NODEJS #####

curl -sL https://deb.nodesource.com/setup_20.x -o $usr/nodesource_setup.sh
bash $usr/nodesource_setup.sh
apt install nodejs -y
rm -rf $usr/nodesource_setup.sh