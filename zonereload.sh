#!/bin/bash

docker exec masterdns rndc -k /etc/bind/local-config/rndc.key -y rndc-key reload
