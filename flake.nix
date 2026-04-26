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
      packageFor = system: (with import nixpkgs
        {
          inherit system;
          config.permittedInsecurePackages = [
            "python-2.7.18.12"
          ];
          config.packageOverrides = (pkgs: {
            liblinear =
              if pkgs.stdenv.hostPlatform.isStatic then
                pkgs.liblinear.overrideAttrs (old: {
                  postPatch = (old.postPatch or "") + ''
                    cat >> Makefile <<'EOF'

                    liblinear.a: linear.o newton.o blas/blas.a
                    	$(AR) rcs liblinear.a linear.o newton.o blas/blas.a
                    EOF
                  '';
                  buildFlags = [
                    "liblinear.a"
                    "predict"
                    "train"
                  ];
                  installPhase = ''
                    runHook preInstall

                    install -Dt $out/lib liblinear.a
                    install -D train $bin/bin/liblinear-train
                    install -D predict $bin/bin/liblinear-predict
                    install -Dm444 -t $dev/include linear.h

                    runHook postInstall
                  '';
                })
              else
                pkgs.liblinear;

            nnn = pkgs.nnn.overrideAttrs (old:
              {
                buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.musl-fts ];
              } // (if pkgs.lib.versionAtLeast pkgs.lib.version "23.05" then {
                env = (old.env or { }) // {
                  NIX_CFLAGS_COMPILE = "-I${pkgs.musl-fts}/include";
                  NIX_LDFLAGS = "-lfts";
                };
              } else {
                NIX_CFLAGS_COMPILE = "-I${pkgs.musl-fts}/include";
                NIX_LDFLAGS = "-lfts";
              }));
          });
        };
        let
          releaseNotes = writeText "release.txt" ''
            - binutils v${binutils.version}
            - curl v${curl.version}
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
          cp ${pkgsCross.musl32.pkgsStatic.binutils}/bin/strings $out/bin/strings-x86
          cp ${pkgsCross.musl32.pkgsStatic.curl}/bin/curl $out/bin/curl-x86
          cp ${pkgsCross.musl32.pkgsStatic.nmap}/bin/nmap $out/bin/nmap-x86
          cp ${pkgsCross.musl32.pkgsStatic.nnn}/bin/.nnn-wrapped $out/bin/nnn-x86
          cp ${pkgsCross.musl32.pkgsStatic.python2}/bin/python2.7 $out/bin/python2.7-x86
          cp ${pkgsCross.musl32.pkgsStatic.socat}/bin/socat $out/bin/socat-x86
          cp ${pkgsCross.musl32.pkgsStatic.tcpdump}/bin/tcpdump $out/bin/tcpdump-x86
          cp ${pkgsCross.musl64.pkgsStatic.binutils}/bin/objdump $out/bin/objdump-x64
          cp ${pkgsCross.musl64.pkgsStatic.binutils}/bin/strings $out/bin/strings-x64
          cp ${pkgsCross.musl64.pkgsStatic.curl}/bin/curl $out/bin/curl-x64
          cp ${pkgsCross.musl64.pkgsStatic.nmap}/bin/nmap $out/bin/nmap-x64
          cp ${pkgsCross.musl64.pkgsStatic.nnn}/bin/.nnn-wrapped $out/bin/nnn-x64
          cp ${pkgsCross.musl64.pkgsStatic.python2}/bin/python2.7 $out/bin/python2.7-x64
          cp ${pkgsCross.musl64.pkgsStatic.socat}/bin/socat $out/bin/socat-x64
          cp ${pkgsCross.musl64.pkgsStatic.tcpdump}/bin/tcpdump $out/bin/tcpdump-x64

          cp ${releaseNotes} $out/release.txt
        ''
      );
    in
    {
      packages = forAllSystems (system: {
        default = packageFor system;
      });

      defaultPackage = forAllSystems packageFor;
    };
}
