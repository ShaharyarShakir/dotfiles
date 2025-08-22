{ config, pkgs, ... }:

{
  home.username = "shaharyar";
  home.homeDirectory = "/home/shaharyar";
  home.stateVersion = "24.11";
 # home.file.".config/qtile".source = /home/tony/home-manager-dotfiles/qtile;

  home.packages = with pkgs; [
    bat
    neofetch
  ];
}

