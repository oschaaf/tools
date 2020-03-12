#!/bin/bash

set +x 
set +e
set -u

pushd perf/docker
docker build -f Dockerfile.perf -t "oschaaf/istio-perf:dev" .
docker push oschaaf/istio-perf:dev 
popd
RUN_BENCHMARK=1 ./istio-benchmark.sh
#kubectl exec -n twopods-istio svc/fortioclient -c perf -it /usr/share/bcc/tools/profile  1

