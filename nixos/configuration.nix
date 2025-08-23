# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs,inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
       inputs.home-manager.nixosModules.default

    ];

 # home-manager config
  home-manager = {
  useUserPackages = true;
  useGlobalPkgs = true;
  backupFileExtension = "backup";
  extraSpecialArgs = { inherit inputs; };
  users = {
    shaharyar = import ./home.nix;
     };
       };
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  system.stateVersion = "25.05";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
   nix.settings.experimental-features = ["nix-command" "flakes"];
  # Enable networking
  networking.networkmanager.enable = true;
  # Automatic Updating
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";
  # Automatic cleaning
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 10d";
  
  nix.settings.auto-optimise-store = true;
  # Set your time zone.
  time.timeZone = "Asia/Karachi";

  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
  LC_ADDRESS = "en_US.UTF-8";
  LC_IDENTIFICATION = "en_US.UTF-8";
  LC_MEASUREMENT = "en_US.UTF-8";
  LC_MONETARY = "en_US.UTF-8";
  LC_NAME = "en_US.UTF-8";
  LC_NUMERIC = "en_US.UTF-8";
  LC_PAPER = "en_US.UTF-8";
  LC_TELEPHONE = "en_US.UTF-8";
  LC_TIME = "en_US.UTF-8";
};
 fileSystems."/mnt/home_partition" = {
  device = "/dev/disk/by-uuid/bbdb8798-9db7-4cfe-acde-c50b88668e18";
  fsType = "btrfs";
};

 fileSystems."/home" = {
  device = "/mnt/home_partition/home";
  options = [ "bind" ];
};

 # Enable the X11 windowing system.
# X11
  services.xserver.enable = false;

   services.displayManager.sddm = {
      enable = false; # Enable SDDM.
      package = pkgs.kdePackages.sddm;
      extraPackages = with pkgs; [
        sddm-astronaut
        kdePackages.qtsvg
        kdePackages.qtmultimedia
      ];
      wayland.enable = true;
      theme = "sddm-astronaut"; 
    };
   # docker service
   virtualisation.docker.enable = false;
   # Desktop Environment
  services.desktopManager.gnome.enable = false;
  services.displayManager.gdm.enable = true;
  services.xserver.desktopManager.plasma5.enable = false;
# Hyprland 
programs.hyprland = {
    enable = true;
    xwayland.enable = true;
};
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
  xdg-desktop-portal-wlr
  ];

environment.variables = {
  XDG_SESSION_TYPE = "wayland";
  XDG_CURRENT_DESKTOP = "Hyprland";
};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shaharyar = {
    isNormalUser = true;
    description = "shaharyar";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird

    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim 
    wget
    trash-cli
    devbox	
    brave
    google-chrome
    nerd-fonts.jetbrains-mono
    kitty
    ghostty
    zsh
    bat
    fzf
    ripgrep
    fd 
    eza
    git
    yazi
    vscode
    vlc
    lazygit
    tmux
    zed-editor
    swappy
    wl-clipboard
    cliphist
    distrobox
    podman
    waybar
    hyprpaper
    hyprshot
    hypridle
    pyprland
    wlogout
    rofi-wayland
    wofi
      ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
 boot.kernelModules = [ "overlay" ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "25.05"; # Did you read the comment?

}
