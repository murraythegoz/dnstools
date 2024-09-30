# dnstools
Some short scripts to manage a master bind dns server, mostly running as a docker (but can be adapted to run on the host directly)

These include:
- autozoneupdate.sh: create main zone config on bind by putting a zone file in a special directory
- binddumpserial.py: update the serial of the zone with the common YYYYMMDDNN serial notation
- zonereload.sh: script to reload bind running in a docker container
