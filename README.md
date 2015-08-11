[![Circle CI](https://circleci.com/gh/rax-brazil/pub-ssh-keys.svg?style=svg)](https://circleci.com/gh/rax-brazil/pub-ssh-keys)

pub-ssh-keys
============
This script will populate the `authorized_keys` file on a server with the entries in this repository. To run this script, use the following command (as root):

```
curl -s https://raw.githubusercontent.com/rax-brazil/pub-ssh-keys/master/rackerkeys.sh | bash
```

This script performs the following actions:

 * Adds our `rack` management user.
 * Adds the `authorized_keys` file to that user's home directory.
 * Performs a checksum on this file.
 * Adds a cron entry to update this file on a scheduled basis.
 * Grants sudo permissions to the `rack` user.

Checksum
========

To regenerate the checksum file before uploading, perform the following command:
```
md5sum authorized_keys > authorized_keys.md5sum
```
