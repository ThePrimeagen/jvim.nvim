## JSON and YAML Navigation

### Installation

```viml
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'theprimeagen/jvim.nvim'
```

### How to use
Pick your favorite remaps and just put em on!  Put this in your `ftplugin`
folder.  Here is an example of mine (I have copied and pasted it below for
convenience):

Yes I did use the arrow keys because I have them nearish the home row on my
[Kinesis Advantage 2](https://bit.ly/primeagen-adv2).  I never use them, might
as well make them useful for something!

```viml
nnoremap <left> :lua require("jvim").to_parent()<CR>
nnoremap <right> :lua require("jvim").descend()<CR>
nnoremap <up> :lua require("jvim").prev_sibling()<CR>
nnoremap <down> :lua require("jvim").next_sibling()<CR>
```

Or if you're using `ftplugin/{json,yaml}.lua`:

```lua
local jvim = require("jvim")
local opts = {noremap = true, silent = true}
vim.keymap.set('n', '<left>', jvim.to_parent, opts)
vim.keymap.set('n', '<right>', jvim.descend, opts)
vim.keymap.set('n', '<up>', jvim.prev_sibling, opts)
vim.keymap.set('n', '<down>', jvim.next_sibling, opts)
```
