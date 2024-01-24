#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

trap "echo 'Missing parameter'; exit 1" INT TERM EXIT
username="$1"
access_token="$2"
reponame="$3"
project_key="$5"

trap - INT TERM EXIT

spacename="$username"
if [ $# -ge 4 ]; then
    spacename="$4"
fi


# CURL_OPTS=(-u "$username:$password" --silent)


# echo "Validating BitBucket credentials..."
# curl --fail "${CURL_OPTS[@]}" "https://api.bitbucket.org/2.0/user" > /dev/null || (
#     echo "... failed. Most likely, the provided credentials are invalid. Terminating..."
#     exit 1
# )


reponame=$(echo $reponame | tr '[:upper:]' '[:lower:]')



echo "Checking if BitBucket repository \"$spacename/$project_key/$reponame\" exists..."
 curl https://api.bitbucket.org/2.0/repositories/$spacename/$reponame -H "Authorization: Bearer $access_token" -H "Accept: application/json" | grep "error" > /dev/null && (
    echo "BitBucket repository \"$spacename/$project_key/$reponame\" does NOT exist, creating it..."
    curl -X POST --fail https://api.bitbucket.org/2.0/repositories/$spacename/$reponame -H "Authorization: Bearer $access_token" -H "Accept: application/json" -H "Content-Type: application/json" -d '{"scm": "git", "is_private": "true", "project": { "key": "'$project_key'" }}'
 )


# curl "${CURL_OPTS[@]}" "https://api.bitbucket.org/2.0/repositories/$spacename/$reponame" | grep "error" > /dev/null && (
#     echo "BitBucket repository \"$spacename/$reponame\" does NOT exist, creating it..."
#     curl -X POST --fail "${CURL_OPTS[@]}" "https://api.bitbucket.org/2.0/repositories/$spacename/$reponame" -H "Content-Type: application/json" -d '{"scm": "git", "is_private": "true"}' > /dev/null
# )

echo "Pushing to remote..."
git push https://x-token-auth:"$access_token"@bitbucket.org/$spacename/$reponame.git --all --force
