# `static inline` helpers from modes.h, which have no exported symbol.
ghostty_mode_new(value::Integer, ansi::Bool) = UInt16((UInt16(value) & 0x7fff) | (UInt16(ansi) << 15))
ghostty_mode_value(mode::UInt16) = mode & 0x7fff
ghostty_mode_ansi(mode::UInt16) = (mode >> 15) != 0

# Used by GHOSTTY_ENUM_MAX_VALUE.
const INT_MAX = typemax(Cint)
