# Micronaut update BOM action

Updates the Micronaut BOM by creating a pull request in micronaut-core's `gradle.properties`.

It requires a GitHub PAT with read/write permissions in micronaut-core.

## Example usage

```yaml
- name: Checkout micronaut-core
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.GH_TOKEN }}
    repository: micronaut-projects/micronaut-core
    ref: ${{ env.githubCoreBranch }}
    path: micronaut-core # Must be micronaut-core
  continue-on-error: true      
- name: Export Gradle Properties
  uses: micronaut-projects/github-actions/export-gradle-properties@master            
- name: Update BOM
  uses: micronaut-projects/github-actions/update-bom@master
  with:
    token: ${{ secrets.GH_TOKEN }}
  continue-on-error: true
```
