vim9script

import autoload '../obsidian.vim'

const default_mappings = {
    follow_wikilink: 'gd',
    create_note: '<leader>on',
    surround_brackets: '<leader>os',
    view_backlinks: '<leader>ob',
    rename_note: '<leader>or',
}

def GetMappings(): dict<string>
    return extendnew(default_mappings, g:obsidian_mappings)
enddef

export def SetupMappings()
    var mappings = GetMappings()

    if !empty(mappings.view_backlinks)
        execute 'nnoremap <silent> '
            .. mappings.view_backlinks
            .. ' <scriptcmd>obsidian#ViewBacklinks()<CR>'
    endif

    if !empty(mappings.create_note)
        execute 'nnoremap '
            .. mappings.create_note
            .. ' :ObsidianNewNote '
    endif

    if !empty(mappings.surround_brackets)
        execute 'vnoremap <silent> '
            .. mappings.surround_brackets
            .. ' <scriptcmd>obsidian#SurroundWithBrackets()<CR>'
    endif

    if !empty(mappings.rename_note)
        execute 'nnoremap <silent> '
            .. mappings.rename_note
            .. ' <scriptcmd>obsidian#RenameNote()<CR>'
    endif

    if !empty(mappings.follow_wikilink)
        execute 'nnoremap <silent> '
            .. mappings.follow_wikilink
            .. ' <scriptcmd>obsidian#FollowWikilink()<CR>'
    endif
enddef

