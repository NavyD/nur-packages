{
  stdenv,
  fetchurl,
  lib,
  installShellFiles,
  system ? stdenv.hostPlatform.system,
}: let
  inherit (lib.strings) optionalString;
  inherit (builtins) stringLength;
  pname = "sheldon";
  version = "0.6.6";
  # [Set Configuration Options](https://doc.rust-lang.org/reference/conditional-compilation.html#set-configuration-options)
  target = field:
    {
      x86_64-linux = {
        arch = "x86_64";
        os = "linux";
        vendor = "unknown";
        env = "musl";
        hash = "sha256-9JeE0XRblaZL8BObwm8DlxQ7ahyr3GktqykIYL0GNY0=";
      };
      aarch64-linux = {
        arch = "aarch64";
        os = "linux";
        vendor = "unknown";
        env = "musl";
        hash = "sha256-FU09XO8bvwN/t3hRJhxZhfsGqqvT6wUGAgafFG2f9mQ=";
      };
      # x86_64-darwin = {
      #   arch = "x86_64";
      #   os = "darwin";
      #   vendor = "apple";
      #   env = "";
      #   hash = "";
      # };
    }
    ."${system}"
    ."${field}"
    or (throw "Unsupported field ${field} or system: ${stdenv.hostPlatform.system} ");
in
  stdenv.mkDerivation rec {
    # automatically set name to "${pname}-${version}" by default.
    inherit pname;
    inherit version;
    src = fetchurl {
      url = "https://github.com/rossmacarthur/sheldon/releases/download/${version}/${pname}-${version}-${target "arch"}-${target "vendor"}-${target "os"}${let
        env = target "env";
      in
        if stringLength env != 0
        then "-${env}"
        else ""}.tar.gz";
      sha256 = "${target "hash"}";
    };
    nativeBuildInputs = [installShellFiles];
    unpackPhase = "tar xzf ${src}";
    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 ${pname} $out/bin
      # [0.6.6: Support and bundle shell completions](https://github.com/rossmacarthur/sheldon/blob/trunk/RELEASES.md#066)
      if [ -d completions ]; then
        installShellCompletion --zsh --name _sheldon completions/sheldon.zsh
      fi
    '';
    doInstallCheck = true;
    installCheckPhase = "$out/bin/${pname} --version";
    # passthru.updateScript = writeScript "update-sheldon" ''
    #   #!/usr/bin/env nix-shell
    #   #!nix-shell -i bash -p curl pcre common-updater-scripts jq

    #   set -eu -o pipefail

    #   version="$(curl -sSL -H 'Accept: application/json' 'https://api.github.com/repos/rossmacarthur/sheldon/releases/latest' | jq -r '.name')"
    #   update-source-version ${pname} "$version"
    # '';
    meta = with lib; {
      homepage = "https://github.com/rossmacarthur/sheldon";
      description = "Fast, configurable, shell plugin manager";
      license = licenses.mit;
      platforms = ["x86_64-linux" "aarch64-linux"];
    };
  }
