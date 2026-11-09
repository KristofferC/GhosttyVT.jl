"""
    GhosttyVT

Julia interface to [libghostty-vt](https://lib.ghostty.org), the terminal
emulation library from Ghostty. A [`Terminal`](@ref) consumes the bytes a
program writes (escape sequences included) and keeps the resulting screen,
scrollback, cursor and modes, which can be read back cell by cell or formatted
as plain text, VT sequences or HTML.

The complete C API is available, unwrapped, in the `GhosttyVT.LibGhosttyVT`
submodule.
"""
module GhosttyVT

include("LibGhosttyVT.jl")
using .LibGhosttyVT: LibGhosttyVT
const L = LibGhosttyVT

export Terminal, Cell, Style, RGB, cursor, cursor_visible, mode, title, pwd, active_screen,
       nrows, cells, format, encode, reset!,
       on_write_pty!, on_bell!, on_title_changed!, on_semantic_prompt!

struct GhosttyError <: Exception
    func::Symbol
    result::L.GhosttyResult
end
Base.showerror(io::IO, e::GhosttyError) = print(io, "GhosttyError: ", e.func, " returned ", e.result)

check(result, func::Symbol) = result == L.GHOSTTY_SUCCESS ? nothing : throw(GhosttyError(func, result))

############
# Terminal #
############

"""
    Terminal(cols = 80, rows = 24; scrollback_bytes = typemax(Int)) <: IO

A terminal emulator. Write the output of a program to it with `write` or
`print`; escape sequences are interpreted, not stored. Scrollback is unlimited
by default.

Not thread-safe: use a terminal from one task at a time.
"""
mutable struct Terminal <: IO
    ptr::L.GhosttyTerminal
    callbacks::Dict{Symbol, Any}
    # An exception thrown by a callback, rethrown once control is back in Julia.
    callback_error::Any
    key_encoder::L.GhosttyKeyEncoder
    key_event::L.GhosttyKeyEvent
end

function Terminal(cols::Integer = 80, rows::Integer = 24; scrollback_bytes::Integer = typemax(Int))
    ptr = Ref{L.GhosttyTerminal}(C_NULL)
    check(L.ghostty_terminal_new(C_NULL, ptr, cols, rows), :ghostty_terminal_new)
    t = Terminal(ptr[], Dict{Symbol, Any}(), nothing, C_NULL, C_NULL)
    finalizer(close, t)
    setopt!(t, L.GHOSTTY_TERMINAL_OPT_USERDATA, pointer_from_objref(t))
    setopt!(t, L.GHOSTTY_TERMINAL_OPT_SCROLLBACK_MAX_BYTES, Ref{Csize_t}(min(scrollback_bytes, typemax(Csize_t))))
    return t
end

function Base.close(t::Terminal)
    t.key_event == C_NULL || L.ghostty_key_event_free(t.key_event)
    t.key_encoder == C_NULL || L.ghostty_key_encoder_free(t.key_encoder)
    t.ptr == C_NULL || L.ghostty_terminal_free(t.ptr)
    t.ptr = t.key_event = t.key_encoder = C_NULL
    return nothing
end
Base.isopen(t::Terminal) = t.ptr != C_NULL
handle(t::Terminal) = isopen(t) ? t.ptr : throw(ArgumentError("terminal is closed"))

function setopt!(t::Terminal, opt, value)
    GC.@preserve value check(L.ghostty_terminal_set(handle(t), opt, value isa Ref ? Base.unsafe_convert(Ptr{Cvoid}, value) : Ptr{Cvoid}(value)),
                              :ghostty_terminal_set)
end

function getdata(t::Terminal, key, ::Type{T}) where {T}
    out = Ref{T}()
    check(L.ghostty_terminal_get(handle(t), key, out), :ghostty_terminal_get)
    return out[]
end

function rethrow_callback_error(t::Terminal)
    err = t.callback_error
    if err !== nothing
        t.callback_error = nothing
        throw(err)
    end
end

function Base.unsafe_write(t::Terminal, p::Ptr{UInt8}, n::UInt)
    L.ghostty_terminal_vt_write(handle(t), p, n)
    rethrow_callback_error(t)
    return Int(n)
end
Base.write(t::Terminal, b::UInt8) = (r = Ref(b); GC.@preserve r unsafe_write(t, Base.unsafe_convert(Ptr{UInt8}, r), UInt(1)))

