#!/usr/bin/env bash
set -euo pipefail

packages=${1:?archive.sh: name the directory holding the .deb files}
root=${2:?archive.sh: name the directory to build the archive in}
url=${3:?archive.sh: name the URL the archive is served from}
key=${4:?archive.sh: name the file holding the key the archive signs with}

suite=stable
component=main

home=$(mktemp -d)
conf=$(mktemp -d)
db=$(mktemp -d)
trap 'rm -rf "$home" "$conf" "$db"' EXIT
chmod 700 "$home"

gpg --homedir "$home" --batch --quiet --import "$key"
fingerprint=$(gpg --homedir "$home" --list-secret-keys --with-colons | awk -F: '/^fpr/ { print $10; exit }')

mkdir -p "$root"
root=$(CDPATH='' cd "$root" && pwd)

architectures=$(
  for deb in "$packages"/*.deb; do dpkg-deb --field "$deb" Architecture; done \
    | grep -vx all | sort -u | tr '\n' ' '
)
: "${architectures:?archive.sh: no .deb in $packages names an architecture}"

cat > "$conf/distributions" <<DISTRIBUTION
Origin: thruput-io
Label: thruput-io
Codename: $suite
Suite: $suite
Architectures: $architectures
Components: $component
Description: packages built by thruput-io
SignWith: $fingerprint
DISTRIBUTION

GNUPGHOME=$home reprepro --basedir "$root" --confdir "$conf" --dbdir "$db" --outdir "$root" \
  --priority optional includedeb "$suite" "$packages"/*.deb

gpg --homedir "$home" --batch --quiet --armor --export > "$root/thruput-io-archive-keyring.asc"

{
  echo 'Types: deb'
  echo "URIs: $url"
  echo "Suites: $suite"
  echo "Components: $component"
  echo 'Signed-By:'
  sed -e 's/^$/./' -e 's/^/ /' "$root/thruput-io-archive-keyring.asc"
} > "$root/thruput-io.sources"

: > "$root/.nojekyll"

echo "$(find "$root/pool" -name '*.deb' | wc -l | tr -d ' ') packages for $architectures in $suite, signed by $fingerprint"
