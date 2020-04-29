# Micronaut update BOM action

Updates the Micronaut BOM by creating a pull request in micronaut-core's `gradle.properties`.

It requires a GitHub PAT with read/write permissions in micronaut-core.

The target branch will be inferred from the GitHub release data.

## Example usage

```yaml
- name: Determine the target branch
  id: target_branch
  run: |
    target_branch=`cat $GITHUB_EVENT_PATH | jq '.release.target_commitish' | sed -e 's/^"\(.*\)"$/\1/g'`
    echo ::set-output name=target_branch::${target_branch}      
- name: Checkout micronaut-core
  uses: actions/checkout@v2
  with:
    token: ${{ secrets.GH_TOKEN }}
    repository: micronaut-projects/micronaut-core
    ref: ${{ steps.target_branch.outputs.target_branch }}
    path: micronaut-core      
- name: Update BOM
  uses: micronaut-projects/github-actions/update-bom@master
  with:
    token: ${{ secrets.GH_TOKEN }}
    branch: ${{ steps.target_branch.outputs.target_branch }}
    property: micronautMavenPluginVersion # Refers to the key in gradle.properties
    version: ${{ steps.release_version.outputs.release_version }}
```
