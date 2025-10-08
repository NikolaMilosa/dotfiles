" Name:         wallbash
" Description:  wallbash template
" Author:       The HyDE Project
" License:      Same as Vim
" Last Change:  April 2025

if exists('g:loaded_wallbash') | finish | endif
let g:loaded_wallbash = 1


" Detect background based on terminal colors
if $BACKGROUND =~# 'light'
  set background=light
else
  set background=dark
endif

" hi clear
let g:colors_name = 'wallbash'

let s:t_Co = &t_Co

" Terminal color setup
if (has('termguicolors') && &termguicolors) || has('gui_running')
  let s:is_dark = &background == 'dark'

  " Define terminal colors based on the background
  if s:is_dark
    let g:terminal_ansi_colors = ['0D2322', '7AA365', '7AC2BF', '7AC291',
                                \ '65A394', '9AE6B2', '9AE6E2', 'FFFFFF',
                                \ '265247', '92C27A', '9AE6E2', 'AAF0C1',
                                \ '7AC2B0', 'AAF0C1', 'AAF0ED', 'FFFFFF']
  else
    " Lighter colors for light theme
    let g:terminal_ansi_colors = ['FFFFFF', 'B3E69A', 'AAF0ED', 'AAF0C1',
                                \ '9AE6D3', 'CCFFDC', 'CCFFFD', '5A7964',
                                \ 'FFFFFF', 'C1F0AA', 'CCFFFD', 'CCFFDC',
                                \ 'AAF0DE', 'CCFFDC', 'CCFFFD', '0D2322']
  endif

  " Nvim uses g:terminal_color_{0-15} instead
  for i in range(g:terminal_ansi_colors->len())
    let g:terminal_color_{i} = g:terminal_ansi_colors[i]
  endfor
endif

      " For Neovim compatibility
      if has('nvim')
        " Set Neovim specific terminal colors
        let g:terminal_color_0 = '#' . g:terminal_ansi_colors[0]
        let g:terminal_color_1 = '#' . g:terminal_ansi_colors[1]
        let g:terminal_color_2 = '#' . g:terminal_ansi_colors[2]
        let g:terminal_color_3 = '#' . g:terminal_ansi_colors[3]
        let g:terminal_color_4 = '#' . g:terminal_ansi_colors[4]
        let g:terminal_color_5 = '#' . g:terminal_ansi_colors[5]
        let g:terminal_color_6 = '#' . g:terminal_ansi_colors[6]
        let g:terminal_color_7 = '#' . g:terminal_ansi_colors[7]
        let g:terminal_color_8 = '#' . g:terminal_ansi_colors[8]
        let g:terminal_color_9 = '#' . g:terminal_ansi_colors[9]
        let g:terminal_color_10 = '#' . g:terminal_ansi_colors[10]
        let g:terminal_color_11 = '#' . g:terminal_ansi_colors[11]
        let g:terminal_color_12 = '#' . g:terminal_ansi_colors[12]
        let g:terminal_color_13 = '#' . g:terminal_ansi_colors[13]
        let g:terminal_color_14 = '#' . g:terminal_ansi_colors[14]
        let g:terminal_color_15 = '#' . g:terminal_ansi_colors[15]
      endif

" Function to dynamically invert colors for UI elements
function! s:inverse_color(color)
  " This function takes a hex color (without #) and returns its inverse
  " Convert hex to decimal values
  let r = str2nr(a:color[0:1], 16)
  let g = str2nr(a:color[2:3], 16)
  let b = str2nr(a:color[4:5], 16)

  " Calculate inverse (255 - value)
  let r_inv = 255 - r
  let g_inv = 255 - g
  let b_inv = 255 - b

  " Convert back to hex
  return printf('%02x%02x%02x', r_inv, g_inv, b_inv)
endfunction

" Function to be called for selection background
function! InverseSelectionBg()
  if &background == 'dark'
    return 'CCFFFD'
  else
    return '295247'
  endif
endfunction

" Add high-contrast dynamic selection highlighting using the inverse color function
augroup WallbashDynamicHighlight
  autocmd!
  " Update selection highlight when wallbash colors change
  autocmd ColorScheme wallbash call s:update_dynamic_highlights()
augroup END

