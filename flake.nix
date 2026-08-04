{
  description = "GKMtec";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    antigravity-nix,
    ...
  } @ inputs: {
    nixosConfigurations.gkmtec = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {
          # Allow unfree packages since Antigravity is proprietary
          nixpkgs.config.allowUnfree = true;

          environment.systemPackages = [
            antigravity-nix.packages.x86_64-linux.default # Antigravity Base App
            antigravity-nix.packages.x86_64-linux.google-antigravity-ide # Antigravity IDE
            antigravity-nix.packages.x86_64-linux.google-antigravity-cli # CLI (agy)
          ];
        }
      ];
    };
  };
}
