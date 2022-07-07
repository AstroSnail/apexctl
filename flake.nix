{
  description = "A tool to control SteelSeries Apex keyboards on Linux";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          apexctl = pkgs.callPackage self { };
          apexctl-advanced = pkgs.callPackage self { advanced = true; };
        });
    };
}