function! s:update_dynamic_highlights()
  let l:bg_color = synIDattr(synIDtrans(hlID('Normal')), 'bg#')
  if l:bg_color != ''
    let l:bg_color = l:bg_color[1:] " Remove # from hex color
    let l:inverse = s:inverse_color(l:bg_color)

    " Apply inverse color to selection highlights
    execute 'highlight! CursorSelection guifg=' . l:bg_color . ' guibg=#' . l:inverse

    " Link dynamic highlights to various selection groups
    highlight! link NeoTreeCursorLine CursorSelection
    highlight! link TelescopeSelection CursorSelection
    highlight! link CmpItemSelected CursorSelection
    highlight! link PmenuSel CursorSelection
    highlight! link WinSeparator VertSplit
  endif
endfunction

" Make selection visible right away for current colorscheme
call s:update_dynamic_highlights()

" Conditional highlighting based on background
if &background == 'dark'
  " Base UI elements with transparent backgrounds
  hi Normal guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi Pmenu guibg=#5A7964 guifg=#FFFFFF gui=NONE cterm=NONE
  hi StatusLine guifg=#FFFFFF guibg=#5A7964 gui=NONE cterm=NONE
  hi StatusLineNC guifg=#FFFFFF guibg=#265247 gui=NONE cterm=NONE
  hi VertSplit guifg=#65A3A0 guibg=NONE gui=NONE cterm=NONE
  hi LineNr guifg=#65A3A0 guibg=NONE gui=NONE cterm=NONE
  hi SignColumn guifg=NONE guibg=NONE gui=NONE cterm=NONE
  hi FoldColumn guifg=#FFFFFF guibg=NONE gui=NONE cterm=NONE

  " NeoTree with transparent background including unfocused state
  hi NeoTreeNormal guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi NeoTreeEndOfBuffer guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi NeoTreeFloatNormal guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi NeoTreeFloatBorder guifg=#65A3A0 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeWinSeparator guifg=#265247 guibg=NONE gui=NONE cterm=NONE

  " NeoTree with transparent background
  hi NeoTreeNormal guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi NeoTreeEndOfBuffer guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi NeoTreeRootName guifg=#CCFFFD guibg=NONE gui=bold cterm=bold

  " TabLine highlighting with complementary accents
  hi TabLine guifg=#FFFFFF guibg=#5A7964 gui=NONE cterm=NONE
  hi TabLineFill guifg=NONE guibg=NONE gui=NONE cterm=NONE
  hi TabLineSel guifg=#0D2322 guibg=#CCFFFD gui=bold cterm=bold
  hi TabLineSeparator guifg=#65A3A0 guibg=#5A7964 gui=NONE cterm=NONE

  " Interactive elements with dynamic contrast
  hi Search guifg=#265247 guibg=#AAF0ED gui=NONE cterm=NONE
  hi Visual guifg=#265247 guibg=#9AE6E2 gui=NONE cterm=NONE
  hi MatchParen guifg=#265247 guibg=#CCFFFD gui=bold cterm=bold

  " Menu item hover highlight
  hi CmpItemAbbrMatch guifg=#CCFFFD guibg=NONE gui=bold cterm=bold
  hi CmpItemAbbrMatchFuzzy guifg=#AAF0ED guibg=NONE gui=bold cterm=bold
  hi CmpItemMenu guifg=#FFFFFF guibg=NONE gui=italic cterm=italic
  hi CmpItemAbbr guifg=#FFFFFF guibg=NONE gui=NONE cterm=NONE
  hi CmpItemAbbrDeprecated guifg=#FFFFFF guibg=NONE gui=strikethrough cterm=strikethrough

  " Specific menu highlight groups
  hi WhichKey guifg=#CCFFFD guibg=NONE gui=NONE cterm=NONE
  hi WhichKeySeparator guifg=#FFFFFF guibg=NONE gui=NONE cterm=NONE
  hi WhichKeyGroup guifg=#9AE6E2 guibg=NONE gui=NONE cterm=NONE
  hi WhichKeyDesc guifg=#AAF0ED guibg=NONE gui=NONE cterm=NONE
  hi WhichKeyFloat guibg=#265247 guifg=NONE gui=NONE cterm=NONE

  " Selection and hover highlights with inverted colors
  hi CursorColumn guifg=NONE guibg=#5A7964 gui=NONE cterm=NONE
  hi Cursor guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi lCursor guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi CursorIM guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi TermCursor guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi TermCursorNC guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi CursorLine guibg=NONE ctermbg=NONE gui=underline cterm=underline
  hi CursorLineNr guifg=#CCFFFD guibg=NONE gui=bold cterm=bold

  hi QuickFixLine guifg=#265247 guibg=#9AE6E2 gui=NONE cterm=NONE
  hi IncSearch guifg=#265247 guibg=#CCFFFD gui=NONE cterm=NONE
  hi NormalNC guibg=#265247 guifg=#FFFFFF gui=NONE cterm=NONE
  hi Directory guifg=#AAF0ED guibg=NONE gui=NONE cterm=NONE
  hi WildMenu guifg=#265247 guibg=#CCFFFD gui=bold cterm=bold

  " Add highlight groups for focused items with inverted colors
  hi CursorLineFold guifg=#CCFFFD guibg=#265247 gui=NONE cterm=NONE
  hi FoldColumn guifg=#FFFFFF guibg=NONE gui=NONE cterm=NONE
  hi Folded guifg=#FFFFFF guibg=#5A7964 gui=italic cterm=italic

  " File explorer specific highlights
  hi NeoTreeNormal guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi NeoTreeEndOfBuffer guibg=NONE guifg=#FFFFFF gui=NONE cterm=NONE
  hi NeoTreeRootName guifg=#CCFFFD guibg=NONE gui=bold cterm=bold
  hi NeoTreeFileName guifg=#FFFFFF guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeFileIcon guifg=#AAF0ED guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeDirectoryName guifg=#AAF0ED guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeDirectoryIcon guifg=#AAF0ED guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitModified guifg=#9AE6E2 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitAdded guifg=#7AC2BF guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitDeleted guifg=#7AA365 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitUntracked guifg=#7AC291 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeIndentMarker guifg=#578F8C guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeSymbolicLinkTarget guifg=#9AE6E2 guibg=NONE gui=NONE cterm=NONE

  " File explorer cursor highlights with strong contrast
  " hi NeoTreeCursorLine guibg=#9AE6E2 guifg=#0D2322 gui=bold cterm=bold
  " hi! link NeoTreeCursor NeoTreeCursorLine
  " hi! link NeoTreeCursorLineSign NeoTreeCursorLine

  " Use wallbash colors for explorer snack in dark mode
  hi WinBar guifg=#FFFFFF guibg=#5A7964 gui=bold cterm=bold
  hi WinBarNC guifg=#FFFFFF guibg=#265247 gui=NONE cterm=NONE
  hi ExplorerSnack guibg=#CCFFFD guifg=#0D2322 gui=bold cterm=bold
  hi BufferTabpageFill guibg=#0D2322 guifg=#FFFFFF gui=NONE cterm=NONE
  hi BufferCurrent guifg=#FFFFFF guibg=#CCFFFD gui=bold cterm=bold
  hi BufferCurrentMod guifg=#FFFFFF guibg=#9AE6E2 gui=bold cterm=bold
  hi BufferCurrentSign guifg=#CCFFFD guibg=#265247 gui=NONE cterm=NONE
  hi BufferVisible guifg=#FFFFFF guibg=#5A7964 gui=NONE cterm=NONE
  hi BufferVisibleMod guifg=#FFFFFF guibg=#5A7964 gui=NONE cterm=NONE
  hi BufferVisibleSign guifg=#9AE6E2 guibg=#265247 gui=NONE cterm=NONE
  hi BufferInactive guifg=#FFFFFF guibg=#265247 gui=NONE cterm=NONE
  hi BufferInactiveMod guifg=#65A3A0 guibg=#265247 gui=NONE cterm=NONE
  hi BufferInactiveSign guifg=#65A3A0 guibg=#265247 gui=NONE cterm=NONE

  " Fix link colors to make them more visible
  hi link Hyperlink NONE
  hi link markdownLinkText NONE
  hi Underlined guifg=#FF00FF guibg=NONE gui=bold,underline cterm=bold,underline
  hi Special guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownUrl guifg=#FF00FF guibg=NONE gui=underline cterm=underline
  hi markdownLinkText guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi htmlLink guifg=#FF00FF guibg=NONE gui=bold,underline cterm=bold,underline

  " Add more direct highlights for badges in markdown
  hi markdownH1 guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownLinkDelimiter guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownLinkTextDelimiter guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownIdDeclaration guifg=#FF00FF guibg=NONE gui=bold cterm=bold
