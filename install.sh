#! /bin/bash -eu

docker build -t ec2ssh .
mkdir -p ~/bin
ln -fs $PWD/ec2ssh ~/bin/ec2ssh
