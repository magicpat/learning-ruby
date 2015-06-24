#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

#curl -i -H "Content-Type: application/json" -X PUT -d "@${SCRIPT_DIR}/fixture/0.json" http://localhost:9393/traces
#curl -i -H "Content-Type: application/json" -X PUT -d "@${SCRIPT_DIR}/fixture/1.json" http://localhost:9393/traces
#curl -i -H "Content-Type: application/json" -X PUT -d "@${SCRIPT_DIR}/fixture/2.json" http://localhost:9393/traces
#curl -i -H "Content-Type: application/json" -X PUT -d "@${SCRIPT_DIR}/fixture/3.json" http://localhost:9393/traces
#curl -i -H "Content-Type: application/json" -X PUT -d "@${SCRIPT_DIR}/fixture/4.json" http://localhost:9393/traces
curl -i -H "Content-Type: application/json" -X PUT -d "@${SCRIPT_DIR}/fixture/5.json" http://localhost:9393/traces
