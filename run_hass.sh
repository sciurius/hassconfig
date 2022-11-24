#!/bin/sh

# For use without systemd.

export PATH=`pwd`/bin:$PATH
ret=100

while [ $ret = 100 ]; do
    hass
    ret=$?
    echo ""
    echo "Return status = $ret"
    echo ""
done
    
