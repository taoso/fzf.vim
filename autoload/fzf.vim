function s:findRoot()
	let result = system('git rev-parse --show-toplevel')
	if v:shell_error == 0
		return substitute(result, '\n*$', '', 'g')
	endif

	return "."
endfunction

function OpenFile(...)
	let root = getcwd()
	if has('nvim')
		let path = getline(1)
	else
		let path = term_getline(b:term_buf, 1)
	endif

	silent close

	let full_path = root.'/'.path
	if filereadable(full_path)
		while &buftype != ""
			execute 'wincmd w'
		endwhile
		execute 'edit '.full_path
	endif
endfunction

function! fzf#Open()
	keepalt bo 9 new

	let root = s:findRoot()
	if root != '.'
		execute 'lcd '.root
	endif

	if has('nvim')
		let options = {'on_exit': 'OpenFile'}
		call termopen('fzf', options)
		startinsert
	else
		let options = {'term_name':'FZF','curwin':1,'exit_cb':'OpenFile'}
		let b:term_buf = term_start('fzf', options)
	endif
endfunction
