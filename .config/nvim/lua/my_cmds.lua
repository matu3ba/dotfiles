--! Commands not part of hydra or closely related derived ones
-- luacheck: globals vim
-- luacheck: no max line length
--==Dependencies
local has_plenary, plenary = pcall(require, 'plenary')
if not has_plenary then vim.print 'Please install plenary for all features.' end

--==Globals
local api = vim.api
local utils = require 'my_utils'
local home = nil
if utils.is_windows == true then
  home = os.getenv 'HOMEPATH'
  assert(home ~= nil)
else
  home = os.getenv 'HOME'
  assert(home ~= nil)
end
local sep = utils.path_separator

--==edit_config
local add_cmd = api.nvim_create_user_command -- NOTE: lua does not follow symlinks
local config_edit = 'edit ' .. home .. sep .. 'dotfiles' .. sep .. '.config' .. sep .. 'nvim'
-- local config_edit = vim.fn.stdpath 'config' -- does not work on nix
add_cmd('CAer', config_edit .. sep .. 'lua' .. sep .. 'my_aerial.lua', {})
add_cmd('CBuf', config_edit .. sep .. 'lua' .. sep .. 'my_buf.lua', {})
add_cmd('CCmd', config_edit .. sep .. 'lua' .. sep .. 'my_cmds.lua', {})
add_cmd('CDap', config_edit .. sep .. 'lua' .. sep .. 'my_dap.lua', {})
add_cmd('CGdb', config_edit .. sep .. 'lua' .. sep .. 'my_gdb.lua', {})
add_cmd('CGs', config_edit .. sep .. 'lua' .. sep .. 'my_gitsign.lua', {})
add_cmd('CHa', config_edit .. sep .. 'lua' .. sep .. 'my_harpoon.lua', {})
add_cmd('CHydra', config_edit .. sep .. 'lua' .. sep .. 'my_hydra.lua', {})
add_cmd('CInit', config_edit .. sep .. 'init.lua', {})
add_cmd('CKey', config_edit .. sep .. 'lua' .. sep .. 'my_keymaps.lua', {})
add_cmd('CLi', config_edit .. sep .. 'lua' .. sep .. 'my_lint.lua', {})
add_cmd('CLsp', config_edit .. sep .. 'lua' .. sep .. 'my_lsp.lua', {})
add_cmd('COil', config_edit .. sep .. 'lua' .. sep .. 'my_oil.lua', {})
add_cmd('COpts', config_edit .. sep .. 'lua' .. sep .. 'my_opts.lua', {})
add_cmd('COver', config_edit .. sep .. 'lua' .. sep .. 'my_over.lua', {})
add_cmd('CPl', config_edit .. sep .. 'lua' .. sep .. 'my_plugins.lua', {})
add_cmd('CSt', config_edit .. sep .. 'lua' .. sep .. 'my_statusline.lua', {})
add_cmd('CSu', config_edit .. sep .. 'lua' .. sep .. 'my_surround.lua', {})
add_cmd('CJfi', config_edit .. sep .. 'lua' .. sep .. 'my_jfind.lua', {})
add_cmd('CTel', config_edit .. sep .. 'lua' .. sep .. 'my_telesc.lua', {})
add_cmd('CTre', config_edit .. sep .. 'lua' .. sep .. 'my_treesitter.lua', {})
add_cmd('CUtil', config_edit .. sep .. 'lua' .. sep .. 'my_utils.lua', {})

local lazy_packs_dir_edit = 'edit ' .. vim.fn.stdpath("data")
add_cmd('DLazy', lazy_packs_dir_edit .. sep .. 'lazy/', {})

local df_edit = 'edit ' .. home .. sep .. 'dotfiles'
local df_configs_edit = df_edit .. sep .. '.config'
local df_config_shells_edit = df_configs_edit .. sep .. 'shells'
local df_scr_edit = df_edit .. sep .. 'scr'
add_cmd('Dotf', df_edit, {})
add_cmd('Scripts', df_scr_edit, {})
add_cmd('Config', df_configs_edit, {})
add_cmd('Ghostty', df_configs_edit .. sep .. 'ghostty' .. sep .. 'config', {})
add_cmd('Aliases', df_config_shells_edit .. sep .. 'aliases', {})
add_cmd('AliasesGit', df_config_shells_edit .. sep .. 'aliases_git', {})
add_cmd('Templates', df_edit .. sep .. 'templates', {})
add_cmd('Zigstd', 'edit ' .. home .. sep .. 'dev' .. sep .. 'zdev' .. sep
  .. 'zig' .. sep .. 'master' .. sep .. 'lib' .. sep .. 'std', {})
