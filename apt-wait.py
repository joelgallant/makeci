import fcntl, time
handle = open("/var/lib/dpkg/lock", "w")
while True:
    try:
        fcntl.lockf(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        break
    except IOError:
        time.sleep(1)

fcntl.lockf(handle, fcntl.LOCK_UN)
