# Regenerate src/LibGhosttyVT.jl from the libghostty-vt headers:
#     julia --project=gen gen/generator.jl [include_dir]
# By default the headers come from the libghostty_vt_jll artifact.
using Clang.Generators

include_dir = if isempty(ARGS)
    import libghostty_vt_jll
    joinpath(libghostty_vt_jll.artifact_dir, "include")
else
    normpath(ARGS[1])
end

cd(@__DIR__)
options = load_options(joinpath(@__DIR__, "generator.toml"))
args = get_default_args()
push!(args, "-I$include_dir", "-DGHOSTTY_STATIC")
headers = [joinpath(include_dir, "ghostty", "vt.h")]
ctx = create_context(headers, args, options)
build!(ctx)
