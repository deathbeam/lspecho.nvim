# lspecho.nvim
Just echo the LSP progress, its that simple.

People put LSP progress to statusline or to corner as virtual text but you can also just echo it and it will
be displayed on cmdline thats empty most of the time anyway and 1 whole line is more than enough space for
LSP status. Originally I wrote this for my dotfiles but I figured might as well just make it plugin.

![lsp-progress](https://github.com/deathbeam/lspecho.nvim/assets/5115805/206d75ac-8533-4758-a35f-1426eed8cf42)

## Installation

Just use [lazy.nvim](https://github.com/folke/lazy.nvim) or `:h packages` with git submodules or something else I don't care.
Read the documentation of whatever you want to use.

## Usage

Just require and call setup and thats it.

```lua
require("lspecho").setup()
```

## Similar projects

- https://github.com/linrongbin16/lsp-progress.nvim - in statusline
- https://github.com/j-hui/fidget.nvim - in corner
