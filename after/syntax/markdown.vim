" Copied from Vimsidian
" https://github.com/greeschenko/vimsidian
"
" Copyright (c) 2026 Alex Hryshchenko
" Licensed under the MIT License

vim9script

syntax region WikiLink start=/\[\[/ end=/\]\]/ contains=WikiLinkOpen,WikiLinkClose,WikiLinkText keepend

syntax match WikiLinkOpen /\[\[/ contained
syntax match WikiLinkClose /\]\]/ contained
syntax match WikiLinkText /[^[\]]\+/ contained

syntax match Tag /\(^\|\s\)\zs#[a-zA-Z0-9_/-]\+/

highlight default link WikiLinkOpen Comment
highlight default link WikiLinkClose Comment
highlight default link WikiLinkText Statement
highlight default link Tag Identifier

