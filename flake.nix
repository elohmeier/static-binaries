{
  description = "static-binaries";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      defaultPackage = forAllSystems (system: (with import nixpkgs { inherit system; };  (
        let
          releaseNotes = writeText "release.txt" ''
            - nmap v${nmap.version}
            - python2 v${python2.version}
            - tcpdump v${tcpdump.version}
          '';
        in
        runCommand "static-binaries" { } ''
          mkdir -p $out/bin
          cp ${pkgsCross.musl32.pkgsStatic.nmap}/bin/nmap $out/bin/nmap-x86
          cp ${pkgsCross.musl32.pkgsStatic.python2}/bin/python2.7 $out/bin/python2.7-x86
          cp ${pkgsCross.musl32.pkgsStatic.tcpdump}/bin/tcpdump $out/bin/tcpdump-x86
          cp ${pkgsCross.musl64.pkgsStatic.nmap}/bin/nmap $out/bin/nmap-x64
          cp ${pkgsCross.musl64.pkgsStatic.python2}/bin/python2.7 $out/bin/python2.7-x64
          cp ${pkgsCross.musl64.pkgsStatic.tcpdump}/bin/tcpdump $out/bin/tcpdump-x64

          cp ${releaseNotes} $out/release.txt
        ''
      )
      ));
    };
}
