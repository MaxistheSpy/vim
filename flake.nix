{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    mnw.url = "github:Gerg-L/mnw";
  };
  outputs =
    {
      self,
      nixpkgs,
      mnw,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
      ];
      forSystems = nixpkgs.lib.genAttrs supportedSystems;
      paths = {
        aarch64-darwin = "/Users/max/nvim";
        x86_64-linux = "/home/max/nvim";
        aarch64-linux = "/home/max/nvim";
      };
    in

    {

      formatter = forSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "format";
          runtimeInputs = builtins.attrValues {
            inherit (pkgs)
              nixfmt-rfc-style
              deadnix
              statix
              fd
              stylua
              ;
          };
          text = ''
            fd "$@" -t f -e nix -x statix fix -- '{}'
            fd "$@" -t f -e nix -X deadnix -e -- '{}' \; -X nixfmt '{}'
            fd "$@" -t f -e lua -X stylua --indent-type Spaces --indent-width 2 '{}'
          '';
        }
      );

      packages = forSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          main = mnw.lib.wrap pkgs {
            neovim = pkgs.neovim-unwrapped;
            initLua = ''
              require('cfg')
            '';
            plugins = {
              start = with pkgs.vimPlugins; [
                #NAV
                oil-nvim # FILES
                harpoon2 # FILE JUMP TAG
                telescope-nvim # TELESCOPE
                plenary-nvim # TELESCOPE
                #MISC
                rose-pine # colorscheme
                #EDITOR
                undotree # UNDO HISTORY
                vim-fugitive # GIT
                nvim-treesitter.withAllGrammars # SYNTAX HIGHLIGHT
                nvim-lspconfig
                which-key-nvim
                blink-cmp
                mini-completion
                mini-icons
                mini-diff
								conform-nvim
                treesj

                mini-jump
                eyeliner-nvim
                telescope-frecency-nvim
                snacks-nvim
                lazydev-nvim
                gitsigns-nvim
                diffview-nvim
              ];
              dev.config = {
                pure = ./.;
                impure = paths.${system};
              };
            };
            extraBinPath = builtins.attrValues {
              inherit (pkgs)
                deadnix
                statix
                nixd
                nil
                nixfmt
                lua-language-server
                stylua
                ;
            };
          };

          default = self.packages.${system}.main.devMode;

        }
      );

    };
}
