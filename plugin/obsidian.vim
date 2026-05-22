if !has('vim9script') ||  v:version < 900
    finish
endif

vim9script

if exists('g:loaded_obsidian')
    finish
endif
g:loaded_obsidian = 1

import autoload '../utils/utils.vim'
import autoload '../autoload/obsidian.vim'

# Directory to search for files (default is the current directory)
g:obsidian_vault_dir = utils.NormalizePath(get(g:, 'obsidian_vault_dir', '.'))
g:obsidian_newfile_dir = utils.NormalizePath(get(g:, 'obsidian_newfile_dir', g:obsidian_vault_dir .. '/new_notes'))
g:obsidian_mappings = get(g:, 'obsidian_mappings', {})

# Commands available for all filetypes
command! -nargs=1 ObsidianNewNote obsidian#OpenNewNote('<args>')

obsidian.Setup()
