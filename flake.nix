{
  description = "An over-engineered Hello World in bash";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs =
    { self, nixpkgs }:
    let

      # inherit nixpkgs;

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }
      );

      FLUTTER_VERSION = "3.27.1";
      FILENAME = "flutter_linux_${FLUTTER_VERSION}-stable.tar.xz";
      FETCH_URL = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FILENAME}";

      flutterArchive = builtins.fetchurl {
        url = "${FETCH_URL}";
        sha256 = "sha256-YUl+tkzXs6qZypkRzNkhyNq3mv2QnKHJ/5VGBn689so=";
        executable = false;
      };
    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

        flutter =
          with final;
          stdenv.mkDerivation rec {
            name = "flutter-${version}";

            unpackPhase = ":";
            buildPhase = ''
              tar -xvf "${flutterArchive}"
            '';
            installPhase = "mkdir -p $out; cp -ar flutter/* $out";

          };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) flutter;
      });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.flutter);

      # A NixOS module, if applicable (e.g. if the package provides a system service).
      nixosModules.flutter =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [ self.overlay ];

          environment.systemPackages = [ pkgs.flutter ];

          #systemd.services = { ... };
        };

      # # Tests run by 'nix flake check' and by Hydra.
      # checks = forAllSystems
      #   (system:
      #     with nixpkgsFor.${system};

      #     {
      #       inherit (self.packages.${system}) hello;

      #       # Additional tests, if applicable.
      #       test = stdenv.mkDerivation {
      #         name = "hello-test-${version}";

      #         buildInputs = [ hello ];

      #         unpackPhase = "true";

      #         buildPhase = ''
      #           echo 'running some integration tests'
      #           [[ $(hello) = 'Hello Nixers!' ]]
      #         '';

      #         installPhase = "mkdir -p $out";
      #       };
      #     }

      #     // lib.optionalAttrs stdenv.isLinux {
      #       # A VM test of the NixOS module.
      #       vmTest =
      #         with import (nixpkgs + "/nixos/lib/testing-python.nix") {
      #           inherit system;
      #         };

      #         makeTest {
      #           nodes = {
      #             client = { ... }: {
      #               imports = [ self.nixosModules.hello ];
      #             };
      #           };

      #           testScript =
      #             ''
      #               start_all()
      #               client.wait_for_unit("multi-user.target")
      #               client.succeed("hello")
      #             '';
      #         };
      #     }
      #   );

    };
}
