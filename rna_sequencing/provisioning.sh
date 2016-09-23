#!/bin/bash
sleep 30
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
sudo service docker restart
mkdir /home/ubuntu/SCRATCH
cd /home/ubuntu/SCRATCH
sudo docker load < /tmp/pipeline-star-0.2.15.tar
sudo rm /tmp/pipeline-star-0.2.15.tar
sudo docker load < /tmp/docker.htseq.v2.9.tar
sudo rm /tmp/docker.htseq.v2.9.tar
sudo umount /tmp
sudo echo 'MINTMPKB=0' > sudo /etc/default/mountoverflowtmp
sudo apt-get -y install python-pip
sudo -H pip install --upgrade pip
sudo -H pip install virtualenv
sudo -H pip install virtualenvwrapper
sudo -H pip install awscli --ignore-installed six
mkdir /home/ubuntu/.aws
echo '[default]' > /home/ubuntu/.aws/config
echo 'aws_access_key_id=' | sudo tee -a /home/ubuntu/.aws/config
echo 'aws_secret_access_key=' | sudo tee -a /home/ubuntu/.aws/config
echo 'region=us-east-1' | sudo tee -a /home/ubuntu/.aws/config
aws s3 cp s3://abbvie-partners/references /home/ubuntu/SCRATCH/references --recursive
truncate -s 0 /home/ubuntu/.aws/config
wget https://gdc-api.nci.nih.gov/data/9c78cca3-c7d3-4cde-9d6c-54ec09421958 -o star.index.genome.d1.vd1.gtfv22.tar.gz
wget https://gdc-api.nci.nih.gov/data/fe1750e4-fc2d-4a2c-ba21-5fc969a24f27 -o gencode.v22.annotation.gtf.gz
tar -zxvf star.index.genome.d1.vd1.gtfv22.tar.gz
tar -zxvf gencode.v22.annotation.gtf.gz
export WORKON_HOME=~/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv p2
workon p2
