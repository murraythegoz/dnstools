#!/usr/bin/env python

import sys
import re
import datetime
import fileinput
import os


def update_serial(file_path):
    with open(file_path, "r") as zonefile:
        content = zonefile.read()

    zoneserial = re.search(r"(\d+).*serial", content)
    if not zoneserial:
        print("No serial found. Is that a zone file?")
        return

    olddate, oldserial = zoneserial.group(1)[:8], zoneserial.group(1)[8:]
    curdate = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%d")

    if len(zoneserial.group(1)) == 10:
        print("Correct format, updating")
        if olddate < curdate:
            newdate = curdate
            newserial = "00"
        elif olddate == curdate:
            newdate = olddate
            newserial = str(int(oldserial) + 1).zfill(2)
        else:
            print("Incorrect old serial, please check")
            return
    else:
        print("Old format, will normalize to YYYYMMDDSS")
        newdate = curdate
        newserial = "00"

    newzoneserial = f"{newdate}{newserial} ; serial"
    print(newzoneserial)

    with fileinput.FileInput(file_path, inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace(zoneserial.group(0), newzoneserial), end='')


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: " + os.path.basename(sys.argv[0]) + " <zonefile>")
        sys.exit(1)
    update_serial(sys.argv[1])
