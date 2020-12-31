#!/bin/bash

# clone the repository
# git clone https://github.com/ajveldhi/srs_assign.git

# First set the below AWS credentials

#echo 'export AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXXX"' >> .profile
#echo 'export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXX"'  >> .profile
#echo 'export AWS_DEFAULT_REGION="us-east-1"'  >> .profile

# install terraform ansible and awscli
wget https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
sleep 1
sudo apt update
sudo apt install unzip -y
sleep 1
unzip terraform_0.13.4_linux_amd64.zip
sudo mv terraform /usr/local/bin
sleep 1
sudo apt-get update -y
sudo apt-add-repository ppa:ansible/ansible -y
sleep 1
sudo apt-get install ansible -y

sudo apt-get install python-pip -y  ;  sleep 1 ; pip install awscli  ; sleep 1 ; sudo ln -s $PWD/.local/bin/aws /usr/local/bin/aws

cd tr

terraform init
terraform get
sleep 1
terraform apply -auto-approve

## get the public IPs of instances
cd ..
aws  ec2 describe-instances --filters "Name=instance-state-name,Values=running"  --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text > public_ips.txt

# add all instances to known_hosts so that we do not get issues while running ansible
cat public_ips.txt | awk '{ print "ssh-keyscan -H "$1" >> ~/.ssh/known_hosts" }'   > add_host.sh
sh add_host.sh

cat public_ips.txt > hosts

mmm=$PWD"/tr/modules/ec2/mykey"

cat hosts  | awk '{print $1 " ansible_ssh_private_key_file='$mmm'"}' > host
sed  -i '1i [docker]' host

## installing docker on all instances
ansible-playbook doc_playbook.yml -i host

ansible-playbook add_docker_user_playbook.yml -i host

ansible-galaxy collection install community.general

sleep 1

##  docker swarm on first node
ansible-playbook new_swarm.yaml -i host

##  docker compose on first node
ansible-playbook doc-com-playbook.yml -i host

sleep 1

echo "docker swarm join-token worker" > get_token.sh
head -1 public_ips.txt | awk '{print "ssh -i '$mmm' -l ubuntu "$1" < get_token.sh " }'  > add_wo.sh
tail -2 add_wo.sh > add_wo1.sh
tail -4 hosts | awk '{print "ssh -i '$mmm' -l ubuntu "$1" < add_wo1.sh " }'  > add_nodes.sh

##  adding nodes to swarm
sh add_nodes.sh

## scp the file docker-compose.yml to fist node the run docker-compose up -d


