 #!/bin/bash
 set -e 
 set -x
 
 python3 runner/runner.py --duration 93 --conn 10,20 --qps 1000 --serversidecar
