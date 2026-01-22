{
    description = "Garden System Configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

        home-manager.url = "github:nix-community/home-manager/release-25.11";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, disko, ... } @inputs: {
        nixosConfigurations = {
            garden = nixpkgs.lib.nixosSystem {
                specialArgs = {inherit inputs;};
                modules = [
					disko.nixosModules.disko
                    ./configuration.nix
                ];
            };
        };
    };
}
