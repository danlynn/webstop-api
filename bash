#!/usr/bin/env bash

echo

. ./.helpers.sh

#check_all_service_ports
if [[ $? = 0 ]]; then
  docker-compose run gem bash
fi

echo
echo
