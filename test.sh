#!/bin/bash

METHOD=${1}

curl \
    -v \
    -H "Content-Type: application/json" \
    -d '{"username": "jal", "password": "wtfasshole"}' \
    -u jalbot:TerUBK4n4Vs8qRFQYbP64LD8Uxk6 \
    -X ${METHOD} \
    localhost:5045/v1/accounts
