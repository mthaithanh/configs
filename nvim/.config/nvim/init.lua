-- ==== packer ====
local fn = vim.fn
local execute = vim.api.nvim_command
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

vim.cmd [[packadd packer.nvim]]
vim.api.nvim_exec([[
augroup Packer
autocmd!
autocmd BufWritePost plugins.lua PackerCompile
augroup end
]], false)

local use = require('packer').use
require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true}
  use {'neovim/nvim-lspconfig'}
  use {'nvim-lua/popup.nvim'}
  use {'nvim-lua/plenary.nvim'}
  use {'nvim-lua/completion-nvim'}
  use {'nvim-treesitter/nvim-treesitter'}
  use {'nvim-telescope/telescope.nvim'}
  -- programming
  use {'rust-lang/rust.vim'}
  use {'SirVer/ultisnips'}
  use {'honza/vim-snippets'}
  -- color theme
  use {'chriskempson/base16-vim'}
  use {'hoob3rt/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true}}
  -- editing
  use {'tpope/vim-fugitive'}
  use {'tpope/vim-surround'}
  use {'tpope/vim-commentary'}
  use {'jiangmiao/auto-pairs'}
  -- other
  use {'folke/which-key.nvim'}
end)

-- ==== mapping and settings helpers ====
local utils = {}
local scopes = {o = vim.o, b = vim.bo, w = vim.wo, g = vim.g}
function utils.opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end
function utils.map(type, key, value, opts)
  local options = opts or {}
  vim.api.nvim_set_keymap(type, key, value, options)
