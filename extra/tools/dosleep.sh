#!/bin/bash

while [ true ]; do
  echo "Ejecutando: $@"
  $@
  sleep 15
done