"""
    resize!(t::Terminal, cols, rows)

Resize the terminal, reflowing wrapped lines.
"""
function Base.resize!(t::Terminal, cols::Integer, rows::Integer)
    check(L.ghostty_terminal_resize(handle(t), cols, rows, 0, 0), :ghostty_terminal_resize)
    return t
end

"""
    reset!(t::Terminal)

Full reset (RIS): clears the screen, scrollback and modes.
"""
reset!(t::Terminal) = (L.ghostty_terminal_reset(handle(t)); t)

"""
    size(t::Terminal) -> (rows, cols)

Size of the active area.
"""
Base.size(t::Terminal) = (Int(getdata(t, L.GHOSTTY_TERMINAL_DATA_ROWS, UInt16)), Int(getdata(t, L.GHOSTTY_TERMINAL_DATA_COLS, UInt16)))
Base.displaysize(t::Terminal) = size(t)

"""
    nrows(t::Terminal; scrollback = false)

Number of rows in the active area, or including scrollback.
"""
nrows(t::Terminal; scrollback::Bool = false) =
    scrollback ? Int(getdata(t, L.GHOSTTY_TERMINAL_DATA_TOTAL_ROWS, Csize_t)) : size(t)[1]

"""
    cursor(t::Terminal) -> (row, col)

1-based cursor position in the active area.
"""
cursor(t::Terminal) = (Int(getdata(t, L.GHOSTTY_TERMINAL_DATA_CURSOR_Y, UInt16)) + 1,
                       Int(getdata(t, L.GHOSTTY_TERMINAL_DATA_CURSOR_X, UInt16)) + 1)

cursor_visible(t::Terminal) = getdata(t, L.GHOSTTY_TERMINAL_DATA_CURSOR_VISIBLE, Bool)

"""
    active_screen(t::Terminal) -> :primary or :alternate
"""
active_screen(t::Terminal) =
    getdata(t, L.GHOSTTY_TERMINAL_DATA_ACTIVE_SCREEN, L.GhosttyTerminalScreen) == L.GHOSTTY_TERMINAL_SCREEN_ALTERNATE ?
        :alternate : :primary

# Empty strings may come back as NULL.
cstring(ptr, len) = len == 0 ? "" : unsafe_string(ptr, len)
getstring(t::Terminal, key) = (s = getdata(t, key, L.GhosttyString); cstring(s.ptr, s.len))

"""
    title(t::Terminal)

Window title set by the program (OSC 0/2), or `""`.
"""
title(t::Terminal) = getstring(t, L.GHOSTTY_TERMINAL_DATA_TITLE)

"""
    pwd(t::Terminal)

Working directory reported by the program (OSC 7), or `""`.
"""
Base.pwd(t::Terminal) = getstring(t, L.GHOSTTY_TERMINAL_DATA_PWD)

#########
# Modes #
#########

const MODES = Dict{Symbol, L.GhosttyMode}(
    Symbol(lowercase(chopprefix(string(name), "GHOSTTY_MODE_"))) => getfield(L, name)
    for name in names(L) if startswith(string(name), "GHOSTTY_MODE_") && getfield(L, name) isa L.GhosttyMode)

"""
    mode(t::Terminal, name::Symbol)
    mode(t::Terminal, number::Integer; ansi = false)

Whether a terminal mode is set. `name` is one of `keys(GhosttyVT.MODES)`, e.g.
`:bracketed_paste`, `:cursor_visible` or `:alt_screen`; `number` is a DEC
private mode number (or an ANSI mode number with `ansi = true`).
"""
mode(t::Terminal, name::Symbol) = getmode(t, get(() -> throw(ArgumentError("unknown mode $name")), MODES, name))
mode(t::Terminal, number::Integer; ansi::Bool = false) = getmode(t, L.ghostty_mode_new(number, ansi))

function getmode(t::Terminal, m::L.GhosttyMode)
    cfg = Ref(L.GhosttyTerminalModeConfig(m, false))
    check(L.ghostty_terminal_get(handle(t), L.GHOSTTY_TERMINAL_DATA_MODE, cfg), :ghostty_terminal_get)
    return cfg[].value
end

##########
# Styles #
##########

struct RGB
    r::UInt8
    g::UInt8
    b::UInt8
end

"""
    Style

Cell attributes. Colors are `nothing` (the terminal default), a palette index
(`UInt8`) or an [`RGB`](@ref). `underline` is one of `:none`, `:single`,
`:double`, `:curly`, `:dotted` and `:dashed`.
"""
struct Style
    fg::Union{Nothing, UInt8, RGB}
    bg::Union{Nothing, UInt8, RGB}
    underline_color::Union{Nothing, UInt8, RGB}
    bold::Bool
    italic::Bool
    faint::Bool
    blink::Bool
    inverse::Bool
    invisible::Bool
    strikethrough::Bool
    overline::Bool
    underline::Symbol
