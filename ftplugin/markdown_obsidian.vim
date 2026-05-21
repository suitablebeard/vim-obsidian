if !has('vim9script') ||  v:version < 900
    finish
endif

vim9script

if exists('b:did_ftplugin_obsidian')
    finish
endif
b:did_ftplugin_obsidian = 1

import autoload '../utils/utils.vim'
import autoload '../autoload/obsidian.vim'

if !hasmapto('<Plug>ObsidianOpenWikilink')
    nmap <unique> <buffer> gd <Plug>ObsidianOpenWikilink
endif

if !hasmapto('<Plug>ObsidianCreateWikilink')
    vmap <unique> <buffer> <leader>os <Plug>ObsidianCreateWikilink
endif

command! -nargs=0 -buffer ObsidianOpenWikilink obsidian#OpenWikilink()
command! -nargs=0 -buffer ObsidianCreateWikilink obsidian#CreateWikilink()
command! -nargs=0 -buffer ObsidianBacklinks obsidian#GetBacklinks()

nnoremap <buffer> <silent> <Plug>ObsidianOpenWikilink <scriptcmd>ObsidianOpenWikilink<CR>
noremap <buffer> <silent> <Plug>ObsidianCreateWikilink <scriptcmd>ObsidianCreateWikilink<CR>

augroup ObsidianWikilinkCompletion
    autocmd!
    autocmd TextChangedI *.md obsidian#WikilinkCompletion()
augroup END