else
  " Light theme with transparent backgrounds
  hi Normal guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi Pmenu guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi StatusLine guifg=#FFFFFF guibg=#4B7D5B gui=NONE cterm=NONE
  hi StatusLineNC guifg=#0D2322 guibg=#FFFFFF gui=NONE cterm=NONE
  hi VertSplit guifg=#4B7D5B guibg=NONE gui=NONE cterm=NONE
  hi LineNr guifg=#4B7D5B guibg=NONE gui=NONE cterm=NONE
  hi SignColumn guifg=NONE guibg=NONE gui=NONE cterm=NONE
  hi FoldColumn guifg=#265247 guibg=NONE gui=NONE cterm=NONE

  " NeoTree with transparent background including unfocused state
  hi NeoTreeNormal guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi NeoTreeEndOfBuffer guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi NeoTreeFloatNormal guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi NeoTreeFloatBorder guifg=#4B7D70 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeWinSeparator guifg=#FFFFFF guibg=NONE gui=NONE cterm=NONE

  " NeoTree with transparent background
  hi NeoTreeNormal guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi NeoTreeEndOfBuffer guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi NeoTreeRootName guifg=#295247 guibg=NONE gui=bold cterm=bold

  " TabLine highlighting with complementary accents
  hi TabLine guifg=#0D2322 guibg=#FFFFFF gui=NONE cterm=NONE
  hi TabLineFill guifg=NONE guibg=NONE gui=NONE cterm=NONE
  hi TabLineSel guifg=#FFFFFF guibg=#295247 gui=bold cterm=bold
  hi TabLineSeparator guifg=#4B7D5B guibg=#FFFFFF gui=NONE cterm=NONE

  " Interactive elements with complementary contrast
  hi Search guifg=#FFFFFF guibg=#3A6B5F gui=NONE cterm=NONE
  hi Visual guifg=#FFFFFF guibg=#4B7D5B gui=NONE cterm=NONE
  hi MatchParen guifg=#FFFFFF guibg=#295247 gui=bold cterm=bold

  " Menu item hover highlight
  hi CmpItemAbbrMatch guifg=#295247 guibg=NONE gui=bold cterm=bold
  hi CmpItemAbbrMatchFuzzy guifg=#3A6B5F guibg=NONE gui=bold cterm=bold
  hi CmpItemMenu guifg=#265247 guibg=NONE gui=italic cterm=italic
  hi CmpItemAbbr guifg=#0D2322 guibg=NONE gui=NONE cterm=NONE
  hi CmpItemAbbrDeprecated guifg=#5A7964 guibg=NONE gui=strikethrough cterm=strikethrough

  " Specific menu highlight groups
  hi WhichKey guifg=#295247 guibg=NONE gui=NONE cterm=NONE
  hi WhichKeySeparator guifg=#5A7964 guibg=NONE gui=NONE cterm=NONE
  hi WhichKeyGroup guifg=#4B7D70 guibg=NONE gui=NONE cterm=NONE
  hi WhichKeyDesc guifg=#3A6B5F guibg=NONE gui=NONE cterm=NONE
  hi WhichKeyFloat guibg=#FFFFFF guifg=NONE gui=NONE cterm=NONE

  " Selection and hover highlights with inverted colors
  hi CursorColumn guifg=NONE guibg=#FFFFFF gui=NONE cterm=NONE
  hi Cursor guibg=#0D2322 guifg=#FFFFFF gui=NONE cterm=NONE
  hi lCursor guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi CursorIM guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi TermCursor guibg=#0D2322 guifg=#FFFFFF gui=NONE cterm=NONE
  hi TermCursorNC guibg=#FFFFFF guifg=#0D2322 gui=NONE cterm=NONE
  hi CursorLine guibg=NONE ctermbg=NONE gui=underline cterm=underline
  hi CursorLineNr guifg=#295247 guibg=NONE gui=bold cterm=bold

  hi QuickFixLine guifg=#FFFFFF guibg=#3A6B5F gui=NONE cterm=NONE
  hi IncSearch guifg=#FFFFFF guibg=#295247 gui=NONE cterm=NONE
  hi NormalNC guibg=#FFFFFF guifg=#265247 gui=NONE cterm=NONE
  hi Directory guifg=#295247 guibg=NONE gui=NONE cterm=NONE
  hi WildMenu guifg=#FFFFFF guibg=#295247 gui=bold cterm=bold

  " Add highlight groups for focused items with inverted colors
  hi CursorLineFold guifg=#295247 guibg=#FFFFFF gui=NONE cterm=NONE
  hi FoldColumn guifg=#265247 guibg=NONE gui=NONE cterm=NONE
  hi Folded guifg=#0D2322 guibg=#FFFFFF gui=italic cterm=italic

  " File explorer specific highlights
  hi NeoTreeNormal guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi NeoTreeEndOfBuffer guibg=NONE guifg=#0D2322 gui=NONE cterm=NONE
  hi NeoTreeRootName guifg=#295247 guibg=NONE gui=bold cterm=bold
  hi NeoTreeFileName guifg=#0D2322 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeFileIcon guifg=#3A6B5F guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeDirectoryName guifg=#3A6B5F guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeDirectoryIcon guifg=#3A6B5F guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitModified guifg=#4B7D70 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitAdded guifg=#578F69 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitDeleted guifg=#7AA365 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeGitUntracked guifg=#7AC291 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeIndentMarker guifg=#578F81 guibg=NONE gui=NONE cterm=NONE
  hi NeoTreeSymbolicLinkTarget guifg=#4B7D70 guibg=NONE gui=NONE cterm=NONE

  " File explorer cursor highlights with strong contrast
  " hi NeoTreeCursorLine guibg=#3A6B5F guifg=#FFFFFF gui=bold cterm=bold
  " hi! link NeoTreeCursor NeoTreeCursorLine
  " hi! link NeoTreeCursorLineSign NeoTreeCursorLine

  " Use wallbash colors for explorer snack in light mode
  hi WinBar guifg=#0D2322 guibg=#FFFFFF gui=bold cterm=bold
  hi WinBarNC guifg=#265247 guibg=#FFFFFF gui=NONE cterm=NONE
  hi ExplorerSnack guibg=#295247 guifg=#FFFFFF gui=bold cterm=bold
  hi BufferTabpageFill guibg=#FFFFFF guifg=#5A7964 gui=NONE cterm=NONE
  hi BufferCurrent guifg=#FFFFFF guibg=#295247 gui=bold cterm=bold
  hi BufferCurrentMod guifg=#FFFFFF guibg=#4B7D70 gui=bold cterm=bold
  hi BufferCurrentSign guifg=#295247 guibg=#FFFFFF gui=NONE cterm=NONE
  hi BufferVisible guifg=#0D2322 guibg=#FFFFFF gui=NONE cterm=NONE
  hi BufferVisibleMod guifg=#265247 guibg=#FFFFFF gui=NONE cterm=NONE
  hi BufferVisibleSign guifg=#4B7D70 guibg=#FFFFFF gui=NONE cterm=NONE
  hi BufferInactive guifg=#5A7964 guibg=#FFFFFF gui=NONE cterm=NONE
  hi BufferInactiveMod guifg=#65A394 guibg=#FFFFFF gui=NONE cterm=NONE
  hi BufferInactiveSign guifg=#65A394 guibg=#FFFFFF gui=NONE cterm=NONE

  " Fix link colors to make them more visible
  hi link Hyperlink NONE
  hi link markdownLinkText NONE
  hi Underlined guifg=#FF00FF guibg=NONE gui=bold,underline cterm=bold,underline
  hi Special guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownUrl guifg=#FF00FF guibg=NONE gui=underline cterm=underline
  hi markdownLinkText guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi htmlLink guifg=#FF00FF guibg=NONE gui=bold,underline cterm=bold,underline

  " Add more direct highlights for badges in markdown
  hi markdownH1 guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownLinkDelimiter guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownLinkTextDelimiter guifg=#FF00FF guibg=NONE gui=bold cterm=bold
  hi markdownIdDeclaration guifg=#FF00FF guibg=NONE gui=bold cterm=bold
