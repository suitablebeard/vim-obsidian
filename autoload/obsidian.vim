vim9script

import autoload 'internal/tags.vim'
import autoload 'internal/backlinks.vim'
import autoload 'internal/mappings.vim'

export def Setup()
    mappings.SetupMappings()
enddef

export def ObsidianAutocompleter()
    var line_text = getline('.')
    var cursor_col = col('.') - 1
    var text_before_cursor = line_text->strpart(0, cursor_col)

    if text_before_cursor =~ '\[\[$'
        WikilinkCompletion(cursor_col)
        return
    endif

    if text_before_cursor =~ '\(^\|\s\)#$'
        TagCompletion(cursor_col)
        return
    endif
enddef

def WikilinkCompletion(cursor_col: number)
    # searches files using Vim's built-in 'find'
    var files = globpath(g:obsidian_vault_dir, '**/*', 0, 1)
        ->filter((_, path) => !isdirectory(path))
    var unresolved_links = backlinks.GetUnresolvedLinks()

    var file_items = files->mapnew((_, file) => CreateFileCompletionItem(file))
    var link_items = unresolved_links->mapnew((_, link) => CreateLinkCompletionItem(link))
    var completion_items = extendnew(file_items, link_items)

    if !empty(completion_items)
        complete(cursor_col + 1, completion_items)
    endif
enddef

def CreateFileCompletionItem(file: string): dict<string>
    var filename: string = fnamemodify(file, ':t:r')

    var fileextension: string = fnamemodify(file, ':e')
    var hasNoExtension = fileextension == ''
    var isMdFile = fileextension == 'md'
    fileextension = (hasNoExtension || isMdFile) ? '' : $'.{fileextension}'

    var display_text: string = $"{filename}{fileextension}"

    var parentDir: string = fnamemodify(file, ':h:t')
    parentDir = (parentDir == '.' || parentDir == '') ? fnamemodify(getcwd(), ':t') : parentDir

    var item: dict<string> = {
        word: filename,
        abbr: display_text,
        menu: parentDir,
    }

    return item
enddef

def CreateLinkCompletionItem(link: string): dict<string>
    return { word: link, menu: '[UNRESOLVED]'}
enddef

def TagCompletion(cursor_col: number)
    # 1. Get all tags
    var all_tags = tags.GetAllTags()

    # 2. Send tags to autocomplete
    return
enddef

export def SurroundWithBrackets(): void
    # This function was written by Gemini
    var save_z = getreg('z')
    var save_z_type = getregtype('z')
    execute 'normal! "zy'
    var content = getreg('z')
    setreg('z', $"[[{content}]]")
    execute 'normal! gv"zp'
    setreg('z', save_z, save_z_type)
enddef

export def FollowWikilink(): void
    var currentLine = getline('.')
    var cursorPos = col('.') - 1
    var wikilink: string = GetWikilinkUnderCursor(currentLine, cursorPos)
    if wikilink ==# ''
        echom 'Your cursor must be inside a wikilink to open the file.'
        return
    endif

    var [_, filename, headerLink,_, displayText] = ParseWikilink(wikilink)
    var files = globpath(g:obsidian_vault_dir, $'**/{fnameescape(filename)}.md', 0, 1)
        ->filter((_, path) => !isdirectory(path))

    var numOfFiles = len(files)
    if numOfFiles >= 2
        var qfItems = files->map((_, filePath) => ({
            filename: fnamemodify(filePath, ':p:~'),
            text: fnamemodify(filePath, ':t'),
            lnum: 1,
            col: 1
        }))

        setqflist([], 'r', { items: qfItems })
        copen
        return
    endif

    var singleFileMatchesFilename: bool = !empty(files) && fnamemodify(files[0], ':t:r') ==# filename
    if numOfFiles == 1 && singleFileMatchesFilename
        execute $'edit {files[0]}'
        return
    endif

    CreateNewNote(filename)
    return
enddef

