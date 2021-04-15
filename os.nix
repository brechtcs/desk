{ pkgs, ... }:

let
  apps = import ./apps.nix {};
  prompt = ./prompt.lua;

in {
  imports = [
    ./couch.nix
    ./users.nix
    ./x.nix
  ];

  console.keyMap = "azerty";
  time.timeZone = "Europe/Brussels";

  programs.adb.enable = true;
  programs.bash.promptInit = ''PS1="\$(${pkgs.lua}/bin/lua ${prompt})"'';
  programs.nm-applet.enable = true;
  networking.networkmanager.enable = true;
  sound.enable = true;

  environment.systemPackages = [
    pkgs.git
    pkgs.lua
    apps.vi
  ];
}
