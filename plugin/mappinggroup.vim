"=============================================================================
"        File: mappinggroup.vim
"      Author: Chao-Kuo Lin (chaokuo@iname.com) 
" Last Change: Wed May 12 17:54:51 EDT 2004
" Description: Mapping key groups using function keys.
"   Copyright:     
"
" Copyright (c) 2004 Chao-Kuo Lin (chaokuo@iname.com).
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy of
" this software and associated documentation files (the "Software"), to deal in
" the Software without restriction, including without limitation the rights to
" use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
" of the Software, and to permit persons to whom the Software is furnished to do
" so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE."
"=============================================================================
"
"   Intro:
"     This plugin allows you to use function keys F1, F2, ... to act as 
"     multilevel menu keys, so that you can define different group of
"     key mappings.  It is good for actions that are important but not
"     important enough which you just want to assign some key to it.
"
"   Installation:
"     Drop this script in your plugin directory and read the usage on
"     how to define your own menus.
"
"   Usage:
"     By default, you can define keys from F2 to F9, in which:
"
"       F1 is defined to list all the current mapping in the status line
"       F11 is defined to go back to the previous level
"       F12 is to restart and go to the main/root level
"
"     In order to use it, you would want to write your own functions that
"     call the functions explained in the next paragraph.  All you need to 
"     do is set the variable g:mappingGroupStart to the name of your function.  
"
"     Example:
"
"     ----------------------------------------------------------------
"     function! MyMappingGroupStart()
"       call MappingAddGroup(3, "Coding", 
"         "MyMappingProgrammingGroup", "Programming stuff")
"       call MappingAddGroup(8, "Manager", 
"         "MyMappingWinManagerGroup", "WinManager stuff")
"       call MappingAddGroup(9, "Misc", 
"         "MyMappingMiscGroup", "Misc stuff")
"     endfunction

"     let g:mappingGroupStart = "MyMappingGroupStart"
"     ----------------------------------------------------------------
"
"
"     There are three functions that you will need to add new mappings:
"     ----------------------------------------------------------------
"       * MappingAddCommand(n, name, cmd, comment)
"
"         Adds a new key mapping that when pressed will execute.  
"         Example:
"           call MappingAddCommand(2, "Delete", "dd", 
"             "delete a line")
"         What it does is add F2 to create delete one line.  But of
"         course you would want to do something more complicated than
"         that.
"
"         Arguments:
"           n - The function key number you want to bind
"           name - 
"             The short description of the key which will be displayed
"             at the bottom when pressing F1
"           cmd - 
"             The command to execute, the last <CR> can be ommitted
"             because this function appends it automatically.
"           comment - 
"             A longer description for the command, current has no
"             use.
"
"     ----------------------------------------------------------------
"       * MappingAddFunction(n, name, funname, comment)
"
"         Adds a key mapping such that when pressed it will call the
"         function you specify.  If you want to bind a key to open
"         another new level, then you shouldn't use this function.
"         Please read the following function.  This function is
"         useful when commands you want to execute are not simple
"         key sequences or are too long and will look ugly if binded
"         using the previous function. 
"
"         Example:
"           call MappingAddFunction(3, "Header", 
"             "MyMappingCProgrammingCHeader", "Generates file header")
"         
"         In the function MyMappingCProgrammingCHeader, I get the user
"         input and automatically generate simple C/C++ header comments and
"         include guards.
"
"         Arguments:
"           n - The function key number you want to bind
"           name - 
"             The short description of the key which will be displayed
"             at the bottom when pressing F1
"           funname -
"             The name of the function that you want to execute when the
"             key is pressed.  Script private functions cannot be used
"             here for some reason.  If you know a way to incorporate
"             script private functions that start with s: please let me know.
"           comment - 
"             A longer description for the command which current has no use.
"
"
"     ----------------------------------------------------------------
"       * MappingAddGroup(n, name, funname, comment)
"         This is the function which you can bind keys to open up
"         new level of mappings which is simliar to opening a submenu.
"
"         Example:
"           call MappingAddGroup(2, "C/C++", "MyMappingCProgrammingGroup", 
"             "C/C++ related commands")
"         
"         The function MyMappingCProgrammingGroup would have calls to
"         MappingAddCommand, MappingAddFunction and MappingAddGroup to
"         popluate the menu.
"
"         Arguments:
"           n - The function key number you want to bind
"           name - 
"             The short description of the key which will be displayed
"             at the bottom when pressing F1
"           funname -
"             The name of the function that you want to execute when the
"             key is pressed.  Script private functions cannot be used
"             here for some reason.  If you know a way to incorporate
"             script private functions that start with s: please let me know.
"           comment - 
"             A longer description for the command which currently has no use.
"     ----------------------------------------------------------------
"
"   Variables:
"
"     g:mappingGroupStart
"       The variable that you wnat to set to point to your main group 
"       funciont that will add items to the first level menu.
"
"     g:mappingGroupStartKeyNumber 
"       The starting number of function key that you want to use, so if I
"       define it as 1, then my keys will start from F1, F2, F3, ...
"
"     g:mappingGroupEndKeyNumber
"       The ending number of the funciton key.  So if it's defined as 9 and
"       g:mappingGroupStartKeyNumber is 1, then you can define F1, F2, F3
"       , ... , F9 to perform different tasks.
"
" ============================================================================

"{{{ Variable initialization
" quit if the user doesnt want us or if we are already loaded.
if exists("loaded_mappinggroup")
  finish
