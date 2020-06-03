#!/bin/bash
# $1 == GH_TOKEN

set -e

echo "Configuring git"
git config --global user.email "micronaut-build@users.noreply.github.com"
git config --global user.name "micronaut-build"
cd micronaut-core
projectName="${GITHUB_REPOSITORY:19}"
git checkout -b "$projectName-$projectVersion"

if [ ! -z $bomProperty ]; 
then
    echo "name: $bomProperty"
    echo "value: ${!bomProperty}"
    sed -i "s/^$bomProperty.*$/$bomProperty\=${projectVersion}/" gradle.properties
fi

if [ ! -z $bomProperties ]; 
then
    IFS=','
    for property in $bomProperties
    do
        echo "name: $property"
        echo "value: ${!property}"
        sed -i "s/^$property.*$/$property\=${!property}/" gradle.properties
    done
fi

echo "Changes Applied"
git diff

if [ -z $DRY_RUN ]
then
    echo "Creating pull request"
    git add gradle.properties
    git commit -m "Bump $projectName to $projectVersion"
    git push origin "$projectName-$projectVersion"
    pr_url=`curl -s --request POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" https://api.github.com/repos/micronaut-projects/micronaut-core/pulls --data "{\"title\": \"Bump $projectName to $projectVersion\", \"head\":\"$projectName-$projectVersion\", \"base\":\"$githubCoreBranch\"}" | jq '.issue_url' | sed -e 's/^"\(.*\)"$/\1/g'`
    echo "Pull request URL: $pr_url"
    curl -i --request PATCH -H "Authorization: Bearer $1" -H "Content-Type: application/json" $pr_url --data "{\"labels\": [\"type: dependency-upgrade\"]}"
fi