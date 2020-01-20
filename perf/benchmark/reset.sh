#!/bin/bash

set +x
set -e 

#kubectl delete --grace-period=0 --force namespace twopods || true
DNS_DOMAIN=localhost ./setup_test.sh || true

NIGHTHAWK_CLIENT=$(kubectl -n twopods get pods --sort-by='.status.containerStatuses[0].restartCount' -lapp=fortioclient -o custom-columns=NAME:.metadata.name --no-headers)
NIGHTHAWK_SERVER=$(kubectl -n twopods get pods --sort-by='.status.containerStatuses[0].restartCount' -lapp=fortioserver -o custom-columns=NAME:.metadata.name --no-headers)

echo "============== nighthawk client pod logs captured"
kubectl -n twopods logs -c captured $NIGHTHAWK_CLIENT | tail -n 4
echo ""
echo "============== nighthawk client pod logs uncaptured"
kubectl -n twopods logs -c uncaptured $NIGHTHAWK_CLIENT | tail -n 4
echo ""
echo "============== nighthawk test server pod logs captured"
kubectl -n twopods logs -c captured $NIGHTHAWK_SERVER | tail -n 4
echo ""
echo "============== nighthawk test server pod logs uncaptured"
kubectl -n twopods logs -c uncaptured $NIGHTHAWK_SERVER | tail -n 4
echo ""
