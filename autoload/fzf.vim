function s:findRoot()
	let result = system('git rev-parse --show-toplevel')
	if v:shell_error == 0
		return substitute(result, '\n*$', '', 'g')
	endif

	return "."
endfunction

function s:collect(...)
	let root = getcwd()
	silent bdelete!

	let result = a:000[0]
	if filereadable(result)
		let lines = readfile(result)
		if len(lines) == 1
			execute 'edit '.root.'/'.lines[0]
		endif
		call delete(result)
	endif
endfunction

function! fzf#Open()
	let result = tempname()

	keepalt below 9 new

	let root = s:findRoot()
	if root != '.'
		execute 'lcd '.root
	endif

	if has('nvim')
		let options = {'name':'FZF'}
		let options["on_exit"] = function('s:collect', [result])
		call termopen(['sh', '-c', 'fzf > '.result], options)
		startinsert
	else
		let options = {'term_finish':'close','term_name':'FZF', 'curwin':1}
		let options["exit_cb"] = function('s:collect', [result])
		call term_start(['sh', '-c', 'fzf > '.result], options)
	endif
endfunction
