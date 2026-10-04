# apt

The signed apt archive for thruput-io packages, served from GitHub Pages.

```sh
curl -fsSL https://thruput.se/apt/thruput-io.sources \
  | sudo tee /etc/apt/sources.list.d/thruput-io.sources > /dev/null
sudo apt-get update
```

## How a package gets here

Every repository named in `sources.txt` attaches its `.deb` files to a GitHub
Release. `publish` takes the latest release of each, builds one archive with
`reprepro` (suite `stable`, component `main`), signs it, deploys it to Pages and
then installs every package in it on a clean `debian:testing-slim`.

It runs every hour, after `key` (so after every push to `main`), and by hand
from the Actions tab. A
scheduled run whose releases are already served does nothing.

Nothing here holds a credential to another repository: releases are public, and
the only secret is the signing key.

## Adding a repository

Add `owner/repo` to `sources.txt`. Its releases must carry `.deb` assets.

## Setup

1. Settings → Pages → Source: **GitHub Actions**.
2. Nothing else. `key` runs on every merge to `main` and generates
   `ARCHIVE_SIGNING_KEY` the first time only, storing it as a repository secret
   through the Hemming app. Once the secret exists it never replaces it. To
   rotate the key, delete the secret and run `key` again.