export def GetWikilinkUnderCursor(str: string, cursorPos: number): string
    if strchars(getline('.')) == 0 | return '' | endif

    var cursorChar = str[cursorPos]
    var openBracketsIndex: number
    var closeBracketsIndex: number

    # Searches backwards for '[[' from the cursor
    var backwardsStartPos = (cursorChar ==# ']') ? cursorPos - 2 : cursorPos
    for i in range(backwardsStartPos, 0, -1)
        var char: string = str[i]
        if char !~# '\[\|\]' | continue | endif
        if char ==# ']' | return '' | endif

        var doubleBrackets = GetDoubleBrackets(char, str, i)
        openBracketsIndex = doubleBrackets != -1 ? doubleBrackets : -1
        if openBracketsIndex != -1 | break | endif
    endfor

    # Searches forwards for ']]' from the cursor
    var forwardStarPos = (openBracketsIndex != -1 && cursorChar !=# ']') ? cursorPos + 2 : cursorPos
    for i in range(forwardStarPos, strchars(str) - 1, 1)
        var char: string = str[i]
        if char !~# '\[\|\]' | continue | endif
        if char ==# '[' | return '' | endif

        var doubleBrackets = GetDoubleBrackets(char, str, i)
        closeBracketsIndex = doubleBrackets != -1 ? doubleBrackets : -1
        if closeBracketsIndex != -1 | break | endif
    endfor

    var wikilink = (openBracketsIndex >= 0 && closeBracketsIndex > 0) ? str[openBracketsIndex : closeBracketsIndex + 1] : ''

    return wikilink
enddef

def GetDoubleBrackets(bracket: string, str: string, position: number): number
    var nextBracket = str[position + 1] ==# bracket
    var previousBracket = str[position - 1] ==# bracket
    var result: number = nextBracket ? position : previousBracket ? position - 1 : -1
    return result
enddef

def ParseWikilink(wikilink: string): list<string>
    return wikilink->matchlist('\v\[\[([^#|]+)(#[^|]+)?(\|([^\]]+))?\]\]')[0 : 4]
enddef

export def CreateNewNote(filename: string): void
    if !isdirectory(g:obsidian_newfile_dir)
        mkdir(g:obsidian_newfile_dir, 'p', 0o700)
    endif

    var parsedFilename = filename
        ->substitute('\.md$', '', '')
        ->fnameescape()

    var filePath: string = $'{g:obsidian_newfile_dir}/{parsedFilename}.md'
    execute $'edit {simplify(filePath)}'
    return
enddef

export def ViewBacklinks()
    var path: string = expand('%:p')
    var filename = fnamemodify(path, ':t:r')

    if !executable('rg')
        backlinks.BacklinksVimgrep(path)
        return
    endif

    var files: list<any> = backlinks.BacklinksRg(path)
    if empty(files)
        echo 'No backlinks for: ' .. filename
        return
    endif

    setqflist([], 'r', {
        title: 'Backlinks: ' .. filename,
        lines: files,
        efm: '%f:%l:%c:%m'
    })

    copen

    return
enddef

export def RenameNote()
    if !executable('rg')
        echoerr 'Renaming: you need ripgrep for this'
        return
    endif

    var old_path = expand('%:p')
    if empty(old_path)
        echoerr 'Vim-Obsidian: no note selected'
        return
    endif

    var old_name = fnamemodify(old_path, ':t:r')
    var new_name = input('New note name: ', old_name)

    if empty(new_name) || new_name == old_name
        echom 'You need to provide a new name'
        return
    endif

    var parent_dir = fnamemodify(old_path, ':h')
    var new_path = $'{parent_dir}/{new_name}.md'
    rename(old_path, new_path)

    execute 'file ' .. fnameescape(new_path)

    backlinks.UpdateBacklinks(old_path, old_name, new_name)

    execute 'silent edit ' .. fnameescape(new_path)

    echo $'Renamed "{old_name}" -> "{new_name}"'

    return
enddef
