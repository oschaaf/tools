#!/bin/bash

set -x
set -e

sudo rm -rf dist/
rm requirements.txt || true
python3 -m venv  procstatenv
source procstatenv/bin/activate
pip3 install prometheus-client psutil
pip freeze | grep -v "pkg-resources" > requirements.txt
# We build on a docker to make sure we produce a compatible binary
# (we need to make sure to build it with a compatible glibc version)
docker run -v "$(pwd):/src/" cdrx/pyinstaller-linux:python3

# recreate the directory & fire up the proc stat service
kubectl --namespace twopods-istio exec fortioclient-6b58bf5799-hkq8l -c istio-proxy -- rm -rf /etc/istio/proxy/procstat
kubectl --namespace twopods-istio cp ./ fortioclient-6b58bf5799-hkq8l:/etc/istio/proxy/procstat -c istio-proxy
kubectl --namespace twopods-istio exec fortioclient-6b58bf5799-hkq8l -c istio-proxy -it /etc/istio/proxy/procstat/dist/linux/prom/prom
