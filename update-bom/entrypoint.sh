#!/bin/bash
# $1 == GH_TOKEN
# $2 == branch
# $3 == property
# $4 == version

echo "Configuring git"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git config --global user.name "${GITHUB_ACTOR}"
git clone --depth 1 git@github.com:micronaut-projects/micronaut-core.git --branch $2
cd micronaut-core
git checkout -b "$3-$4"

echo "Setting release version in gradle.properties"
sed -i "s/^$3.*$/$3\=${4}/" gradle.properties
cat gradle.properties

echo "Creating pull request"
git add gradle.properties
git commit -m "Bump $3 to $4"
git push origin "$3-$4"
curl -s --request POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" https://api.github.com/repos/micronaut-projects/micronaut-core/pulls --data "{\"title\": \"Bump $3 to $4\", \"head\":\"$3-$4\", \"base\":\"$2\", \"draft\": true}"
