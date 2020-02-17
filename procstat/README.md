# Proc stat sampler

## Run tests

```bash
python3 -m unittest discover -v tests/
```

## Using the sampler

```
./main.py --help
usage: main.py [-h] [--sample-frequency SAMPLE_FREQUENCY]
               [--track-proc-name [TRACK_PROC_NAME [TRACK_PROC_NAME ...]]]
               [--dump-path DUMP_PATH]

Proc stat sampler CLI

optional arguments:
  -h, --help            show this help message and exit
  --sample-frequency SAMPLE_FREQUENCY
                        Number of samples to obtain per second. Defaults to 1
                        per second.
  --track-proc-name [TRACK_PROC_NAME [TRACK_PROC_NAME ...]]
                        Process name(s) to track, if any. Multiple allowed.
  --dump-path DUMP_PATH
                        Path where the result will be written.
```

# Transform a dump from the sampler to yaml

```
oschaaf@burst:~/code/istio/tools/procstat$ ./dump-to-yaml.py --help
usage: dump-to-yaml.py [-h] [--dump-path DUMP_PATH]

Transforms dumps from the sampler to yaml

optional arguments:
  -h, --help            show this help message and exit
  --dump-path DUMP_PATH
                        Path where the target dump resides.
```

### Sample output:

```
--dump-path /tmp/foo
- cpu_percent: 2.4
  cpu_times:
    guest: 0.0
    guest_nice: 0.0
    idle: 8788185.5
    iowait: 2188.63
    irq: 0.0
    nice: 19.19
    softirq: 14.13
    steal: 0.0
    system: 765.38
    user: 5233.24
  processes: []
  timestamp: 1581979800.9612823
- cpu_percent: 0.0
  cpu_times:
    guest: 0.0
    guest_nice: 0.0
    idle: 8788225.51
    iowait: 2188.63
    irq: 0.0
    nice: 19.19
    softirq: 14.13
    steal: 0.0
    system: 765.38
    user: 5233.25
  processes: []
  timestamp: 1581979801.9625692
- cpu_percent: 0.0
  cpu_times:
    guest: 0.0
    guest_nice: 0.0
    idle: 8788265.53
    iowait: 2188.63
    irq: 0.0
    nice: 19.19
    softirq: 14.13
    steal: 0.0
    system: 765.38
    user: 5233.25
  processes: []
  timestamp: 1581979802.963791
```