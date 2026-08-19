{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

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
  networking.firewall.allowedTCPPorts = [80 443 25565 139 445];
  networking.firewall.allowedUDPPorts = [5353];

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      };
    };
  };
  services.openssh.enable = true;
  services.fail2ban.enable = true;
  services.tailscale.enable = true;
  services.hypridle.enable = true;

  # Ensure host volume directories exist
  systemd.tmpfiles.rules = [
    "d /var/lib/caddy/data 0755 root root -"
    "d /var/lib/caddy/config 0755 root root -"
    "d /var/lib/minecraft-data 0755 root root -"
    "d /var/lib/timemachine 0700 xdecoret users -"
    "d /var/lib/secrets 0700 root root -"
  ];

  # Podman container runtime configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Provide docker CLI wrapper for podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # Declarative OCI Containers
  virtualisation.oci-containers = {
    backend = "podman";
    containers.caddy = {
      image = "docker.io/library/caddy:latest";
      extraOptions = [
        "--network=host"
      ];
      volumes = [
        "/home/xdecoret/nixos-config/caddy/Caddyfile:/etc/caddy/Caddyfile:ro"
        "/home/xdecoret/nixos-config/caddy/wip.caddy:/etc/caddy/wip.caddy:ro"
        "/var/lib/caddy/data:/data"
        "/var/lib/caddy/config:/config"
      ];
      autoStart = true;
    };
    containers.minecraft = {
      image = "docker.io/itzg/minecraft-server:latest";
      extraOptions = [
        "--network=host"
      ];
      environment = {
        EULA = "TRUE";
        TYPE = "PAPER";
        VERSION = "LATEST";
        MEMORY = "4G";
      };
      volumes = [
        "/var/lib/minecraft-data:/data"
      ];
      autoStart = true;
    };
    containers.timemachine = {
      image = "docker.io/mbentley/timemachine:latest";
      extraOptions = [
        "--network=host"
      ];
      environment = {
        TM_USERNAME = "xdecoret";
        TM_UID = "1000";
        TM_GID = "100";
        SET_PERMISSIONS = "false";
        SHARE_NAME = "TimeMachine";
        VOLUME_SIZE_MB = "512000"; # 500 GB quota
      };
      environmentFiles = [
        "/var/lib/secrets/timemachine.env"
      ];
      volumes = [
        # Must be mapped to /opt/${TM_USERNAME}
        "/var/lib/timemachine:/opt/xdecoret"
      ];
      autoStart = true;
    };
  };

  users.users.xdecoret = {
    isNormalUser = true;
    description = "Xavier Decoret";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.fish;
  };

  users.users.gheruha = {
    isNormalUser = true;
    description = "Max Gheruha";
    extraGroups = [];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    alejandra
    bazel_7
    bear
    btop
    buildifier
    caddy
    cargo-nextest
    ccls
    chezmoi
    chromium
    clang
    clang-analyzer
    clang-manpages
    clang-tools
    codechecker
    cowsay
    delta
    dig
    djlint
    docker
    dockerfmt
    duf
    entr
    eza
    fastfetch
    fd
    fish-lsp
    fishPlugins.fzf-fish
    fishPlugins.grc
    fuzzel
    fzf
    gcc
    gh
    github-desktop
    go
    google-chrome
    gopls
    grc
    i3status
    inetutils
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide
    jq
    keymapp
    kitty
    lldb
    lua
    lua-language-server
    luaformatter
    luarocks
    mdformat
    ncdu
    nixd
    nodejs
    openssl
    playerctl
    pocketbase
    prettier
    pyright
    python3
    ripgrep
    rust-analyzer
    rustup
    rustywind
    starpls
    stylua
    swaytools
    tailwindcss
    tailwindcss-language-server
    tldr
    tmux
    tree
    tree-sitter
    tup
    typescript-language-server
    unzip
    vscode-langservers-extracted
    zig
    zip
  ];
  environment.variables = {
    EDITOR = "vim";
    BROWSER = "google-chrome";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  programs.bat.enable = true;
  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.mosh.enable = true;
  programs.neovim.enable = true;
  programs.sway.enable = true;
  programs.vim.enable = true;
  programs.waybar.enable = true;

  # Enable nix-ld to run unpatched dynamic binaries with common fallback libraries (e.g., IDE extensions, Node native addons)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      glibc
    ];
  };

  # Make Google Chrome the default browser
  xdg.mime.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "text/xml" = "google-chrome.desktop";
    "application/xhtml+xml" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
    "x-scheme-handler/mailto" = "google-chrome.desktop";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # r(e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
