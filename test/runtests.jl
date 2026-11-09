using GhosttyVT
using GhosttyVT: LibGhosttyVT
using Test

@testset "write and read back" begin
    t = Terminal(20, 5)
    @test size(t) == (5, 20)
    print(t, "Hello, \e[1;32mworld\e[0m!\r\n")
    @test format(t) == "Hello, world!"
    @test cursor(t) == (2, 1)
    @test t[1, 1].text == "H"
    @test t[1, 1].style == Style()
    w = t[1, 8]
    @test w.text == "w" && w.style.bold && w.style.fg == 0x02
    @test t[1, 20].text == ""
    @test sprint(show, t) == "Terminal(20×5, cursor at (2, 1))"
end

@testset "cells" begin
    t = Terminal(10, 3)
    write(t, "界é\e[38;2;1;2;3mX\e[0m\e[4:3mU\e[0m")
    row = cells(t, 1)
    @test length(row) == 10
    @test row[1].text == "界" && row[1].width == 2
    @test row[2].width == 0
    @test row[3].text == "é"
    @test row[4].style.fg == RGB(1, 2, 3)
    @test row[5].style.underline == :curly
    write(t, "\e]8;;https://julialang.org\e\\link\e]8;;\e\\")
    @test t[1, 6].hyperlink == "https://julialang.org"
    @test t[1, 10].hyperlink == ""
end

@testset "scrollback" begin
    t = Terminal(10, 3)
    for i in 1:10
        print(t, i, "\r\n")
    end
    @test nrows(t) == 3
    @test nrows(t; scrollback = true) == 11
    @test cells(t, 1; scrollback = true)[1].text == "1"
    @test cells(t, 1)[1].text == "9"
    @test format(t) == join(1:10, '\n')
    s = Terminal(10, 3; scrollback_bytes = 0)
    for i in 1:10
        print(s, i, "\r\n")
    end
    @test nrows(s; scrollback = true) == 3
end

@testset "sequences" begin
    t = Terminal(20, 5)
    write(t, "abcdef\e[4D\e[2P")           # DCH
    @test format(t) == "abef"
    write(t, "\e[2J\e[Hmain\e[?1049hALT")    # alternate screen
    @test active_screen(t) == :alternate
    @test format(t) == "    ALT"               # the cursor keeps its column
    write(t, "\e[?1049l")
    @test active_screen(t) == :primary
    @test format(t) == "main"
    write(t, "\e]0;my title\a\e]7;file://host/tmp/dir\a")
    @test title(t) == "my title"
    @test pwd(t) == "file://host/tmp/dir"
end

@testset "modes" begin
    t = Terminal()
    @test !mode(t, :bracketed_paste)
    write(t, "\e[?2004h")
    @test mode(t, :bracketed_paste)
    @test mode(t, 2004)
    @test mode(t, :cursor_visible) && cursor_visible(t)
    write(t, "\e[?25l")
    @test !cursor_visible(t)
    @test !mode(t, 4; ansi = true)
    write(t, "\e[4h")
    @test mode(t, :insert)
    @test_throws ArgumentError mode(t, :no_such_mode)
end

@testset "resize and reset" begin
    t = Terminal(10, 3)
    print(t, "0123456789abc")
    @test format(t) == "0123456789\nabc"
    resize!(t, 20, 3)
    @test format(t) == "0123456789abc"
    reset!(t)
    @test format(t) == ""
end

@testset "formats" begin
    t = Terminal(20, 3)
    write(t, "plain \e[1mbold\e[0m")
    @test format(t, :plain) == "plain bold"
    @test occursin("\e[", format(t, :vt))
    html = format(t, :html)
    @test occursin("bold", html) && occursin("<", html)
    @test repr(MIME"text/html"(), t) == html
    @test_throws ArgumentError format(t, :pdf)
end

@testset "callbacks" begin
    t = Terminal(20, 5)
    replies = String[]
    on_write_pty!(r -> push!(replies, r), t)
    write(t, "ab\e[6n")
    @test replies == ["\e[1;3R"]
    rang = Ref(0)
    on_bell!(() -> rang[] += 1, t)
    write(t, "\a\a")
    @test rang[] == 2
    titles = String[]
    on_title_changed!(s -> push!(titles, s), t)
    write(t, "\e]2;one\a\e]2;two\a")
    @test titles == ["one", "two"]
    events = []
    on_semantic_prompt!(e -> push!(events, e), t)
    write(t, "\e]133;A\ajulia> \e]133;B\a1+1\r\n\e]133;C\a2\r\n\e]133;D;0\a")
    @test [e.kind for e in events] == [:prompt_start, :input_start, :output_start, :command_end]
    @test events[end].exit_code == 0
    on_bell!(() -> error("boom"), t)
    @test_throws CapturedException write(t, "\a")
    write(t, "ok")                                  # the error is not sticky
    on_bell!(nothing, t)
    write(t, "\a")
end

@testset "key encoding" begin
    t = Terminal()
    @test encode(t, 'a') == "a"
    @test encode(t, 'A'; mods = (:shift,)) == "A"
    @test encode(t, 'c'; mods = (:ctrl,)) == "\x03"
    @test encode(t, :enter) == "\r"
    @test encode(t, :up) == "\e[A"
    write(t, "\e[?1h")                              # application cursor keys
    @test encode(t, :up) == "\eOA"
    @test encode(t, :up; mods = (:ctrl,)) == "\e[1;5A"
    @test encode(t, 'x'; mods = (:alt,)) == "\ex"
    @test_throws ArgumentError encode(t, :nope)
end

@testset "close" begin
    t = Terminal()
    close(t)
    @test !isopen(t)
    @test_throws ArgumentError write(t, "x")
    close(t)
end

@testset "raw API" begin
    @test LibGhosttyVT.ghostty_mode_value(LibGhosttyVT.GHOSTTY_MODE_BRACKETED_PASTE) == 2004
end
