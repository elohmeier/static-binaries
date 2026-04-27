# static-binaries

Statically linked (musl) binaries for Linux, built using [nixpkgs](https://github.com/NixOS/nixpkgs).

Please see the [releases page](https://github.com/elohmeier/static-binaries/releases) for the downloads & version information.


## List of Tools

- [binutils](https://www.gnu.org/software/binutils/)
- [BusyBox](https://busybox.net/)
- [curl](https://curl.se/)
- [drill](https://www.nlnetlabs.nl/projects/ldns/about/)
- [file](https://www.darwinsys.com/file/)
- [gzip](https://www.gnu.org/software/gzip/)
- [iperf3](https://software.es.net/iperf/)
- [jq](https://jqlang.github.io/jq/)
- [libarchive / bsdtar](https://www.libarchive.org/)
- [Nmap](https://nmap.org/)
- [nnn](https://github.com/jarun/nnn)
- [Python 2](https://www.python.org/)
- [rclone](https://rclone.org/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [rsync](https://rsync.samba.org/)
- [socat](http://www.dest-unreach.org/socat)
- [SQLite](https://www.sqlite.org/)
- [strace](https://strace.io/)
- [tcpdump](https://www.tcpdump.org/)
- [xz](https://tukaani.org/xz/)
- [zstd](https://facebook.github.io/zstd/)


## Release Asset Names

Release assets use the format `<tool>-<version>-<target>`, where `<target>` is one of:

- `i686-unknown-linux-musl`
- `x86_64-unknown-linux-musl`
- `aarch64-unknown-linux-musl`


## Releases

The GitHub Actions workflow updates `flake.lock` weekly. When the lockfile changes, it builds the bundle, commits the updated lockfile, tags the commit as `vYYYY.MM.DD`, and publishes the binaries as release assets.

Pushes to `master` run a build only. Weekly runs that do not change `flake.lock` skip the release.
