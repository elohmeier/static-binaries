# static-binaries

Statically linked (musl) binaries for 32-bit / 64-bit x86 Linux, built using [nixpkgs](https://github.com/NixOS/nixpkgs).

Please see the [releases page](https://github.com/elohmeier/static-binaries/releases) for the downloads & version information.


## List of Tools

- [binutils](https://www.gnu.org/software/binutils/)
- [curl](https://curl.se/)
- [Nmap](https://nmap.org/)
- [nnn](https://github.com/jarun/nnn)
- [Python 2](https://www.python.org/)
- [socat](http://www.dest-unreach.org/socat)
- [tcpdump](https://www.tcpdump.org/)


## Releases

The GitHub Actions workflow updates `flake.lock` weekly. When the lockfile changes, it builds the bundle, commits the updated lockfile, tags the commit as `vYYYY.MM.DD`, and publishes the binaries as release assets.

Pushes to `master` run a build only. Weekly runs that do not change `flake.lock` skip the release.
