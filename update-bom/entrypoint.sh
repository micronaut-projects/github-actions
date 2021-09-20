#!/bin/bash
# $1 == GH_TOKEN

set -e

CATALOG_FILE=gradle/libs.versions.toml

if [ -n "$MICRONAUT_BUILD_EMAIL" ]; then
    GIT_USER_EMAIL=$MICRONAUT_BUILD_EMAIL
fi

if [ -z "$GIT_USER_EMAIL" ]; then
   GIT_USER_EMAIL="${GITHUB_ACTOR}@users.noreply.github.com"
fi

if [ -z "$GIT_USER_NAME" ]; then
   GIT_USER_NAME="micronaut-build"
fi

echo "Configuring git"
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
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

IFS=''

if [ -f $CATALOG_FILE ]; then
    echo "Updating version catalog..."
    if [ ! -z $bomProperty ];
    then
        if [[ -z "$catalogProperty" ]];
        then
          catalogProperty=$(echo $bomProperty | sed -r -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | sed -r -E 's/-version$//g' )
        fi
        echo "name: $catalogProperty"
        echo "value: ${!bomProperty}"
        sed -i -E "s/^(managed-)?$catalogProperty\s*=\s*\".*$/\1$catalogProperty = \"${projectVersion}\"/" $CATALOG_FILE
    fi

    if [ ! -z $bomProperties ];
    then
        IFS=','
        for property in $bomProperties
        do
            catalogProperty=$(echo $property | sed -r -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | sed -r -E 's/-version$//g')
            echo "name: $catalogProperty"
            echo "value: ${!property}"
            sed -i -E "s/^(managed-)?$catalogProperty\s*=\s*\".*$/\1$catalogProperty = \"${!property}\"/" $CATALOG_FILE
        done
    fi
fi

echo "Changes Applied"
git diff

if [ -z $DRY_RUN ]
then
    echo "Creating pull request"
    git add gradle.properties
    if [ -f $CATALOG_FILE ]; then
        git add $CATALOG_FILE
    fi
    git commit -m "Bump $projectName to $projectVersion"
    git push origin "$projectName-$projectVersion"
    pr_url=`curl -s --request POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" https://api.github.com/repos/micronaut-projects/micronaut-core/pulls --data "{\"title\": \"Bump $projectName to $projectVersion\", \"head\":\"$projectName-$projectVersion\", \"base\":\"$githubCoreBranch\"}" | jq '.issue_url' | sed -e 's/^"\(.*\)"$/\1/g'`
    echo "Pull request URL: $pr_url"
    curl -i --request PATCH -H "Authorization: Bearer $1" -H "Content-Type: application/json" $pr_url --data "{\"labels\": [\"type: dependency-upgrade\"]}"
fi
