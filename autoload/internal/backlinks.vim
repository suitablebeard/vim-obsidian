" Portions of this software are derived from Vimsidian
" https://github.com/greeschenko/vimsidian
"
" Copyright (c) 2026 Alex Hryshchenko
" Licensed under the MIT License

vim9script

export def BacklinksRg(
    mode: string,
    search_path: string,
    file_path: string,
    opts = { only_matched: false  }
): list<list<string>>
    var mode_pattern = {
        generic: '[^\]|#]+',
        specific_note: GetFilenameRegexPattern(file_path)
    }

    var pattern = '(?<=\[\[)' .. mode_pattern[mode]
        .. '(#[^\]|]*)?'
        .. '(\|[^\]]*)?'
        .. '(?=\]\])'

    var cmd = [
        'rg',
        '--vimgrep',
        '--glob',
        '*.md',
        '--pcre2',
        pattern,
        search_path 
    ]

    if opts.only_matched
        add(cmd, '-o')
    endif

    var output = systemlist(cmd)

    if v:shell_error != 0 || empty(output) |  return [] | endif

    return ProcessOutputRg(output)
enddef

def GetFilenameRegexPattern(path: string): string
    var filename = fnamemodify(path, ':t:r')
    var escaped = escape(filename, '\.^$~[]')

    return escaped
enddef

def ProcessOutputRg(output: list<string>): list<list<string>>
    var result = output->mapnew((_, line) => {
        var p = '\([^:]*\)'
            .. ':\(\d\+\)'
            .. ':\(\d\+\)'
            .. ':\(.\{-}'
            .. '\[\['
            .. '\([^#|\]]*\)'
            .. '\(#[^|\]]*\)\='
            .. '\(|[^\]]*\)\='
            .. '\]\]'
            .. '.\{-}\)'

        var parsed_line = line->matchlist(p)

        var whole_line = parsed_line[0]
        var filename = fnamemodify(parsed_line[1], ':t:r')
        var line_num = parsed_line[2]
        var column_num = parsed_line[3]
        var result_line = parsed_line[4]
        var link = parsed_line[5]
        var header_link = parsed_line[6]->substitute('^#', '', '')
        var alias = parsed_line[7]->substitute('^|', '', '')
       
        return [
            whole_line,
            filename,
            line_num,
            column_num,
            result_line,
            link,
            header_link,
            alias
        ]
    })

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

