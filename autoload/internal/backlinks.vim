" Portions of this software are derived from Vimsidian
" https://github.com/greeschenko/vimsidian
"
" Copyright (c) 2026 Alex Hryshchenko
" Licensed under the MIT License

vim9script

export def BacklinksRg(path: string)
    if empty(path)
        echoerr 'Vim-Obsidian: no note selected'
        return
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
        '--smart-case',
        pattern,
        g:obsidian_vault_dir
    ]

    var result = systemlist(cmd)

    if v:shell_error != 0 || empty(result)
        echo 'No backlinks for: ' .. filename
        return
    endif

    setqflist([], 'r', {
        title: 'Backlinks: ' .. filename,
        lines: result,
        efm: '%f:%l:%c:%m'
    })

    copen
enddef

export def BacklinksVimgrep(path: string)
    if empty(path)
        echoerr 'Vim-Obsidian: no note selected'
        return
    endif

    var filename = fnamemodify(path, ':t:r')

    var pattern = $'/\V\c[[{filename}\(#\[^]|]\*\)\=\(|\[^]]\*\)\=]]/j'

    var files = globpath(g:obsidian_vault_dir, '**/*.md', 0, 1)
    var files_escaped = map(copy(files), (_, v) => fnameescape(v))
    var files_str = join(files_escaped, ' ')

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

