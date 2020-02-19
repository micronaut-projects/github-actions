# Micronaut release notes action

Updates a draft release with the latest release notes

## Example usage

```yaml
name: Release Notes

on:
  pull_request:
    types: [closed]
    branches:
      - master
  issues:
    types: [closed,reopened]

jobs:
  release_notes:
    runs-on: ubuntu-latest
    steps:
      - uses: micronaut-projects/github-actions/release-notes@master
        id: release_notes
      - uses: ncipollo/release-action@v1
        with:
          allowUpdates: true
          commit: master
          draft: true
          name: Micronaut Project ${{ steps.release_notes.outputs.next_version }}
          tag: v${{ steps.release_notes.outputs.next_version }}
          bodyFile: CHANGELOG.md
          token: ${{ secrets.GITHUB_TOKEN }}
```
