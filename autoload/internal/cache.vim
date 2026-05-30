" Portions of this software are derived from Vimsidian
" https://github.com/greeschenko/vimsidian
"
" Copyright (c) 2026 Alex Hryshchenko
" Licensed under the MIT License

vim9script

import autoload 'internal/backlinks.vim'

var is_cache_initialized = false

export def CreateCache()
    if is_cache_initialized | return | endif
    is_cache_initialized = true

    echom 'Caching your notes...'

    CacheBacklinks()

    echom 'Cache created!'

    return
enddef

def SaveCacheFile(cache: dict<any>)
    var cache_path = g:obsidian_cache
    if !filereadable(cache_path)
        var dir = fnamemodify(cache_path, ':h')
        if !isdirectory(dir)
            mkdir(dir, 'p')
        endif
    endif

    writefile([json_encode(cache)], cache_path)
enddef

export def GetCache(): dict<any>
    var cache_path = g:obsidian_cache

    if !filereadable(cache_path) | return {} | endif

    try
        var content = readfile(cache_path)
        if empty(content) | return {} | endif

        var backlinks_data = json_decode(content[0])

        return backlinks_data
    catch
        return {}
    endtry
enddef

export def UpdateCache()
    var cache = GetCache()
    var current_note_path = expand('%:p')
    var current_note = expand('%:t:r')

    if !has_key(cache['existing_notes'], current_note)
        cache['existing_notes'][current_note] = true

        if has_key(cache['unresolved_links'], current_note)
            remove(cache['unresolved_links'], current_note)
        endif
    endif

    var cur_links_data = backlinks.BacklinksRg('generic', current_note_path, '')
    var current_links = cur_links_data->mapnew((_, data) => data[5])->uniq()

    var cached_links = cache['note_links']->get(current_note, [])

    var [ removed_links, added_links ] = CompareCachedAndLocalLinks(
        current_links, cached_links
    )

    if !empty(removed_links) || !empty(added_links)
        for link in added_links
            if has_key(cache['existing_notes'], link)
                continue
            endif

            var link_added = has_key(cache['unresolved_links'], link)
            cache['unresolved_links'][link] = (link_added)
                ? cache['unresolved_links'][link] + 1
                : 1
        endfor

        for link in removed_links
            if has_key(cache['unresolved_links'], link)
                cache['unresolved_links'][link] -= 1

                if cache['unresolved_links'][link] == 0
                    remove(cache['unresolved_links'], link)
                endif
            endif
        endfor

        cache['note_links'][current_note] = current_links
    endif


    SaveCacheFile(cache)

    return
enddef

export def CacheBacklinks()
    var [ existing_notes, note_links, unresolved_links ] = ScanVaultBacklinks()
    var cache = {
        existing_notes: existing_notes,
        note_links: note_links,
        unresolved_links: unresolved_links
    }

    SaveCacheFile(cache)

    return
enddef

export def ScanVaultBacklinks(): list<dict<any>>
    var existing_notes: dict<bool> =  {}
    var unresolved_links: dict<number> = {}

    var [ all_links, note_links ] = GetAllBacklinksRg(g:obsidian_vault_dir)

    var notes = GetAllNotes(g:obsidian_vault_dir)
    for note in notes
        var filename = fnamemodify(note, ':r')
        existing_notes[filename] = true
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
        '(?<=\[\[)[^\]|#]+(?=[^\]]*\]\])',
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


def CompareCachedAndLocalLinks(
    current_links: list<string>,
    cached_links: list<string>
): any
    var current_dict = {}
    for link in current_links
        current_dict[link] = true
    endfor

    var cached_dict = {}
    for link in cached_links
        cached_dict[link] = true
    endfor

    var removed_links = []
    for link in cached_links
        if !has_key(current_dict, link)
            add(removed_links, link)
        endif
    endfor

    var added_links = []
    for link in current_links
        if !has_key(cached_dict, link)
            add(added_links, link)
        endif
    endfor

    return [ removed_links, added_links ]
enddef

defcompile
