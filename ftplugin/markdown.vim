if !has('vim9script') ||  v:version < 900
    finish
endif

vim9script

if exists('b:loaded_obsidian')
    finish
endif
b:loaded_obsidian = 1

import '../utils/utils.vim'
import autoload '../autoload/obsidian.vim'

# Directory to search for files (default is the current directory)
g:obsidian_vault_dir = utils.NormalizePath(get(g:, 'obsidian_vault_dir', '.'))
g:obsidian_newfile_dir = utils.NormalizePath(get(g:, 'obsidian_newfile_dir', g:obsidian_vault_dir .. '/new_notes'))

if !hasmapto('<Plug>ObsidianOpenWikilink')
    nmap <unique> <buffer> gd <Plug>ObsidianOpenWikilink
endif

if !hasmapto('<Plug>ObsidianCreateWikilink')
    vmap <unique> <leader>os <Plug>ObsidianCreateWikilink
endif

if !hasmapto('<Plug>ObsidianNewNote')
    nmap <unique> <leader>on <Plug>ObsidianNewNote 
endif

command! -nargs=0 -buffer ObsidianOpenWikilink obsidian#OpenWikilink()
command! -nargs=0 -buffer ObsidianCreateWikilink obsidian#CreateWikilink()
command! -nargs=1 -buffer ObsidianNewNote obsidian#OpenNewNote('<args>')
command! -nargs=0 -buffer ObsidianInsertWikilink obsidian#InsertWikilink()

nnoremap <buffer> <silent> <Plug>ObsidianOpenWikilink <scriptcmd>ObsidianOpenWikilink<CR>
noremap <buffer> <silent> <Plug>ObsidianCreateWikilink <scriptcmd>ObsidianCreateWikilink<CR>
noremap <buffer> <Plug>ObsidianNewNote :ObsidianNewNote 
inoremap <buffer> <silent> [[ <scriptcmd>ObsidianInsertWikilink<CR>

