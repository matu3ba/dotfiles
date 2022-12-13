---- Dependencies ----
local has_plenary, plenary = pcall(require, 'plenary')
if not has_plenary then
  error('Please install plenary for all features.')
end
local utils = require 'my_utils'

---- Configuration files editing ----
local add_cmd = vim.api.nvim_create_user_command
local nvim_edit = 'edit ' .. os.getenv 'HOME' .. '/.config/nvim/'
add_cmd('CCmd', nvim_edit .. 'lua/my_cmds.lua', {})
add_cmd('CDap', nvim_edit .. 'lua/my_dap.lua', {})
add_cmd('CGs', nvim_edit .. 'lua/my_gitsign.lua', {})
add_cmd('CGdb', nvim_edit .. 'lua/my_gdb.lua', {})
add_cmd('CHa', nvim_edit .. 'lua/my_harpoon.lua', {})
add_cmd('CInit', nvim_edit .. 'init.lua', {})
add_cmd('CKey', nvim_edit .. 'lua/my_keymaps.lua', {})
add_cmd('CNvimcmp', nvim_edit .. 'lua/my_nvimcmp.lua', {})
--add_cmd('CLsp', nvim_edit .. 'lua/my_lsp.lua', {})
add_cmd('COpts', nvim_edit .. 'lua/my_opts.lua', {})
add_cmd('CPl', nvim_edit .. 'lua/my_packer.lua', {})
add_cmd('CSt', nvim_edit .. 'lua/my_statusline.lua', {})
add_cmd('CTel', nvim_edit .. 'lua/my_telesc.lua', {})
add_cmd('CTre', nvim_edit .. 'lua/my_treesitter.lua', {})
add_cmd('CUtil', nvim_edit .. 'lua/my_utils.lua', {})
add_cmd('CHydra', nvim_edit .. 'lua/my_hydra.lua', {})

local df_edit = 'edit ' .. os.getenv 'HOME' .. '/dotfiles/'
add_cmd('Dotfiles', df_edit, {})
local df_configs_edit = 'edit ' .. os.getenv 'HOME' .. '/dotfiles/.config/'
add_cmd('Config', df_configs_edit, {})
local aliases_edit = 'edit ' .. os.getenv 'HOME' .. '/dotfiles/.config/shells/aliases'
add_cmd('Aliases', aliases_edit, {})
local aliases_git_edit = 'edit ' .. os.getenv 'HOME' .. '/dotfiles/.config/shells/aliases_git'
add_cmd('AliasesGit', aliases_git_edit, {})
local templates_git_edit = 'edit ' .. os.getenv 'HOME' .. '/dotfiles/templates/'
add_cmd('Templates', templates_git_edit, {})
-- we cant or dont want to unify all bashrcs
local bashrc_edit = 'edit ' .. os.getenv 'HOME' .. '/.bashrc'
add_cmd('Bashrc', bashrc_edit, {})

-- Visit mappings, commands and autocommands:
-- :map, :command. :autocmd

-- Reload init.lua
add_cmd('Reloadconfig', function() require('my_utils').reloadconfig() end, {})
add_cmd('Listpackages', function() require('my_utils').listpackages() end, {})
--plenary is broken with both
-- add_cmd('Reloadconfig', function() plenary.reload.reload_module("my_.*", true) end, {})
-- add_cmd('Reloadconfig', function() plenary.reload.reload_module("my_.*", false) end, {})

add_cmd('Style',
  function(opts)
    require('material.functions').change_style(opts.args)
  end, {
    nargs = 1,
    complete = function(_, _, _)
      return { "darker", "lighter", "palenight", "oceanic", "deep ocean" }
    end,
  }
)

-- vim.keymap.set("n", "<leader>sv", "", {
--   silent = true,
--   desc = "reload init.lua",
--   callback = function()
--     vim.cmd([[
--       update $MYVIMRC
--       source $MYVIMRC
--     ]])
--     vim.notify("Nvim config successfully reloaded!", vim.log.levels.INFO, { title = "nvim-config" })
--   end,
-- })

--map('v', '<leader>b', '"+y', opts)
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
-- idea command to invoke chepa
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

-- prints either nt or n
-- add_cmd('Printmode', function() print(vim.api.nvim_get_mode().mode) end, {})

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

---- Macros ----
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

---- Regex ----
-- non-greedy search of \"..\" fields
add_cmd('SelLazyEscStr', [[/\\".\{-}\\"]], {}) -- non-greedy search of \"..\" fields

---- Debug ----
add_cmd('CoutDebug', [[execute 'normal! i' . 'std::cout << DEBUG << "\n";    // DEBUG' . '<Esc>']], {})
add_cmd('RmBufDebug', [[execute 'g/.*DEBUG$/del']], {}) -- non-greedy search of \"..\" fields

---- Harpoon ----
-- send all quickfixlist files to harpoon
add_cmd('HSend', [[:cfdo lua require("harpoon.mark").add_file()]], {})

---- Quickfixlist ----
--<C-q>f to telescope results to quickfixlist
-- there is no quickfixlists overview (how many quickfixlists exist)
-- See :h :cdo for more help
-- :cfdo :badd %
-- add to harpoon

