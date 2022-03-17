local add_cmd = vim.api.nvim_add_user_command
local cmd_tn = 'edit ' .. os.getenv 'HOME' .. '/.config/nvim/'
add_cmd('CCmd', cmd_tn .. 'lua/my_cmds.lua', {})
add_cmd('CDap', cmd_tn .. 'lua/my_dap.lua', {})
add_cmd('CGl', cmd_tn .. 'lua/my_globals.lua', {})
add_cmd('CGs', cmd_tn .. 'lua/my_gitsign.lua', {})
add_cmd('CInit', cmd_tn .. 'init.lua', {})
add_cmd('CKey', cmd_tn .. 'lua/my_keymaps.lua', {})
add_cmd('CLsp', cmd_tn .. 'lua/my_lsp.lua', {})
add_cmd('COpts', cmd_tn .. 'lua/my_opts.lua', {})
add_cmd('CPl', cmd_tn .. 'lua/my_packer.lua', {})
add_cmd('CSt', cmd_tn .. 'lua/my_statusline.lua', {})
add_cmd('CTel', cmd_tn .. 'lua/my_telesc.lua', {})
add_cmd('CTre', cmd_tn .. 'lua/my_treesitter.lua', {})
add_cmd('CRel', function()
  local lua_dirs = vim.fn.glob('./lua/*', 0, 1)
  for _, dir in ipairs(lua_dirs) do
    dir = string.gsub(dir, './lua/', '')
    require('plenary.reload').reload_module(dir)
  end
  -- TODO keybindings and plugin cache are not reloaded
end, {})
-- TODO command that executes last command by sending content to open shell

add_cmd('Replpdflatex', function()
  --local cmd = "terminal watchexec -e tex 'latexmk -pdf -outdir=build main.tex'"
  local filename = vim.fn.expand '%'
  local cmd = "terminal latexmk -pdflatex='pdflatex -file-line-error -synctex=1' -pvc -pdf -outdir=build " .. filename
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})

add_cmd('Repltikzall', function()
  local cmd = "terminal cd figures; watchexec -e tikz './build_tikz.sh'"
  print(cmd)
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})

--map('v', '<leader>b', '"+y', opts)
---- TODO call a lua function to call correct builder
--buf_cwd = getcwd(0)
--=> zig build, if build.zig exists in current folder
--=> better use proper harpoon functions

--add_cmd(
--    'Build',
--    function()
--buf_cwd = getcwd(0)
--        local foldername = vim.fn.expand('%') -- root folder, where (neo)vim was opened
--        local cmd = "terminal latexmk -pdflatex='pdflatex -file-line-error -synctex=1' -pvc -pdf -outdir=build " .. filename
--        vim.cmd 'tabnew'
--        vim.cmd(cmd)
--    end,
--    {}
--)
-- TODO command to invoke chepa
--add_cmd(
--    'Chepa',
--    function()
--        --run command and thats it buf_cwd = vim.fn.getcwd(0)
--    end,
--    {}
--)

-- :enew | .!ls (only useful, if cleaning up buffers is faste)
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
add_cmd('Pmsta', function()
  local this_tex_file = vim.fn.expand '%:p'
  local line_number = vim.fn.line '.'
  local okularcmd = 'okular --noraise "' .. 'build/main.pdf' .. '#src:' .. line_number .. ' ' .. this_tex_file .. '"'
  _G.Pid_okular = vim.fn.jobstart(okularcmd)
  if _G.Pid_okular <= 0 then
    print '_G.Pid_okular: could not launch okular'
  end
end, {})
add_cmd('Pmsto', function()
  if _G.Pid_okular ~= nil and _G.Pid_okular > 0 then
    _ = vim.fn.jobstop(_G.Pid_okular)
    _G.Pid_okular = nil
  end
end, {})
add_cmd('Pdffigure', function()
  vim.fn.jobstart('okular figures/' .. vim.fn.expand '%:t:r' .. '.pdf')
end, {})

add_cmd('Repltikzthis', function()
  local bashcmd = [[cd figures; watchexec -w ]]
    .. vim.fn.expand '%:t'
    .. [[ "lualatex --shell-escape '\def\zzz{']]
    .. vim.fn.expand '%:t'
    .. [['} \input myscript.tex'"]]
  --print(bashcmd)
  local cmd = 'terminal ' .. bashcmd
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})
add_cmd('Repllualatex', function()
  local cmd = "terminal latexmk -pvc -pdflatex='lualatex --file-line-error --synctex=1' -pdf -outdir=build main.tex"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})
add_cmd('ReplpdeAll', function()
  local cmd =
    "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests && ./pde'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})
add_cmd('ReplpdeTest', function()
  -- "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests'"
  local cmd =
    "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./test_pde'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})
add_cmd('ReplpdeTestgdb', function()
  local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst 'make -j8 && gdb -ex run ./runTests'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})
add_cmd('Buildpde', function()
  local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})
add_cmd('Test123', function()
  local cmd = 'terminal echo ${HOME}'
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end, {})

-- ideas to configure buffer stuff, ie with toggleterm used here:
--local files = {
--  python = "python3 -i " .. exp("%:t"),
--  lua = "lua " .. exp("%:t"),
--  c = "gcc -o temp " .. exp("%:t") .. " && ./temp && rm ./temp",
--  cpp = "clang++ -o temp " .. exp("%:t") .. " && ./temp && rm ./temp",
--  java = "javac "
--    .. exp("%:t")
--    .. " && java "
--    .. exp("%:t:r")
--    .. " && rm *.class",
--  rust = "cargo run",
--  javascript = "node " .. exp("%:t"),
--  typescript = "tsc " .. exp("%:t") .. " && node " .. exp("%:t:r") .. ".js",
--}
--function Run_file()
--  local command = files[vim.bo.filetype]
--  if command ~= nil then
--    Open_term:new({ cmd = command, close_on_exit = false }):toggle()
--    print("Running: " .. command)
--  end
--end
