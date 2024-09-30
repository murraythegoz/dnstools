#!/bin/bash
#put zone files in a directory and build a bind zone config to reference all individual zone files  
#this script is tailored for a docker bind deployment

#config dir in host
BASEPATH=/opt/dnsserver/dns-data/local-config
#where zone files are put
AUTOZONEPATH=$BASEPATH/autozones
#autozone file is referenced by main bind local-config (usually bind.conf.local) with an include statement
AUTOZONEFILE=$BASEPATH/named.conf.autozone
#zone files path in docker container's tree path if dockerized deployment
ZONEDEFPATH=/etc/bind/local-config/autozones
#if non-dockerized deployment, simply set same as AUTOZONEPATH
#ZONEDEFPATH=$AUTOZONEPATH


#enable extended gbbing to allow proper regex matching of autozone files
shopt -s extglob

#backup former autozone file
cp -a $AUTOZONEFILE $AUTOZONEFILE.old

#create new empty autozone file
> $AUTOZONEFILE.new
# only includes zone files ending with local or arpa, thus excluding e.g. any "*.bak" 
# adjust the regex according to the files you want to include.
# if you want to include all just use "*" 
for zonefile in $AUTOZONEPATH/*+(arpa|local); do

    #name zone after the zonefile name.
    CURZONE="$(basename "$zonefile")"
    cat <<EOF >> $AUTOZONEFILE.new
zone "$CURZONE" {
    type master;
    file "$ZONEDEFPATH/$CURZONE";
    masterfile-format text;

    #enable notification and transfer to secondaries
    notify yes;
    also-notify     { 192.0.2.1; 192.0.2.2; };
    allow-transfer  { 192.0.2.1; 192.0.2.2; };
};
EOF
    done

cat $AUTOZONEFILE.new > $AUTOZONEFILE
rm $AUTOZONEFILE.new
#follow a "rndc reload" to update bind 
