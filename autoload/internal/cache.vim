" Portions of this software are derived from Vimsidian
" https://github.com/greeschenko/vimsidian
"
" Copyright (c) 2026 Alex Hryshchenko
" Licensed under the MIT License

vim9script

var is_cache_initialized = false

export def CreateCache()
    if is_cache_initialized | return | endif
    is_cache_initialized = true

    echom 'Caching your notes...'

    CacheBacklinks()

    echom 'Cache created!'
enddef

export def CacheBacklinks()
    var [ existing_notes, note_links, unresolved_links ] = ScanVaultBacklinks()
    var cache = {
        note_links: note_links,
        unresolved_links: unresolved_links
    }

    var cache_path = g:obsidian_cache
    if !filereadable(cache_path)
        var dir = fnamemodify(cache_path, ':h')
        if !isdirectory(dir)
            mkdir(dir, 'p')
        endif
    endif

    writefile([json_encode(cache)], cache_path)

    return
enddef

export def ScanVaultBacklinks(): list<dict<any>>
    var existing_notes: dict<number> =  {}
    var unresolved_links = {}

    var [ all_links, note_links ] = GetAllBacklinksRg(g:obsidian_vault_dir)

    var notes = GetAllNotes(g:obsidian_vault_dir)
    for note in notes
        var filename = fnamemodify(note, ':r')
        existing_notes[filename] = 1
    endfor

    for link in keys(all_links)
        var is_resolved = has_key(existing_notes, link)
        var is_added = has_key(unresolved_links, link)
        if !empty(link) && !is_resolved && !is_added
            unresolved_links[link] = all_links[link]
        endif
    endfor

    return [ existing_notes, note_links, unresolved_links ]
enddef

export def GetAllBacklinksRg(path: string): list<dict<any>>
    var all_links = {}
    var note_links = {}

    var cmd = [
        'rg',
        '--vimgrep',
        '-o',
        '--glob',
        '*.md',
        '--pcre2',
        '(?<=\[\[)[^\]|#]+',
        path
    ]

    var output = systemlist(cmd)

    if v:shell_error != 0 || empty(output) | return [] | endif

    for match in output
        var [_, file, _, _, link; _] = match
            ->matchlist('\([^:]*\):\(\d\+\):\(\d\+\):\(.\+\)')
        var filename = fnamemodify(file, ':t:r')

        if !has_key(note_links, filename)
            note_links[filename] = []
        endif
        add(note_links[filename], link) # { 'Questions...': [ 'Networking' ], ... }
        note_links[filename] = copy(note_links[filename])->uniq()

        var link_added = has_key(all_links, link)
        all_links[link] = (link_added) ? all_links[link] + 1 : 1
    endfor

    return [ all_links, note_links ]
enddef

def GetAllNotes(path: string): list<string>
    return systemlist(['rg', '--files', '--glob', '*.md', path])
        ->mapnew((_, file) => fnamemodify(file, ':t:r'))
enddef

export def GetCache(): dict<any>
    var cache_path = g:obsidian_cache

    if !filereadable(cache_path) | return {} | endif

    try
        var content = readfile(cache_path)
        if empty(content) | return {} | endif

        var backlinks_data = json_decode(content[0])

        return json_decode(backlinks_data)
    catch
        return {}
    endtry
enddef

export def UpdateCache()
    # This happens after writing to the file
    # 1. Check if current was nonexistent and considered an unresolved link
    # 2. Scan all wikilinks in the file
    return
enddef

defcompile
