#!/bin/bash
# $1 == GH_TOKEN
# $2 == branch
# $3 == properties
# $4 == property
# $5 == version

set -e

echo "Configuring git"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git config --global user.name "${GITHUB_ACTOR}"
cd micronaut-core
projectName="${GITHUB_REPOSITORY:19}"
git checkout -b "$projectName-$5"

if [ ! -z $3 ]; then
    trimSpace="$(echo -e "$3" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    IFS=$'\n'       
    for j in $trimSpace
    do
        propertyName=$(echo "$j" | awk -F "=" '{print $1}')
        propertyVersion=$(echo "$j" | awk -F "=" '{print $2}')
        sed -i "s/^$propertyName.*$/$propertyName\=${propertyVersion}/" gradle.properties
    done
else
    sed -i "s/^$4.*$/$4\=${5}/" gradle.properties
fi

echo "Changes Applied"
git diff

echo "Creating pull request"
git add gradle.properties
git commit -m "Bump $projectName to $5"
git push origin "$projectName-$5"
curl -s --request POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" https://api.github.com/repos/micronaut-projects/micronaut-core/pulls --data "{\"title\": \"Bump $projectName to $5\", \"head\":\"$projectName-$5\", \"base\":\"$2\"}"
