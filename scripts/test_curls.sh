#!/bin/bash

URL=${1}
URL=${URL:-localhost:5045/v1/accounts}

METHOD=${2}
METHOD=${METHOD:-POST}

AUTH=$(echo -e "${API_USERNAME}:${API_PASSWORD}" | base64)
AUTH_HEADER="Authorization: Basic ${AUTH}"

curl \
    -v \
    -s \
    -X "${METHOD}" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"${DEFAULT_API_EMAIL}\", \"username\": \"${DEFAULT_API_USERNAME}\", \"password\": \"${DEFAULT_API_PASSWORD}\"}" \
    "${URL}"
