#### summary

- /source-charset:utf8
  decodes the source file as UTF-8, irrespective of the encoding of the source
  file or the system’s code page

- /execution-charset:utf-8
  avoid the problem of depending on the system’s code page when C++ string
  literals are declared without a prefix. UTF-8 will always be used.

- /utf8
  use charset for source and execution

- [ ] utf8 encoded files with utf16 encoded strings

#### sources

https://devblogs.microsoft.com/cppblog/new-options-for-managing-character-sets-in-the-microsoft-cc-compiler/
https://pspdfkit.com/blog/2021/string-literals-character-encodings-and-multiplatform-cpp/

https://www.compart.com/en/unicode/U+30EB
