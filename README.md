# GhosttyVT.jl

Julia interface to [libghostty-vt](https://lib.ghostty.org), the terminal
emulation library from [Ghostty](https://ghostty.org). Feed a `Terminal` the
bytes a program writes and read back the screen, scrollback, cursor and modes,
or format the screen as plain text, VT sequences or HTML.

```julia
using GhosttyVT

t = Terminal(80, 24)
print(t, "Hello, \e[1;32mworld\e[0m!\r\n")

format(t)              # "Hello, world!"
format(t, :html)       # styled HTML
t[1, 8]                # Cell("w", 1, Style(fg = 0x02, bold = true, ...), "")
cursor(t)              # (2, 1)
mode(t, :bracketed_paste)

# Answer queries such as cursor position reports, as a real terminal would.
on_write_pty!(reply -> write(program_stdin, reply), t)

# Bytes a terminal in this state sends for a key press.
encode(t, :up)                  # "\e[A" (or "\eOA" in application cursor mode)
encode(t, 'c'; mods = (:ctrl,)) # "\x03"
```

The whole C API is available, unwrapped, in `GhosttyVT.LibGhosttyVT`, which
is generated from the headers with Clang.jl (see `gen/`).