end

const UNDERLINES = (:none, :single, :double, :curly, :dotted, :dashed)

function decode_color(b::NTuple{16, UInt8}, off::Int)
    tag = b[off + 1]
    tag == UInt8(L.GHOSTTY_STYLE_COLOR_PALETTE) && return b[off + 2]
    tag == UInt8(L.GHOSTTY_STYLE_COLOR_RGB) && return RGB(b[off + 2], b[off + 3], b[off + 4])
    return nothing
end

function Style(s::L.GhosttyStyle)
    b = getfield(s, :data)
    flags = UInt16(b[13]) | UInt16(b[14]) << 8
    f(flag) = flags & flag != 0
    ul = (flags >> 8) & 0x7
    Style(decode_color(b, 0), decode_color(b, 4), decode_color(b, 8),
          f(L.GHOSTTY_STYLE_FLAG_BOLD), f(L.GHOSTTY_STYLE_FLAG_ITALIC), f(L.GHOSTTY_STYLE_FLAG_FAINT),
          f(L.GHOSTTY_STYLE_FLAG_BLINK), f(L.GHOSTTY_STYLE_FLAG_INVERSE), f(L.GHOSTTY_STYLE_FLAG_INVISIBLE),
          f(L.GHOSTTY_STYLE_FLAG_STRIKETHROUGH), f(L.GHOSTTY_STYLE_FLAG_OVERLINE),
          ul < length(UNDERLINES) ? UNDERLINES[ul + 1] : :single)
end

const DEFAULT_STYLE = Style(L.GhosttyStyle(ntuple(_ -> 0x00, 16)))
Style() = DEFAULT_STYLE

#########
# Cells #
#########

"""
    Cell

One grid cell. `text` is the grapheme cluster drawn in the cell (`""` when
empty), `width` is 1, 2 for the leading half of a wide character, or 0 for the
spacer cell that follows a wide character (or ends a row before one that
wrapped). `hyperlink` is the OSC 8 URI, or `""`.
"""
struct Cell
    text::String
    width::Int8
    style::Style
    hyperlink::String
end

function gridref(t::Terminal, tag, row::Integer, col::Integer)
    pt = Ref(L.GhosttyPoint(ntuple(_ -> 0x00, 24)))
    GC.@preserve pt begin
        p = Base.unsafe_convert(Ptr{L.GhosttyPoint}, pt)
        p.tag = tag
        p.value.coordinate = L.GhosttyPointCoordinate(col - 1, row - 1)
    end
    ref = Ref(L.GhosttyGridRef(C_NULL, 0, 0))
    check(L.ghostty_terminal_grid_ref(handle(t), pt[], ref), :ghostty_terminal_grid_ref)
    return ref
end

function cellget(cell::L.GhosttyCell, key, ::Type{T}) where {T}
    out = Ref{T}()
    check(L.ghostty_cell_get(cell, key, out), :ghostty_cell_get)
    return out[]
end

function graphemes(ref)
    buf = Vector{UInt32}(undef, 4)
    n = Ref{Csize_t}(0)
    while true
        r = L.ghostty_grid_ref_graphemes(ref, buf, length(buf), n)
        r == L.GHOSTTY_SUCCESS && return String(map(Char, view(buf, 1:n[])))
        r == L.GHOSTTY_OUT_OF_SPACE || check(r, :ghostty_grid_ref_graphemes)
        resize!(buf, n[])
    end
end

function hyperlink(ref)
    n = Ref{Csize_t}(0)
    r = L.ghostty_grid_ref_hyperlink_uri(ref, C_NULL, 0, n)
    r == L.GHOSTTY_SUCCESS && n[] == 0 && return ""
    buf = Vector{UInt8}(undef, n[])
    check(L.ghostty_grid_ref_hyperlink_uri(ref, buf, length(buf), n), :ghostty_grid_ref_hyperlink_uri)
    return String(buf)
end

