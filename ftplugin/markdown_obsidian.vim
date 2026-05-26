if !has('vim9script') ||  v:version < 900
    finish
endif

vim9script

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

    # autocmd BufWritePost <buffer> {

    # }

    autocmd TextChangedI *.md obsidian#ObsidianAutocompleter()
augroup END
