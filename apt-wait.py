import fcntl, time
handle = open("/var/lib/dpkg/lock", "w")
while True:
    try:
        fcntl.lockf(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        exit(0)
    except IOError:
        time.sleep(1)
