let s:suite = themis#suite('TeXTable')
let s:scope = themis#helper('scope')
let s:funcs = s:scope.funcs('autoload/TeXTable.vim')

function! s:suite.test_need_escape()
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
  " Need escape
  for l:char in l:chars_need_escape
    call assert_true(s:funcs.need_escape(l:char), 'Inputed: ' . l:char . ' | ',)
  endfor

  " Unneed escape
  for l:char in ['a', '\.']
    call assert_false(s:funcs.need_escape(l:char), 'Inputed: ' . l:char . ' | ',)
  endfor
endfunction

function! s:suite.test_csv_to_table()
  let l:expected = [
        \ '1 & 2 & 3 \\ \hline',
        \ 'a & b & c \\ \hline',
        \ ]
  " Simple case
  let l:sources = [
        \ '1,2,3',
        \ 'a,b,c',
        \ ]
  call assert_equal(l:expected, s:funcs.csv_to_table(l:sources, ','))

  " include spaces
  let l:sources = [
        \ '1, 2, 3',
        \ 'a,  b,c',
        \ ]
  call assert_equal(l:expected, s:funcs.csv_to_table(l:sources, ','))

  " can use '.' etc
  let l:sources = [
        \ '1.2.3',
        \ 'a.b.c',
        \ ]
  call assert_equal(l:expected, s:funcs.csv_to_table(l:sources, '.'))

  " Not strip space that not action as separator
  let l:sources = [
        \ '1,2 3, 4',
        \ 'a b,c,d',
        \ ]
  let l:expected = [
        \ '1 & 2 3 & 4 \\ \hline',
        \ 'a b & c & d \\ \hline',
        \ ]
  call assert_equal(l:expected, s:funcs.csv_to_table(l:sources, ','))

  " must to fit as same as longest one
  let l:sources = [
        \ '1,2',
        \ 'a,b,c',
        \ ]
  let l:expected = [
        \ '1 & 2 &  \\ \hline',
        \ 'a & b & c \\ \hline',
        \ ]
  call assert_equal(l:expected, s:funcs.csv_to_table(l:sources, ','))
endfunction

function s:suite.test_add_table()
  " Add header/footer
  let l:expected = [
        \ "\\begin{table}[htbp]",
        \ "\t\\centering",
        \ "\t\\caption{}",
        \ "\tsampletext",
        \ "\t\\label{table:}",
        \ "\\end{table}",
        \ ]
  let l:sources = ['sampletext']
  call assert_equal(l:expected, s:funcs.add_table(l:sources))
endfunction

function s:suite.test_add_tabular()
  " Add header/footer
  let l:expected = [
        \ "\\begin{tabular}{l|l|l}",
        \ "\\hline",
        \ "\ta & b & c",
        \ "\\end{tabular}",
        \ ]
  let l:sources = ['a & b & c']
  call assert_equal(l:expected, s:funcs.add_tabular(l:sources))

  " If string does not have &, aligner must be only one.
  let l:expected = [
        \ "\\begin{tabular}{l}",
        \ "\\hline",
        \ "\ta",
        \ "\\end{tabular}",
        \ ]
  let l:sources = ['a']
  call assert_equal(l:expected, s:funcs.add_tabular(l:sources))

  " If set g:textable_align, must use it.
  let g:textable_align = 'c'
  let l:expected = [
        \ "\\begin{tabular}{c|c|c}",
        \ "\\hline",
        \ "\ta & b & c",
        \ "\\end{tabular}",
        \ ]
  let l:sources = ['a & b & c']
  call assert_equal(l:expected, s:funcs.add_tabular(l:sources))
  unlet g:textable_align
endfunction

function s:suite.test_TeXTable()
  call setline(1, ['1,2,3', 'a,b,c'])
  execute '1,2TeXTable'
  " There are empty lines in `processed`
  let l:processed = filter(getline(1, '$'), {_, v -> !empty(v)})
  let l:expected = [
        \ "\\begin{table}[htbp]",
        \ "\t\\centering",
        \ "\t\\caption{}",
        \ "\t\\begin{tabular}{l|l|l}",
        \ "\t\\hline",
        \ "\t\t1 & 2 & 3 \\\\ \\hline",
        \ "\t\ta & b & c \\\\ \\hline",
        \ "\t\\end{tabular}",
        \ "\t\\label{table:}",
        \ "\\end{table}",
        \ ]
  call assert_equal(l:expected, l:processed)
  execute '%delete'

  " Set g:textable_align, must use it
  let g:textable_align = 'c'
  call setline(1, ['1,2,3', 'a,b,c'])
  execute '1,2TeXTable'
  " There are empty lines in `processed`
  let l:processed = filter(getline(1, '$'), {_, v -> !empty(v)})
  let l:expected = [
        \ "\\begin{table}[htbp]",
        \ "\t\\centering",
        \ "\t\\caption{}",
        \ "\t\\begin{tabular}{c|c|c}",
        \ "\t\\hline",
        \ "\t\t1 & 2 & 3 \\\\ \\hline",
        \ "\t\ta & b & c \\\\ \\hline",
        \ "\t\\end{tabular}",
        \ "\t\\label{table:}",
        \ "\\end{table}",
        \ ]
  call assert_equal(l:expected, l:processed)
  unlet g:textable_align
endfunction

