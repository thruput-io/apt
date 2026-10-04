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

It runs when a source tells it there is a release: the source's pipeline
sends a `release` repository dispatch once its integration tests have passed
on `main`. It also runs once after `key`. It does not run on a schedule or by
hand.

Nothing here holds a credential to another repository: releases are public, and
the only secret is the signing key. A source needs one to send the dispatch:
a token from the org's distribution app, with Contents write on this
repository.

## Adding a repository

Add `owner/repo` to `sources.txt`. Its releases must carry `.deb` assets, and
its pipeline must send the `release` dispatch after releasing.

## Setup

1. Settings → Pages → Source: **GitHub Actions**.
2. Nothing else. `key` runs once, on the merge that adds it to `main`: it
   generates `ARCHIVE_SIGNING_KEY` and stores it as a repository secret through
   the Hemming app, and `publish` follows it. To rotate the key, change
   `key.yml`.