endif

" UI elements that are the same in both themes with transparent backgrounds
hi NormalFloat guibg=NONE guifg=NONE gui=NONE cterm=NONE
hi FloatBorder guifg=#4B7D5B guibg=NONE gui=NONE cterm=NONE
hi SignColumn guifg=NONE guibg=NONE gui=NONE cterm=NONE
hi DiffAdd guifg=#FFFFFF guibg=#7AC2BF gui=NONE cterm=NONE
hi DiffChange guifg=#FFFFFF guibg=#65A379 gui=NONE cterm=NONE
hi DiffDelete guifg=#FFFFFF guibg=#7AA365 gui=NONE cterm=NONE
hi TabLineFill guifg=NONE guibg=NONE gui=NONE cterm=NONE

" Fix selection highlighting with proper color derivatives
hi TelescopeSelection guibg=#CCFFDC guifg=#0D2322 gui=bold cterm=bold
hi TelescopeSelectionCaret guifg=#FFFFFF guibg=#CCFFDC gui=bold cterm=bold
hi TelescopeMultiSelection guibg=#9AE6B2 guifg=#0D2322 gui=bold cterm=bold
hi TelescopeMatching guifg=#92C27A guibg=NONE gui=bold cterm=bold

" Minimal fix for explorer selection highlighting
hi NeoTreeCursorLine guibg=#CCFFDC guifg=#0D2322 gui=bold