end
let loaded_mappinggroup = 1

if !exists("g:mappingGroupStartKeyNumber")
  let g:mappingGroupStartKeyNumber = 2
endif

if !exists("g:mappingGroupEndKeyNumber")
  let g:mappingGroupEndKeyNumber = 9
endif

" initialization
let s:mappingGroupHistory = ""
let g:mappingCurrentGroup = "<SID>MappingGroupMain"
"}}}

"{{{ Mapping groups
"{{{ accessor
function! s:MappingKey(n)
  return "<F" . a:n . ">"
endfunction

function! s:MappingCommentString(n)
  return "s:mappingComment" . a:n
endfunction

function! s:MappingNameString(n)
  return "s:mappingName" . a:n
endfunction

function! s:MappingStartKeyNumber()
  return g:mappingGroupStartKeyNumber
endfunction

function! s:MappingEndKeyNumber()
  return g:mappingGroupEndKeyNumber
endfunction
"}}}
"{{{ cleaning
function! s:MappingReset()
let n = s:MappingStartKeyNumber()
  while n <= s:MappingEndKeyNumber()
    let key = s:MappingKey(n)
    if strlen(maparg(key))
      execute "unmap " . key
      execute "let " . s:MappingCommentString(n) " = ''"
      execute "let " . s:MappingNameString(n) " = ''"
    endif
    let n = n + 1
  endwhile
endfunction
"}}}
"{{{ adding
function! s:MappingAdd(n, name, cmd, type, comment)
  let key = s:MappingKey(a:n)
  execute "noremap " . key . " " . a:cmd
  execute "let s:mappingComment" . a:n . " = '" . a:type "\t" . a:comment . "'"
  execute "let s:mappingName" . a:n . " = '" . a:name . "'"
endfunction

function! MappingAddCommand(n, name, cmd, comment)
  call s:MappingAdd(a:n, a:name, a:cmd . "<CR>", "Command", a:comment)
endfunction

function! MappingAddFunction(n, name, funname, comment)
  let cmd = ":call " . a:funname . "()<CR>"
  call s:MappingAdd(a:n, a:name, cmd, "Function", a:comment)
endfunction

function! MappingAddGroup(n, name, funname, comment)
  let cmd = ":call <SID>MappingPushHistory()<CR>:let g:mappingCurrentGroup = '" . a:funname . "'<CR>:call <SID>MappingReset()<CR>" . ":call " . a:funname . "()<CR>:call <SID>MappingListShort()<CR>"
  let name = a:name . ']'
  call s:MappingAdd(a:n, name, cmd, "Group", a:comment)
endfunction
"}}}
  "{{{ comment-printing
function! s:MappingListComment(n)
  let commentvar = s:MappingCommentString(a:n)
  let key = s:MappingKey(a:n)
  if strlen(maparg(key))
    execute "echo '" . key . "' . " . commentvar
  endif
endfunction

function! MappingListComments()
  let n = 1
  while n <= 12
    call s:MappingListComment(n)
    let n = n + 1
  endwhile
endfunction
"}}}
"{{{ shortname-printing
function! s:MappingListGetShort(n)
  let namevar = s:MappingNameString(a:n)
  let key = s:MappingKey(a:n)
  if strlen(maparg(key))
    return "" . a:n . ">" . {namevar} . " "
  endif
  return ""
endfunction

function! s:MappingListShort()
  let n = 1
  let result = ""
  while n <= 12
    let result = result . s:MappingListGetShort(n)
    let n = n + 1
  endwhile
  echo result
endfunction
"}}}
"{{{ group-history
function! s:MappingPushHistory()
  let s:mappingGroupHistory = g:mappingCurrentGroup . ":" . s:mappingGroupHistory
endfunction

function! s:MappingPopHistory()
  let separatoridx = stridx(s:mappingGroupHistory, ":")
  if separatoridx <= 0 
    let s:mappingGroupHistory = ""
    return ""
  endif
  let result = strpart(s:mappingGroupHistory, 0, separatoridx)
  let s:mappingGroupHistory = strpart(s:mappingGroupHistory, separatoridx + 1)
  return result
endfunction

function! s:MappingGotoPreviousGroup()
  let last = s:MappingPopHistory()
  if strlen(last)
    call s:MappingReset()
    execute "call " . last . "()" 
    let g:mappingCurrentGroup = last
    call s:MappingListShort()
  else
    echo "No more previous in history"
  endif
endfunction
"}}}
"{{{ main
function! s:MappingGroupMain()
  call MappingAddFunction(1, "List", "<SID>MappingListShort", "List Keymap Names")
  call MappingAddFunction(11, "Prev", "<SID>MappingGotoPreviousGroup", "Goes Back to the Previous Visiting Group")
  call MappingAddFunction(12, "Home", "<SID>MappingGroupRestart", "Restart the Group Mapping")
  if exists("g:mappingGroupStart")
    execute 'call ' . g:mappingGroupStart . '()'
  endif
endfunction

function! s:MappingGroupRestart()
  call s:MappingGroupStart()
  call s:MappingListShort()
endfunction

function! s:MappingGroupStart()
  let s:mappingGroupHistory = ''
  let g:mappingCurrentGroup = '<SID>MappingGroupMain'
  call s:MappingReset()
  call s:MappingGroupMain()
endfunction

call s:MappingGroupStart()
"}}}

"}}}

