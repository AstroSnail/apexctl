{
  description = "A tool to control SteelSeries Apex keyboards on Linux";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = let
        pkgs = nixpkgs.legacyPackages.${system};
        callApexctl = pkgs.callPackage self;
      in {
        apexctl = callApexctl { inherit self; };
        apexctl-advanced = callApexctl {
          inherit self;
          advanced = true;
        };
      };
      defaultPackage = self.packages.${system}.apexctl;
    });
}
