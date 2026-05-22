if !has('vim9script') ||  v:version < 900
    finish
endif

vim9script

if exists('b:did_ftplugin_obsidian')
    finish
endif
b:did_ftplugin_obsidian = 1

import autoload '../autoload/obsidian.vim'

if !hasmapto('<Plug>ObsidianOpenWikilink')
    nmap <unique> <buffer> gd <Plug>ObsidianOpenWikilink
endif

if !hasmapto('<Plug>ObsidianSurrondWithBrackets')
    vmap <unique> <buffer> <leader>os <Plug>ObsidianSurrondWithBrackets
endif
endif

command! -nargs=0 -buffer ObsidianOpenWikilink obsidian#OpenWikilink()
command! -nargs=0 -buffer ObsidianSurrondWithBrackets obsidian#SurrondWithBrackets()
command! -nargs=0 -buffer ObsidianBacklinks obsidian#GetBacklinks()
command! -nargs=0 -buffer ObsidianRenameNote obsidian#RenameNote()

nnoremap <buffer> <silent> <Plug>ObsidianOpenWikilink <scriptcmd>ObsidianOpenWikilink<CR>
noremap <buffer> <silent> <Plug>ObsidianSurrondWithBrackets <scriptcmd>ObsidianSurrondWithBrackets<CR>

augroup ObsidianWikilinkCompletion
    autocmd!
    autocmd TextChangedI *.md obsidian#ObsidianAutocompleter()
augroup END
