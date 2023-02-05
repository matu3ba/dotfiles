--! StatusLine
local M = {}

local fn = vim.fn
local api = vim.api
local path_sep = require('plenary.path').path.sep

-- https://elianiva.my.id/post/neovim-lua-statusline/

--1. filepath:line:column, (percentage + total line count)
--2. search hits + relative position,
--3. lsp status (working/not working, initializing)

-- diagnostics mode: various timings
-- 1. treesitter initializing timing
-- 2. lsp initializing timing
-- 3. tags lookup timing

-- 1. writing delay?
-- 2. ??
