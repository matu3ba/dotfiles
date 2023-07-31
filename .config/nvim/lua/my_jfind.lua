--! Jfind configuration for fast searching with dependency jfind
-- luacheck: globals vim
-- luacheck: no max line length
local has_jfind, jfind = pcall(require, 'jfind')
local has_key, key = pcall(require, 'jfind.key')
if not has_jfind or not has_key then
  -- print("not has_jfind or not has_key")
  return
end

jfind.setup({
    exclude = {
        ".git",
        ".idea",
        ".vscode",
        ".sass-cache",
        ".class",
        "__pycache__",
        "node_modules",
        "target",
        "build",
        "tmp",
        "assets",
        "dist",
        "public",
        "*.iml",
        "*.meta"
    },
    border = "rounded",
    -- tmux = true,
  --
});

-- or you can provide more customization
-- for more information, read the "Lua Jfind Interface" section
vim.keymap.set("n", "<leader>ff", function()
    jfind.findFile({
        formatPaths = true,
        hidden = true,
        callback = {
            [key.DEFAULT] = vim.cmd.edit,
            [key.CTRL_S] = vim.cmd.split,
            [key.CTRL_V] = vim.cmd.vsplit,
        }
    })
end)

-- make sure to rebuld jfind if you want live grep
vim.keymap.set("n", "<leader>gr", function()
    jfind.liveGrep({
        exclude = {"*.hpp"},       -- overrides setup excludes
        hidden = true,             -- grep hidden files/directories
        caseSensitivity = "smart", -- sensitive, insensitive, smart
                                   --     will use vim settings by default
        callback = {
            [key.DEFAULT] = jfind.editGotoLine,
            [key.CTRL_B] = jfind.splitGotoLine,
            [key.CTRL_N] = jfind.vsplitGotoLine,
        }
    })
end)

-- TODO
-- local jfind = require("jfind")
-- local Key = require("jfind.key")
--
-- jfind.liveGrep({
--     selectAll = true,
--     callback = {
--         [Key.DEFAULT] = function(results)
--             local qflist = {};
--             for i, v in pairs(results) do
--                 qflist[i] = {filename = v[1], lnum = v[2]}
--             end
--             vim.fn.setqflist(qflist)
--         end
--     }
-- })
