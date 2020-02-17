#!/bin/bash
# $1 == GH_TOKEN
# $2 == repository (eg: Codertocat/Hello-World)
# $3 == target branch (eg: master)

organisation=`dirname $2`
repository=`basename $2`

echo -n "Determining lastest tag: "
latest_tag=`curl -s "https://api.github.com/repos/$2/releases/latest" | jq '.tag_name' | sed -e 's/"//g'`
echo $latest_tag

echo -n "Determining lastest version: "
latest_version=`echo $latest_tag | sed -e 's/v//g'`
echo $latest_version

echo -n "Determining next version: "
next_version=`/increment_version.sh -p $latest_version`
echo $next_version

github_changelog_generator --user $organisation --project $repository --token $1 \
        --enhancement-labels "type: enhancement" \
        --bug-labels "type: bug" \
        --exclude-labels "status: stale,closed: notabug,closed: duplicate,closed: question,closed: invalid,closed: won't fix" \
        --breaking-labels "type: breaking" \
        --deprecated-labels "type: deprecated" \
        --removed-labels "type: removed" \
        --usernames-as-github-logins \
        --release-branch "$3" \
        --since-tag $latest_tag