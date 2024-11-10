# ~/.config/nix/flake.nix

{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      configuration =
        { pkgs, ... }:
        {

          services.nix-daemon.enable = true;
          security.pam.enableSudoTouchIdAuth = true;
          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility. please read the changelog
          # before changing: `darwin-rebuild changelog`.
          system.stateVersion = 4;

          # The platform the configuration will be used on.
          # If you're on an Intel system, replace with "x86_64-darwin"
          nixpkgs.hostPlatform = "x86_64-darwin";

          # Declare the user that will be running `nix-darwin`.
          users.users."alan.tai" = {
            name = "alan.tai";
            home = "/Users/alan.tai";
          };

          environment.systemPackages = [
            pkgs.nixfmt-rfc-style
            pkgs.ripgrep
            pkgs.fzf
            pkgs.oh-my-posh
            pkgs.coreutils
            pkgs.nerdfonts
            pkgs.jq
            pkgs.bash-completion
            pkgs.nix-bash-completions
            pkgs.rectangle
          ];

          homebrew = {
            enable = true;
            # onActivation.cleanup = "uninstall";

            taps = [ ];
            brews = [ ];
            casks = [
              # "linearmouse"
            ];
          };
        };

      # To view all configuration opts: https://nix-community.github.io/home-manager/options.xhtml#opt-home.file
      homeconfig =
        { pkgs, ... }:
        {
          # this is internal compatibility configuration 
          # for home-manager, don't change this!
          home.stateVersion = "23.05";
          # Let home-manager install and manage itself.
          programs.home-manager.enable = true;

          programs = {
            bash = {
              enable = true;
              enableCompletion = true;
              shellAliases = {
                "nix.switch" = "darwin-rebuild switch --flake ~/nix";
              };
              bashrcExtra = "[ -f ~/.env ] && source ~/.env\nsource ~/dotfiles/.bashrc";
            };
            neovim = {
              enable = true;
              defaultEditor = true;
              extraConfig = ''
                set number relativenumber
              '';
              viAlias = true;
              vimAlias = true;
            };
          };

          home = {
            packages = with pkgs; [ ];
            sessionVariables = {
              EDITOR = "nvim";
            };
            # file.{symlink_path}.source will symlink the file at the assigned path to the {symlink_path}
            # The assigned path must be local to the flake.
            file = {
              ".config".source = ./config;
              "test".source = ./config;
            };
          };
        };
    in
    {
      darwinConfigurations."JSA-190350" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              users."alan.tai" = homeconfig;
            };
          }
        ];
      };
    };
}
