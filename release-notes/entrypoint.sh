#!/bin/bash
# $1 == GH_TOKEN
# $2 == repository (eg: Codertocat/Hello-World)

organisation=`dirname $2`
repository=`basename $2`

github_changelog_generator --user $organisation --project $repository --token $1  --enhancement-labels "type: enhancement" --bug-labels "type: bug" --exclude-labels "status: stale,closed: notabug,closed: duplicate,closed: question,closed: invalid,closed: won't fix" --breaking-labels "type: breaking" --deprecated-labels "type: deprecated" --removed-labels "type: removed" --usernames-as-github-logins --unreleased-only
#--release-branch "1.3.x" --since-tag "v1.3.9"