# Micronaut export-gradle-properties action

Updates the Micronaut BOM by creating a pull request in micronaut-core's `gradle.properties`.

It requires a GitHub PAT with read/write permissions in micronaut-core.

The target branch will be inferred from the GitHub release data.

## Example usage

```yaml
- name: Export Gradle Properties
  uses: micronaut-projects/github-actions/export-gradle-properties@master
- name: Update BOM
  uses: micronaut-projects/github-actions/update-bom@master
  with:
    token: ${{ secrets.GH_TOKEN }}
    branch: master 
    property: ${{ env.projectVersion }}
    version: ${{ steps.release_version.outputs.release_version }}
```
