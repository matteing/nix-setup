/* -------------------------------------------------------------------------- */
/*                    Shell scripts, dotfiles and aliases.                    */
/* -------------------------------------------------------------------------- */

{ config, pkgs, ... }:

let 
  username = "sergio";
  zshTheme = "minimal_improved";

  # Depends on the symlink in "home.file".
  notesPath = "~/iCloud/Notes";
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/Users/${username}";

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

  # Set up useful symlinks.
  # https://www.reddit.com/r/NixOS/comments/u09cz9/home_manager_create_my_own_symlinks_automatically/
  home.file = {
    "iCloud" = {
      source = config.lib.file.mkOutOfStoreSymlink "/Users/${username}/Library/Mobile Documents/com~apple~CloudDocs";
    };
  };

  programs.git = {
    enable = true;
    userName = "Sergio Mattei";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Before installing things to systemPackages, check if they're
  # home-manager compatible. If they are, opt for that, as the configuration is 
  # automatically cross-platform and installed to home instead.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # General
      home = "cd ~";
      rebuild = "cd ~/nix; make rebuild";

      # Projects
      workon = "cd ~/Projects/$1";
      django = "python manage.py";
      fly-proxy-db = "flyctl proxy 15432:5432 -s -a";
      npm = "pnpm";
      actually-npm = "npm";

      # Opinionated note management
      create-daily-note = "python3 ${notesPath}/Management/create-daily-note.py";
      daily = "create-daily-note";
      today = "create-daily-note";
      tomorrow = "create-daily-note --tomorrow";
      note = "open 'ia-writer://new?path=${notesPath}/Inbox'";
      clip = "open 'ia-writer://new?path=${notesPath}/Clippings'";
      autoindex = "python3 ${notesPath}/Management/run-autoindex.py ${notesPath}";
    };

    sessionVariables = {
      EDITOR = "nano";
      VISUAL = "$EDITOR";
      ERL_AFLAGS = "-kernel shell_history enabled -kernel shell_history_file_bytes 1024000";
      KERL_CONFIGURE_OPTIONS="--enable-dynamic-ssl-lib --with-ssl=/opt/homebrew/opt/openssl@3 --enable-hipe --enable-shared-zlib --enable-smp-support --enable-threads --enable-wx --disable-debug --without-javac";
      KERL_BUILD_DOCS = "yes";
    };

    initExtra = ''
      ${(builtins.readFile ../zsh/themes/${zshTheme}.zsh-theme)}

      # Disable the right-hand side prompt (unsure why it's even set at all?)
      # export RPROMPT=""

      # Initialize Brew.
      eval "$(/opt/homebrew/bin/brew shellenv)"

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

      # Initialize the asdf version manager.
      . ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh
    '';
  };
}