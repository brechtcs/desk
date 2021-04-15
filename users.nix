{ ... }:

{
  users.users.desk.isNormalUser = true;
  users.users.desk.description = "Desk";
  users.users.desk.home = "/home/desk";
  users.users.desk.extraGroups = [ "adbuser" "networkmanager" "wheel" ];
}
