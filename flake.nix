{
  description = "A flake for building ApexCtl";
  outputs = { self, nixpkgs }:
    let supportedSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      defaultPackage = supportedSystems (system:
        nixpkgs.legacyPackages."${system}".callPackage ./default.nix {
          inherit self;
        });
    };
}
