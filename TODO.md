# TODO

1. Create documentation and help tags
2. Take a look at Ale and CoC for handling autocompletion
3. Serve unresolved links to wikilink autocompletion
    - [ ] make it cache the unresolved links when VimEnter
    - [ ] make it check for unresolved links after BufWritePost but only for the current file
        - [ ] this should also check the current note itself since it might be a note once considered nonexistent
    - [ ] make it asynchronous
4. Add ignored directories
5. Find good color to PmenuMatch (color of the matched text in autocomplete)
6. Make updating backlinks async

# After

1. Change plugin description after implementing tags, backlinks, and outgoing links
    - A plugin that connects your Obsidian vault with Vim. Lightweight Markdown note-taking with native support for wikilinks, tags, and backlinks.

# Maybe

1. Maybe allow opening other filetypes inside wikilinks, though this would require to open them is other apps
2. Feat to generate a table of contents
3. Transition from to use `gf` to open wikilink
    - something like this: <expr> isInWikilink() ? <cmd>FollowWikilink()<CR> : 'gf'
4. Add tags feature
    - (maybe not): auto complete when typing a tag
    - search for tags in file using `gr`: grepping for the tag and add references to quickfix list
5. Make file searching truly fuzzy and update results shown while typing
    - this might not be needed with the since I have the 'completeopt' with the 'fuzzy' option
    - probably with ripgrep
    - take a look at 'completefunc' and 'complete-functions'
    - take a look at the code from:
        - [fuzzbox](https://github.com/vim-fuzzbox/fuzzbox.vim);
        - [minifuzzy](https://github.com/chrispane11/minifuzzy.vim);
        - [vim-haystack](https://github.com/tpope/vim-haystack)