" Fix for LazyVim menu selection highlighting
hi Visual guibg=#DDFFCC guifg=#0D2322 gui=bold
hi CursorLine guibg=NONE ctermbg=NONE gui=underline cterm=underline
hi PmenuSel guibg=#DDFFCC guifg=#0D2322 gui=bold
hi WildMenu guibg=#DDFFCC guifg=#0D2322 gui=bold

" Create improved autocommands to ensure highlighting persists with NeoTree focus fixes
augroup WallbashSelectionFix
  autocmd!
  " Force these persistent highlights with transparent backgrounds where possible
  autocmd ColorScheme * if &background == 'dark' |
    \ hi Normal guibg=NONE |
    \ hi NeoTreeNormal guibg=NONE |
    \ hi SignColumn guibg=NONE |
    \ hi NormalFloat guibg=NONE |
    \ hi FloatBorder guibg=NONE |
    \ hi TabLineFill guibg=NONE |
    \ else |
    \ hi Normal guibg=NONE |
    \ hi NeoTreeNormal guibg=NONE |
    \ hi SignColumn guibg=NONE |
    \ hi NormalFloat guibg=NONE |
    \ hi FloatBorder guibg=NONE |
    \ hi TabLineFill guibg=NONE |
    \ endif

  " Force NeoTree background to be transparent even when unfocused
  autocmd WinEnter,WinLeave,BufEnter,BufLeave * if &ft == 'neo-tree' || &ft == 'NvimTree' |
    \ hi NeoTreeNormal guibg=NONE |
    \ hi NeoTreeEndOfBuffer guibg=NONE |
    \ endif

  " Fix NeoTree unfocus issue specifically in LazyVim
  autocmd VimEnter,ColorScheme * hi link NeoTreeNormalNC NeoTreeNormal

  " Make CursorLine less obtrusive by using underline instead of background
  autocmd ColorScheme * hi CursorLine guibg=NONE ctermbg=NONE gui=underline cterm=underline

  " Make links visible across modes
  autocmd ColorScheme * if &background == 'dark' |
    \ hi Underlined guifg=#FF00FF guibg=NONE gui=bold,underline cterm=bold,underline |
    \ hi Special guifg=#FF00FF guibg=NONE gui=bold cterm=bold |
    \ else |
    \ hi Underlined guifg=#FF00FF guibg=NONE gui=bold,underline cterm=bold,underline |
    \ hi Special guifg=#FF00FF guibg=NONE gui=bold cterm=bold |
    \ endif

  " Fix markdown links specifically
  autocmd FileType markdown hi markdownUrl guifg=#FF00FF guibg=NONE gui=underline,bold
  autocmd FileType markdown hi markdownLinkText guifg=#FF00FF guibg=NONE gui=bold
  autocmd FileType markdown hi markdownIdDeclaration guifg=#FF00FF guibg=NONE gui=bold
  autocmd FileType markdown hi htmlLink guifg=#FF00FF guibg=NONE gui=bold,underline