function Cell(ref)
    c = Ref{L.GhosttyCell}(0)
    check(L.ghostty_grid_ref_cell(ref, c), :ghostty_grid_ref_cell)
    cell = c[]
    wide = cellget(cell, L.GHOSTTY_CELL_DATA_WIDE, L.GhosttyCellWide)
    width = wide == L.GHOSTTY_CELL_WIDE_WIDE ? 2 : wide == L.GHOSTTY_CELL_WIDE_NARROW ? 1 : 0
    text = cellget(cell, L.GHOSTTY_CELL_DATA_HAS_TEXT, Bool) ? graphemes(ref) : ""
    style = Ref(L.GhosttyStyle(ntuple(_ -> 0x00, 16)))
    check(L.ghostty_grid_ref_style(ref, style), :ghostty_grid_ref_style)
    link = cellget(cell, L.GHOSTTY_CELL_DATA_HAS_HYPERLINK, Bool) ? hyperlink(ref) : ""
    return Cell(text, width, Style(style[]), link)
end

screen_tag(scrollback::Bool) = scrollback ? L.GHOSTTY_POINT_TAG_SCREEN : L.GHOSTTY_POINT_TAG_ACTIVE

"""
    t[row, col] -> Cell

The cell at a 1-based position in the active area.
"""
Base.getindex(t::Terminal, row::Integer, col::Integer) = Cell(gridref(t, L.GHOSTTY_POINT_TAG_ACTIVE, row, col))

"""
    cells(t::Terminal, row; scrollback = false) -> Vector{Cell}

All cells of a row. With `scrollback = true`, `row` counts from the oldest
scrollback row instead of the top of the active area.
"""
cells(t::Terminal, row::Integer; scrollback::Bool = false) =
    [Cell(gridref(t, screen_tag(scrollback), row, col)) for col in 1:size(t)[2]]

"""
    cells(t::Terminal; scrollback = false) -> Vector{Vector{Cell}}

All rows of the active area, or of the whole screen including scrollback.
"""
cells(t::Terminal; scrollback::Bool = false) = [cells(t, row; scrollback) for row in 1:nrows(t; scrollback)]

##############
# Formatting #
##############

const FORMATS = (plain = L.GHOSTTY_FORMATTER_FORMAT_PLAIN, vt = L.GHOSTTY_FORMATTER_FORMAT_VT,
                 html = L.GHOSTTY_FORMATTER_FORMAT_HTML)

"""
    format(t::Terminal, as::Symbol = :plain; unwrap = false, trim = true) -> String

The screen including scrollback as `:plain` text, `:vt` (text with escape
sequences that reproduce the styles) or `:html`. `unwrap` joins lines that
were wrapped because they were too long; `trim` removes trailing spaces.
"""
function format(t::Terminal, as::Symbol = :plain; unwrap::Bool = false, trim::Bool = true)
    fmt = get(() -> throw(ArgumentError("format must be one of $(keys(FORMATS))")), FORMATS, as)
    f = Ref{L.GhosttyFormatter}(C_NULL)
    check(L.ghostty_formatter_terminal_new(C_NULL, f, handle(t)), :ghostty_formatter_terminal_new)
    try
        for (opt, val) in ((L.GHOSTTY_FORMATTER_OPT_EMIT, Ref(fmt)), (L.GHOSTTY_FORMATTER_OPT_UNWRAP, Ref(unwrap)),
                           (L.GHOSTTY_FORMATTER_OPT_TRIM, Ref(trim)))
            check(L.ghostty_formatter_set(f[], opt, val), :ghostty_formatter_set)
        end
        ptr, len = Ref{Ptr{UInt8}}(C_NULL), Ref{Csize_t}(0)
        check(L.ghostty_formatter_format_alloc(f[], C_NULL, ptr, len), :ghostty_formatter_format_alloc)
        s = cstring(ptr[], len[])
        ptr[] == C_NULL || L.ghostty_free(C_NULL, ptr[], len[])
        return s
    finally
        L.ghostty_formatter_free(f[])
    end
end

function Base.show(io::IO, t::Terminal)
    print(io, "Terminal(")
    isopen(t) ? print(io, join(reverse(size(t)), "×"), ", cursor at ", cursor(t)) : print(io, "closed")
    print(io, ")")
end
Base.show(io::IO, ::MIME"text/plain", t::Terminal) = (show(io, t); isopen(t) && print(io, ":\n", format(t)))
Base.show(io::IO, ::MIME"text/html", t::Terminal) = print(io, format(t, :html))

#############
# Callbacks #
#############

terminal_from(userdata::Ptr{Cvoid}) = unsafe_pointer_to_objref(userdata)::Terminal

