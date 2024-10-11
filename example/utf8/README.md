#### summary

clang

- has sane defaults of UTF-8 since long time
- `gcc -fexec-charset=UTF-8 -finput-charset=UTF-8 file.c`
- `g++ -fexec-charset=UTF-8 -finput-charset=UTF-8 file.cpp`

gcc

- has sane defaults of UTF-8 since long time
- `gcc -fexec-charset=UTF-8 -finput-charset=UTF-8 file.c`
- `g++ -fexec-charset=UTF-8 -finput-charset=UTF-8 file.cpp`

msvc

- still no sane defaults with UTF-8
  msvc default to some undocumented heuristic without finding BOM

- /source-charset:utf-8
  decodes the source file as UTF-8, irrespective of the encoding of the source
  file or the system’s code page

- /execution-charset:utf-8
  avoid the problem of depending on the system’s code page when C++ string
  literals are declared without a prefix. UTF-8 will always be used.

- /utf-8
  use charset for source and execution

- utf-8 encoded files with utf16 encoded strings requires /source-charset:utf-8
  xor file with UTF-8 BOM

#### checks

```
C++ literals strings works as constant: We can do this: "ξπΫ"
static_assert((unsigned char)u8"ξπΫ"[0] == 0xce &&
              (unsigned char)u8"ξπΫ"[1] == 0xbe &&
              (unsigned char)u8"ξπΫ"[2] == 0xcf &&
              (unsigned char)u8"ξπΫ"[3] == 0x80 &&
              (unsigned char)u8"ξπΫ"[4] == 0xce &&
              (unsigned char)u8"ξπΫ"[5] == 0xab, "are you using correct settings?");

static_assert((unsigned char)"ξπΫ"[0] == 0xce &&
              (unsigned char)"ξπΫ"[1] == 0xbe &&
              (unsigned char)"ξπΫ"[2] == 0xcf &&
              (unsigned char)"ξπΫ"[3] == 0x80 &&
              (unsigned char)"ξπΫ"[4] == 0xce &&
              (unsigned char)"ξπΫ"[5] == 0xab, "are you using correct settings?");
```

#### sources

https://devblogs.microsoft.com/cppblog/new-options-for-managing-character-sets-in-the-microsoft-cc-compiler/
https://pspdfkit.com/blog/2021/string-literals-character-encodings-and-multiplatform-cpp/

https://www.compart.com/en/unicode/U+30EB
