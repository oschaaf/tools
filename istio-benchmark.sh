#/bin/bash

set +x
set -e
set -u

# run in istio-install dir

gcloud container clusters get-credentials otto-perf-cluster --zone us-central1-c --project istio-external-01

export PROJECT_ID=istio-external-01
export CLUSTER_NAME=otto-perf-cluster
export ZONE=us-central1-c
export DNS_DOMAIN=local

#export MACHINE_TYPE=n1-standard-16
#export IMAGE=UBUNTU
#export MIN_NODES=1
#export ISTIO_VERSION=1.4.3
#export GKE_VERSION=1.13.7-gke.xx

export ISTIO_RELEASE=1.4-alpha.0ef2cd46e2da64b9252c36ca4bf90aa474b73610
export DNS_DOMAIN=local

export NAMESPACE=twopods-istio
export INTERCEPTION_MODE=REDIRECT
export ISTIO_INJECT=true

do_setup_cluster="${SETUP_CLUSTER:-0}"
istio_tools_root="${ISTIO_TOOLS_ROOT:-$(pwd)}"
do_run_benchmark="${RUN_BENCHMARK:-0}"

echo "do_setup_cluster: ${do_setup_cluster}"
echo "istio_tools_root: ${istio_tools_root}"
echo "do_run_benchmark: ${do_run_benchmark}"

# Use the create_cluster.sh script as a sentinel to sanity check
if [ ! -f "${istio_tools_root}/perf/istio-install/create_cluster.sh" ]; then
    echo "Couldn't find create cluster script ${istio_tools_root}/perf/istio-install/create_cluster.sh"
    exit 1
fi

#gcloud config set project "${PROJECT_ID}"

if [[ ${do_setup_cluster} -eq "1" ]]; then
    pushd "${istio_tools_root}/perf/istio-install"
    echo "Create a cluster"
    ./create_cluster.sh $CLUSTER_NAME
    echo "Setting up istio"
    ./setup_istio_release.sh $ISTIO_RELEASE dev
    popd
fi

if [[ ${do_run_benchmark} -eq "1" ]]; then
    set -x
    kubectl delete namespace $NAMESPACE || true
  
    pushd "${istio_tools_root}/perf/benchmark"
    echo "Set up fortioclient / fortioserver pods"
    ./setup_test.sh
    echo "Run tests"
    #python3 runner/runner.py  --config_file ./configs/istio/mixer_latency.yaml

# nsenter --target 1 --mount --uts --ipc --net --pid -- bash -l
# -v, --volume=[host-src:]container-dest[:<options>]: Bind mount a volume.
#docker run --privileged \
#  -v /sys:/sys \
#  -v /etc/lsb-release:/etc/lsb-release.host \
#  -v /var/cache/linux-headers/modules_dir:/lib/modules \
#  -v /lib/modules:/lib/modules.host \
#  -v /var/cache/linux-headers/generated:/usr/src \
#  -v /usr:/usr-host \
#  -v /boot:/boot.host \
#  --rm -it ubuntu:18.04

#[ ! -d "/usr/src/linux-lakitu-*" ] && apt update \
#  && apt install -y curl \
#  && bash <(curl https://gist.githubusercontent.com/oschaaf/494ef6cfcc6d0d0ad72b079f2c62409e/raw/2138a7dbb1b7a2192dd7048742f8edf3193829cb/headers.sh)


#apk add make gcc curl bash 
#cd ~
#bash
#wget https://gist.githubusercontent.com/oschaaf/494ef6cfcc6d0d0ad72b079f2c62409e/raw/2138a7dbb1b7a2192dd7048742f8edf3193829cb/headers.sh
#chmod +x headers.sh
#./headers.sh
#!/bin/bash

# set -Eeuo pipefail

# kversion=v"$(uname -r | sed -E 's/\+*$//')"
# wget "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/$kversion.tar.gz"
# mkdir kernel
# tar xzf "$kversion.tar.gz" -C kernel
# echo "export BPFTRACE_KERNEL_SOURCE=$PWD/kernel"


python3 runner/runner.py --conn 20 --qps 20000 --duration 10 --custom_profiling_command="profile-bpfcc -df {duration} -p {sidecar_pid}" --custom_profiling_name="bcc-oncputime-sidecar"
#python3 runner/runner.py --conn 20 --qps 20000 --duration 10 --serversidecar --custom_profiling_command="offcputime-bpfcc -df {duration} -p {sidecar_pid}" --custom_profiling_name="bcc-offcputime-sidecar"
#python3 runner/runner.py --conn 20 --qps 20000 --duration 10 --serversidecar --custom_profiling_command="offwaketime-bpfcc -df {duration} -p {sidecar_pid}" --custom_profiling_name="bcc-offwaketime-sidecar"
#python3 runner/runner.py --conn 20 --qps 20000 --duration 10 --serversidecar --custom_profiling_command="wakeuptime-bpfcc -f -p {sidecar_pid} {duration}" --custom_profiling_name="bcc-wakeuptime-sidecar"
#python3 runner/runner.py --conn 20 --qps 20000 --duration 10 --serversidecar --custom_profiling_command="perf record -F 99 -a -g -p {sidecar_pid} -- sleep {duration} && perf script | ~/FlameGraph/stackcollapse-perf.pl | c++filt -n" --custom_profiling_name="perf-oncputime-sidecar"


    #python3 runner/runner.py --conn 2 --qps 10000 --duration 10 --custom_profiling_command="profile-bpfcc -df {duration}" --custom_profiling_name="bcc-oncputime-machine-wide"
    #python3 runner/runner.py --conn 2 --qps 10000 --duration 10 --serversidecar --custom_profiling_command="stackcount-bpfcc 'c:*alloc*' -df -D {duration} -P" --custom_profiling_name="bcc-stackcount-alloc-machine-wide"
    #python3 runner/runner.py --conn 2 --qps 100000 --duration 50 --serversidecar --custom_profiling_command="stackcount-bpfcc c:*alloc* -df -D {duration} -p {sidecar_pid}" --custom_profiling_name="bcc-stackcount-alloc-sidecar"
    #python3 runner/runner.py --conn 2 --qps 10000 --duration 10 --serversidecar --custom_profiling_command="offcputime-bpfcc -df {duration}" --custom_profiling_name="bcc-offcputime-machine-wide"
    #python3 runner/runner.py --conn 2 --qps 10000 --duration 10 --serversidecar --custom_profiling_command="perf record -F 99 -a -g -- sleep {duration} && perf script | ~/FlameGraph/stackcollapse-perf.pl  | c++filt -n" --custom_profiling_name="perf-on-cpu-machine-wide"
    #python3 runner/runner.py --conn 2 --qps 10000 --duration 10 --custom_profiling_command="perf record -e syscalls:sys_enter_brk -a -g -- sleep {duration} && perf script | ~/FlameGraph/stackcollapse-perf.pl  | c++filt -n" --custom_profiling_name="perf-brk-machine-wide"
    #python3 runner/runner.py --conn 2 --qps 10000 --duration 10 --custom_profiling_command="perf record -e syscalls:sys_enter_mmap -a -g -- sleep {duration} && perf script | ~/FlameGraph/stackcollapse-perf.pl  | c++filt -n" --custom_profiling_name="perf-mmap-machine-wide"

    #python3 runner/runner.py --conn 2 --qps 1000 --duration 10 --serversidecar
fi 
