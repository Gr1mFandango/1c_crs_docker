#!/bin/bash

if [ "$1" = "crserver" ]; then
  exec gosu usr1cv8 /opt/1cv8/i386/$ONEC_VERSION/crserver -port $CRS_PORT -d /home/usr1cv8/.1cv8 
fi                  

exec "$@"