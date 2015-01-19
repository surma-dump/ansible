#!/bin/bash

HOSTNAME={{ hostname }}
APIKEY={{ domain_token }}
DOMAIN={{ domain_name }}
IP=$(curl -s http://jsonip.com | grep -Eo "[0-9.]{5,}")

if [ $(curl -s -X GET -H "X-DNSimple-Domain-Token: $APIKEY" -H "Accept: application/json" "https://api.dnsimple.com/v1/domains/$DOMAIN/records?type=A" | grep $HOSTNAME | wc -l) -eq 0 ]; then
        echo "Creating new record..."
        curl -s -X POST -H "X-DNSimple-Domain-Token: $APIKEY" -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"record\":{\"name\":\"$HOSTNAME\",\"record_type\": \"A\", \"content\": \"$IP\", \"ttl\": 60}}" "https://api.dnsimple.com/v1/domains/$DOMAIN/records"

else
        ID=$(curl -s -X GET -H "X-DNSimple-Domain-Token: $APIKEY" -H "Accept: application/json" "https://api.dnsimple.com/v1/domains/$DOMAIN/records?type=A" | python -mjson.tool | grep "\"$HOSTNAME\"" -B4 -A6 | grep '"id"' | grep -Eo '[0-9]+')
        echo "Found existing record with ID $ID"
        curl -s -X PUT -H "X-DNSimple-Domain-Token: $APIKEY" -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"record\":{\"name\":\"$HOSTNAME\",\"record_type\": \"A\", \"content\": \"$IP\", \"ttl\": 60}}" "https://api.dnsimple.com/v1/domains/$DOMAIN/records/$ID"
fi
