{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.neovim;

  extraConfig = ''
    "" Encoding
    set encoding=utf-8
    set fileencoding=utf-8
    set fileencodings=utf-8,iso-8859-1


    "" Tabs. May be overriten by autocmd rules
    set tabstop=4
    set ts=4
    set softtabstop=0
    set shiftwidth=4
    set expandtab
    set autoindent
    set smartindent


    "" Enable filetype detection:
    filetype on
    filetype plugin on
    filetype indent on

    autocmd Filetype make set noexpandtab
    autocmd Filetype c set expandtab
    autocmd Filetype cpp set expandtab
    autocmd Filetype tex set tabstop=2 shiftwidth=2 textwidth=119

    let g:tex_flavor = 'latex'


    "" Remove trailing whitespaces on save
    autocmd BufWritePre * %s/\s\+$//e


    "" Set tab size to 4 in gitcommit
    autocmd FileType gitcommit setl ts=4


    "" Directories for swp files
    set nobackup
    set noswapfile
    set nowb


    "" Automatically update a file if it is changed externally
    set autoread


    "" Visual settings
    syntax on
    let g:enable_bold_font = 1
    set background=dark
    colorscheme hybrid_material
    set ruler
    set number
    set cursorline
    set cursorcolumn
    set colorcolumn=121

    "" Enable modelines
    set modeline
    set modelines=5


    "" Airline
    set laststatus=2

    let g:airline_powerline_fonts = 1
    let g:airline_theme='hybrid'

    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    " unicode symbols
    let g:airline_left_sep = '»'
    let g:airline_left_sep = '▶'
    let g:airline_right_sep = '«'
    let g:airline_right_sep = '◀'
    let g:airline_symbols.linenr = '␊'
    let g:airline_symbols.linenr = '␤'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.paste = 'Þ'
    let g:airline_symbols.paste = '∥'
    let g:airline_symbols.whitespace = 'Ξ'

    " airline symbols
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = ''


    "" Mappings
    let mapleader=","

    " turn off search highlight with ,-<space>
    nnoremap <leader><space> :nohlsearch<CR>

    :map <leader>iso :w ++enc=iso-8859-1<C-M>


    "" Buffers

    " Enable the list of buffers
    let g:airline#extensions#tabline#enabled = 1

    " Show just the filename
    let g:airline#extensions#tabline#fnamemod = ':t'

    " This allows buffers to be hidden if you've modified a buffer.
    " This is almost a must if you wish to use buffers in this way.
    set hidden

    " To open a new empty buffer
    " This replaces :tabnew which I used to bind to this mapping
    nmap <leader>w :enew<cr>

    " Move to the next buffer
    nmap <leader>n :bnext<CR>

    " Move to the previous buffer
    nmap <leader>p :bprevious<CR>

    " Close the current buffer and move to the previous one
    " This replicates the idea of closing a tab
    nmap <leader>q :bp <BAR> bd #<CR>

    " Show all open buffers and their status
    nmap <leader>l :ls<CR>

    " Disables formatting in paste mode
    set pastetoggle=<F3>


    "" Auto formatter
    let g:formatdef_nixpkgs_fmt = '"${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"'
    let g:formatters_nix = ['nixpkgs_fmt']

    let g:autoformat_autoindent = 0
    let g:autoformat_retab = 0

    noremap <F3> :Autoformat<CR>
    "au BufWrite * :Autoformat
  '';

  plugins = with pkgs.vimPlugins; [
    vim-airline
    vim-airline-themes
    vim-hybrid-material

    nerdtree
    csv-vim
    gitignore-vim
    rust-vim
    vim-autoformat
    vim-json
    vim-nix
    vim-tmux
    vim-toml
    vimtex
  ];
in

{

  ###### interface

  options = {

    custom.programs.neovim = {

      enable = mkEnableOption "neovim config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final neovim.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.neovim = { inherit (config.programs.neovim) finalPackage; };

    home.sessionVariables.EDITOR = "nvim";

    programs.neovim = {
      inherit extraConfig plugins;

      enable = true;
      viAlias = true;
      vimAlias = true;
    };

  };

}
