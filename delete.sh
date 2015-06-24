#!/bin/bash

if [ "$1" == "" ]; then
    echo "Requires Trace-ID as first parameter (for deletion)"
    exit 1
fi

curl -i -H "Accept: application/json" -X DELETE http://127.0.0.1:9393/traces/$1
