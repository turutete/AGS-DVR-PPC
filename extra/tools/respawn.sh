#!/bin/bash

file="respawn-$$.zlog"
contador=0

while [ true ]; do
  $@
  (( contador += 1 ))
  #echo "contador: ${contador}"
  echo "contador: ${contador}" > /var/log/${file}
  #sleep XXX   #pruebas
done
