"=============================================================================
"        File: example.vim
"      Author: Chao-Kuo Lin (chaokuo@iname.com) 
" Last Change: Wed May 12 18:03:38 EDT 2004
" Description: Examples for using mappinggroup.vim
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


" {{{ Programming mapping"
" {{{ C/C++
function! MyMappingCProgrammingGroup()
  call MappingAddCommand(2, "Fold", "yyPi//{{{ <ESC>}O//}}}<ESC>{jjjA", "Adds the fold mark for the program")
  call MappingAddFunction(3, "Header", "MyMappingCProgrammingCHeader", "Generates file header")
  call MappingAddFunction(4, "Class", "MyMappingCProgrammingCClassHeader", "Generates class skeleton")
  call MappingAddCommand(5, "Compile", ":make", "Compiles the program")
  call MappingAddFunction(6, "Ctag", "MyMappingCProgrammingCtags", "Generate Ctag File")
  call MappingAddFunction(7, "Accessor", "MyMappingCProgrammingCClassAccessor", "Generates getter/setter methods")
endfunction

" {{{ generate ctags
function! s:GenerateCtags(extensions)
  let extensions = "(" . a:extensions . ")$"
  let cmd = "find ./ | egrep '" . extensions . "' | xargs ctags"
  call system(cmd)
endfunction

function! MyMappingCProgrammingCtags()
  call s:GenerateCtags("c|cc|h|hh")
endfunction
"}}}

" {{{ generate header
function! MyMappingCProgrammingCHeader()
  let briefcomment = input("Brief comment for this file: ")
  let currentfile = bufname("%")
  let currentfilename = fnamemodify(currentfile, ":t")
  let currentfileroot = fnamemodify(currentfile, ":t:r") 
  let currentfileext = fnamemodify(currentfile, ":t:e") 
  let ifdefname = "_" . toupper(currentfileroot) . "_" . toupper(currentfileext) . "_"
  call append(0, "/**")
  call append(1, " * @file " . currentfilename)
  call append(2, " * @brief " . briefcomment)
  call append(3, " *")
  call append(4, " * @date " . strftime("%c"))
  call append(5, " * @author Chao-Kuo Lin")
  call append(6, " */")
  call append(7, "#ifndef " . ifdefname)
  call append(8, "#define " . ifdefname)
  call append(10, "#endif")
endfunction
" }}}

function! s:MultiplyString(str, times)
  let i = 0
  let result = ""
  while i < a:times
    let result = result . a:str
    let i = i + 1
  endwhile
  return result
endfunction

" {{{ generate class header
function! MyMappingCProgrammingCClassHeader()
  let currentlinenumber = line(".")
  let indentation = s:MultiplyString(" ", col("."))
  let classname = input("Class name: ")
  let baseclassname = input("Base class name: ")
  let classbriefcomment = input("Class comment: ")
  let classheader = "class " . classname
  if(strlen(baseclassname) > 0)
    let classheader = classheader . " : public " . baseclassname
  endif
  
  call append(currentlinenumber, indentation . "/**")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . " * " . classbriefcomment)
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . " */")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "//{{{")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . classheader)
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "{")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "  public:")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "    /** Constructor */")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "    " . classname . "();")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "    /** Destructor */")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "    virtual ~" . classname . "();")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "  protected:")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "};")
  let currentlinenumber = currentlinenumber + 1
  call append(currentlinenumber, indentation . "//}}}")
endfunction
" }}}

