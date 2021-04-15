{ lib, pkgs, ... }:

let
  wmrc = ./wm.lua;

in {
  services.xserver.enable = true;
  services.xserver.layout = "be";
  services.xserver.libinput.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.displayManager.defaultSession = "none+awesome";
  services.xserver.windowManager.session = lib.singleton {
    name = "awesome";
    start = ''
      ${pkgs.awesome}/bin/awesome --config ${wmrc} &
      waitPID=$!
    '';
  };
}
