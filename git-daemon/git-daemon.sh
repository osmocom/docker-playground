#!/bin/bash

#* STRICT_PATHS    : 0 or 1, default 0
#* INIT_TIMEOUT    : numeric, 0 - use git default value
#* TIMEOUT         : numeric, 0 - use git default value
#* MAX_CONNECTIONS : numeric, default 32
#* VERBOSE         : 0 or 1, default 0
#* REUSEADDR       : 0 or 1, default 1

ARGS=""

if [[ "${STRICT_PATHS}" == "1" ]]; then
    ARGS="${ARGS} --strict-paths"
fi

if [ -z "${REUSEADDR}" ] || [ "${REUSEADDR}" == "1" ]; then
    ARGS="${ARGS} --reuseaddr"
fi

if [ -z "${VERBOSE}" ] || [ "${VERBOSE}" == "1" ]; then
    ARGS="${ARGS} --verbose"
fi

if [ -n "${INIT_TIMEOUT}" ]; then
    ARGS="${ARGS} --init-timeout=${TIMEOUT}"
fi

if [ -n "${TIMEOUT}" ]; then
    ARGS="${ARGS} --timeout=${TIMEOUT}"
fi

if [ -n "${MAX_CONNECTIONS}" ]; then
    ARGS="${ARGS} --max-connections=${MAX_CONNECTIONS}"
fi

git daemon --base-path=/git ${ARGS}
