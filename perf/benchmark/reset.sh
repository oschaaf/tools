 #kubectl delete --grace-period=0 --force namespace twopods
 DNS_DOMAIN=localhost ./setup_test.sh
 python3 runner/runner.py --duration 93 --conn 10,20 --qps 1000 --serversidecar
 