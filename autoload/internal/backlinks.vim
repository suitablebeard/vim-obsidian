" Portions of this software are derived from Vimsidian
" https://github.com/greeschenko/vimsidian
"
" Copyright (c) 2026 Alex Hryshchenko
" Licensed under the MIT License

vim9script

export def BacklinksRg(path: string): list<any>
    if empty(path)
        echoerr 'Vim-Obsidian: no note selected'
        return []
    endif

    var filename = fnamemodify(path, ':t:r')
    var escaped = escape(filename, '\.^$~[]')

    var pattern = '\[\[' .. escaped
        .. '(#[^\]|]*)?'
        .. '(\|[^\]]*)?'
        .. '\]\]'

    var cmd = [
        'rg',
        '--vimgrep',
        '--glob',
        '*.md',
        pattern,
        g:obsidian_vault_dir
    ]

    var result = systemlist(cmd)

    if v:shell_error != 0 || empty(result) | return [] | endif

    return result
enddef

export def BacklinksVimgrep(path: string)
    if empty(path)
        echoerr 'Vim-Obsidian: no note selected'
        return
    endif

    var files = globpath(g:obsidian_vault_dir, '**/*.md', 0, 1)
    var files_escaped = map(copy(files), (_, v) => fnameescape(v))
    var files_str = join(files_escaped, ' ')

    var filename = fnamemodify(path, ':t:r')
    var pattern = $'/\V\c[[{filename}\(#\[^]|]\*\)\=\(|\[^]]\*\)\=]]/j'

    try
        execute 'silent! vimgrep ' .. pattern .. ' ' .. files_str

        if len(getqflist()) == 0
            echo 'No backlinks for: ' .. filename
            return
        endif

        copen
    catch
        echo 'No backlinks for: ' .. filename
    endtry
enddef

export def UpdateBacklinks(old_path: string, old_name: string, new_name: string)
    var files: list<any> = BacklinksRg(old_path)->mapnew((_, path) => {
        var endOfPath = path->match(':\d') - 1
        return path[: endOfPath]
    })

    if empty(files)
        echo 'No backlinks to update'
        return
    endif

    var search = '\(\[\[\)'
        .. escape(old_name, '\.^$~[]')
        .. '\(\#[^]|]*\)\?'
        .. '\(|[^]]*\)\?'
        .. '\(\]\]\)'

    var replace = '\1' .. new_name .. '\2\3\4'

    for file in files
        execute 'silent edit ' .. fnameescape(file)

        silent execute(':%s/' .. search .. '/' .. replace .. '/ge')

        update
    endfor

    return
enddef

export def GetUnresolvedLinks(): list<any>
    var notes = systemlist(['rg', '--files', g:obsidian_vault_dir])
        ->mapnew((_, path) => fnamemodify(path, ':t:r'))

    var note_dict = {}
    for note in notes
        note_dict[note] = 1
    endfor

    var all_backlinks = GetAllBacklinksRg()

    var unresolved = {}
    for link in all_backlinks
        if !empty(link) && !has_key(note_dict, link) && !has_key(unresolved, link)
            unresolved[link] = 1
        endif
    endfor

    return keys(unresolved)
enddef

export def GetAllBacklinksRg(): list<string>
    var cmd = [
        'rg',
        '--no-filename',
        '--no-line-number',
        '-o',
        '--glob',
        '*.md',
        '--pcre2',
        '(?<=\[\[)[^\]|#]+',
        g:obsidian_vault_dir
    ]

    var result = systemlist(cmd)

    if v:shell_error != 0 || empty(result) | return [] | endif

    return result
enddef
