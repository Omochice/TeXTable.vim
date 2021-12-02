# TeXTable.vim

The Vim/Neovim plugin that convert CSV-like text to TeX's table.

## Installation

Use your favorite plugin manager.

- vim-plug

    ```
    Plug 'Omochice/TeXTable.vim'
    ```

- dein.vim

    ```
    call dein#add('Omochice/TeXTable.vim')
    ```

## Usage

![sample-movie-to-use](https://i.gyazo.com/78882ae7320ac9f6233ee7e1e723a288.gif)

```tex
1,2,3
a,b,c
```

Select the text on visual-mode and execute `'<,'>TeXTable` then it become below.

```tex
\begin{table}[htbp]
	\centering
	\caption{}
	\begin{tabular}{l|l|l}
	\hline
		1 & 2 & 3 \\ \hline
		a & b & c \\ \hline
	\end{tabular}
	\label{table:}
\end{table}
```

If you need only `tabular`, execute `TeXTable!`.

```tex
\begin{tabular}{l|l|l}
\hline
	1 & 2 & 3 \\ \hline
	a & b & c \\ \hline
\end{tabular}
```

If you want to separate with `.`, use `TeXTable .`.

NOTE: The length of columns in `tabular` fit as same as longest one.

## Variables

- `g:textable_algin`

    The character used as aligner in `tabular`.
    Default: `'l'`

## LICENSE

MIT
