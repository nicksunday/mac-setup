#!/bin/bash
# Git should already be installed

# Install Kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# Copy Kitty Theme
if [[ ! -d "$HOME/.config/kitty" ]]; then
	mkdir -p "$HOME/.config/kitty"
fi

cp current-theme.conf "$HOME/.config/kitty/current-theme.conf"

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Brewfile
brew bundle

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install vim-plug for neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Setup Plugin Dir
if [[ ! -d "$HOME/.config/nvim" ]]; then
	mkdir -p "$HOME/.config/nvim"
fi

# Install Powerline Fonts
## clone
git clone https://github.com/powerline/fonts.git --depth=1
## install
cd fonts || return
./install.sh
## clean-up a bit
cd .. || return
rm -rf fonts

# Setup Plugins
cat << EOF > "$HOME/.config/nvim"
" Plugins will be downloaded under the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Declare the list of plugins.
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'PhilRunninger/nerdtree-buffer-ops'
Plug 'PhilRunninger/nerdtree-visual-selection'
Plug 'vim-airline/vim-airline'
Plug 'fladson/vim-kitty'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1

" List ends here. Plugins become visible to Vim after this call.
call plug#end()
EOF

# Setup vimrc
cat << EOF > "$HOME/.vim/vimrc"
" Linting settings
let g:ale_lint_on_enter = 0
let g:ale_echo_msg_format = '[%linter%] [%code%] %s [%severity%]'

" Enable linters
let g:ale_linters = {
\   'bash': ['shellcheck'],
\   'python': ['pylint'],
\   'yaml': ['yamllint'],
\}

let g:ale_fixers = {
\ '*': ['remove_trailing_lines', 'trim_whitespace'],
\ 'python': ['autopep8'],
\}
EOF

# Add syntax highlighting to zshrc
echo "source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$HOME/.zshrc"

echo "Open a file and run :PlugInstall"
