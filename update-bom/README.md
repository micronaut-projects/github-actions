# Micronaut update BOM action

Updates the Micronaut BOM by creating a pull request in micronaut-core's `gradle.properties`.

It requires a GitHub PAT with read/write permissions in micronaut-core.

The target branch will be inferred from the GitHub release data.

## Example usage

```yaml
- name: Checkout micronaut-core
  uses: actions/checkout@v2
  with:
    token: ${{ secrets.GH_TOKEN }}
    repository: micronaut-projects/micronaut-core
    ref: master # Or 1.3.x etc
    path: micronaut-core  # Must be micronaut-core
- name: Update BOM
  uses: micronaut-projects/github-actions/update-bom@master
  with:
    token: ${{ secrets.GH_TOKEN }}
    branch: master # Or 1.3.x etc
    properties: | 
      micronautMavenPluginVersion=${{ steps.release_version.outputs.release_version }}
```
