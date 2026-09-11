# Github composite actions for graalvm workflow

Usage example:
```yaml
name: GraalVM Latest CI
on:
  push:
    branches:
      - master
      - '[1-9]+.[0-9]+.x'
  pull_request:
    branches:
      - master
      - '[1-9]+.[0-9]+.x'
jobs:
  build:
    if: github.repository != 'micronaut-projects/micronaut-project-template'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        graalvm: [ 'latest' ]
        java: [ '17' ]
    steps:
      - uses: actions/checkout@v4
      - name: Pre-Build Steps
        uses: micronaut-projects/github-actions/graalvm/pre-build@master
        id: pre-build
        with:
          develocity-access-key: ${{ secrets.GRADLE_ENTERPRISE_ACCESS_KEY }}
          graalvm: ${{ matrix.graalvm }}
          java: ${{ matrix.java }}
      - name: Build Steps
        uses: micronaut-projects/github-actions/graalvm/build@master
        id: build
        env:
          GH_TOKEN_PUBLIC_REPOS_READONLY: ${{ secrets.GH_TOKEN_PUBLIC_REPOS_READONLY }}
          GH_USERNAME: ${{ secrets.GH_USERNAME }}
      - name: Post-Build Steps
        uses: micronaut-projects/github-actions/graalvm/post-build@master
        id: post-build
        with:
          java: ${{ matrix.java }}
```

## Develocity access

Pass the Develocity access key to `build-matrix` and `pre-build` through the `develocity-access-key` input, not as an
environment variable:

```yaml
      - name: Pre-Build Steps
        uses: micronaut-projects/github-actions/graalvm/pre-build@<sha>
        with:
          develocity-access-key: ${{ secrets.GRADLE_ENTERPRISE_ACCESS_KEY }}
          java: ${{ matrix.java }}
```

[setup-gradle](https://github.com/gradle/actions/blob/main/docs/setup-gradle.md#managing-develocity-access-keys)
exchanges the key, in `host=key` form, for a short-lived token and exports it as `DEVELOCITY_ACCESS_KEY` and
`GRADLE_ENTERPRISE_ACCESS_KEY` for the following steps. The exchange needs Develocity 2024.1 or later.

- Do not also set `DEVELOCITY_ACCESS_KEY` or `GRADLE_ENTERPRISE_ACCESS_KEY` on the calling step or on later steps: an
  explicit step environment replaces the exported token with the long-lived key.
- If the exchange fails, setup-gradle exports nothing, so the build has no Develocity credential from this action. If
  the key is passed only as an environment variable instead, setup-gradle leaves that long-lived key in place.
- A short-lived token has the same permissions as the key it came from. Give pull request builds a key whose
  Develocity user cannot write to the build cache.

Both actions set `ORG_GRADLE_PROJECT_cachePush=false` for every event except a push to `master`, `main` or an `x.y.x`
branch. This sets the default for the Micronaut build plugins; it is not a permission check, and a step that sets the
property itself overrides it.
