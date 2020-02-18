#!/usr/bin/env python3

from prometheus_client import start_http_server, Histogram
import random
import time
from os import pipe, fdopen
from signal import signal, SIGINT, SIGTERM
from argparse import ArgumentParser
from modules.sampler import Sampler
from modules.collector import Collector

global COLLECTOR


def signal_handler(a, b):
    print("stopping... ")
    global COLLECTOR
    COLLECTOR.stop()


if __name__ == '__main__':
    parser = ArgumentParser(description='Proc stat sampler CLI')
    parser.add_argument("--track-proc-name", type=str, nargs="*",
                        help='Optional process name(s) to track.', default=[])
    parser.add_argument("--sample-frequency", type=int, default=1,
                        help='Number of samples to obtain per second.')
    parser.add_argument("--http-port", type=int, default=8000,
                        help='Http port for exposing prometheus metrics.')

    args = parser.parse_args()

    signal(SIGINT, signal_handler)
    signal(SIGTERM, signal_handler)

    global COLLECTOR
    r, w = pipe()
    COLLECTOR = Collector(fdopen(w, "wb", 1024), sampler=Sampler(
        process_names_of_interest=args.track_proc_name), sample_interval=1.0/args.sample_frequency)
    start_http_server(args.http_port)

    COLLECTOR.start()
    
    cpu_percent = Histogram('machine_cpu_percent', 'Machine wide cpu percentages observed')
    cpu_time = Histogram('machine_cpu_time', 'Description of histogram')

    with fdopen(r, "rb", 1024) as f:
        it = COLLECTOR.read_dump(f)
        for entry in it:
            cpu_percent.observe(entry["cpu_percent"])
            cpu_percent.observe(entry["cpu_times"].softirq)
    print("stopped")
