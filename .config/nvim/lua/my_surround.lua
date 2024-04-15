-- luacheck: globals vim
-- luacheck: no max line length
local has_sur, sur = pcall(require, 'nvim-surround')
if not has_sur then return end

--     Old text                    Command         New text
-- --------------------------------------------------------------------------------
--====text
--     surr*ound_words             ysiw)           (surround_words)
--     *make strings               ys$"            "make strings"
--     [delete ar*ound me!]        ds]             delete around me!
--     'change quot*es'            cs'"            "change quotes"
--====html_simple
--     *                           <C-g>stcode<CR> <code>*</code>
--     *                           <C-g>Stcode<CR> <code>
--                                                   x
--                                                 </code>
--     |some|                      St<b>           <b>some</b>
--     <b>HTML t*ags</b>           cstab<CR>       <ab>HTML t*ags</ab>
--     remove <b>HTML t*ags</b>    dst             remove HTML tags
--     change <b>inside t*ags</b>  cit             change <b></b>
--     remove <b>inside t*ags</b>  dit             remove <b></b>
--====html_span
--     *                           <C-g>spcode<CR> <code>*</code>
--     *                           <C-g>Spcode<CR> <code>
--                                                   x
--                                                 </code>
--     <b>HTML t*ags</b>           cspab<CR>       <ab>HTML t*ags</ab>
--     remove <b>HTML t*ags</b>    dsp             remove HTML tags
--     change <b>inside t*ags</b>  cip             change <b></b>
--     remove <b>inside t*ags</b>  dip             remove <b></b>
--====coding
--     *                           <C-g>sfname<CR> name(*)
--     *                           <C-g>Sfname<CR> name(
--                                                   x
--                                                 )
--     |some|                      Sffn1           fn1(some)
--     delete(functi*on calls)     dsf             function calls
--     change(functi*on calls)     csfc2<CR>       *c2(function calls
--     test123                     ysiwfname<CR>   name(test123)
--     *word_another bla           ysit<space>"    "word_another"* bla
--     TODO explain ysa
--     TODO selection actions
--      selection S" to put " around selected text
--      (da da) ->(  ysa") -> ("da da")
-- see also https://github.com/kylechui/nvim-surround/blob/84a26afce16cffa7e3322cfa80a42cddf60616eb/lua/nvim-surround/config.lua


-- local blabla = function()
--   error("blabla", 1)
-- end

-- idea adjust
sur.setup {
  surrounds = {
    -- sPan, because its pasted so often
    ["p"] = {
        add = function()
          local input = sur.config.get_input("Enter HTML tag: ")
          if input then
            -- validate HTML
            -- local open, close = get_expanded_surrounds(input)
            -- return { open, close }
            return {}
          end
        end,
        find = function()
          return require('nvim-surround.config').get_selection({ motion = "at" })
        end,
        delete = "^(%b<>)().-(%b<>)()$",
        change = {
          target = "^<([^%s<>]*)().-([^/]*)()>$",
          replacement = function()
            local input = require('nvim-surround.config').get_input("Enter the HTML tag: ")
            if input then
              local element = input:match("^<?([^%s>]*)")
              local attributes = input:match("^<?[^%s>]*%s+(.-)>?$")

              local open = attributes and element .. " " .. attributes or element
              local close = element

              return { { open }, { close } }
            end
          end,
        },
    },
  }
}