end
function utils.noremap(type, key, value, opts)
  local options = {noremap = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(type, key, value, options)
end
function utils.nnoremap(key, value, opts)
  utils.noremap('n', key, value, opts)
end
function utils.inoremap(key, value, opts)
  utils.noremap('i', key, value, opts)
end
function utils.vnoremap(key, value, opts)
  utils.noremap('v', key, value, opts)
end
function utils.xnoremap(key, value, opts)
  utils.noremap('x', key, value, opts)
end
function utils.tnoremap(key, value, opts)
  utils.noremap('t', key, value, opts)
end
function utils.cnoremap(key, value, opts)
  utils.noremap('c', key, value, opts)
end
function utils.nmap(key, value, opts)
  utils.map('n', key, value, opts)
end
function utils.imap(key, value, opts)
  utils.map('i', key, value, opts)
end
function utils.vmap(key, value, opts)
  utils.map('v', key, value, opts)
end
function utils.tmap(key, value, opts)
  utils.map('t', key, value, opts)
end

local o = vim.o
local g = vim.g

-- ==== Options =====
-- line numbers
utils.opt('w', 'number', true)
utils.opt('w', 'numberwidth', 6)
utils.opt('w', 'relativenumber', true)
-- line numbers
utils.opt('o', 'mouse', 'a')
-- faster macros
utils.opt('o', 'lazyredraw', true)
-- matching parenthesis
utils.opt('o', 'showmatch', true)
-- switch buffer without saving them
utils.opt('o', 'hidden', true)
-- better searching
utils.opt('o', 'ignorecase', true)
utils.opt('o', 'smartcase', true)
utils.opt('o', 'hlsearch', false)
-- show lines bellow cursor
utils.opt('o', 'scrolloff', 5)
utils.opt('o', 'sidescrolloff', 5)
-- highlight cursorline
utils.opt('g', 'cursorline', true)
-- tab config
utils.opt('b', 'expandtab', true)
utils.opt('b', 'shiftwidth', 2)
utils.opt('b', 'tabstop', 2)
utils.opt('b', 'softtabstop', 2)
-- split in reasonable positions
utils.opt('o', 'splitright', true)
utils.opt('o', 'splitbelow', true)
-- folds
utils.opt('w', 'foldmethod', 'expr')
utils.opt('w', 'foldexpr', 'nvim_treesitter#foldexpr()')
utils.opt('o', 'foldlevelstart', 99)
o.formatoptions = o.formatoptions:gsub("r", ""):gsub("o", "")

-- ===== colorsheme settings =====
utils.opt('o', 'termguicolors', true)
vim.cmd('syntax on')
vim.cmd('colorscheme base16-gruvbox-dark-hard')
-- vim.g.gruvbox_contrast_dark = "hard"
-- lualine
require('lualine').setup{
  options = {theme = 'gruvbox', section_separators = '', component_separators = ''}
}

-- ==== save hooks =====
-- remove trailing whitespaces
vim.cmd([[autocmd BufWritePre * %s/\s\+$//e]])
-- remove trailing newline
vim.cmd([[autocmd BufWritePre * %s/\n\+\%$//e]])
-- Run xrdb whenever Xdefaults or Xresources are updated.
vim.cmd([[autocmd BufWritePost *xresources !xrdb %]])

-- ===== mappings =====
utils.map('', '<Space>', '<Nop>', {noremap = true, silent = true})
g.mapleader = " "
g.maplocalleader = " "
-- split navigation
utils.map("", "<C-h>", "<C-w>h")
utils.map("", "<C-j>", "<C-w>j")
utils.map("", "<C-k>", "<C-w>k")
utils.map("", "<C-l>", "<C-w>l")
-- split window
utils.nnoremap("<leader>wJ", "<cmd>split window<cr>")
utils.nnoremap("<leader>wL", "<cmd>vsplit window<cr>")
-- move lines up and down in visual mode
utils.xnoremap("K", ":move '<-2<CR>gv-gv")
utils.xnoremap("J", ":move '>+1<CR>gv-gv")
-- spellcheck
utils.nnoremap("<leader>sp", ":setlocal spell spelllang=de")
-- write to ----READONLY---- files
utils.cnoremap("w!!",  "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")
-- useful bindings
utils.inoremap("jk", "<Esc>")
utils.nnoremap("<F4>", "<cmd>vs $MYVIMRC<CR>")
utils.nnoremap("<F5>", "/cmd>source $MYVIMRC<CR>")

-- ===== telescope setup =====
require('telescope').setup {
  pickers = {
    buffers = {
      previewer = false,
    }
  }
}
utils.nnoremap('<leader>,', '<cmd>Telescope buffers<cr>')
utils.nnoremap('<leader>.', '<cmd>Telescope git_files<cr>')
utils.nnoremap('<leader>/', '<cmd>Telescope file_browser<cr>')
utils.nnoremap('<leader>fg', '<cmd>Telescope live_grep<cr>')
utils.nnoremap('<leader>fG', '<cmd>Telescope find_files<cr>')
utils.nnoremap('<leader>fh', '<cmd>Telescope help_tags<cr>')

-- ===== completion settings =====
vim.o.completeopt = "menuone,noinsert,noselect"
vim.g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
vim.g.completion_enable_snippet = 'UltiSnips'
vim.g.completion_matching_ignore_case = 1
vim.g.completion_trigger_keyword_length = 3
-- utils.inoremap("<Tab>", 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
-- utils.inoremap("<S-Tab>", 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true})

vim.g.UltiSnipsExpandTrigger="<tab>"
vim.g.UltiSnipsJumpForwardTrigger="<C-n>"
vim.g.UltiSnipsJumpBackwardTrigger="<C-p>"
vim.g.UltiSnipsEditSplit="vertical"

-- ===== lsp setup =====
local custom_attach = function(client)
  print("LSP started.");
  require'completion'.on_attach(client)
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false, update_in_insert = false }
  )
  -- automatic diagnostics popup
  vim.api.nvim_command('autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics()')
  -- speedup diagnostics popup
  vim.o.updatetime = 1000
  utils.nnoremap('gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
  utils.nnoremap('gd','<cmd>lua vim.lsp.buf.definition()<CR>')
  utils.nnoremap('K','<cmd>lua vim.lsp.buf.hover()<CR>')
  utils.nnoremap('gr','<cmd>lua vim.lsp.buf.references()<CR>')
  utils.nnoremap('gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
  utils.nnoremap('gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
  utils.nnoremap('<F5>','<cmd>lua vim.lsp.buf.code_action()<CR>')
  utils.nnoremap('<leader>r','<cmd>lua vim.lsp.buf.rename()<CR>')
  utils.nnoremap('<leader>=','<cmd>lua vim.lsp.buf.formatting()<CR>')
  utils.nnoremap('<leader>d','<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  utils.nnoremap('<leader>D','<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
end
-- setup all lsp servers here
local nvim_lsp = require'lspconfig'
nvim_lsp.clangd.setup {on_attach = custom_attach}
nvim_lsp.cmake.setup {on_attach = custom_attach}
nvim_lsp.dockerls.setup {on_attach = custom_attach}
nvim_lsp.gopls.setup {on_attach = custom_attach}
nvim_lsp.rust_analyzer.setup {on_attach = custom_attach}
nvim_lsp.sumneko_lua.setup {
  cmd = {'lua-language-server'},
  on_attach = custom_attach,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        enable = true,
        globals = {"vim", "describe", "it", "before_each", "after_each"},
        completion = {keywordSnippet = "Disable"}
      },
      workspace = {
        library = {
          [fn.expand("$VIMRUNTIME/lua")] = true,
          [fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
        },
        maxPreload = 1000,
        preloadFileSize = 1000,
      }
    }
  }
}
nvim_lsp.texlab.setup{on_attach = custom_attach}
nvim_lsp.tsserver.setup{on_attach = custom_attach}
nvim_lsp.yamlls.setup{on_attach = custom_attach}

local nvim_treesitter = require 'nvim-treesitter.configs'
nvim_treesitter.setup {
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "javascript",
    "lua",
    -- "make",
    -- "markdown",
    "python",
    -- "rust",
    "toml",
    "typescript",
    "yaml",
  },
  highlight = {enable = true},
}
