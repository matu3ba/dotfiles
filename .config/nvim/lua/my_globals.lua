-- TODO use reloading from plenary

--_G.P = function(v)
--  print(vim.inspect(v))
--  return v
--end

--_G.RELOAD = function(...)
--  return require("plenary.reload").reload_module(...)
--end

--_G.R = function(name)
--  RELOAD(name)
--  return require(name)
--end

-- remove trailing carriage returns (^M)
--:e ++ff=dos
--:set ff=unix
--
-- TODO printing option
_G.ToggleOption = function(option)
  if option == false then
    option = true
  else
    option = false
  end
end