# Callbacks run inside libghostty; an exception must not unwind through it.
function run_callback(t::Terminal, name::Symbol, args...)
    f = get(t.callbacks, name, nothing)
    f === nothing && return
    try
        f(args...)
    catch err
        t.callback_error === nothing && (t.callback_error = CapturedException(err, catch_backtrace()))
    end
    return
end

function c_write_pty(::L.GhosttyTerminal, ud::Ptr{Cvoid}, data::Ptr{UInt8}, len::Csize_t)
    run_callback(terminal_from(ud), :write_pty, cstring(data, len))
    return nothing
end
c_bell(::L.GhosttyTerminal, ud::Ptr{Cvoid}) = (run_callback(terminal_from(ud), :bell); nothing)
c_title_changed(::L.GhosttyTerminal, ud::Ptr{Cvoid}) = (t = terminal_from(ud); run_callback(t, :title_changed, title(t)); nothing)

const SEMANTIC_KINDS = Dict(L.GHOSTTY_SEMANTIC_PROMPT_PROMPT_START => :prompt_start,
                            L.GHOSTTY_SEMANTIC_PROMPT_INPUT_START => :input_start,
                            L.GHOSTTY_SEMANTIC_PROMPT_OUTPUT_START => :output_start,
                            L.GHOSTTY_SEMANTIC_PROMPT_COMMAND_END => :command_end)

function c_semantic_prompt(::L.GhosttyTerminal, ud::Ptr{Cvoid}, ev::Ptr{L.GhosttyTerminalSemanticPrompt})
    e = unsafe_load(ev)
    event = (kind = get(SEMANTIC_KINDS, e.kind, :unknown),
             exit_code = e.has_exit_code ? Int(e.exit_code) : nothing,
             command = cstring(e.command.ptr, e.command.len))
    run_callback(terminal_from(ud), :semantic_prompt, event)
    return nothing
end

function set_callback!(t::Terminal, name::Symbol, opt, f, cfunc::Ptr{Cvoid})
    if f === nothing
        delete!(t.callbacks, name)
        setopt!(t, opt, C_NULL)
    else
        t.callbacks[name] = f
        setopt!(t, opt, cfunc)
    end
    return t
end

"""
    on_write_pty!(f, t::Terminal)

Call `f(reply::String)` when the terminal answers the program, e.g. a cursor
position report for `ESC [ 6 n` or device attributes. Forward `reply` to the
program's input to emulate a real terminal. `f = nothing` removes it.
"""
on_write_pty!(f, t::Terminal) = set_callback!(t, :write_pty, L.GHOSTTY_TERMINAL_OPT_WRITE_PTY, f,
    @cfunction(c_write_pty, Cvoid, (L.GhosttyTerminal, Ptr{Cvoid}, Ptr{UInt8}, Csize_t)))

"""
    on_bell!(f, t::Terminal)

Call `f()` on BEL.
"""
on_bell!(f, t::Terminal) = set_callback!(t, :bell, L.GHOSTTY_TERMINAL_OPT_BELL, f,
    @cfunction(c_bell, Cvoid, (L.GhosttyTerminal, Ptr{Cvoid})))

"""
    on_title_changed!(f, t::Terminal)

Call `f(title::String)` when the program sets the window title.
"""
on_title_changed!(f, t::Terminal) = set_callback!(t, :title_changed, L.GHOSTTY_TERMINAL_OPT_TITLE_CHANGED, f,
    @cfunction(c_title_changed, Cvoid, (L.GhosttyTerminal, Ptr{Cvoid})))

"""
    on_semantic_prompt!(f, t::Terminal)

Call `f(event)` for OSC 133 shell-integration marks, where `event` is a named
tuple `(; kind, exit_code, command)` and `kind` is one of `:prompt_start`,
`:input_start`, `:output_start` and `:command_end`.
"""
on_semantic_prompt!(f, t::Terminal) = set_callback!(t, :semantic_prompt, L.GHOSTTY_TERMINAL_OPT_SEMANTIC_PROMPT, f,
    @cfunction(c_semantic_prompt, Cvoid, (L.GhosttyTerminal, Ptr{Cvoid}, Ptr{L.GhosttyTerminalSemanticPrompt})))

################
# Key encoding #
################

const KEY_ALIASES = Dict(:up => :arrow_up, :down => :arrow_down, :left => :arrow_left, :right => :arrow_right,
                         :esc => :escape, :return => :enter, :pageup => :page_up, :pagedown => :page_down)

