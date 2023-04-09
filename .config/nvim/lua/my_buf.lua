--! lib_buf setup and configuartion.
local has_libbuf, libbuf = pcall(require, 'libbuf')
if not has_libbuf then return end

local _ = libbuf

-- local cwd = vim.lop.cwd
--libbuf
