# save this as shell.nix
{ pkgs ? import <nixpkgs> {
  config.allowUnfree = true;
}
, ruby ? pkgs.ruby
, git ? pkgs.git
, libyaml ? pkgs.libyaml
, cursor ? pkgs.code-cursor
}:


pkgs.stdenv.mkDerivation {
  name = "ruby-shell";
  buildInputs = [
    cursor
    git
    libyaml
    ruby
  ];
  shellHook = ''
    export PATH="$(pwd)/bin:$PATH"
  '';
}

