let s:save_cpo = &cpo
set cpo&vim

function! s:need_escape(char) abort
  let l:chars_need_escape = [
        \ '\',
        \ '+',
        \ '.',
        \ '*',
        \ '[',
        \ ']',
        \ '(',
        \ ')',
        \ '{',
        \ '}',
        \ '?',
        \ '^',
        \ '$',
        \ '|',
        \ ]
  return index(l:chars_need_escape, a:char) != -1
endfunction

function! s:csv_to_table(text, sep) abort
  " Split each with separator
  let l:separator = '\s*' . (s:need_escape(a:sep) ? '\' . a:sep : a:sep) . '\s*'
  let l:table = map(a:text, {_,v -> split(v, l:separator, v:true)})
  " Fit length to longest one
  let l:n_columns = max(map(copy(l:table), {_, v -> len(v)}))
  " Convert tex table contents
  call map(l:table, {_, v -> join(v, ' & ') . ' \\ \hline'})
  return l:table
endfunction

function! s:add_table(contents) abort
  let l:table = [
        \ "\\begin{table}[htbp]",
        \ "\t\\centering",
        \ "\t\\caption{}",
        \ "\t\\label{table:}",
        \ "\\end{table}",
        \ ]
  call extend(l:table, map(a:contents, {_, v -> "\t" . v}), 2)
  return l:table
endfunction

function! s:add_tabular(contents) abort
  let l:n_columns = len(split(a:contents[0], '&'))
  " Construct aligner
  let l:aligner = join(repeat([(exists('g:textable_algin') ? g:textable_algin : 'l')], l:n_columns), '|')
  let l:tabular = [
        \ "\\begin{tabular}{" . l:aligner . '}',
        \ "\\hline",
        \ "\\end{tabular}",
        \ ]
  call extend(l:tabular, map(a:contents, {_, v -> "\t" . v}), 2)
  return l:tabular
endfunction

function! TeXTable#makeTeXTable(bang, line1, line2, ...) abort
  " Convert csv-like text to LaTeX's table.
  " Save current position
  let l:pos = getpos('.')
  let l:contents = map(range(a:line1, a:line2), {_, v -> getline(v)})
  let l:sep = get(a:000, 0, ',')
  " Convert csv to tex table
  let l:contents = s:csv_to_table(l:contents, l:sep)
  " If bang then add only tabular
  let l:rows = a:bang =~ '!' ?
        \ s:add_tabular(l:contents) :
        \ s:add_table(s:add_tabular(l:contents))
  " Delete original text into black hole register
  silent execute printf('%d,%ddelete _', a:line1, a:line2)
  " Output Rows
  silent call append(a:line1-1, l:rows)
  call setpos('.', l:pos)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
