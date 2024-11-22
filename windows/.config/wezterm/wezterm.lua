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

-- Much more involved MSYS2 setup to get fish, Rust, cargo etc
-- https://stackoverflow.com/questions/47379214/step-by-step-instruction-to-install-rust-and-cargo-for-mingw-with-msys2
-- local launch_menu = {}
-- if wezterm.target_triple == "x86_64-pc-windows-msvc" then
--   table.insert(launch_menu, {
--     label = "PowerShell",
--     args = { "pwsh.exe", "-nol" },
--   })
--   table.insert(launch_menu, {
--     label = "MSYS UCRT64",
--     args = { "cmd.exe ", "/k", "C:\\msys64\\msys2_shell.cmd -defterm -here -no-start -ucrt64 -shell fish" },
--   })
--   -- config.default_prog = { "pwsh", "-nol" }
--   config.default_prog = { "cmd.exe ", "/k", "C:\\msys64\\msys2_shell.cmd -defterm -here -no-start -ucrt64 -shell fish" }
-- end
-- config.launch_menu = launch_menu

return config
