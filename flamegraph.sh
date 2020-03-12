#!/bin/bash
mkdir ~/tmp | true

# sudo apt install linux-tools-gke-4.15
# sudo apt-get install linux-headers-gcp


# Might need to allow priviledged proxy containers.
# istioctl manifest apply --set values.global.proxy.privileged=true
# Might need writeable dir for apt-get update to work
# istioctl manifest apply --set values.global.proxy.enableCoreDump=true

sudo apt-get install bpfcc-tools
sudo /usr/sbin/offcputime-bpfcc  -df -p `pgrep -nx htop` 3 > ~/tmp/out.stacks
pushd ~/tmp
git clone https://github.com/brendangregg/FlameGraph
cd FlameGraph
./flamegraph.pl --color=io --title="Off-CPU Time Flame Graph" --countname=us < ~/tmp/out.stacks > ~/tmp/out.svg
cp ~/tmp/out.svg ~/code/istio/tools/
