# Micronaut export-gradle-properties action

Exports `gradle.properties` as environment variables.

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
