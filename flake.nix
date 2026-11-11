{
  description = "bidama-shiryou, a blue distribution";

  inputs.blue.url = "github:pleme-io/blue";

  outputs =
    { blue, ... }:
    let
      project = blue.lib.project { src = ./.; };
      danpenDiff =
        system:
        let
          pkgs = blue.inputs.nixpkgs.legacyPackages.${system};
          crate = "crates/danpen-diff";
        in
        pkgs.rustPlatform.buildRustPackage {
          pname = "shiryou-danpen-diff";
          version = "0.1.0";
          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [
              ./crates/danpen-diff
              ./bidamas
            ];
          };
          cargoRoot = crate;
          buildAndTestSubdir = crate;
          cargoLock.lockFile = ./crates/danpen-diff/Cargo.lock;
          preCheck = ''
            export HOME=$TMPDIR
          '';
          checkFlags = [ "--test-threads=1" ];
          postInstall = ''
            mkdir -p $out
            echo "danpen agrees with apollo-compiler" > $out/agreement
          '';
        };
    in
    project
    // {
      checks = builtins.mapAttrs (system: checks: checks // { danpen-diff = danpenDiff system; }) project.checks;
    };
}
