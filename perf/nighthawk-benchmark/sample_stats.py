import psutil
import time

while True:
    # sample = psutil.cpu_times_percent(interval=0)
    sample = psutil.cpu_freq(percpu=True)
    print(sample)
    time.sleep(0.1)


