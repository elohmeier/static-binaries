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
      defaultPackage = forAllSystems (system: (with import nixpkgs
        {
          inherit system;
          config.packageOverrides = (pkgs: {
            # remove when https://github.com/NixOS/nixpkgs/pull/187914 is merged
            nnn = pkgs.nnn.overrideAttrs (old: {
              buildInputs = old.buildInputs ++ [ pkgs.musl-fts ];
              NIX_CFLAGS_COMPILE = "-I${pkgs.musl-fts}/include";
              NIX_LDFLAGS = "-lfts";
            });
          });
        };
        let
          releaseNotes = writeText "release.txt" ''
            - binutils v${binutils.version}
            - curl v${curl.version}
            - git v${gitMinimal.version}
            - nmap v${nmap.version}
            - nnn v${nnn.version}
            - python2 v${python2.version}
            - socat v${socat.version}
            - tcpdump v${tcpdump.version}
          '';
        in
        runCommand "static-binaries" { } ''
          mkdir -p $out/bin

          cp ${pkgsCross.musl32.pkgsStatic.binutils}/bin/objdump $out/bin/objdump-x86
          cp ${pkgsCross.musl32.pkgsStatic.binutils}/bin/strings $out/bin/string-x86
          cp ${pkgsCross.musl32.pkgsStatic.curl}/bin/curl $out/bin/curl-x86
          cp ${pkgsCross.musl32.pkgsStatic.gitMinimal}/bin/git $out/bin/git-x86
          cp ${pkgsCross.musl32.pkgsStatic.nmap}/bin/nmap $out/bin/nmap-x86
          cp ${pkgsCross.musl32.pkgsStatic.nnn}/bin/nnn $out/bin/nnn-x86
          cp ${pkgsCross.musl32.pkgsStatic.python2}/bin/python2.7 $out/bin/python2.7-x86
          cp ${pkgsCross.musl32.pkgsStatic.socat}/bin/socat $out/bin/socat-x86
          cp ${pkgsCross.musl32.pkgsStatic.tcpdump}/bin/tcpdump $out/bin/tcpdump-x86
          cp ${pkgsCross.musl64.pkgsStatic.binutils}/bin/objdump $out/bin/objdump-x64
          cp ${pkgsCross.musl64.pkgsStatic.binutils}/bin/strings $out/bin/string-x64
          cp ${pkgsCross.musl64.pkgsStatic.curl}/bin/curl $out/bin/curl-x64
          cp ${pkgsCross.musl64.pkgsStatic.gitMinimal}/bin/git $out/bin/git-x64
          cp ${pkgsCross.musl64.pkgsStatic.nmap}/bin/nmap $out/bin/nmap-x64
          cp ${pkgsCross.musl64.pkgsStatic.nnn}/bin/nnn $out/bin/nnn-x64
          cp ${pkgsCross.musl64.pkgsStatic.python2}/bin/python2.7 $out/bin/python2.7-x64
          cp ${pkgsCross.musl64.pkgsStatic.socat}/bin/socat $out/bin/socat-x64
          cp ${pkgsCross.musl64.pkgsStatic.tcpdump}/bin/tcpdump $out/bin/tcpdump-x64

          cp ${releaseNotes} $out/release.txt
        ''
      ));
    };
}
