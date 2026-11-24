# Micronaut pre-release action

Performs some actions before doing a release

## Example usage

```yaml
uses: alvarosanchez/github-actions/pre-release@master
with:
  token: ${{ secrets.GITHUB_TOKEN }}
```

## Environment variables

By default the release version is derived from the release tag (`GITHUB_REF`) and the target branch from the
`target_commitish` of the release in the event payload. When the workflow is not triggered by a `release` event
(for example `workflow_dispatch`), they can be provided with the following environment variables:

* `RELEASE_VERSION`: the version to release (e.g. `1.2.3`).
* `TARGET_BRANCH`: the branch to push the release commit to (e.g. `1.2.x`).

The release is only switched back from draft when the event payload contains a release.

```yaml
uses: micronaut-projects/github-actions/pre-release@master
env:
  RELEASE_VERSION: ${{ inputs.release_version }}
  TARGET_BRANCH: ${{ inputs.target_branch }}
with:
  token: ${{ secrets.GITHUB_TOKEN }}
```
