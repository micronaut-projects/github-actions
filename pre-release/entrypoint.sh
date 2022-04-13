#!/bin/bash
# $1 == GH_TOKEN

echo -n "Determining release version: "
release_version=${GITHUB_REF:11}
echo $release_version

if [ -n "$MICRONAUT_BUILD_EMAIL" ]; then
    GIT_USER_EMAIL=$MICRONAUT_BUILD_EMAIL
fi

if [ -z "$GIT_USER_NAME" ]; then
   GIT_USER_NAME="micronaut-build"
fi

echo "Configuring git"
git config --global --add safe.directory /github/workspace
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
git fetch

echo -n "Determining target branch: "
target_branch=`cat $GITHUB_EVENT_PATH | jq '.release.target_commitish' | sed -e 's/^"\(.*\)"$/\1/g'`
echo $target_branch
git checkout $target_branch

echo "Setting release version in gradle.properties"
sed -i "s/^projectVersion.*$/projectVersion\=${release_version}/" gradle.properties
cat gradle.properties

echo "Pushing release version and recreating v${release_version} tag"
git add gradle.properties
git commit -m "[skip ci] Release v${release_version}"
git push origin $target_branch
git push origin :refs/tags/v${release_version}
git tag -fa v${release_version} -m "Release v${release_version}"
git push origin $target_branch --tags

echo "Closing again the release after updating the tag"
release_url=`cat $GITHUB_EVENT_PATH | jq '.release.url' | sed -e 's/^"\(.*\)"$/\1/g'`
echo $release_url
curl -s --request PATCH -H "Authorization: Bearer $1" -H "Content-Type: application/json" $release_url --data "{\"draft\": false}"