augroup END

" Create a more aggressive fix for NeoTree background in LazyVim
augroup FixNeoTreeBackground
  autocmd!
  " Force NONE background for NeoTree at various points to override tokyonight fallback
  autocmd ColorScheme,VimEnter,WinEnter,BufEnter * hi NeoTreeNormal guibg=NONE guifg=#FFFFFF ctermbg=NONE
  autocmd ColorScheme,VimEnter,WinEnter,BufEnter * hi NeoTreeNormalNC guibg=NONE guifg=#FFFFFF ctermbg=NONE
  autocmd ColorScheme,VimEnter,WinEnter,BufEnter * hi NeoTreeEndOfBuffer guibg=NONE guifg=#FFFFFF ctermbg=NONE

  " Also fix NvimTree for NvChad
  autocmd ColorScheme,VimEnter,WinEnter,BufEnter * hi NvimTreeNormal guibg=NONE guifg=#FFFFFF ctermbg=NONE
  autocmd ColorScheme,VimEnter,WinEnter,BufEnter * hi NvimTreeNormalNC guibg=NONE guifg=#FFFFFF ctermbg=NONE
  autocmd ColorScheme,VimEnter,WinEnter,BufEnter * hi NvimTreeEndOfBuffer guibg=NONE guifg=#FFFFFF ctermbg=NONE

  " Apply highlight based on current theme
  autocmd ColorScheme,VimEnter * if &background == 'dark' |
    \ hi NeoTreeCursorLine guibg=#CCFFDC guifg=#0D2322 gui=bold cterm=bold |
    \ hi NvimTreeCursorLine guibg=#CCFFDC guifg=#0D2322 gui=bold cterm=bold |
    \ else |
    \ hi NeoTreeCursorLine guibg=#295247 guifg=#FFFFFF gui=bold cterm=bold |
    \ hi NvimTreeCursorLine guibg=#295247 guifg=#FFFFFF gui=bold cterm=bold |
    \ endif

  " Force execution after other plugins have loaded
  autocmd VimEnter * doautocmd ColorScheme
