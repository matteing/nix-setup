{ config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "sergio";
  home.homeDirectory = "/Users/sergio";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
    };

    shellAliases = {
      workon = "cd ~/Projects/$1";
    };

    initExtra = ''
      ${(builtins.readFile ../zsh/themes/bubblegum.zsh-theme)}

      # Initialize applications that package optional CLI utilities.
      append_to_bin=(
        "/Applications/Postgres.app/Contents/Versions/latest/bin"
        "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
      )

      for dir in $append_to_bin; do
        # If path exists...
        if [ -d "$dir" ]; then
          export PATH="$dir:$PATH"
        fi
      done
    '';
  };
}