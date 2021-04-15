{ nixpkgs ? import <nixpkgs> {} }:

let
  core = nixpkgs.coreutils;
  sh = nixpkgs.writeShellScriptBin;
  web = name: url: ui name "${nixpkgs.chromium}/bin/chromium-browser --app=${url}";
  ui = name: cmd: sh name "${cmd} >> ~/.appslog 2>&1 &";

  query = "$(echo $* | sed -e 's/ /+/g')";
  randarg = "$(${core}/bin/shuf -e $* | ${core}/bin/head -n 1)";
  searchduck = "https://duckduckgo.com";
  searchnix = "https://search.nixos.org";

in rec {
  # desktop apps
  gedit = ui "gedit" "${nixpkgs.gnome3.gedit}/bin/gedit $*";
  lxappearance = ui "lxappearance" "${nixpkgs.lxappearance}/bin/lxappearance";
  nautilus = ui "nautilus" "${nixpkgs.gnome3.nautilus}/bin/nautilus";
  thunderbird = ui "thunderbird" "${nixpkgs.thunderbird}/bin/thunderbird";
  
  # web apps
  github = web "github" "https://github.com";
  hey = web "hey" "https://app.hey.com";
  namecheap = web "namecheap" "https://namecheap.com";
  opts = web "opts" "${searchnix}/options?query=${query}";
  pkgs = web "pkgs" "${searchnix}/packages?query=${query}";
  twitter = web "twitter" "https://twitter.com/${randarg}";
  whatsapp = web "whatsapp" "https://web.whatsapp.com";

  # terminal apps
  ddg = sh "ddg" "${nixpkgs.w3m}/bin/w3m ${searchduck}/?q=${query}";
  vi = nixpkgs.vim_configurable.customize {
    name = "vi";

    vimrcConfig.plug.plugins = [
      nixpkgs.vimPlugins.goyo
      nixpkgs.vimPlugins.lexima-vim
      nixpkgs.vimPlugins.polyglot
    ];
  };
}
