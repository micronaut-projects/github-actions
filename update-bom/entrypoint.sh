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
projectName="${GITHUB_REPOSITORY:19}"
git checkout -b "$projectName-$4"
trimSpace="$(echo -e "$3" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
IFS=$'\n'       
for j in $trimSpace
do
    propertyName=$(echo "$j" | awk -F "=" '{print $1}')
    propertyVersion=$(echo "$j" | awk -F "=" '{print $2}')
    sed -i "s/^$propertyName.*$/$propertyName\=${propertyVersion}/" gradle.properties
done

echo "Changes Applied"
git diff

echo "Creating pull request"
git add gradle.properties
git commit -m "Bump $projectName to $4"
git push origin "$projectName-$4"
curl -s --request POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" https://api.github.com/repos/micronaut-projects/micronaut-core/pulls --data "{\"title\": \"Bump $projectName to $4\", \"head\":\"$projectName-$4\", \"base\":\"$2\"}"
