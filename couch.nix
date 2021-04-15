{ pkgs, ... }:

{
  services.couchdb.enable = true;
  services.couchdb.package = pkgs.couchdb2;
}