augroup END

" Add custom autocommand specifically for LazyVim markdown links
augroup LazyVimMarkdownFix
  autocmd!
  " Force link visibility in LazyVim with stronger override
  autocmd FileType markdown,markdown.mdx,markdown.gfm hi! def link markdownUrl MagentaLink
  autocmd FileType markdown,markdown.mdx,markdown.gfm hi! def link markdownLinkText MagentaLink
  autocmd FileType markdown,markdown.mdx,markdown.gfm hi! def link markdownLink MagentaLink
  autocmd FileType markdown,markdown.mdx,markdown.gfm hi! def link markdownLinkDelimiter MagentaLink
  autocmd FileType markdown,markdown.mdx,markdown.gfm hi! MagentaLink guifg=#FF00FF gui=bold,underline

  " Apply when LazyVim is detected
  autocmd User LazyVimStarted doautocmd FileType markdown
  autocmd VimEnter * if exists('g:loaded_lazy') | doautocmd FileType markdown | endif
augroup END

" Add custom autocommand specifically for markdown files with links
augroup MarkdownLinkFix
  autocmd!
  " Use bright hardcoded magenta that will definitely be visible
  autocmd FileType markdown hi markdownUrl guifg=#FF00FF guibg=NONE gui=underline,bold
  autocmd FileType markdown hi markdownLinkText guifg=#FF00FF guibg=NONE gui=bold
  autocmd FileType markdown hi markdownIdDeclaration guifg=#FF00FF guibg=NONE gui=bold
  autocmd FileType markdown hi htmlLink guifg=#FF00FF guibg=NONE gui=bold,underline

  " Force these highlights right after vim loads
  autocmd VimEnter * if &ft == 'markdown' | doautocmd FileType markdown | endif
augroup END

" Remove possibly conflicting previous autocommands
augroup LazyVimFix
  autocmd!
augroup END

augroup MinimalExplorerFix
  autocmd!
augroup END
