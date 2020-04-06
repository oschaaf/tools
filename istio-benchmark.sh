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
    python3 runner/runner.py --conn 2 --qps 10000 --duration 100 --serversidecar --perf=true
    #python3 runner/runner.py --conn 2 --qps 1000 --duration 1 --serversidecar
fi 
