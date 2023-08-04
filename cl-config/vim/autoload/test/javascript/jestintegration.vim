if !exists('g:test#javascript#jest#file_pattern')
  let g:test#javascript#jestintegration#file_pattern = '\vintegration\-spec\.ts$'
endif

function! test#javascript#jestintegration#test_file(file) abort
  if a:file =~# g:test#javascript#jestintegration#file_pattern
      if exists('g:test#javascript#runner')
          return g:test#javascript#runner ==# 'jest'
      else
        return test#javascript#has_package('jest')
      endif
  endif
endfunction

function! test#javascript#jestintegration#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '-t '.shellescape(name, 1)
    endif
    return ['--no-coverage', '--runTestsByPath', name, '--', a:position['file']]
  elseif a:type ==# 'file'
    return ['--no-coverage', '--runTestsByPath', '--', a:position['file']]
  else
    return []
  endif
endfunction

let s:yarn_command = '\<yarn\>'
function! test#javascript#jestintegration#build_args(args) abort
  if exists('g:test#javascript#jestintegration#executable')
    \ && g:test#javascript#jestintegration#executable =~# s:yarn_command
    return filter(a:args, 'v:val != "--"')
  else
    return a:args
  endif
endfunction

function! test#javascript#jestintegration#executable() abort
  if filereadable('node_modules/.bin/jest')
    return 'node_modules/.bin/jest --config src/jest-integration.json'
  else
    return 'jest --config src/jest-integration.json'
  endif
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#javascript#patterns)
  return (len(name['namespace']) ? '^' : '') .
       \ test#base#escape_regex(join(name['namespace'] + name['test'])) .
       \ (len(name['test']) ? '$' : '')
endfunction
