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
	if has('nvim')
		let buf = nvim_create_buf(v:false, v:true)

		let ui = nvim_list_uis()[0]
		let w = float2nr(floor(ui.width*0.8))
		let h = float2nr(floor(ui.height*0.5))
		let opts = {'relative': 'editor',
                          \ 'border': "rounded",
                          \ 'width': w,
                          \ 'height': h,
                          \ 'col': (ui.width - w) / 2,
                          \ 'row': ui.height / 3 - h / 2,
                          \ 'style': 'minimal',
                          \ }
		call nvim_open_win(buf, 1, opts)
	else
		keepalt bo 9 new
	endif

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
