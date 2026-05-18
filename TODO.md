# TODO

1. Get a LICENSE
2. Create documentation and help tags
3. Transition from to use `gf` to open wikilink
    - something like this: <expr> isInWikilink() ? <cmd>openWikilink()<CR> : 'gf'
4. Add tags feature
    - (maybe not): auto complete when typing a tag
    - search for tags in file using `gr`: grepping for the tag and add references to quickfix list
5. Take a look at Ale and CoC for handling autocompletion
6. Feat to rename files and update all wikilinks

# After

1. Change plugin description after implementing tags, backlinks, and outgoing links
    - A plugin that connects your Obsidian vault with Vim. Lightweight Markdown note-taking with native support for wikilinks, tags, and backlinks.

# Maybe

1. Maybe allow opening other filetypes inside wikilinks, though this would require to open them is other apps
3. Feat to generate a table of contents
4. Make file searching truly fuzzy and update results shown while typing
    - this might not be needed with the since I have the 'completeopt' with the 'fuzzy' option
    - probably with ripgrep
    - take a look at 'completefunc' and 'complete-functions'
    - take a look at the code from:
        - [fuzzbox](https://github.com/vim-fuzzbox/fuzzbox.vim);
        - [minifuzzy](https://github.com/chrispane11/minifuzzy.vim);
        - [vim-haystack](https://github.com/tpope/vim-haystack)
