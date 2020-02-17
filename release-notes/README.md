# Micronaut release notes action

Updates a draft release with the latest release notes

## Example usage

```yaml
uses: micronaut-projects/github-actions/release-notes@master
with:
  token: ${{ secrets.GITHUB_TOKEN }}
  repository: ${{ github.repository }}
```
