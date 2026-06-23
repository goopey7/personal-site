{
  description = "Personal blog made with typst";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    site-generator-src = {
      url = "github:wade-cheng/compile-typst-site";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      site-generator-src,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};

          manifest = (pkgs.lib.importTOML "${site-generator-src}/Cargo.toml").package;
          site-generator = pkgs.rustPlatform.buildRustPackage {
            pname = manifest.name;
            version = manifest.version;

            src = "${site-generator-src}";
            cargoLock = {
              lockFile = "${site-generator-src}/Cargo.lock";
            };

            doCheck = false;

            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin (
              with pkgs.darwin.apple_sdk.frameworks;
              [
                Security
                SystemConfiguration
              ]
            );
          };
        in
        {
          site-generator = site-generator;

          default = pkgs.stdenv.mkDerivation {
            name = "personal-site";

            src = ./.;

            nativeBuildInputs = [
              site-generator
              pkgs.typst
            ];

            buildPhase = ''
              compile-typst-site -p .
            '';

            installPhase = ''
              mkdir -p $out
              cp -a _site/. $out/
            '';
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              typst
              self.packages.${system}.site-generator
            ];
          };
        }
      );
    };
}
