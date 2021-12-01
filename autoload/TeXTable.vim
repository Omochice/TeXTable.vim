let s:save_cpo = &cpo
set cpo&vim

function! s:need_escape(char) abort
  let s:chars_need_escape = [
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
  return get(s:chars_need_escape, a:char) != -1
endfunction

function! TeXTable#makeTeXTable(bang, line1, line2, ...) abort
  " Convert csv-like text to LaTeX's table.
  " Example '1,2,3' => '1 & 2 & 3 \\ \hline'
  let l:contents = map(range(a:line1, a:line2), {_, v -> getline(v)})
  " Split each comma
  let l:sep = get(a:000, 0, ',')
  let l:sep = s:need_escape(l:sep) ? '\' . l:sep : l:sep
  call map(l:contents, {_, v -> split(v, '\s*' . l:sep . '\s*', v:true)})
  " let l:n_columns = len(l:contents[0])
  let l:n_columns = max(map(copy(l:contents), {_, v -> len(v)}))
  " Fit to header's length
  call map(l:contents, {_, v -> v + repeat([''], l:n_columns - len(v))})
  " Construct rows
  call map(l:contents, {_, v -> join(v, ' & ') . ' \\ \hline'})
  let l:table = [
        \ "\\begin{table}[htbp]",
        \ "\t\\centering",
        \ "\t\\caption{}",
        \ "\t\\label{table:}",
        \ "\\end{table}",
        \ ]
  let l:align = join(repeat([(exists('g:textable_algin') ? g:textable_algin : 'l')], l:n_columns), '|')
  let l:tabular = [
        \ "\\begin{tabular}{" . l:align . '}',
        \ "\\hline",
        \ "\\end{tabular}",
        \ ]
  call extend(l:tabular, map(l:contents, {_, v -> "\t" . v}), 2)
  " Save current position
  let l:pos = getpos('.')
  " Delete original text into black hole register
  silent execute printf('%d,%ddelete _', a:line1, a:line2)
  let l:rows = a:bang =~ '!' ?
        \ l:tabular :
        \ extend(l:table, map(l:tabular, {_, v -> "\t" . v}), 3)
  " Output Rows
  silent call append(a:line1-1, l:rows)
  call setpos('.', l:pos)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
