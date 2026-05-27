if !has('vim9script') ||  v:version < 900
    finish
endif

vim9script

var current_file_path = expand('%:p')
var parsed_vault_path = escape(g:obsidian_vault_dir, '\^$.*~[]')
if current_file_path !~# $'^{parsed_vault_path}' 
    finish
endif

if exists('b:did_ftplugin_obsidian')
    finish
endif
b:did_ftplugin_obsidian = 1

import autoload '../autoload/obsidian.vim'

# Commands available only in markdown files
command! -nargs=0 -buffer ObsidianFollowWikilink obsidian#FollowWikilink()
command! -nargs=0 -buffer ObsidianSurroundWithBrackets obsidian#SurroundWithBrackets()
command! -nargs=0 -buffer ObsidianBacklinks obsidian#ViewBacklinks()
command! -nargs=0 -buffer ObsidianRenameNote obsidian#RenameNote()

augroup ObsidianWikilinkFtpluginSetup
    autocmd!
    autocmd VimEnter,BufEnter <buffer> obsidian#LoadCache()
    autocmd BufWritePost <buffer> obsidian#UpdateCache()
    autocmd TextChangedI <buffer> obsidian#ObsidianAutocompleter()
augroup END
