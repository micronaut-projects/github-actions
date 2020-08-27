#!/bin/bash
# $1 == GH_TOKEN
# $2 == repository (eg: Codertocat/Hello-World)
# $3 == target branch (eg: master)

echo "target branch: $3"
organisation=`dirname $2`
repository=`basename $2`

echo -n "Determining lastest tag: "
latest_tag=`curl -s https://api.github.com/repos/$2/releases | jq -cr ".[] | select (.target_commitish == \"$3\") | .tag_name" | head -1`

echo $latest_tag

echo -n "Determining lastest version: "
latest_version=`echo $latest_tag | sed -e 's/v//g'`
echo $latest_version

if [ -z $latest_version ]
then
  if [ "$3" == "master" ]
  then
    next_version="1.0.0"
  else
    next_version=`echo $3 | sed -e 's/x/0/g'`
  fi
else
  next_version=`/increment_version.sh -p $latest_version`
fi

echo -n "Determining next version: "
echo $next_version

echo "::set-output name=next_version::$next_version"

echo -n "Checking if ${next_version} tag exists"
is_version_published=`curl -s https://api.github.com/repos/$2/tags | jq ".[] | select(.name == \"v$next_version\")"`

if [ -z "$is_version_published" ]; then
  echo -n "Tag doesn't exist, generating changelog"
  github_changelog_generator --user $organisation --project $repository --token $1 \
        --enhancement-labels "type: enhancement" \
        --bug-labels "type: bug" \
        --exclude-labels "status: stale,closed: notabug,closed: duplicate,closed: question,closed: invalid,closed: won't fix" \
        --breaking-labels "type: breaking" \
        --deprecated-labels "type: deprecated" \
        --removed-labels "type: removed" \
        --header-label "" \
        --usernames-as-github-logins \
        --release-branch "$3" \
        --unreleased-only \
        --future-release v$next_version

  if [ -f "CHANGELOG.md" ]; then
    echo -n "Changelog generated"
    echo "::set-output name=generated_changelog::true"
  else
    echo -n "Changelog not generated"
    echo "::set-output name=generated_changelog::false"
  fi
else
  echo -n "Tag ${next_version} already published. Skipping changelog generation"
  echo "::set-output name=generated_changelog::false"
fi

exit 0