---- Scripting ----
-- copy path under cursor: yiW
-- pull current filename into where you are: Ctrl+R %
-- vimscript register assignment: :let @+ = expand("%:p")
-- Note: Relative paths are only respected until cwd. If the path goes via parent dir, the absolute path is returned.
add_cmd('Frel', function() vim.fn.setreg('+', plenary.path:new(vim.api.nvim_buf_get_name(0)):make_relative()) end, {}) -- copy relative path
add_cmd('FrelDir', function() vim.fn.setreg('+', vim.fs.dirname(plenary.path:new(vim.api.nvim_buf_get_name(0)):make_relative())) end, {}) -- copy relative path dir
add_cmd('Fabs', function() vim.fn.setreg('+', vim.api.nvim_buf_get_name(0)) end, {}) -- absolute path
add_cmd('FabsDir', function() vim.fn.setreg('+', vim.fs.dirname(vim.api.nvim_buf_get_name(0))) end, {}) -- absolute path dir
add_cmd('Fonly', function() vim.fn.setreg('+', vim.fs.basename(vim.api.nvim_buf_get_name(0))) end, {}) -- only filename
add_cmd('Fline', function()
  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
  local lineNum = vim.api.nvim_win_get_cursor(0)[1]
  vim.fn.setreg('+', fname .. ':' .. tostring(lineNum))
end, {}) -- copy filename:line
add_cmd('Fcolumn', function()
  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
  local line_col_pair = vim.api.nvim_win_get_cursor(0) -- row is 1, column is 0 indexed
  vim.fn.setreg('+', fname .. ':' .. tostring(line_col_pair[1]) .. ':' .. tostring(line_col_pair[2]))
end, {}) -- copy filename:line:column
-- ssh
add_cmd('FrelS', function() vim.fn.setreg('s', plenary.path:new(vim.api.nvim_buf_get_name(0)):make_relative()) end, {}) -- copy relative path
add_cmd('FrelDirS', function() vim.fn.setreg('s', vim.fs.dirname(plenary.path:new(vim.api.nvim_buf_get_name(0)):make_relative())) end, {}) -- copy relative path dir
add_cmd('FabsS', function() vim.fn.setreg('s', vim.api.nvim_buf_get_name(0)) end, {}) -- absolute path
add_cmd('FabsDirS', function() vim.fn.setreg('s', vim.fs.dirname(vim.api.nvim_buf_get_name(0))) end, {}) -- absolute path dir
add_cmd('FonlyS', function() vim.fn.setreg('s', vim.fs.basename(vim.api.nvim_buf_get_name(0))) end, {}) -- only filename
add_cmd('FlineS', function()
  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
  local lineNum = vim.api.nvim_win_get_cursor(0)[1]
  vim.fn.setreg('s', fname .. ':' .. tostring(lineNum))
end, {}) -- copy filename:line
add_cmd('FcolumnS', function()
  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
  local line_col_pair = vim.api.nvim_win_get_cursor(0) -- row is 1, column is 0 indexed
  vim.fn.setreg('s', fname .. ':' .. tostring(line_col_pair[1]) .. ':' .. tostring(line_col_pair[2]))
end, {}) -- copy filename:line:column

if utils.IsWSL() then
  add_cmd('FrelW', function() vim.fn.setreg('w', plenary.path:new(vim.api.nvim_buf_get_name(0)):make_relative()) end, {}) -- copy relative path
  add_cmd('FrelDirW', function() vim.fn.setreg('w', vim.fs.dirname(plenary.path:new(vim.api.nvim_buf_get_name(0)):make_relative())) end, {}) -- copy relative path dir
  add_cmd('FabsW', function() vim.fn.setreg('w', vim.api.nvim_buf_get_name(0)) end, {}) -- absolute path
  add_cmd('FabsDirW', function() vim.fn.setreg('w', vim.fs.dirname(vim.api.nvim_buf_get_name(0))) end, {}) -- absolute path dir
  add_cmd('FonlyW', function() vim.fn.setreg('w', vim.fs.basename(vim.api.nvim_buf_get_name(0))) end, {}) -- only filename
  add_cmd('FlineW', function()
    local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
    local lineNum = vim.api.nvim_win_get_cursor(0)[1]
    vim.fn.setreg('w', fname .. ':' .. tostring(lineNum))
  end, {}) -- copy filename:line
  add_cmd('FcolumnW', function()
    local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
    local line_col_pair = vim.api.nvim_win_get_cursor(0) -- row is 1, column is 0 indexed
    vim.fn.setreg('w', fname .. ':' .. tostring(line_col_pair[1]) .. ':' .. tostring(line_col_pair[2]))
  end, {}) -- copy filename:line:column
end

add_cmd('ShAbsPath', function() print(vim.fn.expand('%:p')) end, {})
add_cmd('ShDate', function() print(os.date()) end, {})

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
-- vim.api.nvim_exec(
-- [[
-- let b:filelist = systemlist("fd '.*.zig'")
-- let b:files = join(b:filelist, ' ')
-- let b:ztags_cmd = "ztags " . b:files
-- let b:res =  system(b:ztags_cmd)
-- ]], false)
add_cmd('Retag', function()
  if vim.bo.filetype == 'zig' then
    local fd_exec = plenary.job:new({command = 'fd', args = { '.*.zig' }}):sync()
    plenary.job:new({ command = 'ztags', args = fd_exec }):start()
  end
end, {})

-- idea optional argument in which register to copy the file path
--
--:%!jq

-- :Man for man page.
-- local mappings: K or C-], C-t, gO for outline
