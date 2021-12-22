## What

A [setup-signore](https://github.com/hashicorp/setup-signore) alternative for Linux GitHub Runners.
Extracts a binary from the Signore Docker image on GitHub Packages to the local disk.

## Why

- the setup-signore GitHub Action requires users to supply a GitHub personal access token
- this version automatically uses the `GITHUB_TOKEN` vended to a running Action to authenticate to the GitHub container registry (ghcr.io)

## Limitations

- Linux only, because macOS workers do not have Docker installed, and Windows workers have other unexplored issues
  - Incidentally, look how [fun](https://github.com/moby/moby/blob/master/contrib/download-frozen-image-v2.sh) it is to "pull" a Docker image without Docker

## How

Add a step to your workflow like so:

```
    steps:
      - name: install signore
        uses: hashicorp/setup-signore-package@v1
```

With no inputs, the `GITHUB_TOKEN` is passed automatically, and a default version of `signore` is used.

Optionally, `token`, `version`, and `signer` can be set:

```
    steps:
      - uses: hashicorp/setup-signore-package@v1
        with:
          version: v0
          signer: test_signer
          token: ${{ secrets.GITHUB_TOKEN }}
```