add_cmd('ZigFmtAll', '! zig fmt .', {})

if utils.is_windows == false then
  -- we cant or dont want to unify all bashrcs
  local bashrc_edit = 'edit ' .. home .. sep .. 'dotfiles' .. sep .. '.bashrc'
  local fishrc_edit = 'edit ' .. home .. sep .. 'dotfiles' .. sep .. '.config' .. sep .. 'fish' .. sep .. 'config.fish'
  add_cmd('Bashrc', bashrc_edit, {})
  add_cmd('Fishrc', fishrc_edit, {})
else
  local ps_config_edit = 'edit ' .. home .. '\\dotfiles\\windows\\Documents\\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1'
  add_cmd('PSConf', ps_config_edit, {})
  local pws_config_edit = 'edit ' .. home .. '\\dotfiles\\windows\\Documents\\PowerShell\\Microsoft.PowerShell_profile.ps1'
  add_cmd('PWConf', pws_config_edit, {})
  local df_write = '! ' .. home .. '\\dotfiles\\fileOverwrite.ps1'
  add_cmd('DotfWrite', df_write, {})
  add_cmd('RmShada', '! rm ' .. vim.fn.stdpath("data") .. '\\shada\\main.shada.tmp.X', {})
end


-- Visit mappings, commands and autocommands:
-- :map, :command. :autocmd

add_cmd('Style', function(opts) require('material.functions').change_style(opts.args) end, {
  nargs = 1,
  complete = function(_, _, _) return { 'darker', 'lighter', 'palenight', 'oceanic', 'deep ocean' } end,
})
--map('v', '<leader>b', '"+y', opts)
--buf_cwd = getcwd(0)
--=> zig build, if build.zig exists in current folder
--=> better use proper harpoon functions

-- lualatex --file-line-error --synctex=1 --output-directory=build

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
-- idea command to invoke chepa
--add_cmd(
--    'Chepa',
--    function()
--        --run command and thats it buf_cwd = vim.fn.getcwd(0)
--    end,
--    {}
--)

-- :enew | .!ls (only useful, if cleaning up buffers is faste)
add_cmd('Bda', [[:bufdo :bdelete]], {}) -- deleting all buffers except current one

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

--==nvim_latex
_G.Pid_okular = nil
add_cmd('Pmsta', function()
  local this_tex_file = vim.fn.expand '%:p'
  local line_number = vim.fn.line '.'
  local okularcmd = 'okular --noraise "' .. 'build' .. sep .. 'main.pdf' .. '#src:' .. line_number .. ' ' .. this_tex_file .. '"'
  _G.Pid_okular = vim.fn.jobstart(okularcmd)
  if _G.Pid_okular <= 0 then print '_G.Pid_okular: could not launch okular' end
end, {})
add_cmd('Pmsto', function()
  if _G.Pid_okular ~= nil and _G.Pid_okular > 0 then
    local _ = vim.fn.jobstop(_G.Pid_okular)
    _G.Pid_okular = nil
  end
end, {})
add_cmd('Pdffigure', function() vim.fn.jobstart('okular figures' .. sep .. vim.fn.expand '%:t:r' .. '.pdf') end, {})

-- prints either nt or n
-- add_cmd('Printmode', function() print(api.nvim_get_mode().mode) end, {})

