# vim-obsidian

A plugin that connects your Obsidian vault with Vim. Lightweight Markdown note-taking with support for wikilinks.

## Usage

> [!warning]
> To use this plugin make sure you are in a markdown file.

### Creating a `[[wikilink]]`

There are three ways to create a wikilink:

1. surrounding text with double brackets with the command `:ObsidianCreateWikilink` or with a mapping;
2. typing `[[` and linking to an existing note in your vault from a completion menu;
3. typing the wikilink verbatim.

Regarding the completion menu, it is recommended to turn on Vim's built-in fuzzy autocompletion for a better experience with:

```vimscript
set completeopt+=fuzzy
```

### Opening a `[[wikilink]]`

To open a wikilink under your cursor, you can use either the command `:ObsidianOpenWikilink` or a mapping.

If, however, the wikilink your trying to open is an "unresolved link", a new markdown file will be created in a subdirectory in your vault.

## Requirements

- Vim >= 9.0 (plugin is written in vim9script, Vim 9+ required, Neovim not supported);
- No other dependancies needed since the plugin uses Vim's built-in `find`.

## Configuration

You can change the following options as you see fit and add them to your `.vimrc`.

```vimscript
" directory where this plugin searches for files. Default: '.' (the current directory, See :pwd)
let g:obsidian_vault_dir = '/vault/dir/'

" directory where new files are created. Default: '{vault_dir}/new_notes'
" NOTE: this needs to be the full path
let g:obsidian_newfile_dir = '/new_notes/dir/'

" mapping to open wikilink under the cursor. Default: gd
nmap <your_keys> <Plug>ObsidianOpenWikilink

" mapping to surround selected text with double brackets. Default: [[
vmap <your_keys> <Plug>ObsidianCreateWikilink
```

## Installation

Install using your favorite package manager, or use Vim's built-in package support:

```
 git clone https://github.com/suitablebeard/vim-obsidian ~/.vim/pack/plugins/start/vim-obsidian
```

## License

MPL 2.0
