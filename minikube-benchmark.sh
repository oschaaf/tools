#/bin/bash

set +x
set -e
set -u

export CLUSTER_NAME=otto-perf-cluster
export DNS_DOMAIN=local
export ISTIO_RELEASE=1.6-alpha.e584773d5cefc36dd3b48766a596215db4a84632
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

if [[ ${do_setup_cluster} -eq "1" ]]; then
    pushd "${istio_tools_root}/perf/istio-install"
    #echo "Create a cluster"
    #./create_cluster.sh $CLUSTER_NAME
    echo "Setting up istio"
    ./setup_istio_release.sh $ISTIO_RELEASE dev
    # Need priviledged proxy containers for sudo
    # Need writeable dir for apt-get update to work, as this gets us writeable directories it needs
    istioctl manifest apply --set values.global.proxy.privileged=true --set values.global.proxy.enableCoreDump=true
    # in container, we no do
    apt-get install linux-tools-generic
    rm /usr/bin/perf
    ln /usr/lib/linux-tools-4.15.0-88/perf /usr/bin/perf
    popd
fi

if [[ ${do_run_benchmark} -eq "1" ]]; then
    kubectl delete namespace $NAMESPACE || true
    pushd "${istio_tools_root}/perf/benchmark"
    echo "Set up fortioclient / fortioserver pods"
    ./setup_test.sh
    echo "Run tests"
    #python3 runner/runner.py  --config_file ./configs/istio/mixer_latency.yaml
    python3 runner/runner.py --conn 2 --qps 1000 --duration 1 --serversidecar --perf=true
fi 
