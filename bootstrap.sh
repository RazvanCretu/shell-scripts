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
`$usr/aws/install`
rm -rf $usr/aws $usr/awscliv2.zip

##### CONDA #####

mkdir $usr/.miniconda3

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $usr/.miniconda3/miniconda.sh
bash $usr/.miniconda3/miniconda.sh -b -u -p $usr/.miniconda3
rm -rf $usr/.miniconda3/miniconda.sh
su - ubuntu -c "$usr/.miniconda3/bin/conda init bash"

chown -R 1000:1000 $usr/.miniconda3
chmod 755 $usr/.miniconda3

su - ubuntu -c "source $usr/.bashrc && $usr/.miniconda3/bin/conda create -n data-engineer --no-default-packages python=3.11 pandas boto3 -y"
curl -o $usr/instance_scheduler_cli-1.5.3-py3-none-any.whl https://s3.amazonaws.com/solutions-reference/instance-scheduler-on-aws/latest/instance_scheduler_cli-1.5.3-py3-none-any.whl
su - ubuntu -c "$usr/.miniconda3/envs/data-engineer/bin/pip install $usr/instance_scheduler_cli-1.5.3-py3-none-any.whl"
rm -rf $usr/instance_scheduler_cli-1.5.3-py3-none-any.whl

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

mkdir $usr/.npm-global
chown -R 1000:1000 $usr/.npm-global
chmod 755 $usr/.npm-global

su - ubuntu -c "npm config set prefix $usr/.npm-global"

printf '\n\nexport PATH=~/.npm-global/bin:$PATH' >> $usr/.bashrc

su - ubuntu -c "npm install -g npm@10.2.5 pm2"
