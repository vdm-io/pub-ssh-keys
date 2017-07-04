[![Circle CI](https://circleci.com/gh/vdm-io/pub-ssh-keys.svg?style=svg)](https://circleci.com/gh/vdm-io/pub-ssh-keys)

pub-ssh-keys
============
This script will populate the `authorized_keys` file on a server with the entries in this repository. To run this script, use the following command (as root):

```
curl -s https://raw.githubusercontent.com/vdm-io/pub-ssh-keys/master/vdmkeys.sh | bash
```

This script performs the following actions:

 * Adds our `vdm` management user.
 * Adds the `authorized_keys` file to that user's home directory.
 * Performs a checksum on this file.
 * Adds a cron entry to update this file on a scheduled basis.
 * Grants sudo permissions to the `vdm` user.

Checksum
========

To regenerate the checksum file before uploading, perform the following command:
```
md5sum authorized_keys > authorized_keys.md5sum
```
##### For Mac:
Install `md5sha1sum` via homebrew before running the `md5sum` command:
```
brew install md5sha1sum
md5sum authorized_keys > authorized_keys.md5sum
```

##### For Windows:
```
git clone git@github.com:<USERNAME>/pub-ssh-keys.git
git config core.autocrlf false
git reset --hard origin/master
md5sum authorized_keys > authorized_keys.md5sum
```
