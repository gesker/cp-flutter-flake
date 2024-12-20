{
  description = "Flake: Just fetch Flutter";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    {
      defaultPackage.x86_64-linux =
        with import nixpkgs { system = "x86_64-linux"; };

        let
          FLUTTER_VERSION = "3.27.1";
          FILENAME = "flutter_linux_${FLUTTER_VERSION}-stable.tar.xz";
          FETCH_URL = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FILENAME}";

          flutterArchive = fetchurl {
            url = "${FETCH_URL}";
            sha256 = "sha256-YUl+tkzXs6qZypkRzNkhyNq3mv2QnKHJ/5VGBn689so=";
            executable = false;
          };
        in

        stdenv.mkDerivation {
          name = "flutter";
          src = self;
          buildPhase = ''
            tar -xvf "${flutterArchive}"
          '';
          installPhase = "mkdir -p $out; cp -ar flutter/* $out";
        };
    };
}
