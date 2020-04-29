# Micronaut update BOM action

Updates the Micronaut BOM by creating a pull request in micronaut-core's `gradle.properties`.

## Example usage

```yaml
uses: micronaut-projects/github-actions/update-bom@master
with:
  branch: master # Or 1.3.x etc. "master" is the default and therefore it could be omitted
  property: micronautMavenPluginVersion # Refers to the key in gradle.properties
  version: ${{ steps.release_version.outputs.release_version }}
```
