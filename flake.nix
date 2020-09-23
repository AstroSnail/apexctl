{
  description = "A tool to control SteelSeries Apex keyboards on Linux";
  outputs = { self, nixpkgs }:
    let supportedSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      packages = supportedSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          callApexctl = pkgs.callPackage self;
        in {
          apexctl = callApexctl { inherit self; };
          apexctl-advanced = callApexctl {
            inherit self;
            advanced = true;
          };
        });
      defaultPackage =
        supportedSystems (system: self.packages.${system}.apexctl);
    };
}
