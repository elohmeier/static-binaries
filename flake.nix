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
            python2 =
              if pkgs.stdenv.hostPlatform.isStatic && pkgs.lib.versionAtLeast pkgs.lib.version "23.05" then
                pkgs.python2.overrideAttrs (old:
                  let
                    oldEnv = old.env or { };
                  in
                  {
                    env = oldEnv // {
                      NIX_CFLAGS_COMPILE = (oldEnv.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
                    };
                  })
              else
                pkgs.python2;

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

            rsync =
              if pkgs.stdenv.hostPlatform.isStatic then
                pkgs.rsync.overrideAttrs (_: {
                  doCheck = false;
                })
              else
                pkgs.rsync;
          });
        };
        let
          tools = pkgs: [
            {
              label = "binutils";
              package = pkgs.binutils;
              bins = [
                { name = "objdump"; path = "${pkgs.binutils}/bin/objdump"; }
                { name = "strings"; path = "${pkgs.binutils}/bin/strings"; }
              ];
            }
            {
              label = "busybox";
              package = pkgs.busybox;
              bins = [
                { name = "busybox"; path = "${pkgs.busybox}/bin/busybox"; }
              ];
            }
            {
              label = "curl";
              package = pkgs.curl;
              bins = [
                { name = "curl"; path = "${pkgs.curl}/bin/curl"; }
              ];
            }
            {
              label = "drill";
              package = pkgs.ldns;
              bins = [
                { name = "drill"; path = "${pkgs.ldns}/bin/drill"; }
              ];
            }
            {
              label = "file";
              package = pkgs.file;
              bins = [
                { name = "file"; path = "${pkgs.file}/bin/file"; }
              ];
            }
            {
              label = "gzip";
              package = pkgs.gzip;
              bins = [
                { name = "gzip"; path = "${pkgs.gzip}/bin/gzip"; }
              ];
            }
            {
              label = "iperf3";
              package = pkgs.iperf3;
              bins = [
                { name = "iperf3"; path = "${pkgs.iperf3}/bin/iperf3"; }
              ];
            }
            {
              label = "jq";
              package = pkgs.jq;
              bins = [
                { name = "jq"; path = "${pkgs.jq}/bin/jq"; }
              ];
            }
            {
              label = "libarchive";
              package = pkgs.libarchive;
              bins = [
                { name = "bsdtar"; path = "${pkgs.libarchive}/bin/bsdtar"; }
              ];
            }
            {
              label = "nmap";
              package = pkgs.nmap;
              bins = [
                { name = "nmap"; path = "${pkgs.nmap}/bin/nmap"; }
              ];
            }
            {
              label = "nnn";
              package = pkgs.nnn;
              bins = [
                { name = "nnn"; path = "${pkgs.nnn}/bin/.nnn-wrapped"; }
              ];
            }
            {
              label = "python2";
              package = pkgs.python2;
              bins = [
                { name = "python2.7"; path = "${pkgs.python2}/bin/python2.7"; }
              ];
            }
            {
              label = "rclone";
              package = pkgs.rclone;
              bins = [
                { name = "rclone"; path = "${pkgs.rclone}/bin/rclone"; }
              ];
            }
            {
              label = "ripgrep";
              package = pkgs.ripgrep;
              bins = [
                { name = "rg"; path = "${pkgs.ripgrep}/bin/rg"; }
              ];
            }
            {
              label = "rsync";
              package = pkgs.rsync;
              bins = [
                { name = "rsync"; path = "${pkgs.rsync}/bin/rsync"; }
              ];
            }
            {
              label = "socat";
              package = pkgs.socat;
              bins = [
                { name = "socat"; path = "${pkgs.socat}/bin/socat"; }
              ];
            }
            {
              label = "sqlite";
              package = pkgs.sqlite;
              bins = [
                { name = "sqlite3"; path = "${pkgs.sqlite}/bin/sqlite3"; }
              ];
            }
            {
              label = "strace";
              package = pkgs.strace;
              bins = [
                { name = "strace"; path = "${pkgs.strace}/bin/strace"; }
              ];
            }
            {
              label = "tcpdump";
              package = pkgs.tcpdump;
              bins = [
                { name = "tcpdump"; path = "${pkgs.tcpdump}/bin/tcpdump"; }
              ];
            }
            {
              label = "xz";
              package = pkgs.xz;
              bins = [
                { name = "xz"; path = "${pkgs.xz}/bin/xz"; }
              ];
            }
            {
              label = "zstd";
              package = pkgs.zstd;
              bins = [
                { name = "zstd"; path = "${pkgs.zstd}/bin/zstd"; }
              ];
            }
          ];
          releaseNotes = writeText "release.txt" (
            lib.concatMapStringsSep "\n" (tool: "- ${tool.label} v${tool.package.version}") (tools pkgsStatic) + "\n"
          );
          copyTools = target: pkgs:
            lib.concatMapStringsSep "\n"
              (tool:
                lib.concatMapStringsSep "\n"
                  (bin: "cp ${bin.path} $out/bin/${bin.name}-${tool.package.version}-${target}")
                  tool.bins)
              (tools pkgs);
        in
        runCommand "static-binaries" { } ''
          mkdir -p $out/bin

          ${copyTools "i686-unknown-linux-musl" pkgsCross.musl32.pkgsStatic}
          ${copyTools "x86_64-unknown-linux-musl" pkgsCross.musl64.pkgsStatic}
          ${copyTools "aarch64-unknown-linux-musl" pkgsCross.aarch64-multiplatform-musl.pkgsStatic}

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
