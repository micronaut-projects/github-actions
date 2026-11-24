#!/bin/bash
# $1 == GH_TOKEN

echo -n "Determining release version: "
if [ -z "$RELEASE_VERSION" ]; then
  release_version=${GITHUB_REF:11}
else
  release_version=${RELEASE_VERSION}
fi
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
if [ -z "$TARGET_BRANCH" ]; then
  target_branch=`cat $GITHUB_EVENT_PATH | jq '.release.target_commitish' | sed -e 's/^"\(.*\)"$/\1/g'`
else
  target_branch=${TARGET_BRANCH}
fi
echo $target_branch
git checkout $target_branch

echo "Setting release version in gradle.properties"
sed -i "s/^projectVersion.*$/projectVersion\=${release_version}/" gradle.properties
cat gradle.properties

echo "Pushing release version and recreating v${release_version} tag"
git add gradle.properties
git commit -m "[skip ci] Release v${release_version}"
git push origin $target_branch
git tag -fa v${release_version} -m "Release v${release_version}"
git push origin $target_branch
# force push the updated tag
git push origin v${release_version} --force

release_url=`cat $GITHUB_EVENT_PATH | jq '.release.url' | sed -e 's/^"\(.*\)"$/\1/g'`
# There is no release to close when not triggered by a release event (e.g. workflow_dispatch)
if [ "$GITHUB_EVENT_NAME" == "release" ] || { [ -n "$release_url" ] && [ "$release_url" != "null" ]; }; then
  echo "Closing again the release after updating the tag"
  echo $release_url
  curl -s --request PATCH -H "Authorization: Bearer $1" -H "Content-Type: application/json" $release_url --data "{\"draft\": false}"
else
  echo "No release found in the event payload, skipping closing the release"
fi
