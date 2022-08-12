#!/bin/bash

optstring=":h"
self=$(basename $0)

_help() {
    cat<<EOF
Usaage for $self

EOF
}

# Parse arguments
while getopts ${optstring} arg; do
    case ${arg} in
        h)
            _help
            exit 0
            ;;
        :)
            echo "Option -${OPTARG} requires argument"
            echo "$self -h for usage help"
            exit 2
            ;;
        ?)
            echo "Unknown option -${OPTARG}"
            _help
            exit 127
            ;;
    esac
done
