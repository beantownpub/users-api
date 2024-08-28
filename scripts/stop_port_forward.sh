#!/bin/bash

PID=$(ps | grep "${1}:${1}" | grep -v 'grep' | awk '{print $1}')

if [[ -n ${PID} ]]; then
    kill "${PID}" || exit 0
fi
