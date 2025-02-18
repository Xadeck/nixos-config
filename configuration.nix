{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "gmktec"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time";
      };
    };
  };
  services.openssh.enable = true;
  services.fail2ban.enable = true;
  services.tailscale.enable = true;
  services.hypridle.enable = true;

  users.users.xdecoret = {
    isNormalUser = true;
    description = "Xavier Decoret";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    alejandra
    bacon
    bear
    btop
    cargo-nextest
    ccls
    chezmoi
    chromium
    clang
    clang-analyzer
    clang-manpages
    clang-tools
    codechecker
    delta
    entr
    eza
    fd
    fishPlugins.fzf-fish
    fishPlugins.grc
    fuzzel
    fzf
    gcc
    go
    google-chrome
    gopls
    grc
    i3status
    jq
    keymapp
    lua
    lua-language-server
    luaformatter
    luarocks
    neofetch
    pkgs.kitty
    playerctl
    pyright
    python3Full
    ripgrep
    rust-analyzer
    rustc
    rustfmt
    rustup
    stylua
    swaytools
    tailscale
    tmux
    tree-sitter
    tree
    zig
    zip
    fish-lsp
  ];
  environment.variables.EDITOR = "vim";

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  programs.bat.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;
  programs.mosh.enable = true;
  programs.neovim.enable = true;
  programs.sway.enable = true;
  programs.vim.enable = true;
  programs.waybar.enable = true;

  programs.nix-ld.enable = true;

  # Make Google Chrome the default browser
  xdg.mime.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