function ghostty_key(key::Symbol)
    key = get(KEY_ALIASES, key, key)
    name = Symbol("GHOSTTY_KEY_", uppercase(string(key)))
    isdefined(L, name) || throw(ArgumentError("unknown key $key"))
    return getfield(L, name)::L.GhosttyKey
end

function ghostty_key(c::Char)
    'a' <= lowercase(c) <= 'z' && return ghostty_key(Symbol(lowercase(c)))
    '0' <= c <= '9' && return ghostty_key(Symbol("digit_", c))
    c == ' ' && return L.GHOSTTY_KEY_SPACE
    return L.GHOSTTY_KEY_UNIDENTIFIED
end

const MODS = (shift = L.GHOSTTY_MODS_SHIFT, ctrl = L.GHOSTTY_MODS_CTRL, alt = L.GHOSTTY_MODS_ALT,
              super = L.GHOSTTY_MODS_SUPER)

"""
    encode(t::Terminal, key; mods = (), action = :press) -> String

The bytes a terminal in the state of `t` sends to the program for a key event,
following its modes (application cursor keys, kitty keyboard flags, ...).
`key` is a `Char` (`'a'`, `'Q'`, `'5'`, ...) or a `Symbol` naming a physical key
(`:enter`, `:up`, `:tab`, `:backspace`, `:f5`, ...); `mods` holds any of
`:shift`, `:ctrl`, `:alt` and `:super`; `action` is `:press`, `:repeat` or
`:release`.

```julia
encode(t, :up)               # "\\e[A", or "\\eOA" in application cursor mode
encode(t, 'c'; mods = (:ctrl,)) # "\\x03"
```
"""
function encode(t::Terminal, key::Union{Char, Symbol}; mods = (), action::Symbol = :press)
    if t.key_encoder == C_NULL
        enc, ev = Ref{L.GhosttyKeyEncoder}(C_NULL), Ref{L.GhosttyKeyEvent}(C_NULL)
        check(L.ghostty_key_encoder_new(C_NULL, enc), :ghostty_key_encoder_new)
        t.key_encoder = enc[]
        check(L.ghostty_key_event_new(C_NULL, ev), :ghostty_key_event_new)
        t.key_event = ev[]
    end
    enc, ev = t.key_encoder, t.key_event
    check(L.ghostty_key_encoder_set_from_terminal(enc, handle(t)), :ghostty_key_encoder_set_from_terminal)
    # `:alt` means Alt on every platform, not a macOS Option key that produces text.
    check(L.ghostty_key_encoder_set(enc, L.GHOSTTY_KEY_ENCODER_OPT_MACOS_OPTION_AS_ALT, Ref(L.GHOSTTY_OPTION_AS_ALT_TRUE)),
          :ghostty_key_encoder_set)
    m = L.GhosttyMods(0)
    for mod in mods
        m |= L.GhosttyMods(get(() -> throw(ArgumentError("unknown modifier $mod")), MODS, mod))
    end
    act = action === :press ? L.GHOSTTY_KEY_ACTION_PRESS : action === :repeat ? L.GHOSTTY_KEY_ACTION_REPEAT :
          action === :release ? L.GHOSTTY_KEY_ACTION_RELEASE : throw(ArgumentError("unknown action $action"))
    text = key isa Char && !iscntrl(key) && :ctrl ∉ mods ? string(key) : ""
    check(L.ghostty_key_event_set_action(ev, act), :ghostty_key_event_set_action)
    check(L.ghostty_key_event_set_key(ev, ghostty_key(key)), :ghostty_key_event_set_key)
    check(L.ghostty_key_event_set_mods(ev, m), :ghostty_key_event_set_mods)
    check(L.ghostty_key_event_set_unshifted_codepoint(ev, key isa Char ? UInt32(lowercase(key)) : UInt32(0)),
          :ghostty_key_event_set_unshifted_codepoint)
    buf = Vector{UInt8}(undef, 64)
    n = Ref{Csize_t}(0)
    GC.@preserve text begin
        check(L.ghostty_key_event_set_utf8(ev, L.GhosttyString(pointer(text), ncodeunits(text))),
              :ghostty_key_event_set_utf8)
        r = L.ghostty_key_encoder_encode(enc, ev, buf, length(buf), n)
        if r == L.GHOSTTY_OUT_OF_SPACE
            resize!(buf, n[])
            r = L.ghostty_key_encoder_encode(enc, ev, buf, length(buf), n)
        end
        check(r, :ghostty_key_encoder_encode)
    end
    return String(resize!(buf, n[]))
end

end # module
