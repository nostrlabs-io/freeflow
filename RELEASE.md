# Zapstore

Install required software:

- `sudo apt install apksigner apktool`
- https://github.com/sibprogrammer/xq
- https://github.com/zapstore/zapstore-cli

Then publish the release

1. `zapstore publish freeflow -v <version>` (<version> without the `v` prefix)
1. Use nsec to sign release events