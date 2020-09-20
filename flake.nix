{
  description = "A flake for building ApexCtl";
  outputs = { self, nixpkgs }:
    let supportedSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      packages = supportedSystems (system:
        let
          callApexctl =
            nixpkgs.legacyPackages."${system}".callPackage ./default.nix;
        in {
          apexctl = callApexctl { inherit self; };
          apexctl-advanced = callApexctl {
            inherit self;
            advanced = true;
          };
        });
      defaultPackage =
        supportedSystems (system: self.packages."${system}".apexctl);
    };
}
