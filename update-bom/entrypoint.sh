#!/bin/bash
# $1 == GH_TOKEN
# $2 == branch
# $3 == properties
# $4 == version

set -e

echo "Configuring git"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git config --global user.name "${GITHUB_ACTOR}"
cd micronaut-core
# git checkout -b "$3-${GITHUB_REPOSTIROY:19}"

trimSpace="$(echo -e "$3" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
IFS=$'\n'       
for j in $trimSpace
do
    echo "$j"
done

# echo "Setting release version in gradle.properties"
# sed -i "s/^$3.*$/$3\=${4}/" gradle.properties
# cat gradle.properties

# echo "Creating pull request"
# git add gradle.properties
# git commit -m "Bump $3 to $4"
# git push origin "$3-$4"
# curl -s --request POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" https://api.github.com/repos/micronaut-projects/micronaut-core/pulls --data "{\"title\": \"Bump $3 to $4\", \"head\":\"$3-$4\", \"base\":\"$2\"}"
