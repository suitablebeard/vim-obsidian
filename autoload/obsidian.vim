vim9script

import autoload 'internal/tags.vim'
import autoload 'internal/backlinks.vim'

export def ObsidianAutocompleter()
    var line_text = getline('.')
    var cursor_col = col('.') - 1
    var text_before_cursor = line_text->strpart(0, cursor_col)

    if text_before_cursor =~ '\[\[$'
        WikilinkCompletion(cursor_col)
        return
    endif

    if text_before_cursor =~ '#$'
        TagCompletion(cursor_col)
        return
    endif
enddef

def WikilinkCompletion(cursor_col: number)
    # searches files using Vim's built-in 'find'
    var files = globpath(g:obsidian_vault_dir, '**/*', 0, 1)
        ->filter((_, path) => !isdirectory(path))
    var completion_items = files->mapnew((_, file) => CreateFileCompletionItem(file))

    if !empty(completion_items)
        complete(cursor_col + 1, completion_items)
    endif
enddef

def CreateFileCompletionItem(file: string): dict<string>
    var filename: string = fnamemodify(file, ':t:r')
    var fileextension: string = fnamemodify(file, ':e')
    fileextension = fileextension != '' ? $'.{fileextension}' : ''
    var parentDir: string = fnamemodify(file, ':h:t')
    parentDir = (parentDir == '.' || parentDir == '') ? fnamemodify(getcwd(), ':t') : parentDir

    var display_text: string = $"{parentDir}/{filename}{fileextension}"

    var item: dict<string> = {
        word: filename,
        abbr: $"{display_text}",
    }

    return item
enddef

def TagCompletion(cursor_col: number)
    # Get all tags
    var all_tags = tags.GetAllTags()
    # Send tags to autocomplete
enddef

export def CreateWikilink(): void
    # This function was written by Gemini
    var save_z = getreg('z')
    var save_z_type = getregtype('z')
    execute 'normal! "zy'
    var content = getreg('z')
    setreg('z', $"[[{content}]]")
    execute 'normal! gv"zp'
    setreg('z', save_z, save_z_type)
enddef

export def OpenWikilink(): void
    var currentLine = getline('.')
    var cursorPos = col('.') - 1
    var wikilink: string = GetWikilinkUnderCursor(currentLine, cursorPos)
    if wikilink ==# ''
        echom 'Your cursor must be inside a wikilink to open the file.'
        return
    endif

    var [_, filename, headerLink,_, displayText] = ParseWikilink(wikilink)
    var files = globpath(g:obsidian_vault_dir, $'**/{fnameescape(filename)}', 0, 1)
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

    OpenNewNote(filename)
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

export def OpenNewNote(filename: string): void
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

export def GetBacklinks()
    var path: string = expand('%:p')

    if executable('rg')
        backlinks.BacklinksRg(path)
        return
    endif

    backlinks.BacklinksVimgrep(path)
enddef
