# lspecho.nvim
Just echo the LSP status, its that simple.

People put LSP status to statusline or to corner as virtual text but you can also just echo it and it will
be displayed on cmdline thats empty most of the time anyway and 1 whole line is more than enough space for
LSP status. Originally I wrote this for my dotfiles but I figured might as well just make it plugin.

![lsp-status](/screenshots/lsp-status.gif)

## Usage

Just require and call setup and thats it.

```lua
require("lspecho").setup()
```

## Similar projects

- https://github.com/linrongbin16/lsp-progress.nvim - in statusline
- https://github.com/j-hui/fidget.nvim - in corner
