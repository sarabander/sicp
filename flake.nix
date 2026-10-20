{
  description = "Unofficial Spanish translation of Structure and Interpretation of Computer Programs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # Example of downloading icons from a non-flake source
    # font-awesome = {
    #   url = "github:FortAwesome/Font-Awesome";
    #   flake = false;
    # };
  };

  outputs = inputs @ {
    nixpkgs,
    typix,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;

      typixLib = typix.lib.${system};

      src = typixLib.cleanTypstSource ./.;
      commonArgs = {
        typstSource = "main.typ";

        fontPaths = [
          "${pkgs.libertine}/share/fonts/truetype/public"
        ];

        virtualPaths = [
          # Add paths that must be locally accessible to typst here
          # {
          #   dest = "icons";
          #   src = "${inputs.font-awesome}/svgs/regular";
          # }
        ];
      };

      unstable_typstPackages = [
        # Add Typst packages here, transitive dependencies are also mandatory
        {
          name = "oxifmt";
          version = "1.0.0";
          hash = "sha256-edTDK5F2xFYWypGpR0dWxwM7IiBd8hKGQ0KArkbpHvI=";
        }
        {
          name = "cetz";
          version = "0.5.2";
          hash = "sha256-wttZ+L+VPlTLGKPN/exYXozRjMNdXLShhYVTQt4KV/E=";
        }
      ];

      # Compile a Typst project, *without* copying the result
      # to the current directory
      build-drv = typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
        });

      # Compile a Typst project, and then copy the result
      # to the current directory
      build-script = typixLib.buildTypstProjectLocal (commonArgs
        // {
          inherit src unstable_typstPackages;
        });

      # Watch a project and recompile on changes
      watch-script = typixLib.watchTypstProject commonArgs;
    in {
      checks = {
        inherit build-drv build-script watch-script;
      };

      packages.default = build-drv;

      apps = rec {
        default = watch;
        build = flake-utils.lib.mkApp {
          drv = build-script;
        };
        watch = flake-utils.lib.mkApp {
          drv = watch-script;
        };
      };

      devShells.default = typixLib.devShell {
        inherit (commonArgs) fontPaths virtualPaths;
        packages = [
          # WARNING: Don't run `typst-build` directly, instead use `nix run .#build`
          # See https://github.com/loqusion/typix/issues/2
          # build-script
          watch-script
          # More packages can be added here, like typstfmt
          pkgs.typstyle
          pkgs.tinymist
          pkgs.nixd
        ];
      };
    });
}
