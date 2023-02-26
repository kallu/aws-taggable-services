#!/bin/bash

# Get a list of all AWS services API actions and create
# lists of services that do or do not, support tagging.

# Dependencies

CURL=curl # https://curl.se/
JQ=jq	  # https://stedolan.github.io/jq/

# Get the list of all services and actions in format SERVICE:ACTION
# This is assuming every service has an API and IAM integration.
$CURL --header 'Connection: keep-alive' \
     --header 'Pragma: no-cache' \
     --header 'Cache-Control: no-cache' \
     --header 'Accept: */*' \
     --header 'Referer: https://awspolicygen.s3.amazonaws.com/policygen.html' \
     --header 'Accept-Language: en-US,en;q=0.9' \
     --silent \
     --compressed \
     'https://awspolicygen.s3.amazonaws.com/js/policies.js' |
    cut -d= -f2 |
    $JQ -r '.serviceMap[] | .StringPrefix as $prefix | .Actions[] | "\($prefix):\(.)"' |
    sort |
    uniq > all-services-n-actions.txt

# Create a list of all services
cat all-services-n-actions.txt | sed 's/\:.*$//g' | sort | uniq > all-services.txt

# Create a list of services that support tagging
# ie. services that have an action with string Tag in it
cat all-services-n-actions.txt | grep '\:.*Tag' | sed 's/\:.*$//g' | sort | uniq > taggable-services.txt

# Create a list services that DONT supporting tagging
# ie. lines that are not present in both all-services.txt and taggable-services.txt
cat all-services.txt  taggable-services.txt | sort | uniq --unique > untaggable-services.txt

TS=$(date)
echo "Updated $TS" > timestamp.txt
