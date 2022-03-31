// typesafe version of (u16*)codepoint with codepoint type u8*
const char = std.mem.bytesAsValue(u16, codepoint[0..2]); // U+0080...U+07FF