-- add_cmd('Replpdflatex', function()
--   --local cmd = "terminal watchexec -e tex 'latexmk -pdf -outdir=build main.tex'"
--   local filename = vim.fn.expand '%'
--   local cmd = "terminal latexmk -pdflatex='pdflatex -file-line-error -synctex=1' -pvc -pdf -outdir=build " .. filename
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('Repllualatex', function()
--   local cmd = "terminal latexmk -pvc -pdflatex='lualatex --file-line-error --synctex=1' -pdf -outdir=build main.tex"
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('Repltikzall', function()
--   local cmd = "terminal cd figures; watchexec -e tikz './build_tikz.sh'"
--   print(cmd)
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('Repltikzthis', function()
--   local bashcmd = [[cd figures; watchexec -w ]]
--     .. vim.fn.expand '%:t'
--     .. [[ "lualatex --shell-escape '\def\zzz{']]
--     .. vim.fn.expand '%:t'
--     .. [['} \input myscript.tex'"]]
--   --print(bashcmd)
--   local cmd = 'terminal ' .. bashcmd
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('ReplpdeAll', function()
--   local cmd =
--     "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests && ./pde'"
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('ReplpdeTest', function()
--   -- "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests'"
--   local cmd =
--     "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./test_pde'"
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('ReplpdeTestgdb', function()
--   local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst 'make -j8 && gdb -ex run ./runTests'"
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('Buildpde', function()
--   local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8'"
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})
-- add_cmd('Test123', function()
--   local cmd = 'terminal echo ${HOME}'
--   vim.cmd 'tabnew'
--   vim.cmd(cmd)
-- end, {})

--==nvim_spacetab
add_cmd('Spacelen2', function()
  vim.bo.expandtab = true --expand tabs to spaces
  vim.bo.shiftwidth = 2 --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop = 2 --Tab key: number of spaces for indendation
end, {})
add_cmd('Spacelen4', function()
  vim.bo.expandtab = true --expand tabs to spaces
  vim.bo.shiftwidth = 4 --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop = 4 --Tab key: number of spaces for indendation
end, {})
add_cmd('Spacelen8', function()
  vim.bo.expandtab = true --expand tabs to spaces
  vim.bo.shiftwidth = 8 --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop = 8 --Tab key: number of spaces for indendation
end, {})
add_cmd('Tablen2', function()
  vim.bo.expandtab = false --expand tabs to spaces
  vim.bo.shiftwidth = 2 --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop = 2 --Tab key: number of spaces for indendation
end, {})
add_cmd('Tablen4', function()
  vim.bo.expandtab = false --expand tabs to spaces
  vim.bo.shiftwidth = 4 --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop = 4 --Tab key: number of spaces for indendation
end, {})
add_cmd('Tablen8', function()
  vim.bo.expandtab = false --expand tabs to spaces
  vim.bo.shiftwidth = 8 --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop = 8 --Tab key: number of spaces for indendation
end, {})

--==macros ----
-- stylua: ignore start
-- move "string" left of text in (text == "string")
-- use case: :ISwap is broken
--f=hveldvf"dbPa == ^jj
-- convert
--   QFETCH(std::string>("received_message");
-- to
--   QFETCH(std::string, received_message);
--f(f(xxhr,a üC$hhx^j
-- stylua: ignore end

--==regex
-- non-greedy search of \"..\" fields
add_cmd('SelLazyEscStr', [[/\\".\{-}\\"]], {}) -- non-greedy search of \"..\" fields
add_cmd('SelLazyStr', [[/".\{-}"]], {}) -- non-greedy search of \"..\" fields

--==debug
add_cmd('CoutDebug', [[execute 'normal! i' . 'std::cout << DEBUG << "\n";    // DEBUG' . '<Esc>']], {})
add_cmd('RmBufDebug', [[execute 'g/.*DEBUG$/del']], {}) -- non-greedy search of \"..\" fields

--==harpoon
-- send all quickfixlist files to harpoon
add_cmd('HSend', [[:cfdo lua require("harpoon.mark").add_file()]], {})

---- Quickfixlist ----
-- nvim -q
-- :cexpr getline(1, '$')
-- TODO parsing bare paths of buffer and use in qflist with :h setqflist()
-- Press <C-q> to add telescope results to quickfixlist
-- :copen opens, :ccl closes quickfixlist, C-w K moves qf list to top.
-- See :h :cdo for more help
-- :cfdo :badd %
-- add to harpoon
-- Review changes with diff before writing file
-- :w !diff % -

---- Scripting ----
-- copy path under cursor: yiW
-- pull current filename into where you are: Ctrl+R %
-- vimscript register assignment: :let @+ = expand("%:p")
-- Note: Relative paths are only respected until cwd. If the path goes via parent dir, the absolute path is returned.
-- TODO setup copy file + dir path for oil with harpoon
-- https://github.com/stevearc/oil.nvim/issues/50

local setPlusAnd0Register = function(content)
  vim.fn.setreg('0', content)
  -- if vim.fn.hasclip
  vim.fn.setreg('+', content)
end

--==nvim_path
--- Sets + register with path [[:line]:column]
---@param path string Path to set.
---@param line integer|nil Optional line to append
---@param column integer|nil Optional column to append
local setCursorInfo = function(path, line, column)
  local str = path
  if line ~= nil then str = str .. ':' .. tostring(line) end
  if column ~= nil then str = str .. ':' .. tostring(column) end
  setPlusAnd0Register(str)
end

-- stylua: ignore start
-- copy cwd into register 0 and '+' register
-- TODO FWrel to provide in git readable format
local has_oil, oil = pcall(require, 'oil')
local has_myoil, myoil = pcall(require, 'my_oil')
if has_oil then
  assert(has_myoil)
  add_cmd('Oabs', function() setPlusAnd0Register(oil.get_current_dir()) end, {})
  add_cmd('Orel', function() setPlusAnd0Register(plenary.path:new(oil.get_current_dir()):make_relative()) end, {})
  if utils.is_windows then
    add_cmd('OExec', function() setPlusAnd0Register(myoil.pwshExec()) end, {})
    add_cmd('OCec', function() setPlusAnd0Register(myoil.pwshCdExec()) end, {})
  else
    -- add_cmd('OFExec', function() setPlusAnd0Register(myoil.fishExec) end, {})
    -- add_cmd('OFCec', function() setPlusAnd0Register(myoil.fishCdExec) end, {})
    -- add_cmd('OExec', function() setPlusAnd0Register(myoil.posixExec) end, {})
    -- add_cmd('OCec', function() setPlusAnd0Register(myoil.posixCdExec) end, {})
  end


end

add_cmd('Frel', function() setPlusAnd0Register(plenary.path:new(api.nvim_buf_get_name(0)):make_relative()) end, {})
add_cmd('FrelDir', function() setPlusAnd0Register(vim.fs.dirname(plenary.path:new(api.nvim_buf_get_name(0)):make_relative())) end, {})
add_cmd('FrelLine', function() setCursorInfo(plenary.path:new(api.nvim_buf_get_name(0)):make_relative(), api.nvim_win_get_cursor(0)[1], nil) end, {})
add_cmd('FrelCol', function()
  local line_col_pair = api.nvim_win_get_cursor(0)
  setCursorInfo(plenary.path:new(api.nvim_buf_get_name(0)):make_relative(), line_col_pair[1], line_col_pair[2])
end, {})
add_cmd('Fabs', function() setPlusAnd0Register(api.nvim_buf_get_name(0)) end, {})
add_cmd('FabsDir', function() setPlusAnd0Register(vim.fs.dirname(api.nvim_buf_get_name(0))) end, {})
add_cmd('FabsLine', function() setCursorInfo(api.nvim_buf_get_name(0), api.nvim_win_get_cursor(0)[1], nil) end, {})
add_cmd('FabsCol', function()
  local line_col_pair = api.nvim_win_get_cursor(0)
  setCursorInfo(api.nvim_buf_get_name(0), line_col_pair[1], line_col_pair[2])
end, {})
add_cmd('Fonly', function() setPlusAnd0Register(vim.fs.basename(api.nvim_buf_get_name(0))) end, {})
add_cmd('FLine', function() setCursorInfo(vim.fs.basename(api.nvim_buf_get_name(0)), api.nvim_win_get_cursor(0)[1], nil) end, {})
add_cmd('FCol', function()
  local line_col_pair = api.nvim_win_get_cursor(0)
  setCursorInfo(vim.fs.basename(api.nvim_buf_get_name(0)), line_col_pair[1], line_col_pair[2])
end, {})
add_cmd('ShAbsPath', function() print(vim.fn.expand '%:p') end, {})
add_cmd('ShDate', function() print(os.date()) end, {})
-- stylua: ignore end

--==zig
-- Retag only local files with https://github.com/gpanders/ztags
-- Use zls for the rest. To index everything, ramfs (/tmp) would
-- be probably best with
-- ```
--   PWD=$(pwd)
--   TMPPWD="/tmp/${PWD}"
--   mkdir -p "${TMPPWD}"
--   SRCPATH="${TMPPWD}/srcfiles"
--   ZIGPATH="${HOME}/dev/git/zi/zig/master/"
--   cd "${ZIGPATH}"
--   fd '${ZIGPATH}/.*.zig' src > "${SRCPATH}"
--   fd '${ZIGPATH}/.*.zig' lib/std >>"${SRCPATH}"
--   fd '.*.zig' lib/std >>"${SRCPATH}"
--   FILES=$(cat "${SRCPATH}")
--   ztags $FILES
--   if ! test -f "tags"; then (echo "no tags file"; exit 1); fi
-- ```
-- NOTE: vimscript wants us to use a list and substitute refuses to work
-- Output capturing from shell is unnecessary (io.popen)
-- api.nvim_exec(
-- [[
-- let b:filelist = systemlist("fd '.*.zig'")
-- let b:files = join(b:filelist, ' ')
-- let b:ztags_cmd = "ztags " . b:files
-- let b:res =  system(b:ztags_cmd)
-- ]], false)
-- FILES=$(fd '.*.zig' src/ lib/std/)
-- ztags -a -r $FILES
add_cmd('RetagZigComp', function()
  -- if vim.bo.filetype == 'zig' then
  -- FILES=$(fd -e zig . 'src/' 'lib/std/') && ztags -a -r $FILES
  local fd_exec = plenary.job:new({ command = 'fd', args = { '-e', 'zig', 'src', 'lib' .. sep .. 'std' } }):sync()
  -- print("fd_exec", vim.print(fd_exec))
  plenary.job:new({ command = 'ztags', args = { '-a', '-r', unpack(fd_exec) } }):start()
  -- end
end, {})
add_cmd('RetagZig', function()
  -- if vim.bo.filetype == 'zig' then
  local fd_exec = plenary.job:new({ command = 'fd', args = { '-e', 'zig', 'src' } }):sync()
  plenary.job:new({ command = 'ztags', args = { '-a', '-r', unpack(fd_exec) } }):start()
  -- end
end, {})

-- TODO proper parsing to distinguish https/http,git@
-- @return upstream remote else origin remote else empty string
local git_show_remote_upstream_else_origin = function(cwd)
  -- git remote show origin
  -- git config --get remote.origin.url
  local remote = plenary.job:new({ cwd = cwd, command = 'git', args = { 'config', '--get', 'remote.upstream.url' } }):sync()
  if (remote and #remote == 1 and remote[1] ~= "") then
    local col_i = string.find(remote[1], ':')
    return remote[1]:sub(5, col_i-1) .. '/' .. remote[1]:sub(col_i+1, -5)
  end
  remote = plenary.job:new({ cwd = cwd, command = 'git', args = { 'config', '--get', 'remote.origin.url' } }):sync()
  if (remote and #remote == 1 and remote[1] ~= "") then
    return remote[1]:sub(5,-1):sub(1,-5)
  end
  return ""
end

-- https://github.com/nvim-lua/plenary.nvim/ /blob/master/ tests/plenary/job_spec.lua
-- /blob/5129a3693c482fcbc5ab99a7706ffc4360b995a0/
add_cmd('GHPerma', function()
  local relpath = plenary.path:new(api.nvim_buf_get_name(0)):make_relative()
  local relpathdir = vim.fs.dirname(relpath)
  local git_root = plenary.job:new({ cwd = relpathdir, command = 'git', args = { 'rev-parse', '--show-toplevel'} }):sync()
  if (not git_root or #git_root ~= 1 or git_root[1] == "") then return end
  local relpath_inrepo = plenary.path:new(relpath):make_relative(git_root[1])

  local isgit = plenary.job:new({ command = 'git', args = { 'rev-parse', '--is-inside-work-tree' } }):sync()
  if (not isgit or isgit[1] ~= "true") then return end
  local remote = git_show_remote_upstream_else_origin(git_root[1])
  vim.print(remote)
  if (remote == "") then return end
  local commitsha = plenary.job:new({ cwd = git_root[1], command = 'git', args = { 'rev-parse', 'HEAD' } }):sync()
  if (not commitsha or #commitsha ~= 1 or commitsha[1] == "") then return end
  local relpath_inrepo_check = plenary.job:new({ cwd = git_root[1], command = 'git', args = { 'ls-files', '--error-unmatch', relpath_inrepo } }):sync()
  vim.print(relpath_inrepo_check)
  if (not relpath_inrepo_check or #relpath_inrepo_check ~= 1 or relpath_inrepo_check[1] ~= relpath_inrepo) then return end
  local permalink = remote .. '/blob/' .. commitsha[1] .. '/' .. relpath_inrepo
  vim.print(permalink)
  setPlusAnd0Register(permalink)
end, {})
-- git branch: git rev-parse --abbrev-ref HEAD
-- add_cmd('GHLink', function()
--   local fd_exec = plenary.job:new({ command = 'fd', args = { '-e', 'zig', 'src' } }):sync()
--   plenary.job:new({ command = 'ztags', args = { '-a', '-r', unpack(fd_exec) } }):start()
-- end, {})
-- idea
-- add_cmd('GHRepo', function()
--   git remote show origin
--   git remote show upstream
--   local fd_exec = plenary.job:new({ command = 'fd', args = { '-e', 'zig', 'src' } }):sync()
--   plenary.job:new({ command = 'ztags', args = { '-a', '-r', unpack(fd_exec) } }):start()
-- end, {})
-- add_cmd('GHDown', function()
  -- TODO
--   local fd_exec = plenary.job:new({ command = 'fd', args = { '-e', 'zig', 'src' } }):sync()
--   plenary.job:new({ command = 'ztags', args = { '-a', '-r', unpack(fd_exec) } }):start()
-- end, {})

--==luafmt
-- https://github.com/nvim-lua/plenary.nvim/issues/474 prevents us from
-- using plenary for spawning another neovim instance like this:
-- add_cmd('CheckTests', function()
--   -- luacheck: push ignore
--   local tests_run = plenary.job:new({ command = 'nvim', args = { '--headless', '--noplugin', '-u', 'tests/minimal.lua', '-c', [["PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.lua'}"]] } })
--   -- luacheck: pop ignore
--   tests_run:start()
--   tests_run:sync()
--   print(vim.inspect.inspect(tests_run:result()))
-- end, {})
add_cmd('CheckFmt', function()
  local stylua_run = plenary.job:new { command = 'stylua', args = { '--color', 'Never', '--check', '.' } }
  stylua_run:sync()
  if stylua_run.code ~= 0 then
    local res_tab = stylua_run:result()
    for _, tables in ipairs(res_tab) do
      print(tables)
    end
    -- print (vim.inspect(stylua_run:result()));
  end
end, {})
add_cmd('FmtThis', function()
  local stylua_run = plenary.job:new { command = 'stylua', args = { '--color', 'Never', '.' } }
  stylua_run:sync()
  if stylua_run.code ~= 0 then print [[Formatting had warning or error. Run 'stylua .']] end
end, {})

--==nvim_util
-- Reload init.lua
-- Reloading your config is not supported with lazy.nvim, use :so instead
-- add_cmd('Reloadconfig', function() require('my_utils').reloadconfig() end, {})
add_cmd('Listpackages', function() require('my_utils').listpackages() end, {})

_G.beforeTogWrap_colorcolumn = '0'
add_cmd('TogWrap', function()
  local tmpcolcol = _G.beforeTogWrap_colorcolumn
  _G.beforeTogWrap_colorcolumn = vim.wo.colorcolumn
  vim.wo.colorcolumn = tmpcolcol
  if vim.wo.wrap == true then
    vim.wo.wrap = false
  else
    vim.wo.wrap = true
  end
end, {})

add_cmd('PrintAllWinOptions', function()
  local win_number = api.nvim_get_current_win()
  local v = vim.wo[win_number]
  local all_options = api.nvim_get_all_options_info()
  local result = ''
  for key, val in pairs(all_options) do
    if val.global_local == false and val.scope == 'win' then result = result .. '|' .. key .. '=' .. tostring(v[key] or '<not set>') end
  end
  print(result)
end, {})

-- uv.tty_get_winsize() for terminal window size
-- Note: The conversion froom vim.fn.getwininfo looks abit broken with sigla table entries.
add_cmd('PrintAllTabInfos', function()
  local windows = api.nvim_tabpage_list_wins(0)
  local reg_wins = {}
  local i = 1
  for _, win in pairs(windows) do
    local cfg = vim.api.nvim_win_get_config(win) -- see nvim_open_win()
    -- check for absence of floating window
    if cfg.relative == '' then
      reg_wins[i] = {}
      local curwin_infos = vim.fn.getwininfo(win)
      -- reg_wins[i]["loclist"] = curwin_infos[1]["loclist"] -- unused
      -- reg_wins[i]["quickfix"] = curwin_infos[1]["quickfix"] -- unused
      -- reg_wins[i]["terminal"] = curwin_infos[1]["terminal"] --unused
      -- reg_wins[i]["topline"] = curwin_infos[1]["topline"] --unused
      -- reg_wins[i]["winbar"] = curwin_infos[1]["winbar"] -- unused
      reg_wins[i]['botline'] = curwin_infos[1]['botline'] -- botmost screen line
      reg_wins[i]['bufnr'] = curwin_infos[1]['bufnr'] -- buffer number
      reg_wins[i]['height'] = curwin_infos[1]['height'] -- window height excluding winbar
      reg_wins[i]['tabnr'] = curwin_infos[1]['tabnr']
      reg_wins[i]['textoff'] = curwin_infos[1]['textoff'] -- foldcolumn, signcolumn etc width
      reg_wins[i]['variables'] = curwin_infos[1]['variables'] --unused
      reg_wins[i]['width'] = curwin_infos[1]['width'] -- width (textoff to derive rightmost screen column)
      reg_wins[i]['wincol'] = curwin_infos[1]['wincol'] -- leftmost screen column of window
      reg_wins[i]['winid'] = curwin_infos[1]['winid']
      reg_wins[i]['winnr'] = curwin_infos[1]['winnr']
      reg_wins[i]['winrow'] = curwin_infos[1]['winrow'] -- topmost screen line

      -- included with offset + 1 in winrow, wincol
      local winpos = api.nvim_win_get_position(win) -- top left corner of window
      reg_wins[i]['row'] = winpos[1]
      reg_wins[i]['col'] = winpos[2]

      i = i + 1
    end
  end
  print(vim.inspect(reg_wins))
end, {})

add_cmd('PrintBuffersWithProperties', function()
  local bufprops = {}
  local bufs = api.nvim_list_bufs()
  -- local buf_loaded = nvim_buf_is_loaded()
  for _, v in ipairs(bufs) do
    local name = api.nvim_buf_get_name(v)
    local is_loaded = api.nvim_buf_is_loaded(v)
    local ty = vim.bo[v].buftype
    local is_ro = vim.bo[v].readonly
    local is_hidden = vim.bo[v].bufhidden
    local is_listed = vim.bo[v].buflisted
    -- print( i, ', ', v, 'name:', name, 'loaded:', is_loaded, 'ty:', ty, 'ro:', is_ro, 'is_hidden:', is_hidden, 'is_listed:', is_listed)
    -- readonly, bufhidden, buflisted
    local row = { name, is_loaded, ty, is_ro, is_hidden, is_listed }
    bufprops[v] = row
  end
  for i, v in pairs(bufprops) do
    print(i, ', ', vim.inspect(v))
  end
  return bufprops
end, {})

-- Note: There may be options arguments added with dash or dashdash.
add_cmd('PrintCliArgs', function()
  local args = 'cli args: '
  for _, v in ipairs(vim.v.argv) do
    args = args .. v .. ' '
  end
  print(args)
end, {})

--add_cmd('RunAsTask', function(params)
--  local bufname = vim.api.nvim_buf_get_name(0)
--  local cmd = params.args
--  -- If no args, use the last yanked text as the command
--  if cmd == "" then
--    cmd = vim.fn.getreg("")
--  end
--  -- If we're in a terminal, use the cwd of the terminal
--  local cwd
--  if vim.startswith(bufname, "term://") then
--    cwd = vim.fn.expand(vim.split(bufname, "//", { plain = true })[2])
--  end
--  require("overseer").run_template({ name = "shell", params = { cmd = cmd }, cwd = cwd })
--end, { args = "*" })

-- source code for session creation with internal data representation is very convoluted
-- add_cmd('MksessTabView', function()
--   -- TODO ensure 1 arg and use it as filepath
--   local old_sessopts = vim.o.sessionoptions
--   vim.o.sessionoptions = "blank,buffers,help,skiprtp,terminal,winsize"
--   vim.cmd[[mksession tabviewsess]]
--   vim.o.sessionoptions = old_sessopts
-- end, {})
-- idea optional argument in which register to copy the file path
--
--:%!jq

-- :Man for man page.
-- local mappings: K or C-], C-t, gO for outline

-- inbuild commands
-- :sort [u for unique lines] [n for numerical]