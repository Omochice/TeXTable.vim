if exists('g:loaded_textable') && g:loaded_textable
  finish
endif
let g:loaded_textable = v:true

comman! -bang -nargs=? -range TeXTable call TeXTable#makeTeXTable('<bang>', <line1>, <line2>, <f-args>)
