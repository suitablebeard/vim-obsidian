# vim-obsidian

A plugin that connects your Obsidian vault with Vim. Lightweight Markdown note-taking with native support for wikilinks, and backlinks.

## Features

- Wikilinks: autocompletion and following them;
- Backlinks:
    - view backlinks for current note;
    - rename current note and update backlinks.

## Usage

> [!warning]
> To use this plugin make sure you are in a markdown file.

For a better experience, set these options in your `.vimrc`:

```vimscript
syntax on                              " for hightlighting wikilinks and tags
filetype plugin indent on              " ensures the plugin loads in .md files
set completeopt+=fuzzy                 " Vim's built-in fuzzy autocompletion
set pumheight=10                       " sets maximum height for autocomplete popup
```

## Commands

| Command                         | Description                                                                                                                 | Default Mapping |
|:--------------------------------|:----------------------------------------------------------------------------------------------------------------------------|:---------------:|
| `:ObsidianFollowWikilink`       | - follows the wikilink under the cursor<br>- following an "unresolved links" creates a new note in `g:obsidian_newfile_dir` |        gd       |
| `:ObsidianSurroundWithBrackets` | surrounds the selected text with [[double brackets]]                                                                        |   \<leader\>os  |
| `:ObsidianNewNote {str}`        | creates note named {str} in the `g:obsidian_newfile_dir`                                                                    |   \<leader\>on  |
| `:ObsidianBacklinks`            | shows all backlinks for the current note                                                                                    |   \<leader\>ob  |
| `:ObsidianRenameNote`           | renames the current note and updates all backlinks                                                                          |   \<leader\>or  |

To change these mappings, see next section.

## Configuration

You can change the following options as you see fit and add them to your `.vimrc`.

| Option                    | Description                                       | Default Value                                  |
| :------------------------ | :---------------------------------------          | :--------------------------------------------  |
| `g:obsidian_vault_dir`    | directory for your vault (full path)              | the current directory (see :pwd)               |
| `g:obsidian_newfile_dir`  | directory where new notes are created (full path) | `g:obsidian_vault_dir`/new_notes               |
| `g:obsidian_mappings`     | dictionary with mappings used                     | (see bellow)                                   |
| `g:obsidian_cache`        | file for caching data                             | `g:obsidian_vault_dir`/.vimobsidian_cache.json |

These are the options for `g:obsidian_mappings` with their default value:

```vimscript
let g:obsidian_mappings = {
    follow_wikilink:     'gd',
    surround_brackets:   '<leader>os',
    new_note:            '<leader>on',
    view_backlinks:      '<leader>ob',
    rename_note:         '<leader>or',
}
```

## Customization

This plugin defines default color mappings for wiki links and tags. If you want to change them to match your favorite color scheme, you can override the highlight groups in your `.vimrc`.

Here are the available highlight groups:

| Highlight Group | Description                          | Default                |
|:----------------|:-------------------------------------|:-----------------------|
| `WikiLinkOpen`  | The opening brackets [[              | linked to `Comment`    |
| `WikiLinkClose` | The closing brackets ]]              | linked to `Comment`    |
| `WikiLinkText`  | The text inside the brackets         | linked to `Statement`  |
| `Tag`           | Hashtags (e.g., #my-tag)             | linked to `Identifier` |
| `PmenuMatch`    | Matched string in autocomplete popup | linked to `Statement`  |

To change it, you can either link it to a different group:

```vimscript
highlight link WikiLinkText Underlined
highlight link Tag Special
```

or define custom colors:

```vimscript
highlight WikiLinkText ctermfg=DarkCyan guifg=#008787
highlight Tag cterm=bold ctermfg=Magenta gui=bold guifg=#ff00ff
```

## Suggested Plugins

We recomend using alongside this plugin:
- [auto-pairs](https://github.com/LunarWatcher/auto-pairs); and
- any fuzzy finder plugin.

## Requirements

- Vim >= 9.0 (plugin is written in vim9script, Vim 9+ required, Neovim not supported);
- [ripgrep](https://github.com/burntsushi/ripgrep)
    - you can discard using ripgrep if you don't want to use `:ObsidianRenameNote` since we use Vim's built-in `find` for everything else.

## Installation

Install using your favorite package manager, or use Vim's built-in package support:

```
 git clone https://github.com/suitablebeard/vim-obsidian ~/.vim/pack/plugins/start/vim-obsidian
```

## License

MPL 2.0
