--==config_choices

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

--==config_choices
config.default_prog = { 'pwsh.exe', '-NoLogo', '-ExecutionPolicy', 'RemoteSigned' }

-- For example, changing the color scheme:
-- 'Material' uses barely visible yellow cursor on bright brackground
-- 'flexoki-light' for z neo the word neo is barely visible and the same for & ".\some.exe"
-- https://github.com/kepano/flexoki
-- config.color_scheme = 'colorscheme'

return config
