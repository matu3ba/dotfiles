local add_cmd = vim.api.nvim_add_user_command
local cmd_tn = 'tabnew ' .. os.getenv 'HOME' .. '/.config/nvim/'
add_cmd('CCmd',  cmd_tn .. 'lua/my_cmds.lua',  {})
add_cmd('CDap',  cmd_tn .. 'lua/my_dap.lua',  {})
add_cmd('CInit', cmd_tn .. 'init.lua', {})
add_cmd('CKey',  cmd_tn .. 'lua/my_keymaps.lua', {})
add_cmd('CLsp',  cmd_tn .. 'lua/my_lsp.lua',  {})
add_cmd('COpts', cmd_tn .. 'lua/my_opts.lua', {})
add_cmd('CPl',   cmd_tn .. 'lua/my_packer.lua', {})
add_cmd('CTel',  cmd_tn .. 'lua/my_telesc.lua', {})
add_cmd('CTre',  cmd_tn .. 'lua/my_treesitter.lua', {})
--add_cmd('Bda', [[:bufdo :bdelete]], {}) -- deleting all buffers except current one

-- REPLs for latex, clippy and cpp with linker mold
--_G.Pdfmain = function()
--  if _G.Pid_okular ~= nil and _G.Pid_okular > 0 then
--    _ = vim.fn.jobstop(_G.Pid_okular);
--    --assert(id == 1); fails on the second stop (the first is successful)
--    _G.Pid_okular = nil;
--  end
--  local this_tex_file = vim.fn.expand('%:p')
--  local line_number = vim.fn.line('.')
--  local okularcmd = 'okular --noraise --unique "' .. "build/main.pdf" .. '#src:' .. line_number .. ' ' .. this_tex_file .. '"'
--  _ = vim.defer_fn(function()
--    _G.Pid_okular = vim.fn.jobstart(okularcmd)
--    if _G.Pid_okular <= 0 then
--      print("_G.Pid_okular: could not launch okular");
--    end
--  end, 2000)
--  do i need to start the timer?
--end
--  only 1 instance is annoying --unique
_G.Pid_okular = nil
_G.Pdfmainstart = function()
  local this_tex_file = vim.fn.expand '%:p'
  local line_number = vim.fn.line '.'
  local okularcmd = 'okular --noraise "' .. 'build/main.pdf' .. '#src:' .. line_number .. ' ' .. this_tex_file .. '"'
  _G.Pid_okular = vim.fn.jobstart(okularcmd)
  if _G.Pid_okular <= 0 then
    print '_G.Pid_okular: could not launch okular'
  end
end
_G.Pdfmainstop = function()
  if _G.Pid_okular ~= nil and _G.Pid_okular > 0 then
    _ = vim.fn.jobstop(_G.Pid_okular)
    _G.Pid_okular = nil
  end
end
_G.Pdffigure = function()
  vim.fn.jobstart('okular figures/' .. vim.fn.expand '%:t:r' .. '.pdf')
end

_G.Repltikzthis = function()
  local bashcmd = [[cd figures; watchexec -w ]]
    .. vim.fn.expand '%:t'
    .. [[ "lualatex --shell-escape '\def\zzz{']]
    .. vim.fn.expand '%:t'
    .. [['} \input myscript.tex'"]]
  --print(bashcmd)
  local cmd = 'terminal ' .. bashcmd
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Repltikzall = function()
  local cmd = "terminal cd figures; watchexec -e tikz './build_tikz.sh'"
  print(cmd)
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Repllualatex = function()
  local cmd = "terminal latexmk -pvc -pdflatex='lualatex --file-line-error --synctex=1' -pdf -outdir=build main.tex"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Replpdflatex = function()
  --local cmd = "terminal watchexec -e tex 'latexmk -pdf -outdir=build main.tex'"
  local cmd = "terminal latexmk -pdflatex='pdflatex -file-line-error -synctex=1' -pvc -pdf -outdir=build main.tex"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end

_G.ReplpdeAll = function()
  local cmd =
    "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests && ./pde'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.ReplpdeTest = function()
  -- "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests'"
  local cmd =
    "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./test_pde'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.ReplpdeTestgdb = function()
  local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst 'make -j8 && gdb -ex run ./runTests'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Buildpde = function()
  local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Test123 = function()
  local cmd = 'terminal echo ${HOME}'
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end

-- command! Pdfmain :lua Pdfmain()
vim.api.nvim_exec(
  [[
if expand('%:e') == 'tex'
  command! Pmsta :lua Pdfmainstart()
  command! Pmsto :lua Pdfmainstop()
  command! Pdffigure :lua Pdffigure()
  command! Repllualatex :lua Repllualatex()
  command! Replpdflatex :lua Replpdflatex()
  command! Repltikzall :lua Repltikzall()
  command! Repltikzthis :lua Repltikzthis()
endif
command! ReplpdeAll :lua Replpde()
command! ReplpdeTest :lua ReplpdeTest()
command! ReplpdeTestgdb :lua ReplpdeTest()
command! Buildpde :lua Buildpde()
command! Test123 :lua Test123()
]],
  false
)