" {{{ generate getter/setter method
" layout should be this:
" variabletype(space)_variablename(';')
" The variablename must be prefixed by underscore
" ends with ('};')
function! MyMappingCProgrammingCClassAccessor()
  let currentlinenumber = line(".")
  let indentation = s:MultiplyString(" ", col(".") - 1)
  let outputlinenumber = currentlinenumber - 1
  let outputmethod = "//{{{ accessor%"
  let currentline = getline(currentlinenumber)
  " while line ends with ';' and there's no '}'
  while strridx(currentline, ";") != -1  && strridx(currentline, "}") == -1
    " the first word right before ';' will be regarded as variable name
    " layout should be this:
    " variabletype(space)variablename(';')
    let semicolonindex = strridx(currentline, ";")
    let spaceindex = strridx(currentline, " ")
    let variablestartindex = spaceindex + 1
    let variablename = strpart(currentline, variablestartindex, semicolonindex - variablestartindex)
    let variablename = strpart(variablename, 1) " get rid of underscore
    let variabletype = strpart(currentline, 0, spaceindex)
    let lastspaceindex = strridx(variabletype, " ")
    let variabletype = strpart(variabletype, lastspaceindex + 1)
    let constvartype = variabletype . " const & "
    let settermethod = "void " . variablename . "(" . constvartype . variablename . ")%{ _" . variablename . " = " . variablename . " }"
    let gettermethod = constvartype . variablename . "() const%{ return _" . variablename . "; }"
    " use % as newline separator
    let outputmethod = outputmethod . "/** Gets " . variablename . " */%"
    let outputmethod = outputmethod . gettermethod . "%"
    let outputmethod = outputmethod . "/** Sets " . variablename . " */%"
    let outputmethod = outputmethod . settermethod . "%"
    let currentlinenumber = currentlinenumber + 1
    let currentline = getline(currentlinenumber)
  endwhile

  let outputmethod = outputmethod . "//}}}%%" "adds an extra newline at end
  while stridx(outputmethod, "%") != -1
    let newlineindex = stridx(outputmethod, "%")
    call append(outputlinenumber, indentation . strpart(outputmethod, 0, newlineindex))
    let outputlinenumber = outputlinenumber + 1
    let outputmethod = strpart(outputmethod, newlineindex + 1)
  endwhile

endfunction
" }}}

" }}}

" {{{ Misc
function! MyMappingMiscProgrammingGroup()
  let datetimecmd = ":call setline(line('.'), getline(line('.')) . ' ' . strftime('%c') )"
  call MappingAddCommand(2, "DateTime", datetimecmd, "Append Date Time Information")
endfunction

function! MyMappingProgrammingGroup()
  call MappingAddGroup(2, "C/C++", "MyMappingCProgrammingGroup", "C/C++ related commands")
  call MappingAddGroup(9, "Misc", "MyMappingMiscProgrammingGroup", "Misc functions")
endfunction
" }}}


"}}}

"{{{ Browser mapping"
function! MyMappingWinManagerGroup()
  call MappingAddFunction(2, "Toggle", "MyMappingWinManagerToggle", "Toggles WinManager")
  call MappingAddCommand(3, "Top", ":FirstExplorerWindow", "Go to the first visible explorer window from the top left")
  call MappingAddCommand(4, "Bottom", ":BottomExplorerWindow", "Go to the last visible explorer window from the top left")
endfunction

function! MyMappingWinManagerToggle()
  if !exists("g:MappingMiniBufferActive") || g:MappingMiniBufferActive
    let g:MappingMiniBufferActive = 0
    execute "normal \\mbc"
  else
    let g:MappingMiniBufferActive = 1
    execute "normal \\mbe"
  endif
  execute ":WMToggle"
endfunction
"}}}

"{{{ Misc mapping
function! MyMappingMiscGroup()
  call MappingAddCommand(2, "Calendar", ":CalendarH", "Display calendar horizontally")
endfunction
"}}}

"{{{ Mapping Group Start"
function! MyMappingGroupStart()
  call MappingAddGroup(3, "Coding", "MyMappingProgrammingGroup", "Programming stuff")
  call MappingAddGroup(8, "Manager", "MyMappingWinManagerGroup", "WinManager stuff")
  call MappingAddGroup(9, "Misc", "MyMappingMiscGroup", "Misc stuff")
endfunction

let g:mappingGroupStart = "MyMappingGroupStart"
"}}}
