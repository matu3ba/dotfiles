--
--TODO https://zignar.net/2023/06/10/debugging-lua-in-neovim/#nlualua
-- how to better setup luarocks with luajit without yet another plugin

--====busted
--====luarocks
--====tooling
--====basics

--====busted

--====luarocks
-- luarocks config lua_version 5.1
--writes to $HOME/.luarocks
--and $HOME/.luarocks/config-5.1.lua
--Possible error: /usr/bin/lua5.1: Directory or File not found

--====tooling
-- luax - lua repl https://github.com/CDSoft/luax

--====basics
-- indices are 1-based
local table_str = {
  [-1] = "t-1", -- ipair does not iterate over this
  [0] = "t0", -- ipair does not iterate over this
  [1] = "t1",
  [2] = "t2",
}

local simplertable_str_alt = { "t1", "t2", }

local table_int = {
  [-1] = -1, -- ipair does not iterate over this
  [0] = 1, -- ipair does not iterate over this
  [1] = 2,
  [2] = 3,
}
local simplertable_int_alt = { 1, 2 }

local function pair_ipair_difference()
  -- deterministic by numeric magnitude,
  -- starts at 1 ignoring non-numeric values and stops on any gap
  for key, value in ipairs(table_str) do print(key, value) end
  -- associative tables with keys preserved but order unspecified
  for key, value in pairs(table_str) do print(key, value) end
end

local function reference()
  _ = table_str
  _ = table_int
  _ = simplertable_str_alt
  _ = simplertable_int_alt

  _ = pair_ipair_difference
end

_ = reference