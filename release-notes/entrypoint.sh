#!/bin/bash
# $1 == GH_TOKEN
# $2 == repository (eg: Codertocat/Hello-World)

organisation=`dirname $2`
repository=`basename $2`

echo -n "Current branch: "
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo $current_branch

echo -n "Determining lastest tag: "
latest_tag=`curl -s https://api.github.com/repos/$2/releases | jq -cr ".[] | select (.target_commitish == \"$current_branch\") | .tag_name" | head -1`
echo $latest_tag

echo -n "Determining lastest version: "
latest_version=`echo $latest_tag | sed -e 's/v//g'`
echo $latest_version

echo -n "Default branch: "
default_branch=`curl -s https://api.github.com/repos/$2 | jq -r .default_branch`
echo $default_branch

if [ -z $latest_version ]; then
  if [ "$default_branch" == "$current_branch" ]; then
    next_version="1.0.0"
  else
    next_version=`echo $current_branch | sed -e 's/x/0/g'`
  fi
else
  next_version=`/increment_version.sh -p $latest_version`
fi

echo -n "Determining next version: "
echo $next_version

echo "::set-output name=next_version::$next_version"

echo "Checking if ${next_version} tag exists"
is_version_published=`curl -s https://api.github.com/repos/$2/tags | jq ".[] | select(.name == \"v$next_version\")"`

if [ -z "$is_version_published" ]; then
  echo "Tag doesn't exist, generating changelog"
  github_changelog_generator --user $organisation --project $repository --token $1 \
        --enhancement-labels "type: enhancement" \
        --bug-labels "type: bug" \
        --exclude-labels "status: stale,closed: notabug,closed: duplicate,closed: question,closed: invalid,closed: won't fix" \
        --breaking-labels "type: breaking" \
        --deprecated-labels "type: deprecated" \
        --removed-labels "type: removed" \
        --header-label "" \
        --usernames-as-github-logins \
        --release-branch "$current_branch" \
        --unreleased-only \
        --future-release v$next_version

  if [ -f "CHANGELOG.md" ]; then
    echo "Changelog generated"
    echo "::set-output name=generated_changelog::true"
  else
    echo "Changelog not generated"
    echo "::set-output name=generated_changelog::false"
  fi
else
  echo "Tag ${next_version} already published. Skipping changelog generation"
  echo "::set-output name=generated_changelog::false"
fi

exit 0