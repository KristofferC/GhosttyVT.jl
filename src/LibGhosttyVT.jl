module LibGhosttyVT

using libghostty_vt_jll
export libghostty_vt_jll

using CEnum: CEnum, @cenum

# `static inline` helpers from modes.h, which have no exported symbol.
ghostty_mode_new(value::Integer, ansi::Bool) = UInt16((UInt16(value) & 0x7fff) | (UInt16(ansi) << 15))
ghostty_mode_value(mode::UInt16) = mode & 0x7fff
ghostty_mode_ansi(mode::UInt16) = (mode >> 15) != 0

# Used by GHOSTTY_ENUM_MAX_VALUE.
const INT_MAX = typemax(Cint)


"""
Style flags.

A 16-bit set of text attributes, laid out as follows:

| Bits | Meaning | |----------|-----------------------------------------------------| | 0 to 7 | On/off attributes, one GHOSTTY\\_STYLE\\_FLAG\\_* per bit | | 8 to 10 | Underline style, a [`GhosttySgrUnderline`](@ref) value | | 11 to 15 | Reserved, always zero |

Test an attribute with a bitwise AND against its GHOSTTY\\_STYLE\\_FLAG\\_* mask. Read the underline style with [`GHOSTTY_STYLE_UNDERLINE`](@ref)().

` style`
"""
const GhosttyStyleFlags = UInt16

"""
    GhosttyResult

Result codes for libghostty-vt operations.

Functions that can fail return one of these codes. GHOSTTY\\_SUCCESS is zero and every error is negative, so `result < 0` tests for any error.

Functions that read or write values by key, such as [`ghostty_terminal_get`](@ref)(), return GHOSTTY\\_UNSUPPORTED for a key that this version of the library does not know. See values for how to use that to support older versions of the library. Functions of an optional feature that this build leaves out return it too. See features.

` core_types`

| Enumerator                     | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| :----------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SUCCESS              | Operation completed successfully                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_OUT\\_OF\\_MEMORY    | Operation failed due to failed allocation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_INVALID\\_VALUE      | An argument is not valid.  For example, a NULL pointer where a value is required, an enum value that is out of range, or a sized struct whose size is too small. When a key is involved, this means the library knows the key but a value passed with it is wrong. Compare GHOSTTY\\_UNSUPPORTED.                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_OUT\\_OF\\_SPACE     | Operation failed because the provided buffer was too small                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_NO\\_VALUE           | The requested value has no value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_IO\\_ERROR           | Operation failed while reading from or writing to external I/O                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_LIMIT\\_EXCEEDED     | Operation failed because encoded input exceeded a configured limit                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_REJECTED             | Operation was rejected by a safety check (e.g. pasted text that could inject commands). Nothing was done. Confirm with the person using your terminal and retry with the operation's allow flag set.                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_UNSUPPORTED          | This library cannot do what was asked.  Returned by the functions that read or write values by key when the key is newer than the library. Nothing is read or written. This usually means the program was built with a newer header than the library it is running with. Check for it to fall back gracefully, as shown in values-older-libraries.  Also returned by every function of an optional feature that this build leaves out. For example, [`ghostty_snapshot_encode`](@ref)() returns it when the library was built without the `snapshot` feature. See features.  |
| GHOSTTY\\_RESULT\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
"""
@cenum GhosttyResult::Int32 begin
    GHOSTTY_SUCCESS = 0
    GHOSTTY_OUT_OF_MEMORY = -1
    GHOSTTY_INVALID_VALUE = -2
    GHOSTTY_OUT_OF_SPACE = -3
    GHOSTTY_NO_VALUE = -4
    GHOSTTY_IO_ERROR = -5
    GHOSTTY_LIMIT_EXCEEDED = -6
    GHOSTTY_REJECTED = -7
    GHOSTTY_UNSUPPORTED = -8
    GHOSTTY_RESULT_MAX_VALUE = 2147483647
end

mutable struct GhosttyTerminalImpl end

"""
Opaque handle to a terminal instance.

` terminal`
"""
const GhosttyTerminal = Ptr{GhosttyTerminalImpl}

mutable struct GhosttySnapshotDecoderImpl end

"""
Opaque handle to an incremental terminal snapshot decoder.

` snapshot`
"""
const GhosttySnapshotDecoder = Ptr{GhosttySnapshotDecoderImpl}

mutable struct GhosttyTrackedGridRefImpl end

"""
Opaque handle to a tracked grid reference.

A tracked grid reference is owned by you and must be freed with [`ghostty_tracked_grid_ref_free`](@ref)(). If the terminal that created it is freed first, the handle remains valid only for tracked-grid-ref APIs: it reports no value and can still be freed.

` grid_ref`
"""
const GhosttyTrackedGridRef = Ptr{GhosttyTrackedGridRefImpl}

mutable struct GhosttyKittyGraphicsImpl end

"""
Opaque handle to a Kitty graphics image storage.

Obtained via [`ghostty_terminal_get`](@ref)() with GHOSTTY\\_TERMINAL\\_DATA\\_KITTY\\_GRAPHICS. The pointer is borrowed from the terminal and remains valid until the next mutating terminal call (e.g. [`ghostty_terminal_vt_write`](@ref)() or [`ghostty_terminal_reset`](@ref)()).

` kitty_graphics`
"""
const GhosttyKittyGraphics = Ptr{GhosttyKittyGraphicsImpl}

mutable struct GhosttyKittyGraphicsImageImpl end

"""
Opaque handle to a Kitty graphics image.

Obtained via [`ghostty_kitty_graphics_image`](@ref)() with an image ID. The pointer is borrowed from the storage and remains valid until the next mutating terminal call.

` kitty_graphics`
"""
const GhosttyKittyGraphicsImage = Ptr{GhosttyKittyGraphicsImageImpl}

mutable struct GhosttyKittyGraphicsPlacementIteratorImpl end

"""
Opaque handle to a Kitty graphics placement iterator.

` kitty_graphics`
"""
const GhosttyKittyGraphicsPlacementIterator = Ptr{GhosttyKittyGraphicsPlacementIteratorImpl}

mutable struct GhosttyRenderStateImpl end

"""
Opaque handle to a render state instance.

` render`
"""
const GhosttyRenderState = Ptr{GhosttyRenderStateImpl}

mutable struct GhosttyRenderStateRowIteratorImpl end

"""
Opaque handle to a render-state row iterator.

` render`
"""
const GhosttyRenderStateRowIterator = Ptr{GhosttyRenderStateRowIteratorImpl}

mutable struct GhosttyRenderStateRowCellsImpl end

"""
Opaque handle to render-state row cells.

` render`
"""
const GhosttyRenderStateRowCells = Ptr{GhosttyRenderStateRowCellsImpl}

mutable struct GhosttyRenderStateImageIteratorImpl end

"""
Opaque handle to an iterator over the image placements of a render state.

` render`
"""
const GhosttyRenderStateImageIterator = Ptr{GhosttyRenderStateImageIteratorImpl}

mutable struct GhosttySearchImpl end

"""
Opaque handle to a terminal search.

A search is bound to the terminal it was created with. It borrows the terminal, so it never frees it, and the search must be freed with [`ghostty_search_free`](@ref)(). If the terminal is freed first, the search detects this: calls that need the terminal fail cleanly and the search can still be freed.

` search`
"""
const GhosttySearch = Ptr{GhosttySearchImpl}

mutable struct GhosttySgrParserImpl end

"""
Opaque handle to an SGR parser instance.

This handle represents an SGR (Select Graphic Rendition) parser that can be used to parse SGR sequences and extract individual text attributes.

` sgr`
"""
const GhosttySgrParser = Ptr{GhosttySgrParserImpl}

mutable struct GhosttyFormatterImpl end

"""
Opaque handle to a formatter instance.

` formatter`
"""
const GhosttyFormatter = Ptr{GhosttyFormatterImpl}

mutable struct GhosttyOscParserImpl end

"""
Opaque handle to an OSC parser instance.

This handle represents an OSC (Operating System Command) parser that can be used to parse the contents of OSC sequences.

` osc`
"""
const GhosttyOscParser = Ptr{GhosttyOscParserImpl}

mutable struct GhosttyOscCommandImpl end

"""
Opaque handle to a single OSC command.

This handle represents a parsed OSC (Operating System Command) command. The command can be queried for its type and associated data.

` osc`
"""
const GhosttyOscCommand = Ptr{GhosttyOscCommandImpl}

"""
    GhosttyFormatterFormat

Terminal content output format.

` formatter`

| Enumerator                                 | Note                                                |
| :----------------------------------------- | :-------------------------------------------------- |
| GHOSTTY\\_FORMATTER\\_FORMAT\\_PLAIN       | Plain text (no escape sequences).                   |
| GHOSTTY\\_FORMATTER\\_FORMAT\\_VT          | VT sequences preserving colors, styles, URLs, etc.  |
| GHOSTTY\\_FORMATTER\\_FORMAT\\_HTML        | HTML with inline styles.                            |
| GHOSTTY\\_FORMATTER\\_FORMAT\\_MAX\\_VALUE |                                                     |
"""
@cenum GhosttyFormatterFormat::UInt32 begin
    GHOSTTY_FORMATTER_FORMAT_PLAIN = 0
    GHOSTTY_FORMATTER_FORMAT_VT = 1
    GHOSTTY_FORMATTER_FORMAT_HTML = 2
    GHOSTTY_FORMATTER_FORMAT_MAX_VALUE = 2147483647
end

"""
    GhosttyCursorStyle

The shape of the cursor.

Programs change the cursor's shape with the DECSCUSR escape sequence (CSI Ps SP q). Set the shape that DECSCUSR 0 restores with GHOSTTY\\_TERMINAL\\_OPT\\_DEFAULT\\_CURSOR\\_STYLE. Read the shape to draw with GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_VISUAL\\_STYLE.

` terminal`

| Enumerator                                | Note                               |
| :---------------------------------------- | :--------------------------------- |
| GHOSTTY\\_CURSOR\\_STYLE\\_BAR            | Bar cursor (DECSCUSR 5, 6).        |
| GHOSTTY\\_CURSOR\\_STYLE\\_BLOCK          | Block cursor (DECSCUSR 1, 2).      |
| GHOSTTY\\_CURSOR\\_STYLE\\_UNDERLINE      | Underline cursor (DECSCUSR 3, 4).  |
| GHOSTTY\\_CURSOR\\_STYLE\\_BLOCK\\_HOLLOW | Hollow block cursor.               |
| GHOSTTY\\_CURSOR\\_STYLE\\_MAX\\_VALUE    |                                    |
"""
@cenum GhosttyCursorStyle::UInt32 begin
    GHOSTTY_CURSOR_STYLE_BAR = 0
    GHOSTTY_CURSOR_STYLE_BLOCK = 1
    GHOSTTY_CURSOR_STYLE_UNDERLINE = 2
    GHOSTTY_CURSOR_STYLE_BLOCK_HOLLOW = 3
    GHOSTTY_CURSOR_STYLE_MAX_VALUE = 2147483647
end

"""
    GhosttyImageLayer

Where an image is drawn relative to the terminal's text.

Draw each frame from the bottom up, in this order:

1. Images in GHOSTTY\\_IMAGE\\_LAYER\\_BELOW\\_BACKGROUND. 2. Cell background colors. 3. Images in GHOSTTY\\_IMAGE\\_LAYER\\_BELOW\\_TEXT. 4. Text. 5. Images in GHOSTTY\\_IMAGE\\_LAYER\\_ABOVE\\_TEXT.

Within a layer, draw images in order of their z-index, lowest first.

A Kitty graphics placement's layer comes from its z-index. Each value below lists its z-index range. For example, a placement with z-index -1 is in GHOSTTY\\_IMAGE\\_LAYER\\_BELOW\\_TEXT.

The render state reports each image's layer with GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_LAYER. To visit only some layers with the Kitty graphics placement iterator, build a mask from the GHOSTTY\\_IMAGE\\_LAYER\\_MASK\\_* macros and set it with GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_ITERATOR\\_OPT\\_LAYER.

` render`

| Enumerator                                   | Note                                                                                               |
| :------------------------------------------- | :------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_IMAGE\\_LAYER\\_BELOW\\_BACKGROUND | Below the cell background colors. Kitty z-index below INT32\\_MIN / 2 (-1,073,741,824).            |
| GHOSTTY\\_IMAGE\\_LAYER\\_BELOW\\_TEXT       | Above the cell background colors and below the text. Kitty z-index from INT32\\_MIN / 2 up to -1.  |
| GHOSTTY\\_IMAGE\\_LAYER\\_ABOVE\\_TEXT       | Above the text. Kitty z-index 0 and above.                                                         |
| GHOSTTY\\_IMAGE\\_LAYER\\_MAX\\_VALUE        |                                                                                                    |
"""
@cenum GhosttyImageLayer::UInt32 begin
    GHOSTTY_IMAGE_LAYER_BELOW_BACKGROUND = 0
    GHOSTTY_IMAGE_LAYER_BELOW_TEXT = 1
    GHOSTTY_IMAGE_LAYER_ABOVE_TEXT = 2
    GHOSTTY_IMAGE_LAYER_MAX_VALUE = 2147483647
end

"""
    GhosttyString

A borrowed byte string (pointer + length).

The memory is not owned by this struct. The pointer is only valid for the lifetime documented by the API that produces or consumes it. Empty strings produced by the library have a non-NULL pointer to valid storage.

` core_types`

| Field | Note                            |
| :---- | :------------------------------ |
| ptr   | Pointer to the string bytes.    |
| len   | Length of the string in bytes.  |
"""
struct GhosttyString
    ptr::Ptr{UInt8}
    len::Csize_t
end

"""
    GhosttyBuffer

A caller-provided byte buffer.

APIs that write to this type use `len` for the number of bytes written on GHOSTTY\\_SUCCESS and the required byte capacity on GHOSTTY\\_OUT\\_OF\\_SPACE.

` core_types`

| Field | Note                                                                                |
| :---- | :---------------------------------------------------------------------------------- |
| ptr   | Destination buffer for bytes. May be NULL when cap is 0 to query required size.     |
| cap   | Capacity of ptr in bytes.                                                           |
| len   | Bytes written on success, or required byte capacity on GHOSTTY\\_OUT\\_OF\\_SPACE.  |
"""
struct GhosttyBuffer
    ptr::Ptr{UInt8}
    cap::Csize_t
    len::Csize_t
end

"""
    GhosttySurfacePosition

A surface-space position in pixels.

This is not a terminal grid coordinate. It represents an x/y position in the rendered surface coordinate space, with (0, 0) at the top-left of the surface.

` selection`

| Field | Note                           |
| :---- | :----------------------------- |
| x     | X position in surface pixels.  |
| y     | Y position in surface pixels.  |
"""
struct GhosttySurfacePosition
    x::Cdouble
    y::Cdouble
end

"""
    GhosttyCodepoints

A borrowed list of Unicode scalar values.

Values are encoded as uint32\\_t scalar values. The memory is not owned by this struct. The pointer is only valid for the lifetime documented by the API that consumes or produces it.

APIs may document special handling for NULL + len 0, such as “use defaults”.

` core_types`

| Field | Note                               |
| :---- | :--------------------------------- |
| ptr   | Pointer to Unicode scalar values.  |
| len   | Number of entries in ptr.          |
"""
struct GhosttyCodepoints
    ptr::Ptr{UInt32}
    len::Csize_t
end

"""
    GhosttyCodepointBuffer

A buffer you provide for the library to fill with Unicode codepoints.

Set ptr to an array of uint32\\_t and cap to the number of elements it holds. The library writes up to cap codepoints and sets len to the total number available. When len is greater than cap, the call returns GHOSTTY\\_OUT\\_OF\\_SPACE and ptr holds only the first cap codepoints.

To learn the count without copying anything, set ptr to NULL and cap to 0, then read len.

This struct has a frozen layout and will not gain fields in future versions.

` core_types`

| Field | Note                                                                                |
| :---- | :---------------------------------------------------------------------------------- |
| ptr   | Where codepoints are written. May be NULL when cap is 0.                            |
| cap   | Number of uint32\\_t elements ptr can hold.                                         |
| len   | Set by the library to the total number of codepoints, whether or not they all fit.  |
"""
struct GhosttyCodepointBuffer
    ptr::Ptr{UInt32}
    cap::Csize_t
    len::Csize_t
end

"""
    ghostty_sized_init(ptr, size)

Initialize a sized struct at runtime.

This does the same thing as [`GHOSTTY_INIT_SIZED`](@ref)(). It sets every byte of the struct to zero and then stores `size` in the struct's `size` field. It is meant for language bindings that cannot use a C macro. Pass the size of the struct as your binding lays it out, which is `sizeof` of the struct in the header the binding was built from. See sized-structs.

```c++
{.c}
 GhosttyRenderStateCursor cursor;
 ghostty_sized_init(&cursor, sizeof(cursor));
```

If `ptr` is NULL, or `size` is too small to hold the `size` field itself, this function does nothing.

` core_types`

# Arguments
* `ptr`: The struct to initialize, or NULL
* `size`: The size of the struct in bytes
"""
function ghostty_sized_init(ptr, size)
    @ccall libghostty_vt.ghostty_sized_init(ptr::Ptr{Cvoid}, size::Csize_t)::Cvoid
end

"""
    ghostty_type_json()

Return the versioned libghostty-vt C type manifest for the current target.

The manifest defines all the public types available in the linked build. The types contain their layouts, enum values, union fields, and more.

Language bindings, such as WebAssembly hosts, should obtain offsets, sizes, alignments, array shapes, enum constants, and tagged-union arms from this manifest rather than hardcoding them. Consumers should reject unknown schema versions and verify the descriptors they require at initialization.

Packed type descriptors define fields using `lsb` and `width`. `lsb` is relative to bit zero of the containing numerical value; for nested packed layouts it is relative to the immediate containing field. Tagged packed unions select an inline arm layout using the named tag field. These layouts describe the current linked build and are not a cross-version stability promise.

Every key enum also has a `keys` object. A key enum is the enum that a `_get`, `_set` or `_get_multi` function takes to pick a value, such as [`GhosttyTerminalData`](@ref) or [`GhosttyTerminalOption`](@ref). Each key lists its `direction` and the `type` that its `void *` value points at:

- An `"out"` key is read. Pass a pointer to storage of `type`, and the library writes the value there. - An `"in"` key is set. Pass a pointer to a value of `type`, and the library reads it. [`ghostty_formatter_get`](@ref)() also takes these keys, and writes a value of the same `type`. - A `type` of `opaque` is an untyped pointer, such as userdata. Pass the pointer itself. - A `type` that names a `callback` descriptor sets a callback. Pass the function pointer itself, not a pointer to it.

Callback descriptors, such as [`GhosttyTerminalBellFn`](@ref), describe a function pointer typedef. `params` lists the parameter types in order and `return` gives the return type. Both use the same type references as struct fields.

The formal format is defined by the <a href="types.schema.json">libghostty-vt ABI manifest JSON Schema</a>.

Example (abbreviated):

```c++
{.json}
 {
   "schema": 1,
   "abi": {
     "target": "wasm32", "os": "freestanding", "environment": "none",
     "pointer_size": 4, "usize_size": 4, "max_alignment": 16,
     "endian": "little"
   },
   "types": {
     "GhosttyRenderStateData": {
       "kind": "enum", "size": 4, "align": 4,
       "underlying": "i32", "prefix": "GHOSTTY_RENDER_STATE_DATA_",
       "values": { "INVALID": 0, "DIRTY": 3, "MAX_VALUE": 2147483647 },
       "keys": {
         "DIRTY": { "direction": "out", "type": "GhosttyRenderStateDirty" }
       }
     },
     "GhosttyTerminalBellFn": {
       "kind": "callback", "size": 4, "align": 4,
       "params": [
         { "type": "GhosttyTerminal" },
         { "type": "pointer", "elem": "opaque", "const": false,
           "nullable": true }
       ],
       "return": { "type": "void" }
     },
     "GhosttyStyleColor": {
       "kind": "struct", "size": 4, "align": 1,
       "fields": {
         "tag": { "offset": 0, "size": 1,
                  "type": "GhosttyStyleColorTag" },
         "value": { "offset": 1, "size": 3,
                    "type": "GhosttyStyleColorValue", "tag": "tag",
                    "arms": { "NONE": null, "PALETTE": "palette",
                              "RGB": "rgb" } }
       }
     }
   }
 }
```

The returned pointer is valid for the lifetime of the process.

` core_types`

# Returns
Pointer to the null-terminated JSON string.
"""
function ghostty_type_json()
    @ccall libghostty_vt.ghostty_type_json()::Cstring
end

# typedef void * ( * GhosttyAllocatorAllocFn ) ( void * ctx , size_t len , uint8_t alignment , uintptr_t ret_addr )
"""
Allocate a block of memory.

This is the `alloc` function of a [`GhosttyAllocatorVtable`](@ref). It's required.

` allocator`

# Arguments
* `ctx`: The allocator's context pointer
* `len`: Number of bytes to allocate
* `alignment`: The block's address must be a multiple of `1 << alignment` bytes. See memory-alignment.
* `ret_addr`: Address of the requesting code, or 0. Safe to ignore.
# Returns
The new block, or NULL if it could not be allocated
"""
const GhosttyAllocatorAllocFn = Ptr{Cvoid}

# typedef bool ( * GhosttyAllocatorResizeFn ) ( void * ctx , void * memory , size_t memory_len , uint8_t alignment , size_t new_len , uintptr_t ret_addr )
"""
Try to grow or shrink a block without moving it.

This is the `resize` function of a [`GhosttyAllocatorVtable`](@ref). It's optional, and leaving it NULL is the same as always returning false.

Return true only if the block at `memory` is now `new_len` bytes long at the same address. Return false if that would require moving it. The library then decides whether to allocate a new block and copy.

For example, an arena that hands out memory from one buffer can resize its most recent block, because nothing comes after it:

```c++
{.c}
 typedef struct {
   uint8_t* base;
   size_t used;
   size_t capacity;
 } Arena;

 static bool arena_resize(void* ctx, void* memory, size_t memory_len,
                          uint8_t alignment, size_t new_len,
                          uintptr_t ret_addr) {
   (void)alignment;
   (void)ret_addr;
   Arena* arena = ctx;
   size_t start = (size_t)((uint8_t*)memory - arena->base);

   // Only the last block can change size in place.
   if (start + memory_len != arena->used) return false;
   if (start + new_len > arena->capacity) return false;

   arena->used = start + new_len;
   return true;
 }
```

` allocator`

# Arguments
* `ctx`: The allocator's context pointer
* `memory`: Start of a block returned by `alloc` or `remap`
* `memory_len`: Current length of the block
* `alignment`: The alignment the block was allocated with
* `new_len`: Requested length, always greater than zero
* `ret_addr`: Address of the requesting code, or 0. Safe to ignore.
# Returns
true if the block was resized in place, false otherwise
"""
const GhosttyAllocatorResizeFn = Ptr{Cvoid}

# typedef void * ( * GhosttyAllocatorRemapFn ) ( void * ctx , void * memory , size_t memory_len , uint8_t alignment , size_t new_len , uintptr_t ret_addr )
"""
Grow or shrink a block, moving it if that is cheaper than a copy.

This is the `remap` function of a [`GhosttyAllocatorVtable`](@ref). It's optional, and leaving it NULL is the same as always returning NULL.

Unlike [`GhosttyAllocatorResizeFn`](@ref), this may return a new address, for example after remapping virtual memory pages. The block must hold the old contents at that address, and the old address is no longer valid.

Return NULL when the only way to do it would be to allocate, copy, and free. The library does that itself, so there is no benefit in doing it here.

` allocator`

# Arguments
* `ctx`: The allocator's context pointer
* `memory`: Start of a block returned by `alloc` or `remap`
* `memory_len`: Current length of the block
* `alignment`: The alignment the block was allocated with
* `new_len`: Requested length, always greater than zero
* `ret_addr`: Address of the requesting code, or 0. Safe to ignore.
# Returns
The resized block, or NULL to let the library copy instead
"""
const GhosttyAllocatorRemapFn = Ptr{Cvoid}

# typedef void ( * GhosttyAllocatorFreeFn ) ( void * ctx , void * memory , size_t memory_len , uint8_t alignment , uintptr_t ret_addr )
"""
Free a block.

This is the `free` function of a [`GhosttyAllocatorVtable`](@ref). It's required. After it returns, the library never uses `memory` again.

` allocator`

# Arguments
* `ctx`: The allocator's context pointer
* `memory`: Start of a block returned by `alloc` or `remap`
* `memory_len`: Current length of the block
* `alignment`: The alignment the block was allocated with
* `ret_addr`: Address of the requesting code, or 0. Safe to ignore.
"""
const GhosttyAllocatorFreeFn = Ptr{Cvoid}

"""
    GhosttyAllocatorVtable

The functions that make up a custom allocator.

`alloc` and `free` are required. `resize` and `remap` are optional, and when they are NULL the library grows memory by allocating a new block, copying, and freeing the old one. See memory-custom for a complete example and memory-alignment for an explanation of `alignment`.

Every function receives the `ctx` pointer from the [`GhosttyAllocator`](@ref) it belongs to. When the library resizes, remaps, or frees memory, it always passes the same `alignment` it used for the original allocation and the current length of the block, so your allocator does not need to record either.

Every function also receives `ret_addr`, the address of the code that requested the memory, or 0 if it is unknown. Allocators that track leaks or report where memory came from can use it. Most allocators ignore it.

Initialize the whole struct to zero before setting the fields you use, so the reserved slots are NULL.

The interface matches Zig's `std.mem.Allocator`. The library is written in Zig, so this lets it use your allocator directly, and it is an interface already proven by a wide range of allocators in the Zig ecosystem. Simple allocators can ignore most of the arguments. Zig's own libc allocator (CAllocator in `lib/std/heap.zig`) is a good short reference.

` allocator`

| Field    | Note                                                                                                                                                                                                                                                                                                                                                                                                          |
| :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| alloc    | Allocates a block. Required.                                                                                                                                                                                                                                                                                                                                                                                  |
| resize   | Resizes a block without moving it. Optional.                                                                                                                                                                                                                                                                                                                                                                  |
| remap    | Resizes a block and may move it. Optional.                                                                                                                                                                                                                                                                                                                                                                    |
| free     | Frees a block. Required.                                                                                                                                                                                                                                                                                                                                                                                      |
| reserved | Reserved for future versions. Must be NULL.  These slots let a future release add new allocator functions without changing the size of this struct. The library ignores any slot it does not know about, so leaving them NULL keeps your code working with future versions.  Debug builds of the library stop with an error if a reserved slot is not NULL, to catch a vtable that was not zero-initialized.  |
"""
struct GhosttyAllocatorVtable
    alloc::GhosttyAllocatorAllocFn
    resize::GhosttyAllocatorResizeFn
    remap::GhosttyAllocatorRemapFn
    free::GhosttyAllocatorFreeFn
    reserved::NTuple{4, Ptr{Cvoid}}
end

"""
    GhosttyAllocator

A custom allocator: a vtable and the context it operates on.

Pass a pointer to one of these to any function that takes an allocator, or pass NULL to use the default allocator described in memory-default. The library does not copy the allocator. It must stay valid for as long as anything allocated with it is in use.

` allocator`

| Field  | Note                                                                                                            |
| :----- | :-------------------------------------------------------------------------------------------------------------- |
| ctx    | Your allocator's state, passed unchanged to every vtable function. May be NULL if your allocator has no state.  |
| vtable | The functions that implement this allocator. Must not be NULL.                                                  |
"""
struct GhosttyAllocator
    ctx::Ptr{Cvoid}
    vtable::Ptr{GhosttyAllocatorVtable}
end

"""
    ghostty_alloc(allocator, len)

Allocate a buffer of `len` bytes.

Uses the provided allocator, or the default allocator if NULL is passed. The returned buffer must be freed with [`ghostty_free`](@ref)() using the same allocator.

` allocator`

# Arguments
* `allocator`: Pointer to the allocator to use, or NULL for the default
* `len`: Number of bytes to allocate
# Returns
Pointer to the allocated buffer, or NULL if len is zero or allocation failed
"""
function ghostty_alloc(allocator, len)
    @ccall libghostty_vt.ghostty_alloc(allocator::Ptr{GhosttyAllocator}, len::Csize_t)::Ptr{UInt8}
end

"""
    ghostty_free(allocator, ptr, len)

Free memory that was allocated by a libghostty-vt function.

Use this to free buffers returned by functions such as [`ghostty_formatter_format_alloc`](@ref)(). Pass the same allocator that was used for the allocation, or NULL if the default allocator was used.

Use this instead of the C `free()`, which can use a different heap than the library. See memory-buffers for why.

Passing a NULL `ptr` does nothing.

` allocator`

# Arguments
* `allocator`: Pointer to the allocator that was used to allocate the memory, or NULL if the default allocator was used
* `ptr`: Pointer to the memory to free (may be NULL)
* `len`: Length of the allocation in bytes (must match the original allocation size)
"""
function ghostty_free(allocator, ptr, len)
    @ccall libghostty_vt.ghostty_free(allocator::Ptr{GhosttyAllocator}, ptr::Ptr{UInt8}, len::Csize_t)::Cvoid
end

"""
    GhosttyOptimizeMode

Build optimization mode.
"""
@cenum GhosttyOptimizeMode::UInt32 begin
    GHOSTTY_OPTIMIZE_DEBUG = 0
    GHOSTTY_OPTIMIZE_RELEASE_SAFE = 1
    GHOSTTY_OPTIMIZE_RELEASE_SMALL = 2
    GHOSTTY_OPTIMIZE_RELEASE_FAST = 3
    GHOSTTY_OPTIMIZE_MODE_MAX_VALUE = 2147483647
end

"""
    GhosttyBuildInfo

Build info data types that can be queried.

Each variant documents the expected output pointer type.

| Enumerator                                              | Note                                                                                                                                                                                                                                                                                   |
| :------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_BUILD\\_INFO\\_INVALID                        | Invalid data type. Never results in any data extraction.                                                                                                                                                                                                                               |
| GHOSTTY\\_BUILD\\_INFO\\_SIMD                           | Whether SIMD-accelerated code paths are enabled.  Output type: bool *                                                                                                                                                                                                                  |
| GHOSTTY\\_BUILD\\_INFO\\_KITTY\\_GRAPHICS               | Whether this build includes the `kitty\\_graphics` feature, which provides the Kitty graphics protocol and the `ghostty\\_kitty\\_graphics\\_*` functions. It is always false on targets without an operating system, such as wasm32-freestanding. See features.  Output type: bool *  |
| GHOSTTY\\_BUILD\\_INFO\\_TMUX\\_CONTROL\\_MODE          | Whether tmux control mode support is available.  Output type: bool *                                                                                                                                                                                                                   |
| GHOSTTY\\_BUILD\\_INFO\\_OPTIMIZE                       | The optimization mode the library was built with.  Output type: [`GhosttyOptimizeMode`](@ref) *                                                                                                                                                                                        |
| GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_STRING               | The full version string (e.g. "1.2.3" or "1.2.3-dev+abcdef").  Output type: [`GhosttyString`](@ref) *                                                                                                                                                                                  |
| GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_MAJOR                | The major version number.  Output type: size\\_t *                                                                                                                                                                                                                                     |
| GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_MINOR                | The minor version number.  Output type: size\\_t *                                                                                                                                                                                                                                     |
| GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_PATCH                | The patch version number.  Output type: size\\_t *                                                                                                                                                                                                                                     |
| GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_PRE                  | The pre metadata string (e.g. "alpha", "beta", "dev"). Has zero length if no pre metadata is present.  Output type: [`GhosttyString`](@ref) *                                                                                                                                          |
| GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_BUILD                | The build metadata string (e.g. commit hash). Has zero length if no build metadata is present.  Output type: [`GhosttyString`](@ref) *                                                                                                                                                 |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_SNAPSHOT             | Whether this build includes the `snapshot` feature, which provides the `ghostty\\_snapshot\\_*` functions. See features.  Output type: bool *                                                                                                                                          |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_FORMATTER            | Whether this build includes the `formatter` feature, which provides the `ghostty\\_formatter\\_*` functions. See features.  Output type: bool *                                                                                                                                        |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_SELECTION            | Whether this build includes the `selection` feature, which provides the `ghostty\\_terminal\\_select\\_*`, `ghostty\\_terminal\\_selection\\_*` and `ghostty\\_selection\\_gesture\\_*` functions. See features.  Output type: bool *                                                  |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_SEARCH               | Whether this build includes the `search` feature, which provides the `ghostty\\_search\\_*` functions. See features.  Output type: bool *                                                                                                                                              |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_RENDER\\_STATE       | Whether this build includes the `render\\_state` feature, which provides the `ghostty\\_render\\_state\\_*` functions. See features.  Output type: bool *                                                                                                                              |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_INPUT\\_ENCODE       | Whether this build includes the `input\\_encode` feature, which provides the key, mouse, focus and paste encoding functions. See features for the full list.  Output type: bool *                                                                                                      |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_COLOR                | Whether this build includes the `color` feature, which provides the `ghostty\\_color\\_*` functions. See features.  Output type: bool *                                                                                                                                                |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_GRID\\_INTROSPECTION | Whether this build includes the `grid\\_introspection` feature, which provides the `ghostty\\_grid\\_ref\\_*`, `ghostty\\_tracked\\_grid\\_ref\\_*`, `[`ghostty_cell_get`](@ref)*` and `[`ghostty_row_get`](@ref)*` functions. See features for the full list.  Output type: bool *    |
| GHOSTTY\\_BUILD\\_INFO\\_FEATURE\\_GLYPH\\_PROTOCOL     | Whether this build includes the `glyph\\_protocol` feature, which lets applications register custom glyphs with Ghostty's glyph protocol. It has no functions of its own. See features.  Output type: bool *                                                                           |
| GHOSTTY\\_BUILD\\_INFO\\_MAX\\_VALUE                    |                                                                                                                                                                                                                                                                                        |
"""
@cenum GhosttyBuildInfo::UInt32 begin
    GHOSTTY_BUILD_INFO_INVALID = 0
    GHOSTTY_BUILD_INFO_SIMD = 1
    GHOSTTY_BUILD_INFO_KITTY_GRAPHICS = 2
    GHOSTTY_BUILD_INFO_TMUX_CONTROL_MODE = 3
    GHOSTTY_BUILD_INFO_OPTIMIZE = 4
    GHOSTTY_BUILD_INFO_VERSION_STRING = 5
    GHOSTTY_BUILD_INFO_VERSION_MAJOR = 6
    GHOSTTY_BUILD_INFO_VERSION_MINOR = 7
    GHOSTTY_BUILD_INFO_VERSION_PATCH = 8
    GHOSTTY_BUILD_INFO_VERSION_PRE = 9
    GHOSTTY_BUILD_INFO_VERSION_BUILD = 10
    GHOSTTY_BUILD_INFO_FEATURE_SNAPSHOT = 11
    GHOSTTY_BUILD_INFO_FEATURE_FORMATTER = 12
    GHOSTTY_BUILD_INFO_FEATURE_SELECTION = 13
    GHOSTTY_BUILD_INFO_FEATURE_SEARCH = 14
    GHOSTTY_BUILD_INFO_FEATURE_RENDER_STATE = 15
    GHOSTTY_BUILD_INFO_FEATURE_INPUT_ENCODE = 16
    GHOSTTY_BUILD_INFO_FEATURE_COLOR = 17
    GHOSTTY_BUILD_INFO_FEATURE_GRID_INTROSPECTION = 18
    GHOSTTY_BUILD_INFO_FEATURE_GLYPH_PROTOCOL = 19
    GHOSTTY_BUILD_INFO_MAX_VALUE = 2147483647
end

"""
    ghostty_build_info(data, out)

Query a compile-time build configuration value.

You must pass a pointer to the correct output type for the requested data (see [`GhosttyBuildInfo`](@ref) variants for types).

` c-vt-build-info/src/main.c build-info-query`

Full program: c-vt-build-info/src/main.c

` build_info`

# Arguments
* `data`: The build info field to query
* `out`: Pointer to store the result (type depends on data parameter)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `data` is GHOSTTY\\_BUILD\\_INFO\\_INVALID or `out` is NULL, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_build_info(data, out)
    @ccall libghostty_vt.ghostty_build_info(data::GhosttyBuildInfo, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_version()

Get the full version of the library as a string.

This is the version of the library your program loaded, which can differ from the [`GHOSTTY_VT_VERSION`](@ref) of the headers it was compiled against. See version "Version" for when that matters.

A release returns its version, such as "1.0.0". A development build also has a pre-release and build suffix, such as "1.1.0-dev+abc1234".

This returns the same text as GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_STRING, but as a null-terminated string that you can pass straight to `printf` or to other languages. To get the version as numbers, use [`ghostty_build_info`](@ref)() with GHOSTTY\\_BUILD\\_INFO\\_VERSION\\_MAJOR and the values that follow it.

```c++
 printf("Using libghostty-vt %s\\n", ghostty_version());
```

` build_info`

# Returns
The version string. It is never NULL, is owned by the library, and stays valid for as long as the library is loaded. Do not free it.
"""
function ghostty_version()
    @ccall libghostty_vt.ghostty_version()::Cstring
end

"""
    GhosttyColorRgb

RGB color value.

` color`

| Field | Note                     |
| :---- | :----------------------- |
| r     | Red component (0-255)    |
| g     | Green component (0-255)  |
| b     | Blue component (0-255)   |
"""
struct GhosttyColorRgb
    r::UInt8
    g::UInt8
    b::UInt8
end

"""
Palette color index (0-255).

` color`
"""
const GhosttyColorPaletteIndex = UInt8

"""
    GhosttyColorPaletteMask

A 256-bit mask of palette indices.

Index i is set iff `(bits[i >> 6] >> (i & 63)) & 1` is 1. The mask is typically initialized to zero and then populated with [`GHOSTTY_COLOR_PALETTE_MASK_SET`](@ref)().

```c++
{.c}
 GhosttyColorPaletteMask mask = {0};
 GHOSTTY_COLOR_PALETTE_MASK_SET(&mask, 20);
 if (GHOSTTY_COLOR_PALETTE_MASK_IS_SET(&mask, 20)) {
   // Index 20 will be preserved.
 }
```

` color`
"""
struct GhosttyColorPaletteMask
    bits::NTuple{4, UInt64}
end

"""
    GhosttyColorX11Entry

An entry in Ghostty's X11 color name table.

` color`

| Field | Note                                                          |
| :---- | :------------------------------------------------------------ |
| name  | Null-terminated color name. NULL marks the end of the table.  |
| color | The RGB value of the color.                                   |
"""
struct GhosttyColorX11Entry
    name::Cstring
    color::GhosttyColorRgb
end

"""
    ghostty_color_rgb_get(color, r, g, b)

Get the RGB color components.

This function extracts the individual red, green, and blue components from a [`GhosttyColorRgb`](@ref) value. Primarily useful in WebAssembly environments where accessing struct fields directly is difficult.

` color`

# Arguments
* `color`: Pointer to the RGB color value (NULL does nothing)
* `r`: Pointer to store the red component (0-255), or NULL to skip it
* `g`: Pointer to store the green component (0-255), or NULL to skip it
* `b`: Pointer to store the blue component (0-255), or NULL to skip it
"""
function ghostty_color_rgb_get(color, r, g, b)
    @ccall libghostty_vt.ghostty_color_rgb_get(color::Ptr{GhosttyColorRgb}, r::Ptr{UInt8}, g::Ptr{UInt8}, b::Ptr{UInt8})::Cvoid
end

"""
    ghostty_color_parse_x11(name, len, out)

Parse an X11 color name.

The color name is resolved from Ghostty's embedded rgb.txt table. Leading and trailing spaces and tabs are trimmed, and matching is ASCII case-insensitive. Hex values are not accepted by this function.

` color`

# Arguments
* `name`: The color name bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `len`: The length of `name` in bytes
* `out`:\\[out\\] The parsed RGB color (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if no color matches or `name` or `out` is NULL
"""
function ghostty_color_parse_x11(name, len, out)
    @ccall libghostty_vt.ghostty_color_parse_x11(name::Cstring, len::Csize_t, out::Ptr{GhosttyColorRgb})::GhosttyResult
end

"""
    ghostty_color_parse(value, len, out)

Parse a flexible Ghostty color value.

Accepts Ghostty's terminal color syntax: X11 color names, hex colors in 3-, 6-, 9-, or 12-digit form (the leading # is optional for 3- and 6-digit values), and `rgb:<red>/<green>/<blue>` or `rgbi:<red>/<green>/<blue>` specifications. Leading and trailing spaces and tabs are trimmed.

` color`

# Arguments
* `value`: The color value bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `len`: The length of `value` in bytes
* `out`:\\[out\\] The parsed RGB color (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if parsing fails or `value` or `out` is NULL
"""
function ghostty_color_parse(value, len, out)
    @ccall libghostty_vt.ghostty_color_parse(value::Cstring, len::Csize_t, out::Ptr{GhosttyColorRgb})::GhosttyResult
end

"""
    ghostty_color_parse_palette_entry(value, len, out_index, out_rgb)

Parse a Ghostty palette entry.

Accepts Ghostty palette config syntax: N=COLOR. N is a palette index from 0 to 255 in decimal or in 0x, 0o, or 0b-prefixed form. Spaces and tabs around N and COLOR are ignored. COLOR accepts the same syntax as [`ghostty_color_parse`](@ref)().

` color`

# Arguments
* `value`: The palette entry bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `len`: The length of `value` in bytes
* `out_index`:\\[out\\] The parsed palette index (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_rgb`:\\[out\\] The parsed RGB color (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE on any failure, including index overflow
"""
function ghostty_color_parse_palette_entry(value, len, out_index, out_rgb)
    @ccall libghostty_vt.ghostty_color_parse_palette_entry(value::Cstring, len::Csize_t, out_index::Ptr{UInt8}, out_rgb::Ptr{GhosttyColorRgb})::GhosttyResult
end

"""
    ghostty_color_palette_default(out)

Get Ghostty's built-in default 256-color palette.

Writes exactly 256 entries: Ghostty's base16 defaults, the xterm 6x6x6 color cube, and the grayscale ramp.

` color`

# Arguments
* `out`:\\[out\\] The output palette, an array of exactly 256 [`GhosttyColorRgb`](@ref) values (NULL does nothing)
"""
function ghostty_color_palette_default(out)
    @ccall libghostty_vt.ghostty_color_palette_default(out::Ptr{GhosttyColorRgb})::Cvoid
end

"""
    ghostty_color_palette_generate(base, skip, bg, fg, harmonious, out)

Generate a 256-color palette from base colors.

The base palette supplies indices 0-15, which are always preserved. If `base` is NULL, Ghostty's default palette is used. If `skip` is NULL, no extra indices are skipped. Set bits in `skip` preserve those indices from `base`. The 216-color cube at indices 16-231 is generated with trilinear CIELAB interpolation, and the grayscale ramp at indices 232-255 is interpolated from the background to the foreground.

For light themes, `harmonious` controls whether the generated palette keeps the background-to-foreground orientation. When false, Ghostty swaps the light background and dark foreground so the cube and ramp run dark-to-light. The output palette may be the same pointer as `base`.

` color`

# Arguments
* `base`: The base palette, an array of exactly 256 [`GhosttyColorRgb`](@ref) values, or NULL to use Ghostty's default palette
* `skip`: The palette indices to preserve from `base`, or NULL for an empty mask
* `bg`: The terminal background color (NULL does nothing)
* `fg`: The terminal foreground color (NULL does nothing)
* `harmonious`: Whether light themes keep background-to-foreground orientation
* `out`:\\[out\\] The output palette, an array of exactly 256 [`GhosttyColorRgb`](@ref) values (NULL does nothing)
"""
function ghostty_color_palette_generate(base, skip, bg, fg, harmonious, out)
    @ccall libghostty_vt.ghostty_color_palette_generate(base::Ptr{GhosttyColorRgb}, skip::Ptr{GhosttyColorPaletteMask}, bg::Ptr{GhosttyColorRgb}, fg::Ptr{GhosttyColorRgb}, harmonious::Bool, out::Ptr{GhosttyColorRgb})::Cvoid
end

"""
    ghostty_color_luminance(color)

Calculate W3C relative luminance for an RGB color.

Returns a normalized value from 0.0 for black to 1.0 for white. See https://www.w3.org/TR/WCAG20/#relativeluminancedef.

` color`

# Arguments
* `color`: The RGB color (NULL returns 0)
# Returns
Relative luminance in the range 0.0 to 1.0
"""
function ghostty_color_luminance(color)
    @ccall libghostty_vt.ghostty_color_luminance(color::Ptr{GhosttyColorRgb})::Cdouble
end

"""
    ghostty_color_perceived_luminance(color)

Calculate perceived luminance for an RGB color.

Returns a normalized value from 0.0 for black to 1.0 for white. Ghostty treats a background color as light when this exceeds 0.5. This is not the metric used internally by [`ghostty_color_palette_generate`](@ref)(), which uses CIELAB lightness.

` color`

# Arguments
* `color`: The RGB color (NULL returns 0)
# Returns
Perceived luminance in the range 0.0 to 1.0
"""
function ghostty_color_perceived_luminance(color)
    @ccall libghostty_vt.ghostty_color_perceived_luminance(color::Ptr{GhosttyColorRgb})::Cdouble
end

"""
    ghostty_color_contrast(a, b)

Calculate the WCAG contrast ratio between two RGB colors.

The contrast ratio is symmetric and ranges from 1.0 for identical colors to 21.0 for black and white.

` color`

# Arguments
* `a`: The first RGB color (NULL returns 0)
* `b`: The second RGB color (NULL returns 0)
# Returns
WCAG contrast ratio in the range 1.0 to 21.0
"""
function ghostty_color_contrast(a, b)
    @ccall libghostty_vt.ghostty_color_contrast(a::Ptr{GhosttyColorRgb}, b::Ptr{GhosttyColorRgb})::Cdouble
end

"""
    ghostty_color_x11_names()

Get Ghostty's X11 color name table.

The returned pointer references static memory valid for the program lifetime and is never NULL. Entries are in rgb.txt order and are terminated by an entry with name == NULL. Aliases are separate entries, such as "medium spring green" and "MediumSpringGreen". Names are the exact supported spellings from rgb.txt; [`ghostty_color_parse_x11`](@ref)() also matches them case-insensitively.

A library built without the color feature returns an empty table, so its first entry is the terminator and the loop below does nothing.

```c++
{.c}
 for (const GhosttyColorX11Entry* e = ghostty_color_x11_names();
      e->name != NULL;
      e++) {
   // e->name and e->color are valid here.
 }
```

` color`

# Returns
Pointer to the first X11 color entry
"""
function ghostty_color_x11_names()
    @ccall libghostty_vt.ghostty_color_x11_names()::Ptr{GhosttyColorX11Entry}
end

"""
    ghostty_color_x11_name_count()

Get the number of X11 color name entries.

The returned count excludes the NULL terminator and is provided so bindings can preallocate storage before reading [`ghostty_color_x11_names`](@ref)().

` color`

# Returns
Number of X11 color name entries
"""
function ghostty_color_x11_name_count()
    @ccall libghostty_vt.ghostty_color_x11_name_count()::Csize_t
end

"""
    GhosttyColorScheme

Color scheme reported in response to a CSI ? 996 n query.

` effects`
"""
@cenum GhosttyColorScheme::UInt32 begin
    GHOSTTY_COLOR_SCHEME_LIGHT = 0
    GHOSTTY_COLOR_SCHEME_DARK = 1
    GHOSTTY_COLOR_SCHEME_MAX_VALUE = 2147483647
end

"""
    GhosttyDeviceAttributesPrimary

Primary device attributes (DA1) response data.

Returned as part of [`GhosttyDeviceAttributes`](@ref) in response to a CSI c query. The conformance\\_level is the Pp parameter and features contains the Ps feature codes.

` effects`

| Field               | Note                                                                 |
| :------------------ | :------------------------------------------------------------------- |
| conformance\\_level | Conformance level (Pp parameter). E.g. 62 for VT220.                 |
| features            | DA1 feature codes. Only the first num\\_features entries are valid.  |
| num\\_features      | Number of valid entries in the features array.                       |
"""
struct GhosttyDeviceAttributesPrimary
    conformance_level::UInt16
    features::NTuple{64, UInt16}
    num_features::Csize_t
end

"""
    GhosttyDeviceAttributesSecondary

Secondary device attributes (DA2) response data.

Returned as part of [`GhosttyDeviceAttributes`](@ref) in response to a CSI > c query. Response format: CSI > Pp ; Pv ; Pc c

` effects`

| Field              | Note                                                             |
| :----------------- | :--------------------------------------------------------------- |
| device\\_type      | Terminal type identifier (Pp). E.g. 1 for VT220.                 |
| firmware\\_version | Firmware/patch version number (Pv).                              |
| rom\\_cartridge    | ROM cartridge registration number (Pc). Always 0 for emulators.  |
"""
struct GhosttyDeviceAttributesSecondary
    device_type::UInt16
    firmware_version::UInt16
    rom_cartridge::UInt16
end

"""
    GhosttyDeviceAttributesTertiary

Tertiary device attributes (DA3) response data.

Returned as part of [`GhosttyDeviceAttributes`](@ref) in response to a CSI = c query. Response format: DCS ! | D...D ST (DECRPTUI).

` effects`

| Field     | Note                                                        |
| :-------- | :---------------------------------------------------------- |
| unit\\_id | Unit ID encoded as 8 uppercase hex digits in the response.  |
"""
struct GhosttyDeviceAttributesTertiary
    unit_id::UInt32
end

"""
    GhosttyDeviceAttributes

Device attributes response data for all three DA levels.

Filled by the device\\_attributes callback in response to CSI c, CSI > c, or CSI = c queries. The terminal uses whichever sub-struct matches the request type.

` effects`
"""
struct GhosttyDeviceAttributes
    primary::GhosttyDeviceAttributesPrimary
    secondary::GhosttyDeviceAttributesSecondary
    tertiary::GhosttyDeviceAttributesTertiary
end

"""
    ghostty_color_scheme_report_encode(scheme, buf, buf_len, out_written)

Encode a color scheme report into an escape sequence.

Encodes a color scheme report into the provided buffer. Dark color schemes emit ESC [ ? 997 ; 1 n, and light color schemes emit ESC [ ? 997 ; 2 n. The encoded bytes are identical to the terminal's internal CSI ? 996 n query response.

Hosts should gate unsolicited sends on [`GHOSTTY_MODE_REPORT_COLOR_SCHEME`](@ref) (mode 2031) being set. Read it with [`ghostty_terminal_get`](@ref)() and GHOSTTY\\_TERMINAL\\_DATA\\_MODE.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets `out_written` to the size needed. The buffer may then hold part of the sequence, which you should discard. To get the size without encoding anything, pass NULL for `buf` and 0 for `buf_len`.

# Arguments
* `scheme`: The color scheme to encode
* `buf`: Buffer to write the sequence into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if the buffer is too small, or GHOSTTY\\_INVALID\\_VALUE if `out_written` is NULL
"""
function ghostty_color_scheme_report_encode(scheme, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_color_scheme_report_encode(scheme::GhosttyColorScheme, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    GhosttyFocusEvent

Focus event types for focus reporting mode (mode 1004).

| Enumerator                    | Note                          |
| :---------------------------- | :---------------------------- |
| GHOSTTY\\_FOCUS\\_GAINED      | Terminal window gained focus  |
| GHOSTTY\\_FOCUS\\_LOST        | Terminal window lost focus    |
| GHOSTTY\\_FOCUS\\_MAX\\_VALUE |                               |
"""
@cenum GhosttyFocusEvent::UInt32 begin
    GHOSTTY_FOCUS_GAINED = 0
    GHOSTTY_FOCUS_LOST = 1
    GHOSTTY_FOCUS_MAX_VALUE = 2147483647
end

"""
    ghostty_focus_encode(event, buf, buf_len, out_written)

Encode a focus event into a terminal escape sequence.

Encodes a focus gained (CSI I) or focus lost (CSI O) report into the provided buffer.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets `out_written` to the size needed. The buffer may then hold part of the sequence, which you should discard. To get the size without encoding anything, pass NULL for `buf` and 0 for `buf_len`.

# Arguments
* `event`: The focus event to encode
* `buf`: Buffer to write the sequence into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if the buffer is too small, or GHOSTTY\\_INVALID\\_VALUE if `event` is not a known focus event or `out_written` is NULL
"""
function ghostty_focus_encode(event, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_focus_encode(event::GhosttyFocusEvent, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

# typedef bool ( * GhosttyReaderFn ) ( void * userdata , uint8_t * buffer , size_t capacity , size_t * out_read )
"""
Read bytes from a source.

The callback must set `out_read` to a value no greater than `capacity` when returning true. A positive value reports progress; it may be less than capacity and does not indicate end-of-file. A zero value is definitive end-of-file. It must not be used to report temporary input starvation or a would-block condition.

Returning false reports a fatal read error and the value of `out_read` is ignored. The library does not inspect or modify errno.

All pointer arguments are borrowed and valid only for the duration of the callback. The callback is invoked synchronously on the calling thread.

# Arguments
* `userdata`: Opaque userdata from [`GhosttyReader`](@ref)
* `buffer`: Destination for read bytes; always non-NULL
* `capacity`: Writable capacity of `buffer`; always greater than zero
* `out_read`:\\[out\\] Number of bytes read when returning true; non-NULL
# Returns
true for a successful read or end-of-file, false for a fatal error
"""
const GhosttyReaderFn = Ptr{Cvoid}

# typedef bool ( * GhosttyWriterFn ) ( void * userdata , const uint8_t * data , size_t len )
"""
Write bytes to a destination.

Returning true means all `len` bytes were accepted. Returning false reports a fatal write error. A callback wrapping an interface that permits partial writes must retry internally until the full slice is accepted or an error occurs.

On failure, the destination may already contain a prefix of the bytes. The calling operation fails and must not be resumed from that partial output. The library does not inspect or modify errno.

`data` is borrowed and valid only for the duration of the callback. The callback is invoked synchronously on the calling thread. Successful return means the bytes were handed to the destination; it does not imply that the destination was flushed or made durable.

# Arguments
* `userdata`: Opaque userdata from [`GhosttyWriter`](@ref)
* `data`: Source bytes; always non-NULL
* `len`: Number of source bytes; always greater than zero
# Returns
true if the complete slice was accepted, false on fatal error
"""
const GhosttyWriterFn = Ptr{Cvoid}

"""
    GhosttyReader

A byte source callback and its opaque context.

The struct is passed by value. `read` must be non-NULL.
"""
struct GhosttyReader
    read::GhosttyReaderFn
    userdata::Ptr{Cvoid}
end

"""
    GhosttyWriter

A byte destination callback and its opaque context.

The struct is passed by value. `write` must be non-NULL.
"""
struct GhosttyWriter
    write::GhosttyWriterFn
    userdata::Ptr{Cvoid}
end

# typedef bool ( * GhosttyMimeReaderFn ) ( void * userdata , GhosttyString mime , GhosttyWriter writer )
"""
Read one MIME-typed representation of some content, streaming its bytes to a writer.

The library calls this with the MIME type of the representation it needs. The callback writes all of that representation's data to `writer`, in as many calls to `writer.write(writer.userdata, data, len)` as is convenient (one call with everything or many small pieces both work), and returns true. Nothing written is retained beyond each write call, so the data may be borrowed from anywhere: a pasteboard item, a file being read, a stream.

Returning false reports that the data could not be read. If the writer refuses a write (returns false), stop and return false without writing more.

All pointer arguments, the mime, and the writer are borrowed and valid only for the duration of the callback. The callback is invoked synchronously on the calling thread. The API receiving the [`GhosttyMimeReader`](@ref) defines which MIME types are requested, how many times, and any consistency requirements across repeated reads.

# Arguments
* `userdata`: Opaque userdata from [`GhosttyMimeReader`](@ref)
* `mime`: The MIME type of the representation to read
* `writer`: Where to write the data; valid only during this call
# Returns
true once all the data was written, false if it could not be read or the writer refused a write
"""
const GhosttyMimeReaderFn = Ptr{Cvoid}

"""
    GhosttyMimeReader

A MIME-typed content source callback and its opaque context.

The struct is passed by value. `read` must be non-NULL.
"""
struct GhosttyMimeReader
    read::GhosttyMimeReaderFn
    userdata::Ptr{Cvoid}
end

"""
Packed cell value.

Represents a single terminal cell. Portable callers can query fields via [`ghostty_cell_get`](@ref)(). Boundary-sensitive callers can decode the packed value using the [`GhosttyCell`](@ref) descriptor returned by [`ghostty_type_json`](@ref)(). The manifest is authoritative for the linked build; hardcoding bit positions is unsupported.

` screen`
"""
const GhosttyCell = UInt64

"""
Opaque row value.

Represents a single terminal row. The internal layout is opaque and must be queried via [`ghostty_row_get`](@ref)(). Obtain row values from terminal query APIs.

` screen`
"""
const GhosttyRow = UInt64

"""
    GhosttyCellsView

A borrowed view of contiguous raw cell values.

The memory is not owned by this struct. The pointer is only valid for the lifetime documented by the API that produces it. Each value can be queried via [`ghostty_cell_get`](@ref)() or decoded using the [`GhosttyCell`](@ref) packed descriptor returned by [`ghostty_type_json`](@ref)().

` screen`

| Field | Note                                    |
| :---- | :-------------------------------------- |
| ptr   | Pointer to len contiguous cell values.  |
| len   | Number of cells.                        |
"""
struct GhosttyCellsView
    ptr::Ptr{GhosttyCell}
    len::Csize_t
end

"""
    GhosttyCellContentTag

Cell content tag.

Describes what kind of content a cell holds.

` screen`

| Enumerator                                      | Note                                                             |
| :---------------------------------------------- | :--------------------------------------------------------------- |
| GHOSTTY\\_CELL\\_CONTENT\\_CODEPOINT            | A single codepoint (may be zero for empty).                      |
| GHOSTTY\\_CELL\\_CONTENT\\_CODEPOINT\\_GRAPHEME | A codepoint that is part of a multi-codepoint grapheme cluster.  |
| GHOSTTY\\_CELL\\_CONTENT\\_BG\\_COLOR\\_PALETTE | No text; background color from palette.                          |
| GHOSTTY\\_CELL\\_CONTENT\\_BG\\_COLOR\\_RGB     | No text; background color as RGB.                                |
| GHOSTTY\\_CELL\\_CONTENT\\_TAG\\_MAX\\_VALUE    |                                                                  |
"""
@cenum GhosttyCellContentTag::UInt32 begin
    GHOSTTY_CELL_CONTENT_CODEPOINT = 0
    GHOSTTY_CELL_CONTENT_CODEPOINT_GRAPHEME = 1
    GHOSTTY_CELL_CONTENT_BG_COLOR_PALETTE = 2
    GHOSTTY_CELL_CONTENT_BG_COLOR_RGB = 3
    GHOSTTY_CELL_CONTENT_TAG_MAX_VALUE = 2147483647
end

"""
    GhosttyCellWide

Cell wide property.

Describes the width behavior of a cell.

` screen`

| Enumerator                            | Note                                                      |
| :------------------------------------ | :-------------------------------------------------------- |
| GHOSTTY\\_CELL\\_WIDE\\_NARROW        | Not a wide character, cell width 1.                       |
| GHOSTTY\\_CELL\\_WIDE\\_WIDE          | Wide character, cell width 2.                             |
| GHOSTTY\\_CELL\\_WIDE\\_SPACER\\_TAIL | Spacer after wide character. Do not render.               |
| GHOSTTY\\_CELL\\_WIDE\\_SPACER\\_HEAD | Spacer at end of soft-wrapped line for a wide character.  |
| GHOSTTY\\_CELL\\_WIDE\\_MAX\\_VALUE   |                                                           |
"""
@cenum GhosttyCellWide::UInt32 begin
    GHOSTTY_CELL_WIDE_NARROW = 0
    GHOSTTY_CELL_WIDE_WIDE = 1
    GHOSTTY_CELL_WIDE_SPACER_TAIL = 2
    GHOSTTY_CELL_WIDE_SPACER_HEAD = 3
    GHOSTTY_CELL_WIDE_MAX_VALUE = 2147483647
end

"""
    GhosttyCellSemanticContent

Semantic content type of a cell.

Set by semantic prompt sequences (OSC 133) to distinguish between command output, user input, and shell prompt text.

` screen`

| Enumerator                              | Note                                             |
| :-------------------------------------- | :----------------------------------------------- |
| GHOSTTY\\_CELL\\_SEMANTIC\\_OUTPUT      | Regular output content, such as command output.  |
| GHOSTTY\\_CELL\\_SEMANTIC\\_INPUT       | Content that is part of user input.              |
| GHOSTTY\\_CELL\\_SEMANTIC\\_PROMPT      | Content that is part of a shell prompt.          |
| GHOSTTY\\_CELL\\_SEMANTIC\\_MAX\\_VALUE |                                                  |
"""
@cenum GhosttyCellSemanticContent::UInt32 begin
    GHOSTTY_CELL_SEMANTIC_OUTPUT = 0
    GHOSTTY_CELL_SEMANTIC_INPUT = 1
    GHOSTTY_CELL_SEMANTIC_PROMPT = 2
    GHOSTTY_CELL_SEMANTIC_MAX_VALUE = 2147483647
end

"""
    GhosttyCellData

Cell data types.

These values specify what type of data to extract from a cell using [`ghostty_cell_get`](@ref).

` screen`

| Enumerator                                 | Note                                                                                                                                                                                     |
| :----------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_CELL\\_DATA\\_INVALID            | Invalid data type. Never results in any data extraction.                                                                                                                                 |
| GHOSTTY\\_CELL\\_DATA\\_CODEPOINT          | The codepoint of the cell (0 if empty or bg-color-only).  Output type: uint32\\_t *                                                                                                      |
| GHOSTTY\\_CELL\\_DATA\\_CONTENT\\_TAG      | The content tag describing what kind of content is in the cell.  Output type: [`GhosttyCellContentTag`](@ref) *                                                                          |
| GHOSTTY\\_CELL\\_DATA\\_WIDE               | The wide property of the cell.  Output type: [`GhosttyCellWide`](@ref) *                                                                                                                 |
| GHOSTTY\\_CELL\\_DATA\\_HAS\\_TEXT         | Whether the cell has text to render.  Output type: bool *                                                                                                                                |
| GHOSTTY\\_CELL\\_DATA\\_HAS\\_STYLING      | Whether the cell has non-default styling.  Output type: bool *                                                                                                                           |
| GHOSTTY\\_CELL\\_DATA\\_STYLE\\_ID         | The style ID for the cell (for use with style lookups).  Output type: [`GhosttyStyleId`](@ref) * (uint16\\_t *)                                                                          |
| GHOSTTY\\_CELL\\_DATA\\_HAS\\_HYPERLINK    | Whether the cell has a hyperlink.  Output type: bool *                                                                                                                                   |
| GHOSTTY\\_CELL\\_DATA\\_PROTECTED          | Whether the cell is protected.  Output type: bool *                                                                                                                                      |
| GHOSTTY\\_CELL\\_DATA\\_SEMANTIC\\_CONTENT | The semantic content type of the cell (from OSC 133).  Output type: [`GhosttyCellSemanticContent`](@ref) *                                                                               |
| GHOSTTY\\_CELL\\_DATA\\_COLOR\\_PALETTE    | The palette index for the cell's background color. Only valid when content\\_tag is GHOSTTY\\_CELL\\_CONTENT\\_BG\\_COLOR\\_PALETTE.  Output type: [`GhosttyColorPaletteIndex`](@ref) *  |
| GHOSTTY\\_CELL\\_DATA\\_COLOR\\_RGB        | The RGB value for the cell's background color. Only valid when content\\_tag is GHOSTTY\\_CELL\\_CONTENT\\_BG\\_COLOR\\_RGB.  Output type: [`GhosttyColorRgb`](@ref) *                   |
| GHOSTTY\\_CELL\\_DATA\\_MAX\\_VALUE        |                                                                                                                                                                                          |
"""
@cenum GhosttyCellData::UInt32 begin
    GHOSTTY_CELL_DATA_INVALID = 0
    GHOSTTY_CELL_DATA_CODEPOINT = 1
    GHOSTTY_CELL_DATA_CONTENT_TAG = 2
    GHOSTTY_CELL_DATA_WIDE = 3
    GHOSTTY_CELL_DATA_HAS_TEXT = 4
    GHOSTTY_CELL_DATA_HAS_STYLING = 5
    GHOSTTY_CELL_DATA_STYLE_ID = 6
    GHOSTTY_CELL_DATA_HAS_HYPERLINK = 7
    GHOSTTY_CELL_DATA_PROTECTED = 8
    GHOSTTY_CELL_DATA_SEMANTIC_CONTENT = 9
    GHOSTTY_CELL_DATA_COLOR_PALETTE = 10
    GHOSTTY_CELL_DATA_COLOR_RGB = 11
    GHOSTTY_CELL_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttyRowSemanticPrompt

Row semantic prompt state.

Indicates whether any cells in a row are part of a shell prompt, as reported by OSC 133 sequences.

` screen`

| Enumerator                                       | Note                                                   |
| :----------------------------------------------- | :----------------------------------------------------- |
| GHOSTTY\\_ROW\\_SEMANTIC\\_NONE                  | No prompt cells in this row.                           |
| GHOSTTY\\_ROW\\_SEMANTIC\\_PROMPT                | Prompt cells exist and this is a primary prompt line.  |
| GHOSTTY\\_ROW\\_SEMANTIC\\_PROMPT\\_CONTINUATION | Prompt cells exist and this is a continuation line.    |
| GHOSTTY\\_ROW\\_SEMANTIC\\_MAX\\_VALUE           |                                                        |
"""
@cenum GhosttyRowSemanticPrompt::UInt32 begin
    GHOSTTY_ROW_SEMANTIC_NONE = 0
    GHOSTTY_ROW_SEMANTIC_PROMPT = 1
    GHOSTTY_ROW_SEMANTIC_PROMPT_CONTINUATION = 2
    GHOSTTY_ROW_SEMANTIC_MAX_VALUE = 2147483647
end

"""
    GhosttyRowData

Row data types.

These values specify what type of data to extract from a row using [`ghostty_row_get`](@ref).

` screen`

| Enumerator                                           | Note                                                                                            |
| :--------------------------------------------------- | :---------------------------------------------------------------------------------------------- |
| GHOSTTY\\_ROW\\_DATA\\_INVALID                       | Invalid data type. Never results in any data extraction.                                        |
| GHOSTTY\\_ROW\\_DATA\\_WRAP                          | Whether this row is soft-wrapped.  Output type: bool *                                          |
| GHOSTTY\\_ROW\\_DATA\\_WRAP\\_CONTINUATION           | Whether this row is a continuation of a soft-wrapped row.  Output type: bool *                  |
| GHOSTTY\\_ROW\\_DATA\\_GRAPHEME                      | Whether any cells in this row have grapheme clusters.  Output type: bool *                      |
| GHOSTTY\\_ROW\\_DATA\\_STYLED                        | Whether any cells in this row have styling (may have false positives).  Output type: bool *     |
| GHOSTTY\\_ROW\\_DATA\\_HYPERLINK                     | Whether any cells in this row have hyperlinks (may have false positives).  Output type: bool *  |
| GHOSTTY\\_ROW\\_DATA\\_SEMANTIC\\_PROMPT             | The semantic prompt state of this row.  Output type: [`GhosttyRowSemanticPrompt`](@ref) *       |
| GHOSTTY\\_ROW\\_DATA\\_KITTY\\_VIRTUAL\\_PLACEHOLDER | Whether this row contains a Kitty virtual placeholder.  Output type: bool *                     |
| GHOSTTY\\_ROW\\_DATA\\_DIRTY                         | Whether this row is dirty and requires a redraw.  Output type: bool *                           |
| GHOSTTY\\_ROW\\_DATA\\_MAX\\_VALUE                   |                                                                                                 |
"""
@cenum GhosttyRowData::UInt32 begin
    GHOSTTY_ROW_DATA_INVALID = 0
    GHOSTTY_ROW_DATA_WRAP = 1
    GHOSTTY_ROW_DATA_WRAP_CONTINUATION = 2
    GHOSTTY_ROW_DATA_GRAPHEME = 3
    GHOSTTY_ROW_DATA_STYLED = 4
    GHOSTTY_ROW_DATA_HYPERLINK = 5
    GHOSTTY_ROW_DATA_SEMANTIC_PROMPT = 6
    GHOSTTY_ROW_DATA_KITTY_VIRTUAL_PLACEHOLDER = 7
    GHOSTTY_ROW_DATA_DIRTY = 8
    GHOSTTY_ROW_DATA_MAX_VALUE = 2147483647
end

"""
    ghostty_cell_get(cell, data, out)

Get data from a cell.

Extracts typed data from the given cell based on the specified data type. The output pointer must be of the appropriate type for the requested data kind. Valid data types and output types are documented in the [`GhosttyCellData`](@ref) enum.

` screen`

# Arguments
* `cell`: The cell value
* `data`: The type of data to extract
* `out`: Pointer to store the extracted data (type depends on data parameter)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `data` is GHOSTTY\\_CELL\\_DATA\\_INVALID or `out` is NULL, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_cell_get(cell, data, out)
    @ccall libghostty_vt.ghostty_cell_get(cell::GhosttyCell, data::GhosttyCellData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_cell_get_multi(cell, count, keys, values, out_written)

Get multiple data fields from a cell in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_cell_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result.

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` screen`

# Arguments
* `cell`: The cell value
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_cell_get_multi(cell, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_cell_get_multi(cell::GhosttyCell, count::Csize_t, keys::Ptr{GhosttyCellData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_row_get(row, data, out)

Get data from a row.

Extracts typed data from the given row based on the specified data type. The output pointer must be of the appropriate type for the requested data kind. Valid data types and output types are documented in the [`GhosttyRowData`](@ref) enum.

` screen`

# Arguments
* `row`: The row value
* `data`: The type of data to extract
* `out`: Pointer to store the extracted data (type depends on data parameter)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `data` is GHOSTTY\\_ROW\\_DATA\\_INVALID or `out` is NULL, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_row_get(row, data, out)
    @ccall libghostty_vt.ghostty_row_get(row::GhosttyRow, data::GhosttyRowData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_row_get_multi(row, count, keys, values, out_written)

Get multiple data fields from a row in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_row_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result.

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` screen`

# Arguments
* `row`: The row value
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_row_get_multi(row, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_row_get_multi(row::GhosttyRow, count::Csize_t, keys::Ptr{GhosttyRowData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
Style identifier type.

Used to look up the full style from a grid reference. Obtain this from a cell via GHOSTTY\\_CELL\\_DATA\\_STYLE\\_ID.

` style`
"""
const GhosttyStyleId = UInt16

"""
    GhosttyStyleColorTag

Style color tags.

Identifies which kind of color a [`GhosttyStyleColor`](@ref) holds. The tag is stored in the one-byte `tag` field of [`GhosttyStyleColor`](@ref), so compare that field against these values.

` style`
"""
@cenum GhosttyStyleColorTag::UInt32 begin
    GHOSTTY_STYLE_COLOR_NONE = 0
    GHOSTTY_STYLE_COLOR_PALETTE = 1
    GHOSTTY_STYLE_COLOR_RGB = 2
    GHOSTTY_STYLE_COLOR_TAG_MAX_VALUE = 2147483647
end

"""
    GhosttyStyleColorValue

Style color value.

The color data of a [`GhosttyStyleColor`](@ref), three bytes long. The tag of the containing color says which field to read:

- GHOSTTY\\_STYLE\\_COLOR\\_NONE: no field is set and all bytes are zero. - GHOSTTY\\_STYLE\\_COLOR\\_PALETTE: read `palette`. The remaining two bytes are zero. - GHOSTTY\\_STYLE\\_COLOR\\_RGB: read `rgb`.

` style`
"""
struct GhosttyStyleColorValue
    data::NTuple{3, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyStyleColorValue}, f::Symbol)
    f === :palette && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :rgb && return Ptr{GhosttyColorRgb}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyStyleColorValue, f::Symbol)
    r = Ref{GhosttyStyleColorValue}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyStyleColorValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyStyleColorValue}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyStyleColorValue, private::Bool = false)
    (:palette, :rgb, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttyStyleColor

Style color.

A color used by a style. It is either unset, an index into the terminal palette, or a direct RGB value. The struct is four bytes: a one-byte tag followed by the three-byte value.

An unset color means the style does not choose a color. Use the terminal's default color for that slot instead.

```c++
{.c}
 switch (style.fg_color.tag) {
   case GHOSTTY_STYLE_COLOR_NONE:
     // Use the terminal's default foreground color.
     break;
   case GHOSTTY_STYLE_COLOR_PALETTE:
     // Look up style.fg_color.value.palette in the palette.
     break;
   case GHOSTTY_STYLE_COLOR_RGB:
     // Use style.fg_color.value.rgb directly.
     break;
 }
```

` style`

| Field | Note                                                                  |
| :---- | :-------------------------------------------------------------------- |
| tag   | The kind of color. One of the [`GhosttyStyleColorTag`](@ref) values.  |
| value | The color data. Which field is valid depends on `tag`.                |
"""
struct GhosttyStyleColor
    data::NTuple{4, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyStyleColor}, f::Symbol)
    f === :tag && return Ptr{UInt8}(x + 0)
    f === :value && return Ptr{GhosttyStyleColorValue}(x + 1)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyStyleColor, f::Symbol)
    r = Ref{GhosttyStyleColor}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyStyleColor}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyStyleColor}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyStyleColor, private::Bool = false)
    (:tag, :value, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttyStyle

Terminal cell style.

The complete visual style of a terminal cell: foreground, background, and underline colors, plus text attributes such as bold and the underline style.

The layout of this struct is fixed. It is 16 bytes on every platform and will not change in future versions, so it does not have a size field and does not need [`GHOSTTY_INIT_SIZED`](@ref)(). If a future version needs more style attributes, it will add a new type instead of changing this one.

Reserved bits are always zero in a style written by the library. This means two styles from the library can be compared with memcmp().

```c++
{.c}
 GhosttyStyle style;
 ghostty_render_state_row_cells_get(
     cells, GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_STYLE, &style);

 if (style.flags & GHOSTTY_STYLE_FLAG_BOLD) {
   // Draw with a bold font.
 }

 if (GHOSTTY_STYLE_UNDERLINE(style) != GHOSTTY_SGR_UNDERLINE_NONE) {
   // Draw an underline, colored by style.underline_color if it is set.
 }
```

` style`

| Field             | Note                                                                   |
| :---------------- | :--------------------------------------------------------------------- |
| fg\\_color        | Foreground (text) color.                                               |
| bg\\_color        | Background color.                                                      |
| underline\\_color | Underline color.                                                       |
| flags             | Text attributes and underline style. See [`GhosttyStyleFlags`](@ref).  |
| reserved          | Reserved for future use. Always zero.                                  |
"""
struct GhosttyStyle
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyStyle}, f::Symbol)
    f === :fg_color && return Ptr{GhosttyStyleColor}(x + 0)
    f === :bg_color && return Ptr{GhosttyStyleColor}(x + 4)
    f === :underline_color && return Ptr{GhosttyStyleColor}(x + 8)
    f === :flags && return Ptr{GhosttyStyleFlags}(x + 12)
    f === :reserved && return Ptr{UInt16}(x + 14)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyStyle, f::Symbol)
    r = Ref{GhosttyStyle}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyStyle}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyStyle}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyStyle, private::Bool = false)
    (:fg_color, :bg_color, :underline_color, :flags, :reserved, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    ghostty_style_default(style)

Get the default style.

Initializes the style to the default values (no colors, no flags). The default style is all zero bytes.

` style`

# Arguments
* `style`: Pointer to the style to initialize (NULL does nothing)
"""
function ghostty_style_default(style)
    @ccall libghostty_vt.ghostty_style_default(style::Ptr{GhosttyStyle})::Cvoid
end

"""
    ghostty_style_is_default(style)

Check if a style is the default style.

Returns true if all colors are unset and all flags are off. Reserved bits are ignored.

` style`

# Arguments
* `style`: Pointer to the style to check (NULL returns false)
# Returns
true if the style is the default style
"""
function ghostty_style_is_default(style)
    @ccall libghostty_vt.ghostty_style_is_default(style::Ptr{GhosttyStyle})::Bool
end

"""
    GhosttyGridRef

A reference to a single cell in the terminal grid.

You don't fill in a grid reference yourself. Get one from the library, usually with [`ghostty_terminal_grid_ref`](@ref)(), and then pass it to the ghostty\\_grid\\_ref\\_* functions to read the cell, its row, its style, and more.

A grid reference is an untracked snapshot. It is only valid until the next call that changes the terminal, such as [`ghostty_terminal_vt_write`](@ref)() or [`ghostty_terminal_resize`](@ref)(). To keep pointing at the same cell across changes, use a tracked reference instead (see [`GhosttyTrackedGridRef`](@ref)).

We can't detect a stale reference, so nothing returns an error for one. A reference holds a raw pointer into the terminal's page list. If that page is still there, you read whatever is at that position now, which may be a different cell. If the page was freed, you read freed memory, and that's undefined behavior. Don't use a reference after the terminal changes.

Start with a zero-initialized value. A zeroed reference doesn't point at any cell, and the ghostty\\_grid\\_ref\\_* functions return GHOSTTY\\_INVALID\\_VALUE for it.

```c++
{.c}
 GhosttyGridRef ref = {0};
 GhosttyPoint point = {
     .tag = GHOSTTY_POINT_TAG_ACTIVE,
     .value = { .coordinate = { .x = 4, .y = 0 } },
 };

 if (ghostty_terminal_grid_ref(terminal, point, &ref) == GHOSTTY_SUCCESS) {
     GhosttyCell cell;
     ghostty_grid_ref_cell(&ref, &cell);
 }
```

The fields describe where the cell lives in the terminal's internal storage. Treat them as read-only. In particular, `x` and `y` are not screen coordinates. To get the cell's position on the screen, call [`ghostty_terminal_point_from_grid_ref`](@ref)().

The layout of this struct is frozen. It is 16 bytes on 64-bit targets and 8 bytes on 32-bit targets such as wasm32. If it ever needs to hold more, that will be a new type.

` grid_ref`

| Field | Note                                            |
| :---- | :---------------------------------------------- |
| node  | The internal storage page that holds the cell.  |
| x     | The cell's column within its page.              |
| y     | The cell's row within its page.                 |
"""
struct GhosttyGridRef
    node::Ptr{Cvoid}
    x::UInt16
    y::UInt16
end

"""
    ghostty_grid_ref_cell(ref, out_cell)

Get the cell from a grid reference.

` grid_ref`

# Arguments
* `ref`: Pointer to the grid reference (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_cell`:\\[out\\] On success, set to the cell at the ref's position (may be NULL)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the ref's node is NULL
"""
function ghostty_grid_ref_cell(ref, out_cell)
    @ccall libghostty_vt.ghostty_grid_ref_cell(ref::Ptr{GhosttyGridRef}, out_cell::Ptr{GhosttyCell})::GhosttyResult
end

"""
    ghostty_grid_ref_row(ref, out_row)

Get the row from a grid reference.

` grid_ref`

# Arguments
* `ref`: Pointer to the grid reference (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_row`:\\[out\\] On success, set to the row at the ref's position (may be NULL)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the ref's node is NULL
"""
function ghostty_grid_ref_row(ref, out_row)
    @ccall libghostty_vt.ghostty_grid_ref_row(ref::Ptr{GhosttyGridRef}, out_row::Ptr{GhosttyRow})::GhosttyResult
end

"""
    ghostty_grid_ref_graphemes(ref, buf, buf_len, out_written)

Get the grapheme cluster codepoints for the cell at the grid reference's position.

Writes the full grapheme cluster (the cell's primary codepoint followed by any combining codepoints) into the provided buffer. Both `buf_len` and `out_written` count codepoints, not bytes.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE, sets `out_written` to the number of codepoints needed, and leaves `buf` unchanged. To get the count without copying anything, pass NULL for `buf` and 0 for `buf_len`. A cell with no text returns GHOSTTY\\_SUCCESS with `out_written` set to 0.

Most cells hold a single codepoint, so a small fixed buffer usually works. Fall back to a heap buffer for longer clusters:

```c++
{.c}
 uint32_t stack[8];
 uint32_t *codepoints = stack;
 size_t count = 0;
 GhosttyResult result = ghostty_grid_ref_graphemes(&ref, stack, 8, &count);
 if (result == GHOSTTY_OUT_OF_SPACE) {
   codepoints = malloc(count * sizeof(uint32_t));
   result = ghostty_grid_ref_graphemes(&ref, codepoints, count, &count);
 }
 if (result == GHOSTTY_SUCCESS) {
   // codepoints[0] through codepoints[count - 1] hold the cluster
 }
 if (codepoints != stack) free(codepoints);
```

` grid_ref`

# Arguments
* `ref`: Pointer to the grid reference (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `buf`: Buffer to write the codepoints into. May be NULL if `buf_len` is 0.
* `buf_len`: Number of uint32\\_t elements `buf` can hold
* `out_written`:\\[out\\] The number of codepoints written, or the number needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the ref's node is NULL, GHOSTTY\\_OUT\\_OF\\_SPACE if the buffer is too small
"""
function ghostty_grid_ref_graphemes(ref, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_grid_ref_graphemes(ref::Ptr{GhosttyGridRef}, buf::Ptr{UInt32}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_grid_ref_hyperlink_uri(ref, buf, buf_len, out_written)

Get the hyperlink URI for the cell at the grid reference's position.

Writes the URI bytes into the provided buffer.

The URI is not NUL-terminated.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE, sets `out_written` to the size needed, and leaves `buf` unchanged. To get the size without copying anything, pass NULL for `buf` and 0 for `buf_len`. A cell with no hyperlink returns GHOSTTY\\_SUCCESS with `out_written` set to 0.

URIs can be long, so asking for the size first is often simplest:

```c++
{.c}
 size_t len = 0;
 if (ghostty_grid_ref_hyperlink_uri(&ref, NULL, 0, &len) == GHOSTTY_OUT_OF_SPACE) {
   uint8_t *uri = malloc(len);
   ghostty_grid_ref_hyperlink_uri(&ref, uri, len, &len);
   // uri holds len bytes
   free(uri);
 }
```

` grid_ref`

# Arguments
* `ref`: Pointer to the grid reference (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `buf`: Buffer to write the URI into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the ref's node is NULL, GHOSTTY\\_OUT\\_OF\\_SPACE if the buffer is too small
"""
function ghostty_grid_ref_hyperlink_uri(ref, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_grid_ref_hyperlink_uri(ref::Ptr{GhosttyGridRef}, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_grid_ref_style(ref, out_style)

Get the style of the cell at the grid reference's position.

` grid_ref`

# Arguments
* `ref`: Pointer to the grid reference (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_style`:\\[out\\] On success, set to the cell's style (may be NULL)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the ref's node is NULL
"""
function ghostty_grid_ref_style(ref, out_style)
    @ccall libghostty_vt.ghostty_grid_ref_style(ref::Ptr{GhosttyGridRef}, out_style::Ptr{GhosttyStyle})::GhosttyResult
end

"""
    GhosttyPointCoordinate

A coordinate in the terminal grid.

` point`

| Field | Note                                                            |
| :---- | :-------------------------------------------------------------- |
| x     | Column (0-indexed).                                             |
| y     | Row (0-indexed). May exceed page size for screen/history tags.  |
"""
struct GhosttyPointCoordinate
    x::UInt16
    y::UInt32
end

"""
    GhosttyPointTag

Point reference tag.

Determines which coordinate system a point uses.

` point`

| Enumerator                          | Note                                           |
| :---------------------------------- | :--------------------------------------------- |
| GHOSTTY\\_POINT\\_TAG\\_ACTIVE      | Active area where the cursor can move.         |
| GHOSTTY\\_POINT\\_TAG\\_VIEWPORT    | Visible viewport (changes when scrolled).      |
| GHOSTTY\\_POINT\\_TAG\\_SCREEN      | Full screen including scrollback.              |
| GHOSTTY\\_POINT\\_TAG\\_HISTORY     | Scrollback history only (before active area).  |
| GHOSTTY\\_POINT\\_TAG\\_MAX\\_VALUE |                                                |
"""
@cenum GhosttyPointTag::UInt32 begin
    GHOSTTY_POINT_TAG_ACTIVE = 0
    GHOSTTY_POINT_TAG_VIEWPORT = 1
    GHOSTTY_POINT_TAG_SCREEN = 2
    GHOSTTY_POINT_TAG_HISTORY = 3
    GHOSTTY_POINT_TAG_MAX_VALUE = 2147483647
end

"""
    GhosttyPointValue

Point value union.

` point`
"""
struct GhosttyPointValue
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyPointValue}, f::Symbol)
    f === :coordinate && return Ptr{GhosttyPointCoordinate}(x + 0)
    f === :_padding && return Ptr{NTuple{2, UInt64}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyPointValue, f::Symbol)
    r = Ref{GhosttyPointValue}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyPointValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyPointValue}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyPointValue, private::Bool = false)
    (:coordinate, :_padding, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttyPoint

Tagged union for a point in the terminal grid.

` point`
"""
struct GhosttyPoint
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyPoint}, f::Symbol)
    f === :tag && return Ptr{GhosttyPointTag}(x + 0)
    f === :value && return Ptr{GhosttyPointValue}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyPoint, f::Symbol)
    r = Ref{GhosttyPoint}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyPoint}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyPoint}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyPoint, private::Bool = false)
    (:tag, :value, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

mutable struct GhosttySelectionGestureImpl end

"""
Opaque handle to state for interpreting terminal selection gestures.

The gesture owns only the state required to interpret pointer events. Calls that use a gesture are not concurrency-safe and must be serialized with terminal mutations.

` selection`
"""
const GhosttySelectionGesture = Ptr{GhosttySelectionGestureImpl}

mutable struct GhosttySelectionGestureEventImpl end

"""
Opaque handle to reusable input data for selection gesture operations.

Event options are set with [`ghostty_selection_gesture_event_set`](@ref)(). Individual gesture operations document which options are required or optional.

` selection`
"""
const GhosttySelectionGestureEvent = Ptr{GhosttySelectionGestureEventImpl}

"""
    GhosttySelection

A range of terminal content between two cells.

A selection is described by the two cells at its ends, `start` and `end`. Both ends are included in the selection. By default the selection is linear: it runs from `start` to `end` the way text flows, wrapping from the end of one row to the start of the next. Set `rectangle` to true to select a rectangular block instead, with `start` and `end` at opposite corners.

The ends keep the direction the user selected in. If the user dragged up or to the left, `start` comes after `end` in the terminal. Don't assume `start` is the top-left end. Use [`ghostty_terminal_selection_ordered`](@ref)() when you need the ends in order.

Both ends are untracked grid references, so a selection is only valid until the next call that changes the terminal. To keep a selection across changes, track its ends with [`GhosttyTrackedGridRef`](@ref) and build a new [`GhosttySelection`](@ref) from fresh snapshots when you need one.

Start with a zero-initialized value. The example below selects the first ten cells of the second row and makes that the terminal's active selection.

```c++
{.c}
 GhosttyPoint start_pt = {
     .tag = GHOSTTY_POINT_TAG_ACTIVE,
     .value = { .coordinate = { .x = 0, .y = 1 } },
 };
 GhosttyPoint end_pt = {
     .tag = GHOSTTY_POINT_TAG_ACTIVE,
     .value = { .coordinate = { .x = 9, .y = 1 } },
 };

 GhosttySelection selection = {0};
 ghostty_terminal_grid_ref(terminal, start_pt, &selection.start);
 ghostty_terminal_grid_ref(terminal, end_pt, &selection.end);
 ghostty_terminal_set(terminal, GHOSTTY_TERMINAL_OPT_SELECTION, &selection);
```

The layout of this struct is frozen. It is 40 bytes on 64-bit targets and 20 bytes on 32-bit targets such as wasm32. If it ever needs to hold more, that will be a new type.

` selection`

| Field     | Note                                                                                                             |
| :-------- | :--------------------------------------------------------------------------------------------------------------- |
| start     | The cell where the selection starts. It is included in the selection.                                            |
| end       | The cell where the selection ends. It is included in the selection.                                              |
| rectangle | Whether this is a rectangular selection. When true, `start` and `end` are opposite corners of a block of cells.  |
"""
struct GhosttySelection
    start::GhosttyGridRef
    _end::GhosttyGridRef
    rectangle::Bool
end

"""
    GhosttySelectionBuffer

A caller-provided buffer of selections.

This follows the same conventions as [`GhosttyBuffer`](@ref): ptr may be NULL with cap 0 to query the required capacity. APIs that fill this type set len to the number of entries written on GHOSTTY\\_SUCCESS, or to the required entry capacity on GHOSTTY\\_OUT\\_OF\\_SPACE.

` selection`

| Field | Note                                                                                          |
| :---- | :-------------------------------------------------------------------------------------------- |
| ptr   | Destination buffer for selections. May be NULL when cap is 0 to query the required capacity.  |
| cap   | Capacity of ptr in entries.                                                                   |
| len   | Entries written on success, or required entry capacity on GHOSTTY\\_OUT\\_OF\\_SPACE.         |
"""
struct GhosttySelectionBuffer
    ptr::Ptr{GhosttySelection}
    cap::Csize_t
    len::Csize_t
end

"""
    GhosttyTerminalSelectWordOptions

Options for deriving a word selection from a terminal grid reference.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)(), then set the fields you need. See sized-structs.

If boundary\\_codepoints is NULL and boundary\\_codepoints\\_len is 0, Ghostty's default word-boundary codepoints are used. If boundary\\_codepoints\\_len is non-zero, boundary\\_codepoints must not be NULL.

` selection`

| Field                       | Note                                                                                              |
| :-------------------------- | :------------------------------------------------------------------------------------------------ |
| size                        | Size of this struct in bytes. Must be set to sizeof([`GhosttyTerminalSelectWordOptions`](@ref)).  |
| ref                         | Grid reference under which to derive the word selection.                                          |
| boundary\\_codepoints       | Optional word-boundary codepoints as uint32\\_t scalar values.                                    |
| boundary\\_codepoints\\_len | Number of entries in boundary\\_codepoints.                                                       |
"""
struct GhosttyTerminalSelectWordOptions
    size::Csize_t
    ref::GhosttyGridRef
    boundary_codepoints::Ptr{UInt32}
    boundary_codepoints_len::Csize_t
end

"""
    GhosttyTerminalSelectWordBetweenOptions

Options for deriving the nearest word selection between two grid references.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)(), then set the fields you need. See sized-structs.

If boundary\\_codepoints is NULL and boundary\\_codepoints\\_len is 0, Ghostty's default word-boundary codepoints are used. If boundary\\_codepoints\\_len is non-zero, boundary\\_codepoints must not be NULL.

` selection`

| Field                       | Note                                                                                                     |
| :-------------------------- | :------------------------------------------------------------------------------------------------------- |
| size                        | Size of this struct in bytes. Must be set to sizeof([`GhosttyTerminalSelectWordBetweenOptions`](@ref)).  |
| start                       | Starting grid reference for the inclusive search range.                                                  |
| end                         | Ending grid reference for the inclusive search range.                                                    |
| boundary\\_codepoints       | Optional word-boundary codepoints as uint32\\_t scalar values.                                           |
| boundary\\_codepoints\\_len | Number of entries in boundary\\_codepoints.                                                              |
"""
struct GhosttyTerminalSelectWordBetweenOptions
    size::Csize_t
    start::GhosttyGridRef
    _end::GhosttyGridRef
    boundary_codepoints::Ptr{UInt32}
    boundary_codepoints_len::Csize_t
end

"""
    GhosttyTerminalSelectLineOptions

Options for deriving a line selection from a terminal grid reference.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)(), then set the fields you need. See sized-structs.

If whitespace is NULL and whitespace\\_len is 0, Ghostty's default line-trim whitespace codepoints are used. If whitespace\\_len is non-zero, whitespace must not be NULL.

` selection`

| Field                        | Note                                                                                              |
| :--------------------------- | :------------------------------------------------------------------------------------------------ |
| size                         | Size of this struct in bytes. Must be set to sizeof([`GhosttyTerminalSelectLineOptions`](@ref)).  |
| ref                          | Grid reference under which to derive the line selection.                                          |
| whitespace                   | Optional codepoints to trim from the start and end of the line.                                   |
| whitespace\\_len             | Number of entries in whitespace.                                                                  |
| semantic\\_prompt\\_boundary | Whether semantic prompt state changes should bound the line selection.                            |
"""
struct GhosttyTerminalSelectLineOptions
    size::Csize_t
    ref::GhosttyGridRef
    whitespace::Ptr{UInt32}
    whitespace_len::Csize_t
    semantic_prompt_boundary::Bool
end

"""
    GhosttySelectionOrder

Ordering of a selection's endpoints in terminal coordinates.

Mirrored orders are only produced by rectangular selections whose start and end endpoints are on opposite diagonal corners that are not simple top-left-to-bottom-right or bottom-right-to-top-left orderings.

` selection`

| Enumerator                                       | Note                                                    |
| :----------------------------------------------- | :------------------------------------------------------ |
| GHOSTTY\\_SELECTION\\_ORDER\\_FORWARD            | Start is before end in top-left to bottom-right order.  |
| GHOSTTY\\_SELECTION\\_ORDER\\_REVERSE            | End is before start in top-left to bottom-right order.  |
| GHOSTTY\\_SELECTION\\_ORDER\\_MIRRORED\\_FORWARD | Rectangular selection from top-right to bottom-left.    |
| GHOSTTY\\_SELECTION\\_ORDER\\_MIRRORED\\_REVERSE | Rectangular selection from bottom-left to top-right.    |
| GHOSTTY\\_SELECTION\\_ORDER\\_MAX\\_VALUE        |                                                         |
"""
@cenum GhosttySelectionOrder::UInt32 begin
    GHOSTTY_SELECTION_ORDER_FORWARD = 0
    GHOSTTY_SELECTION_ORDER_REVERSE = 1
    GHOSTTY_SELECTION_ORDER_MIRRORED_FORWARD = 2
    GHOSTTY_SELECTION_ORDER_MIRRORED_REVERSE = 3
    GHOSTTY_SELECTION_ORDER_MAX_VALUE = 2147483647
end

"""
    GhosttySelectionAdjust

Operation used to adjust a selection endpoint.

Adjustment mutates the selection's logical end endpoint, not whichever endpoint is visually bottom/right. This preserves keyboard and drag behavior for both forward and reversed selections.

` selection`

| Enumerator                                           | Note                                                                                                  |
| :--------------------------------------------------- | :---------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SELECTION\\_ADJUST\\_LEFT                  | Move left to the previous non-empty cell, wrapping upward.                                            |
| GHOSTTY\\_SELECTION\\_ADJUST\\_RIGHT                 | Move right to the next non-empty cell, wrapping downward.                                             |
| GHOSTTY\\_SELECTION\\_ADJUST\\_UP                    | Move up one row at the current column, or to the beginning of the line if already at the top.         |
| GHOSTTY\\_SELECTION\\_ADJUST\\_DOWN                  | Move down to the next non-blank row at the current column, or to the end of the line if none exists.  |
| GHOSTTY\\_SELECTION\\_ADJUST\\_HOME                  | Move to the top-left cell of the screen.                                                              |
| GHOSTTY\\_SELECTION\\_ADJUST\\_END                   | Move to the right edge of the last non-blank row on the screen.                                       |
| GHOSTTY\\_SELECTION\\_ADJUST\\_PAGE\\_UP             | Move up by one terminal page height, or to home if that would move past the top.                      |
| GHOSTTY\\_SELECTION\\_ADJUST\\_PAGE\\_DOWN           | Move down by one terminal page height, or to end if that would move past the bottom.                  |
| GHOSTTY\\_SELECTION\\_ADJUST\\_BEGINNING\\_OF\\_LINE | Move to the left edge of the current line.                                                            |
| GHOSTTY\\_SELECTION\\_ADJUST\\_END\\_OF\\_LINE       | Move to the right edge of the current line.                                                           |
| GHOSTTY\\_SELECTION\\_ADJUST\\_MAX\\_VALUE           |                                                                                                       |
"""
@cenum GhosttySelectionAdjust::UInt32 begin
    GHOSTTY_SELECTION_ADJUST_LEFT = 0
    GHOSTTY_SELECTION_ADJUST_RIGHT = 1
    GHOSTTY_SELECTION_ADJUST_UP = 2
    GHOSTTY_SELECTION_ADJUST_DOWN = 3
    GHOSTTY_SELECTION_ADJUST_HOME = 4
    GHOSTTY_SELECTION_ADJUST_END = 5
    GHOSTTY_SELECTION_ADJUST_PAGE_UP = 6
    GHOSTTY_SELECTION_ADJUST_PAGE_DOWN = 7
    GHOSTTY_SELECTION_ADJUST_BEGINNING_OF_LINE = 8
    GHOSTTY_SELECTION_ADJUST_END_OF_LINE = 9
    GHOSTTY_SELECTION_ADJUST_MAX_VALUE = 2147483647
end

"""
    GhosttySelectionGestureBehavior

Selection behavior chosen for a gesture's click sequence.

` selection`

| Enumerator                                             | Note                                                       |
| :----------------------------------------------------- | :--------------------------------------------------------- |
| GHOSTTY\\_SELECTION\\_GESTURE\\_BEHAVIOR\\_CELL        | Cell-granular drag selection.                              |
| GHOSTTY\\_SELECTION\\_GESTURE\\_BEHAVIOR\\_WORD        | Word selection on press and word-granular drag selection.  |
| GHOSTTY\\_SELECTION\\_GESTURE\\_BEHAVIOR\\_LINE        | Line selection on press and line-granular drag selection.  |
| GHOSTTY\\_SELECTION\\_GESTURE\\_BEHAVIOR\\_OUTPUT      | Semantic command output selection on press and drag.       |
| GHOSTTY\\_SELECTION\\_GESTURE\\_BEHAVIOR\\_MAX\\_VALUE |                                                            |
"""
@cenum GhosttySelectionGestureBehavior::UInt32 begin
    GHOSTTY_SELECTION_GESTURE_BEHAVIOR_CELL = 0
    GHOSTTY_SELECTION_GESTURE_BEHAVIOR_WORD = 1
    GHOSTTY_SELECTION_GESTURE_BEHAVIOR_LINE = 2
    GHOSTTY_SELECTION_GESTURE_BEHAVIOR_OUTPUT = 3
    GHOSTTY_SELECTION_GESTURE_BEHAVIOR_MAX_VALUE = 2147483647
end

"""
    GhosttySelectionGestureBehaviors

Selection behaviors for single-, double-, and triple-click gestures.

` selection`

| Field          | Note                                           |
| :------------- | :--------------------------------------------- |
| single\\_click | Behavior for single-click selection gestures.  |
| double\\_click | Behavior for double-click selection gestures.  |
| triple\\_click | Behavior for triple-click selection gestures.  |
"""
struct GhosttySelectionGestureBehaviors
    single_click::GhosttySelectionGestureBehavior
    double_click::GhosttySelectionGestureBehavior
    triple_click::GhosttySelectionGestureBehavior
end

"""
    GhosttySelectionGestureGeometry

Display geometry used to interpret selection gesture drag events.

` selection`

| Field           | Note                                                                          |
| :-------------- | :---------------------------------------------------------------------------- |
| columns         | Number of columns in the rendered terminal grid. Must be non-zero.            |
| cell\\_width    | Width of one terminal cell in surface pixels. Must be non-zero.               |
| padding\\_left  | Left padding before the terminal grid begins in surface pixels.               |
| screen\\_height | Height of the rendered terminal surface in surface pixels. Must be non-zero.  |
"""
struct GhosttySelectionGestureGeometry
    columns::UInt32
    cell_width::UInt32
    padding_left::UInt32
    screen_height::UInt32
end

"""
    GhosttySelectionGestureAutoscroll

Current autoscroll direction for an active selection drag gesture.

` selection`

| Enumerator                                               | Note                                                         |
| :------------------------------------------------------- | :----------------------------------------------------------- |
| GHOSTTY\\_SELECTION\\_GESTURE\\_AUTOSCROLL\\_NONE        | No selection autoscroll is requested.                        |
| GHOSTTY\\_SELECTION\\_GESTURE\\_AUTOSCROLL\\_UP          | Selection dragging should autoscroll the viewport upward.    |
| GHOSTTY\\_SELECTION\\_GESTURE\\_AUTOSCROLL\\_DOWN        | Selection dragging should autoscroll the viewport downward.  |
| GHOSTTY\\_SELECTION\\_GESTURE\\_AUTOSCROLL\\_MAX\\_VALUE |                                                              |
"""
@cenum GhosttySelectionGestureAutoscroll::UInt32 begin
    GHOSTTY_SELECTION_GESTURE_AUTOSCROLL_NONE = 0
    GHOSTTY_SELECTION_GESTURE_AUTOSCROLL_UP = 1
    GHOSTTY_SELECTION_GESTURE_AUTOSCROLL_DOWN = 2
    GHOSTTY_SELECTION_GESTURE_AUTOSCROLL_MAX_VALUE = 2147483647
end

"""
    GhosttySelectionGestureData

Data fields readable from a selection gesture with [`ghostty_selection_gesture_get`](@ref)().

` selection`

| Enumerator                                           | Note                                                                                                                                                                                                                                            |
| :--------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_INVALID       | Not a real data type. [`ghostty_selection_gesture_get`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real data type.                                         |
| GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_CLICK\\_COUNT | Current click count: uint8\\_t*. 0 means inactive.                                                                                                                                                                                              |
| GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_DRAGGED       | Whether the current/last left-click gesture has dragged: bool*.                                                                                                                                                                                 |
| GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_AUTOSCROLL    | Current autoscroll request: [`GhosttySelectionGestureAutoscroll`](@ref)*.                                                                                                                                                                       |
| GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_BEHAVIOR      | Current gesture behavior: [`GhosttySelectionGestureBehavior`](@ref)*.                                                                                                                                                                           |
| GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_ANCHOR        | Current left-click anchor: [`GhosttyGridRef`](@ref)*.  Returns GHOSTTY\\_NO\\_VALUE if there is no valid active anchor. On success, writes an untracked [`GhosttyGridRef`](@ref) snapshot with normal [`GhosttyGridRef`](@ref) lifetime rules.  |
| GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_MAX\\_VALUE   |                                                                                                                                                                                                                                                 |
"""
@cenum GhosttySelectionGestureData::UInt32 begin
    GHOSTTY_SELECTION_GESTURE_DATA_INVALID = 0
    GHOSTTY_SELECTION_GESTURE_DATA_CLICK_COUNT = 1
    GHOSTTY_SELECTION_GESTURE_DATA_DRAGGED = 2
    GHOSTTY_SELECTION_GESTURE_DATA_AUTOSCROLL = 3
    GHOSTTY_SELECTION_GESTURE_DATA_BEHAVIOR = 4
    GHOSTTY_SELECTION_GESTURE_DATA_ANCHOR = 5
    GHOSTTY_SELECTION_GESTURE_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttySelectionGestureEventType

Selection gesture event type.

The event type is fixed when the event is created. Each event type documents which options are valid and which options are required by gesture operations.

` selection`

| Enumerator                                                       | Note                                                                    |
| :--------------------------------------------------------------- | :---------------------------------------------------------------------- |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_PRESS             | Press event for [`ghostty_selection_gesture_event`](@ref)().            |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_RELEASE           | Release event for [`ghostty_selection_gesture_event`](@ref)().          |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_DRAG              | Drag event for [`ghostty_selection_gesture_event`](@ref)().             |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_AUTOSCROLL\\_TICK | Autoscroll tick event for [`ghostty_selection_gesture_event`](@ref)().  |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_DEEP\\_PRESS      | Deep press event for [`ghostty_selection_gesture_event`](@ref)().       |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_MAX\\_VALUE       |                                                                         |
"""
@cenum GhosttySelectionGestureEventType::UInt32 begin
    GHOSTTY_SELECTION_GESTURE_EVENT_TYPE_PRESS = 0
    GHOSTTY_SELECTION_GESTURE_EVENT_TYPE_RELEASE = 1
    GHOSTTY_SELECTION_GESTURE_EVENT_TYPE_DRAG = 2
    GHOSTTY_SELECTION_GESTURE_EVENT_TYPE_AUTOSCROLL_TICK = 3
    GHOSTTY_SELECTION_GESTURE_EVENT_TYPE_DEEP_PRESS = 4
    GHOSTTY_SELECTION_GESTURE_EVENT_TYPE_MAX_VALUE = 2147483647
end

"""
    GhosttySelectionGestureEventOption

Options stored on a reusable selection gesture event.

Passing NULL as the value to [`ghostty_selection_gesture_event_set`](@ref)() clears the corresponding option.

` selection`

| Enumerator                                                                 | Note                                                                                                                                                                                                                                                       |
| :------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_INVALID                      | Not a real option. [`ghostty_selection_gesture_event_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                    |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_REF                          | Grid reference under the pointer: [`GhosttyGridRef`](@ref)*.  Required for PRESS and DRAG events. Optional for RELEASE events; when unset or cleared, release records that the pointer did not map to a valid cell.                                        |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_POSITION                     | Surface-space pointer position: [`GhosttySurfacePosition`](@ref)*.  Valid for PRESS, DRAG, and AUTOSCROLL\\_TICK.                                                                                                                                          |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_REPEAT\\_DISTANCE            | Maximum repeat-click distance in pixels: double*.                                                                                                                                                                                                          |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_TIME\\_NS                    | Optional monotonic event time in nanoseconds: uint64\\_t*.  If unset, press treats the event as untimed and only single-click behavior is available.                                                                                                       |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_REPEAT\\_INTERVAL\\_NS       | Maximum interval between repeat clicks in nanoseconds: uint64\\_t*.                                                                                                                                                                                        |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_WORD\\_BOUNDARY\\_CODEPOINTS | Word-boundary codepoints: [`GhosttyCodepoints`](@ref)*.  The codepoints are copied into event-owned storage when set. If unset, operations that need word boundaries use Ghostty's defaults.  Valid for PRESS, DRAG, AUTOSCROLL\\_TICK, and DEEP\\_PRESS.  |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_BEHAVIORS                    | Selection behavior table: [`GhosttySelectionGestureBehaviors`](@ref)*.  If unset, press uses the default behavior table: cell, word, line.                                                                                                                 |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_RECTANGLE                    | Whether a drag or autoscroll tick should produce a rectangular selection: bool*.                                                                                                                                                                           |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_GEOMETRY                     | Drag display geometry: [`GhosttySelectionGestureGeometry`](@ref)*. Required for DRAG and AUTOSCROLL\\_TICK.                                                                                                                                                |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_VIEWPORT                     | Viewport coordinate for an autoscroll tick: [`GhosttyPointCoordinate`](@ref)*. Required for AUTOSCROLL\\_TICK.                                                                                                                                             |
| GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_MAX\\_VALUE                  |                                                                                                                                                                                                                                                            |
"""
@cenum GhosttySelectionGestureEventOption::UInt32 begin
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_INVALID = 0
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_REF = 1
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_POSITION = 2
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_REPEAT_DISTANCE = 3
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_TIME_NS = 4
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_REPEAT_INTERVAL_NS = 5
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_WORD_BOUNDARY_CODEPOINTS = 6
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_BEHAVIORS = 7
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_RECTANGLE = 8
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_GEOMETRY = 9
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_VIEWPORT = 10
    GHOSTTY_SELECTION_GESTURE_EVENT_OPT_MAX_VALUE = 2147483647
end

"""
    ghostty_selection_gesture_event_new(allocator, out_event, type)

Create a reusable selection gesture event object.

` selection`

# Arguments
* `allocator`: Allocator, or NULL for the default allocator
* `out_event`: Receives the created event handle
* `type`: Event type. This is fixed for the lifetime of the event.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if out\\_event is NULL or type is invalid, or GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails
"""
function ghostty_selection_gesture_event_new(allocator, out_event, type)
    @ccall libghostty_vt.ghostty_selection_gesture_event_new(allocator::Ptr{GhosttyAllocator}, out_event::Ptr{GhosttySelectionGestureEvent}, type::GhosttySelectionGestureEventType)::GhosttyResult
end

"""
    ghostty_selection_gesture_event_free(event)

Free a selection gesture event object.

Passing NULL is allowed and is a no-op.

` selection`

# Arguments
* `event`: Selection gesture event handle to free
"""
function ghostty_selection_gesture_event_free(event)
    @ccall libghostty_vt.ghostty_selection_gesture_event_free(event::GhosttySelectionGestureEvent)::Cvoid
end

"""
    ghostty_selection_gesture_event_set(event, option, value)

Set or clear an option on a selection gesture event.

The value type depends on option and is documented by [`GhosttySelectionGestureEventOption`](@ref). Passing NULL for value clears the option.

` selection`

# Arguments
* `event`: Selection gesture event handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: Event option to set or clear
* `value`: Pointer to the input value for option, or NULL to clear
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY if copying event-owned data fails, GHOSTTY\\_INVALID\\_VALUE if `event` or `value` is invalid, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_selection_gesture_event_set(event, option, value)
    @ccall libghostty_vt.ghostty_selection_gesture_event_set(event::GhosttySelectionGestureEvent, option::GhosttySelectionGestureEventOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_selection_gesture_event(gesture, terminal, event, out_selection)

Apply a selection gesture event and return the resulting selection snapshot.

This dispatches to the gesture operation matching the event's fixed type. For GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_PRESS, the event must have GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_REF set before calling this function. All other press options use their initialized defaults when unset or cleared.

For GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_RELEASE, only GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_REF is valid. It is optional; if unset or cleared, release records that the pointer did not map to a valid cell. Release events update gesture state but do not produce a selection, so this function returns GHOSTTY\\_NO\\_VALUE after applying them.

For GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_DRAG, GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_REF and GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_GEOMETRY are required. Position, rectangle, and word-boundary codepoints are optional and use initialized defaults when unset or cleared.

For GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_AUTOSCROLL\\_TICK, GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_VIEWPORT and GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_GEOMETRY are required. Position, rectangle, and word-boundary codepoints are optional and use initialized defaults when unset or cleared.

An autoscroll tick scrolls the viewport exactly one row in the direction GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_AUTOSCROLL reports, then continues the drag at the viewport coordinate. The gesture has no timer of its own. While that direction is up or down, send ticks from a timer you run. The interval is up to you, and ticking faster scrolls faster. A tick returns GHOSTTY\\_NO\\_VALUE and scrolls nothing if there's no direction to scroll in. If the cell of the original press is no longer on the active screen, it also resets the gesture and leaves any existing terminal selection alone, so stop your timer.

For GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_TYPE\\_DEEP\\_PRESS, only GHOSTTY\\_SELECTION\\_GESTURE\\_EVENT\\_OPT\\_WORD\\_BOUNDARY\\_CODEPOINTS is valid. It is optional and uses initialized defaults when unset or cleared.

The returned selection is not installed as the terminal's current selection. It is a snapshot with the same lifetime rules as [`GhosttySelection`](@ref).

` selection`

# Arguments
* `gesture`: Selection gesture handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`: Terminal used to interpret and update gesture state
* `event`: Selection gesture event handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_selection`:\\[out\\] On success, receives the resulting selection. May be NULL to apply the event and discard the selection result.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the event does not currently produce a selection, GHOSTTY\\_OUT\\_OF\\_MEMORY if tracking gesture state fails, or GHOSTTY\\_INVALID\\_VALUE if gesture, terminal, event, or required event data is invalid
"""
function ghostty_selection_gesture_event(gesture, terminal, event, out_selection)
    @ccall libghostty_vt.ghostty_selection_gesture_event(gesture::GhosttySelectionGesture, terminal::GhosttyTerminal, event::GhosttySelectionGestureEvent, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_selection_gesture_new(allocator, out_gesture)

Create a selection gesture object.

The gesture stores mutable state for terminal text selection gestures. The gesture is not bound to a terminal at creation time; terminal-dependent APIs take the terminal explicitly.

` selection`

# Arguments
* `allocator`: Allocator, or NULL for the default allocator
* `out_gesture`: Receives the created gesture handle
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if out\\_gesture is NULL, or GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails
"""
function ghostty_selection_gesture_new(allocator, out_gesture)
    @ccall libghostty_vt.ghostty_selection_gesture_new(allocator::Ptr{GhosttyAllocator}, out_gesture::Ptr{GhosttySelectionGesture})::GhosttyResult
end

"""
    ghostty_selection_gesture_free(gesture, terminal)

Free a selection gesture object.

This releases any tracked terminal references owned by the gesture using the provided terminal, then frees the gesture object. Passing NULL for gesture is allowed and is a no-op.

If the terminal is still alive, pass the terminal most recently used with the gesture so any tracked terminal references can be released correctly. If the terminal has already been freed, pass NULL for terminal; the terminal's page storage has already released the underlying tracked references, so the gesture wrapper can be safely discarded without touching the stale terminal state.

` selection`

# Arguments
* `gesture`: Selection gesture handle to free
* `terminal`: Terminal used to release tracked gesture state, or NULL if the terminal has already been freed
"""
function ghostty_selection_gesture_free(gesture, terminal)
    @ccall libghostty_vt.ghostty_selection_gesture_free(gesture::GhosttySelectionGesture, terminal::GhosttyTerminal)::Cvoid
end

"""
    ghostty_selection_gesture_reset(gesture, terminal)

Reset any active selection gesture state.

This cancels the active click sequence and releases any tracked terminal references owned by the gesture without freeing the gesture object. Passing NULL is allowed and is a no-op.

` selection`

# Arguments
* `gesture`: Selection gesture handle to reset
* `terminal`: Terminal used to release tracked gesture state
"""
function ghostty_selection_gesture_reset(gesture, terminal)
    @ccall libghostty_vt.ghostty_selection_gesture_reset(gesture::GhosttySelectionGesture, terminal::GhosttyTerminal)::Cvoid
end

"""
    ghostty_selection_gesture_get(gesture, terminal, data, value)

Read data from a selection gesture.

The type of value depends on data and is documented by [`GhosttySelectionGestureData`](@ref). For GHOSTTY\\_SELECTION\\_GESTURE\\_DATA\\_ANCHOR, the returned [`GhosttyGridRef`](@ref) is an untracked snapshot with normal grid-ref lifetime rules.

` selection`

# Arguments
* `gesture`: Selection gesture handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`: Terminal used to validate terminal-backed gesture state
* `data`: Data field to read
* `value`: Output pointer whose type depends on data
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the requested data has no value, GHOSTTY\\_INVALID\\_VALUE if `gesture`, `terminal`, or `out` is invalid, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_selection_gesture_get(gesture, terminal, data, value)
    @ccall libghostty_vt.ghostty_selection_gesture_get(gesture::GhosttySelectionGesture, terminal::GhosttyTerminal, data::GhosttySelectionGestureData, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_selection_gesture_get_multi(gesture, terminal, count, keys, values, out_written)

Read multiple data fields from a selection gesture in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_selection_gesture_get`](@ref)() once per key, so use whichever reads better.

Each entry in values must point to storage of the type documented by the corresponding [`GhosttySelectionGestureData`](@ref) key.

If any individual read fails, the function returns that error and writes the index of the failing key to out\\_written when out\\_written is non-NULL. On success, out\\_written receives count when non-NULL.

` selection`

# Arguments
* `gesture`: Selection gesture handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`: Terminal used to validate terminal-backed gesture state
* `count`: Number of data fields to read
* `keys`: Data fields to read (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `values`: Output pointers corresponding to keys (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_written`: Optional number of fields read, or failing index on error
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_selection_gesture_get_multi(gesture, terminal, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_selection_gesture_get_multi(gesture::GhosttySelectionGesture, terminal::GhosttyTerminal, count::Csize_t, keys::Ptr{GhosttySelectionGestureData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_terminal_select_word(terminal, options, out_selection)

Derive a word selection snapshot from a terminal grid reference.

The returned selection is not installed as the terminal's current selection. It is a snapshot with the same lifetime rules as [`GhosttySelection`](@ref).

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `options`: Word-selection options
* `out_selection`:\\[out\\] On success, receives the derived selection
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the valid ref has no selectable word content, or GHOSTTY\\_INVALID\\_VALUE if the terminal, options, ref, codepoint pointer, or output pointer are invalid.
"""
function ghostty_terminal_select_word(terminal, options, out_selection)
    @ccall libghostty_vt.ghostty_terminal_select_word(terminal::GhosttyTerminal, options::Ptr{GhosttyTerminalSelectWordOptions}, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_terminal_select_word_between(terminal, options, out_selection)

Derive the nearest word selection snapshot between two terminal grid refs.

Starting at options->start, this searches toward options->end (inclusive) and returns the first selectable word found using Ghostty's word-selection rules.

This is useful for implementing double-click-and-drag selection in a UI. If a user double-clicks one word and drags across spaces or punctuation toward another word, selecting only the word directly under the current pointer can flicker or collapse when the pointer is between words. Instead, ask for the nearest word between the original click and the drag point, ask again in the reverse direction, and combine the two word bounds into the drag selection.

` c-vt-selection/src/main.c selection-word-between`

Full program: c-vt-selection/src/main.c

The returned selection is not installed as the terminal's current selection. It is a snapshot with the same lifetime rules as [`GhosttySelection`](@ref).

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `options`: Word-between-selection options
* `out_selection`:\\[out\\] On success, receives the derived selection
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if there is no selectable word content between the valid refs, or GHOSTTY\\_INVALID\\_VALUE if the terminal, options, refs, codepoint pointer, or output pointer are invalid.
"""
function ghostty_terminal_select_word_between(terminal, options, out_selection)
    @ccall libghostty_vt.ghostty_terminal_select_word_between(terminal::GhosttyTerminal, options::Ptr{GhosttyTerminalSelectWordBetweenOptions}, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_terminal_select_line(terminal, options, out_selection)

Derive a line selection snapshot from a terminal grid reference.

The returned selection is not installed as the terminal's current selection. It is a snapshot with the same lifetime rules as [`GhosttySelection`](@ref).

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `options`: Line-selection options
* `out_selection`:\\[out\\] On success, receives the derived selection
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the valid ref has no selectable line content, or GHOSTTY\\_INVALID\\_VALUE if the terminal, options, ref, codepoint pointer, or output pointer are invalid.
"""
function ghostty_terminal_select_line(terminal, options, out_selection)
    @ccall libghostty_vt.ghostty_terminal_select_line(terminal::GhosttyTerminal, options::Ptr{GhosttyTerminalSelectLineOptions}, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_terminal_select_all(terminal, out_selection)

Derive a selection snapshot covering all selectable terminal content.

The returned selection is not installed as the terminal's current selection. It is a snapshot with the same lifetime rules as [`GhosttySelection`](@ref).

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_selection`:\\[out\\] On success, receives the derived selection
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if there is no selectable content, or GHOSTTY\\_INVALID\\_VALUE if the terminal or output pointer is invalid.
"""
function ghostty_terminal_select_all(terminal, out_selection)
    @ccall libghostty_vt.ghostty_terminal_select_all(terminal::GhosttyTerminal, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_terminal_select_output(terminal, ref, out_selection)

Derive a command-output selection snapshot from a terminal grid reference.

The returned selection is not installed as the terminal's current selection. It is a snapshot with the same lifetime rules as [`GhosttySelection`](@ref).

```c++
{.c}
 GhosttyGridRef ref = {0};
 ghostty_terminal_grid_ref(terminal, point, &ref);

 GhosttySelection selection = {0};
 if (ghostty_terminal_select_output(terminal, &ref, &selection) == GHOSTTY_SUCCESS) {
   ghostty_terminal_set(terminal, GHOSTTY_TERMINAL_OPT_SELECTION, &selection);
 }
```

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `ref`: Grid reference within command output to select (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_selection`:\\[out\\] On success, receives the derived selection
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the valid ref is not selectable command output, or GHOSTTY\\_INVALID\\_VALUE if the terminal, ref, or output pointer is invalid.
"""
function ghostty_terminal_select_output(terminal, ref, out_selection)
    @ccall libghostty_vt.ghostty_terminal_select_output(terminal::GhosttyTerminal, ref::Ptr{GhosttyGridRef}, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_terminal_selection_adjust(terminal, selection, adjustment)

Adjust a selection snapshot using terminal selection semantics.

This mutates your [`GhosttySelection`](@ref) in place. The logical end endpoint is always moved, regardless of whether the selection is forward or reversed visually. The input selection remains a snapshot: after adjustment, call [`ghostty_terminal_set`](@ref)() with GHOSTTY\\_TERMINAL\\_OPT\\_SELECTION to install it as the terminal-owned selection if desired.

The selection's start and end grid refs must both be valid untracked snapshots for the given terminal's currently active screen. In practice, they must come from that terminal and screen, and no mutating terminal call may have occurred since the refs were produced or reconstructed from tracked refs. Passing refs from another terminal, another screen, or stale refs violates this precondition.

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `selection`: Selection snapshot to adjust in place
* `adjustment`: The adjustment operation to apply
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal, selection, or adjustment are invalid. Selection reference validity is a precondition and is not checked.
"""
function ghostty_terminal_selection_adjust(terminal, selection, adjustment)
    @ccall libghostty_vt.ghostty_terminal_selection_adjust(terminal::GhosttyTerminal, selection::Ptr{GhosttySelection}, adjustment::GhosttySelectionAdjust)::GhosttyResult
end

"""
    ghostty_terminal_selection_order(terminal, selection, out_order)

Get the current endpoint ordering of a selection snapshot.

The selection's start and end grid refs must both be valid untracked snapshots for the given terminal's currently active screen. In practice, they must come from that terminal and screen, and no mutating terminal call may have occurred since the refs were produced or reconstructed from tracked refs. Passing refs from another terminal, another screen, or stale refs violates this precondition.

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `selection`: Selection snapshot to inspect
* `out_order`:\\[out\\] On success, receives the selection order
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal, selection, or output pointer are invalid. Selection reference validity is a precondition and is not checked.
"""
function ghostty_terminal_selection_order(terminal, selection, out_order)
    @ccall libghostty_vt.ghostty_terminal_selection_order(terminal::GhosttyTerminal, selection::Ptr{GhosttySelection}, out_order::Ptr{GhosttySelectionOrder})::GhosttyResult
end

"""
    ghostty_terminal_selection_ordered(terminal, selection, desired, out_selection)

Return a selection snapshot with endpoints ordered as requested.

Use GHOSTTY\\_SELECTION\\_ORDER\\_FORWARD to get top-left to bottom-right bounds, and GHOSTTY\\_SELECTION\\_ORDER\\_REVERSE to get bottom-right to top-left bounds. Mirrored desired orders are accepted but normalized the same as forward. The output selection is a fresh untracked snapshot and is not installed as the terminal's current selection.

The selection's start and end grid refs must both be valid untracked snapshots for the given terminal's currently active screen. In practice, they must come from that terminal and screen, and no mutating terminal call may have occurred since the refs were produced or reconstructed from tracked refs. Passing refs from another terminal, another screen, or stale refs violates this precondition.

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `selection`: Selection snapshot to order
* `desired`: Desired endpoint order
* `out_selection`:\\[out\\] On success, receives the ordered selection
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal, selection, desired order, or output pointer are invalid. Selection reference validity is a precondition and is not checked.
"""
function ghostty_terminal_selection_ordered(terminal, selection, desired, out_selection)
    @ccall libghostty_vt.ghostty_terminal_selection_ordered(terminal::GhosttyTerminal, selection::Ptr{GhosttySelection}, desired::GhosttySelectionOrder, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_terminal_selection_contains(terminal, selection, point, out_contains)

Test whether a terminal point is inside a selection snapshot.

This uses the same selection semantics as the terminal, including rectangular/block selections and linear selections spanning multiple rows.

The selection's start and end grid refs must both be valid untracked snapshots for the given terminal's currently active screen. In practice, they must come from that terminal and screen, and no mutating terminal call may have occurred since the refs were produced or reconstructed from tracked refs. Passing refs from another terminal, another screen, or stale refs violates this precondition.

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `selection`: Selection snapshot to inspect
* `point`: Point to test for containment
* `out_contains`:\\[out\\] On success, receives whether point is inside selection
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal, selection, point, or output pointer are invalid. Selection reference validity is a precondition and is not checked.
"""
function ghostty_terminal_selection_contains(terminal, selection, point, out_contains)
    @ccall libghostty_vt.ghostty_terminal_selection_contains(terminal::GhosttyTerminal, selection::Ptr{GhosttySelection}, point::GhosttyPoint, out_contains::Ptr{Bool})::GhosttyResult
end

"""
    ghostty_terminal_selection_equal(terminal, a, b, out_equal)

Test whether two selection snapshots are equal.

Equality uses the terminal's internal selection semantics: both endpoint pins must match and both selections must have the same rectangular/block state. This avoids requiring callers to compare raw [`GhosttyGridRef`](@ref) internals.

Both selections' start and end grid refs must be valid untracked snapshots for the given terminal's currently active screen. In practice, they must come from that terminal and screen, and no mutating terminal call may have occurred since the refs were produced or reconstructed from tracked refs. Passing refs from another terminal, another screen, or stale refs violates this precondition.

` selection`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `a`: First selection snapshot to compare
* `b`: Second selection snapshot to compare
* `out_equal`:\\[out\\] On success, receives whether the selections are equal
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal, selections, or output pointer are invalid. Selection reference validity is a precondition and is not checked.
"""
function ghostty_terminal_selection_equal(terminal, a, b, out_equal)
    @ccall libghostty_vt.ghostty_terminal_selection_equal(terminal::GhosttyTerminal, a::Ptr{GhosttySelection}, b::Ptr{GhosttySelection}, out_equal::Ptr{Bool})::GhosttyResult
end

"""
A packed 16-bit terminal mode.

Encodes a mode value (bits 0–14) and an ANSI flag (bit 15) into a single 16-bit integer. Use the inline helper functions to construct and inspect modes rather than manipulating bits directly.
"""
const GhosttyMode = UInt16

"""
    GhosttyModeReportState

DECRPM report state values.

These correspond to the Ps2 parameter in a DECRPM response sequence (CSI ? Ps1 ; Ps2 \$ y).

| Enumerator                                    | Note                       |
| :-------------------------------------------- | :------------------------- |
| GHOSTTY\\_MODE\\_REPORT\\_NOT\\_RECOGNIZED    | Mode is not recognized     |
| GHOSTTY\\_MODE\\_REPORT\\_SET                 | Mode is set (enabled)      |
| GHOSTTY\\_MODE\\_REPORT\\_RESET               | Mode is reset (disabled)   |
| GHOSTTY\\_MODE\\_REPORT\\_PERMANENTLY\\_SET   | Mode is permanently set    |
| GHOSTTY\\_MODE\\_REPORT\\_PERMANENTLY\\_RESET | Mode is permanently reset  |
| GHOSTTY\\_MODE\\_REPORT\\_MAX\\_VALUE         |                            |
"""
@cenum GhosttyModeReportState::UInt32 begin
    GHOSTTY_MODE_REPORT_NOT_RECOGNIZED = 0
    GHOSTTY_MODE_REPORT_SET = 1
    GHOSTTY_MODE_REPORT_RESET = 2
    GHOSTTY_MODE_REPORT_PERMANENTLY_SET = 3
    GHOSTTY_MODE_REPORT_PERMANENTLY_RESET = 4
    GHOSTTY_MODE_REPORT_MAX_VALUE = 2147483647
end

"""
    ghostty_mode_report_encode(mode, state, buf, buf_len, out_written)

Encode a DECRPM (DEC Private Mode Report) response sequence.

Writes a mode report escape sequence into the provided buffer. The generated sequence has the form: - DEC private mode: CSI ? Ps1 ; Ps2 \$ y - ANSI mode: CSI Ps1 ; Ps2 \$ y

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets `out_written` to the size needed. The buffer may then hold part of the sequence, which you should discard. To get the size without encoding anything, pass NULL for `buf` and 0 for `buf_len`.

` c-vt-modes/src/main.c modes-decrpm`

Full program: c-vt-modes/src/main.c

# Arguments
* `mode`: The mode identifying the mode to report on
* `state`: The report state for this mode
* `buf`: Buffer to write the sequence into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if the buffer is too small, or GHOSTTY\\_INVALID\\_VALUE if `out_written` is NULL
"""
function ghostty_mode_report_encode(mode, state, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_mode_report_encode(mode::GhosttyMode, state::GhosttyModeReportState, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    GhosttyOscCommandType

OSC command types.

` osc`

| Enumerator                                   | Note                                                                                                                                                                                                                                                                                                                                               |
| :------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_OSC\\_COMMAND\\_UNKNOWN            | An OSC sequence whose number the parser does not implement. Read it with the GHOSTTY\\_OSC\\_DATA\\_UNKNOWN\\_* data types.  Only produced when GHOSTTY\\_OSC\\_OPT\\_UNKNOWN\\_MAX\\_BYTES is nonzero. Otherwise these sequences are GHOSTTY\\_OSC\\_COMMAND\\_INVALID.                                                                           |
| GHOSTTY\\_OSC\\_COMMAND\\_PROGRAM\\_STATUS   | A program status report or support query (OSC 7501), which a program sends to say what it is doing, such as working or waiting on the user.  The OSC parser only identifies this command. To receive the report's contents, use a terminal with GHOSTTY\\_TERMINAL\\_OPT\\_PROGRAM\\_STATUS instead (see [`GhosttyTerminalProgramStatus`](@ref)).  |
| GHOSTTY\\_OSC\\_COMMAND\\_TYPE\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                    |
"""
@cenum GhosttyOscCommandType::UInt32 begin
    GHOSTTY_OSC_COMMAND_INVALID = 0
    GHOSTTY_OSC_COMMAND_CHANGE_WINDOW_TITLE = 1
    GHOSTTY_OSC_COMMAND_CHANGE_WINDOW_ICON = 2
    GHOSTTY_OSC_COMMAND_SEMANTIC_PROMPT = 3
    GHOSTTY_OSC_COMMAND_CLIPBOARD_CONTENTS = 4
    GHOSTTY_OSC_COMMAND_REPORT_PWD = 5
    GHOSTTY_OSC_COMMAND_MOUSE_SHAPE = 6
    GHOSTTY_OSC_COMMAND_COLOR_OPERATION = 7
    GHOSTTY_OSC_COMMAND_KITTY_COLOR_PROTOCOL = 8
    GHOSTTY_OSC_COMMAND_SHOW_DESKTOP_NOTIFICATION = 9
    GHOSTTY_OSC_COMMAND_HYPERLINK_START = 10
    GHOSTTY_OSC_COMMAND_HYPERLINK_END = 11
    GHOSTTY_OSC_COMMAND_CONEMU_SLEEP = 12
    GHOSTTY_OSC_COMMAND_CONEMU_SHOW_MESSAGE_BOX = 13
    GHOSTTY_OSC_COMMAND_CONEMU_CHANGE_TAB_TITLE = 14
    GHOSTTY_OSC_COMMAND_CONEMU_PROGRESS_REPORT = 15
    GHOSTTY_OSC_COMMAND_CONEMU_WAIT_INPUT = 16
    GHOSTTY_OSC_COMMAND_CONEMU_GUIMACRO = 17
    GHOSTTY_OSC_COMMAND_CONEMU_RUN_PROCESS = 18
    GHOSTTY_OSC_COMMAND_CONEMU_OUTPUT_ENVIRONMENT_VARIABLE = 19
    GHOSTTY_OSC_COMMAND_CONEMU_XTERM_EMULATION = 20
    GHOSTTY_OSC_COMMAND_CONEMU_COMMENT = 21
    GHOSTTY_OSC_COMMAND_KITTY_TEXT_SIZING = 22
    GHOSTTY_OSC_COMMAND_KITTY_CLIPBOARD_PROTOCOL = 23
    GHOSTTY_OSC_COMMAND_KITTY_DND_PROTOCOL = 24
    GHOSTTY_OSC_COMMAND_HIERARCHICAL_CONTEXT = 25
    GHOSTTY_OSC_COMMAND_KITTY_DESKTOP_NOTIFICATION = 26
    GHOSTTY_OSC_COMMAND_UNKNOWN = 27
    GHOSTTY_OSC_COMMAND_PROGRAM_STATUS = 28
    GHOSTTY_OSC_COMMAND_TYPE_MAX_VALUE = 2147483647
end

"""
    GhosttyOscTerminator

How an OSC sequence was ended.

Programs can end an OSC sequence in two ways. When you reply to a sequence, end the reply the same way the program ended its request. Some programs only recognize replies that match.

` osc`

| Enumerator                               | Note                                                                  |
| :--------------------------------------- | :-------------------------------------------------------------------- |
| GHOSTTY\\_OSC\\_TERMINATOR\\_ST          | The string terminator (ST): ESC followed by a backslash (0x1B 0x5C).  |
| GHOSTTY\\_OSC\\_TERMINATOR\\_BEL         | The bell character, BEL (byte 0x07).                                  |
| GHOSTTY\\_OSC\\_TERMINATOR\\_MAX\\_VALUE |                                                                       |
"""
@cenum GhosttyOscTerminator::UInt32 begin
    GHOSTTY_OSC_TERMINATOR_ST = 0
    GHOSTTY_OSC_TERMINATOR_BEL = 1
    GHOSTTY_OSC_TERMINATOR_MAX_VALUE = 2147483647
end

"""
    GhosttyOscOption

OSC parser options, set with [`ghostty_osc_set`](@ref)().

` osc`

| Enumerator                                  | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| :------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_OSC\\_OPT\\_INVALID               | Not a real option. [`ghostty_osc_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_OSC\\_OPT\\_UNKNOWN\\_MAX\\_BYTES | The most bytes to keep from each OSC sequence whose number the parser does not implement.  Every OSC sequence starts with a number that says what it is, such as 2 for the window title or 8 for a hyperlink. Set this to implement a sequence yourself, and read its raw bytes with GHOSTTY\\_OSC\\_DATA\\_UNKNOWN\\_CONTENT.  Zero, the default, discards these sequences and they produce GHOSTTY\\_OSC\\_COMMAND\\_INVALID. Any other value makes them produce GHOSTTY\\_OSC\\_COMMAND\\_UNKNOWN. A NULL value pointer sets the limit back to zero.  A sequence longer than the limit is still reported. Its content holds the first bytes up to the limit, and GHOSTTY\\_OSC\\_DATA\\_UNKNOWN\\_TRUNCATED is true.  Limits up to 2048 bytes use a buffer the parser already owns and never allocate memory. Larger limits allocate memory from the parser's allocator for each unknown sequence.  Only numbers the parser does not implement are reported this way. A sequence with a number the parser does implement stays GHOSTTY\\_OSC\\_COMMAND\\_INVALID when its contents are malformed.  ```c++ {.c}  GhosttyOscParser parser;  ghostty_osc_new(NULL, &parser);   // Keep up to 1 KiB of each unknown sequence.  size_t max_bytes = 1024;  ghostty_osc_set(parser, GHOSTTY_OSC_OPT_UNKNOWN_MAX_BYTES, &max_bytes);   // Feed the bytes between ESC ] and the terminator. OSC 7400 is made up  // for this example, so the parser does not implement it.  const char* input = "7400;status=busy";  for (size_t i = 0; input[i] != '\\0'; i++) {    ghostty_osc_next(parser, (uint8_t)input[i]);  }   // This sequence ended with BEL (0x07).  GhosttyOscCommand command = ghostty_osc_end(parser, 0x07);  if (ghostty_osc_command_type(command) == GHOSTTY_OSC_COMMAND_UNKNOWN) {    GhosttyString content;    ghostty_osc_command_data(command, GHOSTTY_OSC_DATA_UNKNOWN_CONTENT,                             &content);    // content now holds "7400;status=busy".  }   ghostty_osc_free(parser); ```  Input type: size\\_t*  |
| GHOSTTY\\_OSC\\_OPT\\_MAX\\_VALUE           |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
"""
@cenum GhosttyOscOption::UInt32 begin
    GHOSTTY_OSC_OPT_INVALID = 0
    GHOSTTY_OSC_OPT_UNKNOWN_MAX_BYTES = 1
    GHOSTTY_OSC_OPT_MAX_VALUE = 2147483647
end

"""
    GhosttyOscCommandData

OSC command data types.

These values specify what type of data to extract from an OSC command using [`ghostty_osc_command_data`](@ref).

` osc`

| Enumerator                                           | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| :--------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_OSC\\_DATA\\_INVALID                       | Invalid data type. Never results in any data extraction.                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_OSC\\_DATA\\_CHANGE\\_WINDOW\\_TITLE\\_STR | Window title string data.  Valid for: GHOSTTY\\_OSC\\_COMMAND\\_CHANGE\\_WINDOW\\_TITLE  Output type: [`GhosttyString`](@ref) *. The bytes are not null-terminated, so use the string's length.  Lifetime: Valid until the next call to any ghostty\\_osc\\_* function with  the same parser instance. Memory is owned by the parser.                                                                                                                                                |
| GHOSTTY\\_OSC\\_DATA\\_UNKNOWN\\_CONTENT             | The raw bytes of an unknown sequence: everything that was passed to [`ghostty_osc_next`](@ref)(), including the number at the start. For example, the sequence `ESC ] 7400;status=busy BEL` gives `7400;status=busy`. The bytes are not null-terminated.  Valid for: GHOSTTY\\_OSC\\_COMMAND\\_UNKNOWN  Output type: [`GhosttyString`](@ref) *  Lifetime: Valid until the next call to any ghostty\\_osc\\_* function with the same parser instance. Memory is owned by the parser.  |
| GHOSTTY\\_OSC\\_DATA\\_UNKNOWN\\_TRUNCATED           | True if the unknown sequence was longer than GHOSTTY\\_OSC\\_OPT\\_UNKNOWN\\_MAX\\_BYTES, or memory ran out while reading it. In that case the content holds only the beginning of the sequence.  Valid for: GHOSTTY\\_OSC\\_COMMAND\\_UNKNOWN  Output type: bool *                                                                                                                                                                                                                  |
| GHOSTTY\\_OSC\\_DATA\\_UNKNOWN\\_TERMINATOR          | How the unknown sequence was ended, based on the terminator passed to [`ghostty_osc_end`](@ref)(). If you reply to the sequence, end the reply the same way.  Valid for: GHOSTTY\\_OSC\\_COMMAND\\_UNKNOWN  Output type: [`GhosttyOscTerminator`](@ref) *                                                                                                                                                                                                                            |
| GHOSTTY\\_OSC\\_DATA\\_MAX\\_VALUE                   |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
"""
@cenum GhosttyOscCommandData::UInt32 begin
    GHOSTTY_OSC_DATA_INVALID = 0
    GHOSTTY_OSC_DATA_CHANGE_WINDOW_TITLE_STR = 1
    GHOSTTY_OSC_DATA_UNKNOWN_CONTENT = 2
    GHOSTTY_OSC_DATA_UNKNOWN_TRUNCATED = 3
    GHOSTTY_OSC_DATA_UNKNOWN_TERMINATOR = 4
    GHOSTTY_OSC_DATA_MAX_VALUE = 2147483647
end

"""
    ghostty_osc_new(allocator, parser)

Create a new OSC parser instance.

Creates a new OSC (Operating System Command) parser using the provided allocator. The parser must be freed using [`ghostty_osc_free`](@ref)() when no longer needed.

` osc`

# Arguments
* `allocator`: Pointer to the allocator to use for memory management, or NULL to use the default allocator
* `parser`: Pointer to store the created parser handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_osc_new(allocator, parser)
    @ccall libghostty_vt.ghostty_osc_new(allocator::Ptr{GhosttyAllocator}, parser::Ptr{GhosttyOscParser})::GhosttyResult
end

"""
    ghostty_osc_free(parser)

Free an OSC parser instance.

Releases all resources associated with the OSC parser. After this call, the parser handle becomes invalid and must not be used.

` osc`

# Arguments
* `parser`: The parser handle to free (may be NULL)
"""
function ghostty_osc_free(parser)
    @ccall libghostty_vt.ghostty_osc_free(parser::GhosttyOscParser)::Cvoid
end

"""
    ghostty_osc_reset(parser)

Reset an OSC parser instance to its initial state.

Resets the parser state, clearing any partially parsed OSC sequences and returning the parser to its initial state. This is useful for reusing a parser instance or recovering from parse errors.

` osc`

# Arguments
* `parser`: The parser handle to reset (NULL does nothing)
"""
function ghostty_osc_reset(parser)
    @ccall libghostty_vt.ghostty_osc_reset(parser::GhosttyOscParser)::Cvoid
end

"""
    ghostty_osc_set(parser, option, value)

Set an option on an OSC parser.

`value` points to the option's input type, which is listed in the documentation for each [`GhosttyOscOption`](@ref) value. Pass NULL to restore the option's default.

Options stay set across [`ghostty_osc_reset`](@ref)(). You can change an option at any time, but a sequence that is already being parsed may keep the old setting. It is simplest to set options before the first sequence.

` osc`

# Arguments
* `parser`: The parser handle
* `option`: The option to set
* `value`: Pointer to the new value, or NULL to restore the default
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the parser is NULL, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_osc_set(parser, option, value)
    @ccall libghostty_vt.ghostty_osc_set(parser::GhosttyOscParser, option::GhosttyOscOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_osc_next(parser, byte)

Parse the next byte in an OSC sequence.

Processes a single byte as part of an OSC sequence. The parser maintains internal state to track the progress through the sequence. Call this function for each byte in the sequence data.

When finished pumping the parser with bytes, call [`ghostty_osc_end`](@ref) to get the final result.

` osc`

# Arguments
* `parser`: The parser handle (NULL does nothing)
* `byte`: The next byte to parse
"""
function ghostty_osc_next(parser, byte)
    @ccall libghostty_vt.ghostty_osc_next(parser::GhosttyOscParser, byte::UInt8)::Cvoid
end

"""
    ghostty_osc_end(parser, terminator)

Finalize OSC parsing and retrieve the parsed command.

Call this after feeding every byte of the sequence to [`ghostty_osc_next`](@ref)(), except the byte that ended it. Pass that byte here as the terminator.

If the sequence is not a valid command, this returns NULL. You don't need to check for NULL before calling [`ghostty_osc_command_type`](@ref)(), which returns GHOSTTY\\_OSC\\_COMMAND\\_INVALID for it.

Commands that reply to the program, such as color queries, end their reply the same way the request ended. A terminator of 0x07 (BEL) gets a BEL reply, and any other byte gets an ST reply. Commands that don't reply ignore the terminator.

If the program cancelled the sequence with CAN (0x18) or SUB (0x1A), pass that byte as the terminator. The sequence is then discarded and this returns NULL, whatever command it contained. This matches xterm.

```c++
{.c}
 // The program sent "ESC ] 2 ; hello" to set the window title, then
 // sent CAN instead of a terminator.
 const char* input = "2;hello";
 for (size_t i = 0; input[i] != '\\0'; i++) {
   ghostty_osc_next(parser, (uint8_t)input[i]);
 }

 GhosttyOscCommand command = ghostty_osc_end(parser, 0x18);
 // command is NULL, so the window title does not change.

 ghostty_osc_reset(parser);
```

The returned command handle is valid until the next call to any  `ghostty\\_osc\\_*` function with the same parser instance with the exception of command introspection functions such as [`ghostty_osc_command_type`](@ref).

` osc`

# Arguments
* `parser`: The parser handle (NULL returns NULL)
* `terminator`: The byte that ended the OSC sequence: 0x07 for BEL, 0x5C for ST, or 0x18 (CAN) or 0x1A (SUB) if it was cancelled
# Returns
Handle to the parsed OSC command, or NULL if the sequence is not a valid command or was cancelled
"""
function ghostty_osc_end(parser, terminator)
    @ccall libghostty_vt.ghostty_osc_end(parser::GhosttyOscParser, terminator::UInt8)::GhosttyOscCommand
end

"""
    ghostty_osc_command_type(command)

Get the type of an OSC command.

Returns the type identifier for the given OSC command. This can be used to determine what kind of command was parsed and what data might be available from it.

` osc`

# Arguments
* `command`: The OSC command handle to query (may be NULL)
# Returns
The command type, or GHOSTTY\\_OSC\\_COMMAND\\_INVALID if command is NULL
"""
function ghostty_osc_command_type(command)
    @ccall libghostty_vt.ghostty_osc_command_type(command::GhosttyOscCommand)::GhosttyOscCommandType
end

"""
    ghostty_osc_command_data(command, data, out)

Extract data from an OSC command.

Extracts typed data from the given OSC command based on the specified data type. The output pointer must be of the appropriate type for the requested data kind. Valid command types, output types, and memory safety information are documented in the [`GhosttyOscCommandData`](@ref) enum.

Only GHOSTTY\\_SUCCESS writes to `out`. Every other result leaves it unchanged.

```c++
{.c}
 GhosttyString title;
 if (ghostty_osc_command_data(command,
         GHOSTTY_OSC_DATA_CHANGE_WINDOW_TITLE_STR,
         &title) == GHOSTTY_SUCCESS) {
   printf("title: %.*s\\n", (int)title.len, (const char *)title.ptr);
 }
```

` osc`

# Arguments
* `command`: The OSC command handle to query (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: The type of data to extract
* `out`: Pointer to store the extracted data (type depends on data parameter)
# Returns
- GHOSTTY\\_SUCCESS if the data was written to `out`. - GHOSTTY\\_NO\\_VALUE if the command has no data of this kind, for example asking a window title command for unknown content. - GHOSTTY\\_INVALID\\_VALUE if `command` or `out` is NULL, or `data` is GHOSTTY\\_OSC\\_DATA\\_INVALID. - GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library.
"""
function ghostty_osc_command_data(command, data, out)
    @ccall libghostty_vt.ghostty_osc_command_data(command::GhosttyOscCommand, data::GhosttyOscCommandData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    GhosttySizeReportStyle

Size report style.

Determines the output format for the terminal size report.

| Enumerator                                    | Note                                                                                                                                                                         |
| :-------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SIZE\\_REPORT\\_MODE\\_2048         | In-band size report (mode 2048): ESC [ 48 ; rows ; cols ; height ; width t                                                                                                   |
| GHOSTTY\\_SIZE\\_REPORT\\_CSI\\_14\\_T        | XTWINOPS text area size in pixels: ESC [ 4 ; height ; width t                                                                                                                |
| GHOSTTY\\_SIZE\\_REPORT\\_CSI\\_16\\_T        | XTWINOPS cell size in pixels: ESC [ 6 ; height ; width t                                                                                                                     |
| GHOSTTY\\_SIZE\\_REPORT\\_CSI\\_18\\_T        | XTWINOPS text area size in characters: ESC [ 8 ; rows ; cols t                                                                                                               |
| GHOSTTY\\_SIZE\\_REPORT\\_CSI\\_19\\_T        | XTWINOPS screen size in characters: ESC [ 9 ; rows ; cols t  The physical screen size is not known, so this reports the text area size in characters, the same as CSI 18 t.  |
| GHOSTTY\\_SIZE\\_REPORT\\_STYLE\\_MAX\\_VALUE |                                                                                                                                                                              |
"""
@cenum GhosttySizeReportStyle::UInt32 begin
    GHOSTTY_SIZE_REPORT_MODE_2048 = 0
    GHOSTTY_SIZE_REPORT_CSI_14_T = 1
    GHOSTTY_SIZE_REPORT_CSI_16_T = 2
    GHOSTTY_SIZE_REPORT_CSI_18_T = 3
    GHOSTTY_SIZE_REPORT_CSI_19_T = 4
    GHOSTTY_SIZE_REPORT_STYLE_MAX_VALUE = 2147483647
end

"""
    GhosttySizeReportSize

Terminal size information for encoding size reports.

| Field         | Note                                         |
| :------------ | :------------------------------------------- |
| rows          | Terminal row count in cells.                 |
| columns       | Terminal column count in cells.              |
| cell\\_width  | Width of a single terminal cell in pixels.   |
| cell\\_height | Height of a single terminal cell in pixels.  |
"""
struct GhosttySizeReportSize
    rows::UInt16
    columns::UInt16
    cell_width::UInt32
    cell_height::UInt32
end

"""
    ghostty_size_report_encode(style, size, buf, buf_len, out_written)

Encode a terminal size report into an escape sequence.

Encodes a size report in the format specified by `style` into the provided buffer.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets `out_written` to the size needed. The buffer may then hold part of the sequence, which you should discard. To get the size without encoding anything, pass NULL for `buf` and 0 for `buf_len`.

# Arguments
* `style`: The size report format to encode
* `size`: Terminal size information
* `buf`: Buffer to write the sequence into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if the buffer is too small, or GHOSTTY\\_INVALID\\_VALUE if `size` or `out_written` is NULL
"""
function ghostty_size_report_encode(style, size, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_size_report_encode(style::GhosttySizeReportStyle, size::Ptr{GhosttySizeReportSize}, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    GhosttyKittyGraphicsData

Queryable data kinds for [`ghostty_kitty_graphics_get`](@ref)().

` kitty_graphics`

| Enumerator                                               | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| :------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_DATA\\_INVALID              | Invalid / sentinel value.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_DATA\\_PLACEMENT\\_ITERATOR | Populate a pre-allocated placement iterator with placement data from the storage. Iterator data is only valid as long as the underlying terminal is not mutated.  Output type: [`GhosttyKittyGraphicsPlacementIterator`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_DATA\\_GENERATION           | A value that changes whenever a program sends, replaces, places or deletes an image. It is 0 if nothing has changed the storage yet, which means the storage is empty.  If the value matches the last one you read, the storage holds the same images and placements as before. The placements may still have moved on screen, because scrolling and resizing move them without changing the storage. So this value can't tell you when to read the render state's image list again. For that, use GHOSTTY\\_RENDER\\_STATE\\_DATA\\_IMAGE\\_PLACEMENTS\\_GENERATION. See guide-images-changes.  A value is never reused, not even by another screen, after a reset, or by another terminal. You can use it as a cache key on its own.  Output type: uint64\\_t *  |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_DATA\\_MAX\\_VALUE          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
"""
@cenum GhosttyKittyGraphicsData::UInt32 begin
    GHOSTTY_KITTY_GRAPHICS_DATA_INVALID = 0
    GHOSTTY_KITTY_GRAPHICS_DATA_PLACEMENT_ITERATOR = 1
    GHOSTTY_KITTY_GRAPHICS_DATA_GENERATION = 2
    GHOSTTY_KITTY_GRAPHICS_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttyKittyGraphicsPlacementData

Queryable data kinds for [`ghostty_kitty_graphics_placement_get`](@ref)().

` kitty_graphics`

| Enumerator                                                      | Note                                                                                                                                                                                                                                                                                                                                                                                  |
| :-------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_INVALID         | Invalid / sentinel value.                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_IMAGE\\_ID      | The image ID this placement belongs to.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_PLACEMENT\\_ID  | The placement ID.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_IS\\_VIRTUAL    | Whether this is a virtual placement, which a program shows with Unicode placeholder cells.  A virtual placement appears wherever its placeholder cells are, so the storage has no position for it. The render state's image list positions it from its cells like any other placement, so a renderer doesn't need to check this. See guide-images-placeholders.  Output type: bool *  |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_X\\_OFFSET      | Pixel offset from the left edge of the cell.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_Y\\_OFFSET      | Pixel offset from the top edge of the cell.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_SOURCE\\_X      | Source rectangle x origin in pixels.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_SOURCE\\_Y      | Source rectangle y origin in pixels.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_SOURCE\\_WIDTH  | Source rectangle width in pixels (0 = full image width).  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_SOURCE\\_HEIGHT | Source rectangle height in pixels (0 = full image height).  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_COLUMNS         | Number of columns this placement occupies.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_ROWS            | Number of rows this placement occupies.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_Z               | Z-index for this placement.  Output type: int32\\_t *                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_DATA\\_MAX\\_VALUE     |                                                                                                                                                                                                                                                                                                                                                                                       |
"""
@cenum GhosttyKittyGraphicsPlacementData::UInt32 begin
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_INVALID = 0
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_IMAGE_ID = 1
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_PLACEMENT_ID = 2
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_IS_VIRTUAL = 3
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_X_OFFSET = 4
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_Y_OFFSET = 5
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_SOURCE_X = 6
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_SOURCE_Y = 7
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_SOURCE_WIDTH = 8
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_SOURCE_HEIGHT = 9
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_COLUMNS = 10
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_ROWS = 11
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_Z = 12
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttyKittyGraphicsPlacementIteratorOption

Settable options for [`ghostty_kitty_graphics_placement_iterator_set`](@ref)().

` kitty_graphics`

| Enumerator                                                            | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| :-------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_ITERATOR\\_OPT\\_INVALID     | Not a real option. [`ghostty_kitty_graphics_placement_iterator_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_ITERATOR\\_OPT\\_LAYER       | Only visit placements in the chosen layers.  The value is a mask with one bit for each [`GhosttyImageLayer`](@ref). Combine the GHOSTTY\\_IMAGE\\_LAYER\\_MASK\\_* macros with `|` to choose layers. For example, this visits every placement except the ones drawn below the cell backgrounds:  ```c++ {.c}  uint32_t mask = GHOSTTY_IMAGE_LAYER_MASK_BELOW_TEXT |                  GHOSTTY_IMAGE_LAYER_MASK_ABOVE_TEXT;  ghostty_kitty_graphics_placement_iterator_set(      iterator, GHOSTTY_KITTY_GRAPHICS_PLACEMENT_ITERATOR_OPT_LAYER, &mask); ```  A mask of 0 or a NULL value turns the filter off, and the iterator visits every placement. This is the default. A mask with a bit that matches no layer returns GHOSTTY\\_INVALID\\_VALUE and keeps the current filter.  Each placement's layer comes from its z-index, using the ranges listed in [`GhosttyImageLayer`](@ref). This filter only applies to the storage iterator. To draw images, use the layer the render state reports for each entry (GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_LAYER). The render state uses the same ranges and also includes virtual placements, which are always drawn below the text.  Input type: const uint32\\_t *  |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_ITERATOR\\_OPT\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
"""
@cenum GhosttyKittyGraphicsPlacementIteratorOption::UInt32 begin
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_ITERATOR_OPT_INVALID = 0
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_ITERATOR_OPT_LAYER = 1
    GHOSTTY_KITTY_GRAPHICS_PLACEMENT_ITERATOR_OPT_MAX_VALUE = 2147483647
end

"""
    GhosttyKittyImageFormat

Pixel format of a Kitty graphics image.

Note that stored images are always fully decoded: GHOSTTY\\_KITTY\\_IMAGE\\_FORMAT\\_PNG is never returned by [`ghostty_kitty_graphics_image_get`](@ref)() because PNG payloads are decoded to GHOSTTY\\_KITTY\\_IMAGE\\_FORMAT\\_RGBA before storage. The PNG value exists only for protocol-level completeness.

` kitty_graphics`
"""
@cenum GhosttyKittyImageFormat::UInt32 begin
    GHOSTTY_KITTY_IMAGE_FORMAT_RGB = 0
    GHOSTTY_KITTY_IMAGE_FORMAT_RGBA = 1
    GHOSTTY_KITTY_IMAGE_FORMAT_PNG = 2
    GHOSTTY_KITTY_IMAGE_FORMAT_GRAY_ALPHA = 3
    GHOSTTY_KITTY_IMAGE_FORMAT_GRAY = 4
    GHOSTTY_KITTY_IMAGE_FORMAT_MAX_VALUE = 2147483647
end

"""
    GhosttyKittyImageCompression

Compression of a Kitty graphics image.

Note that stored images are always decompressed: GHOSTTY\\_KITTY\\_IMAGE\\_COMPRESSION\\_ZLIB\\_DEFLATE payloads are inflated before storage, so [`ghostty_kitty_graphics_image_get`](@ref)() always reports GHOSTTY\\_KITTY\\_IMAGE\\_COMPRESSION\\_NONE. Consumers never need to inflate image data themselves.

` kitty_graphics`
"""
@cenum GhosttyKittyImageCompression::UInt32 begin
    GHOSTTY_KITTY_IMAGE_COMPRESSION_NONE = 0
    GHOSTTY_KITTY_IMAGE_COMPRESSION_ZLIB_DEFLATE = 1
    GHOSTTY_KITTY_IMAGE_COMPRESSION_MAX_VALUE = 2147483647
end

"""
    GhosttyKittyGraphicsImageData

Queryable data kinds for [`ghostty_kitty_graphics_image_get`](@ref)().

` kitty_graphics`

| Enumerator                                                 | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| :--------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_INVALID        | Invalid / sentinel value.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_ID             | The image ID.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_NUMBER         | The image number.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_WIDTH          | Image width in pixels.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_HEIGHT         | Image height in pixels.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_FORMAT         | Pixel format of the image. Never GHOSTTY\\_KITTY\\_IMAGE\\_FORMAT\\_PNG; PNG payloads are decoded to RGBA before storage.  Output type: [`GhosttyKittyImageFormat`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_COMPRESSION    | Compression of the image. Always GHOSTTY\\_KITTY\\_IMAGE\\_COMPRESSION\\_NONE; compressed payloads are inflated before storage.  Output type: [`GhosttyKittyImageCompression`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_PIXELS         | The image's pixel data. The string points into memory owned by the terminal and stays valid until the terminal is next modified. Its length is always width * height * bytes per pixel for the reported format.  Returns GHOSTTY\\_NO\\_VALUE if the image's pixels have not arrived yet. The expected size is still available through GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_EXPECTED\\_LEN.  The data is always fully decoded, uncompressed pixels in the format reported by GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_FORMAT: zlib payloads are inflated and PNG payloads are decoded to RGBA at transmission time, before the image is stored. Consumers can upload this directly to the GPU without any decode step.  For an animated image (Kitty graphics animation, actions a=f/a=a) this is the pixel data of the current animation frame. The image's GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_GENERATION changes whenever the current frame changes, so generation-keyed caches remain coherent.  ```c++ {.c}  GhosttyString pixels;  if (ghostty_kitty_graphics_image_get(          image, GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_PIXELS, &pixels) ==      GHOSTTY_SUCCESS) {    upload_texture(pixels.ptr, pixels.len);  } ```  Output type: [`GhosttyString`](@ref) *  |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_EXPECTED\\_LEN | The size of the image's pixel data in bytes, which is width * height * bytes per pixel for the reported format.  This is available even before the pixels arrive, when GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_PIXELS still returns GHOSTTY\\_NO\\_VALUE. In that case the image already counts this many bytes against the storage limit. Once the pixels arrive, this equals the length of GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_PIXELS.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_GENERATION     | A value that changes whenever this image's pixels may have changed: when a program sends the image or replaces it, and when an animation moves to a new frame. Use it as part of your texture cache key. If it matches the texture you have, you don't need to read the pixels again. The render state reports the same value for each of its entries as GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_IMAGE\\_GENERATION.  Don't use the image's size or data length to detect changes instead. A program can send new pixels of the same size under the same ID.  A value is never reused, not even by another image, another screen, or another terminal. It is never 0 for a stored image, so you can use 0 to mean "no texture yet".  One case doesn't change this value. When a program finishes sending an image whose pixels were still on the way, the image keeps its value, and GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_PIXELS starts returning the pixels. GHOSTTY\\_KITTY\\_GRAPHICS\\_DATA\\_GENERATION changes when that happens, so read PIXELS again then.  Output type: uint64\\_t *                                                                                                                                                                                    |
| GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_MAX\\_VALUE    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
"""
@cenum GhosttyKittyGraphicsImageData::UInt32 begin
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_INVALID = 0
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_ID = 1
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_NUMBER = 2
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_WIDTH = 3
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_HEIGHT = 4
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_FORMAT = 5
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_COMPRESSION = 6
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_PIXELS = 7
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_EXPECTED_LEN = 8
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_GENERATION = 9
    GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttyKittyGraphicsPlacementRenderInfo

The geometry of a storage placement, filled in by [`ghostty_kitty_graphics_placement_render_info`](@ref)().

It holds the results of [`ghostty_kitty_graphics_placement_pixel_size`](@ref)(), [`ghostty_kitty_graphics_placement_grid_size`](@ref)(), [`ghostty_kitty_graphics_placement_viewport_pos`](@ref)() and [`ghostty_kitty_graphics_placement_source_rect`](@ref)(), so you can get all of them in one call. That helps most when each call is expensive, such as through FFI or Cgo.

This is for inspecting the storage. To draw, use the render state's image list, which gives the same values for every image on screen. See guide-images-drawing.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)() before each call. See sized-structs.

```c++
{.c}
 GhosttyKittyGraphicsPlacementRenderInfo info =
     GHOSTTY_INIT_SIZED(GhosttyKittyGraphicsPlacementRenderInfo);
 ghostty_kitty_graphics_placement_render_info(iter, image, terminal, &info);
```

` kitty_graphics`

| Field              | Note                                                                                                                                                                                                       |
| :----------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| size               | The size of this struct in bytes. Set it with [`GHOSTTY_INIT_SIZED`](@ref).                                                                                                                                |
| pixel\\_width      | The width to draw the image at, in pixels.                                                                                                                                                                 |
| pixel\\_height     | The height to draw the image at, in pixels.                                                                                                                                                                |
| grid\\_cols        | The number of columns of cells the placement covers.                                                                                                                                                       |
| grid\\_rows        | The number of rows of cells the placement covers.                                                                                                                                                          |
| viewport\\_col     | The column of the top-left cell, where 0 is the leftmost column of the viewport. Only meaningful when `viewport_visible` is true.                                                                          |
| viewport\\_row     | The row of the top-left cell, where 0 is the top row of the viewport. It is negative when the top of the placement scrolled above the viewport. Only meaningful when `viewport_visible` is true.           |
| viewport\\_visible | True when any part of the placement is in the viewport. False when it is entirely outside the viewport, or when the storage can't find its position: a virtual placement, or a placement relative to one.  |
| source\\_x         | The left edge of the part of the image to draw, in image pixels.                                                                                                                                           |
| source\\_y         | The top edge of the part of the image to draw, in image pixels.                                                                                                                                            |
| source\\_width     | The width of the part of the image to draw, in image pixels.                                                                                                                                               |
| source\\_height    | The height of the part of the image to draw, in image pixels.                                                                                                                                              |
"""
struct GhosttyKittyGraphicsPlacementRenderInfo
    size::Csize_t
    pixel_width::UInt32
    pixel_height::UInt32
    grid_cols::UInt32
    grid_rows::UInt32
    viewport_col::Int32
    viewport_row::Int32
    viewport_visible::Bool
    source_x::UInt32
    source_y::UInt32
    source_width::UInt32
    source_height::UInt32
end

"""
    ghostty_kitty_graphics_get(graphics, data, out)

Get data from a kitty graphics storage instance.

The output pointer must be of the appropriate type for the requested data kind.

Returns GHOSTTY\\_UNSUPPORTED when Kitty graphics are disabled at build time.

` kitty_graphics`

# Arguments
* `graphics`: The kitty graphics handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: The type of data to extract
* `out`:\\[out\\] Pointer to store the extracted data
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `out` is NULL, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library or Kitty graphics are disabled at build time
"""
function ghostty_kitty_graphics_get(graphics, data, out)
    @ccall libghostty_vt.ghostty_kitty_graphics_get(graphics::GhosttyKittyGraphics, data::GhosttyKittyGraphicsData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_kitty_graphics_animation_tick(graphics, now_ms, next_ms)

Advance playing animations and get the time of the next frame.

Every playing animation moves to the frame that is due at `now_ms`. An animation moves forward at most one frame per call. If calls arrive late, playback slows down rather than skipping frames.

Images that moved to a new frame get a new GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_GENERATION, and their GHOSTTY_KITTY_GRAPHICS_IMAGE_DATA_PIXELS returns the new frame's pixels.

Time is measured in milliseconds on a clock you choose, such as the time since your application started. The clock must only move forward, and you must keep using the same clock with the same starting point for as long as the terminal exists. The time written to `next_ms` uses the same clock.

This call changes the image storage. Like [`ghostty_terminal_vt_write`](@ref)(), it invalidates any GhosttyKittyGraphicsImage handles and image data pointers you are holding, so look images up again afterwards. The GhosttyKittyGraphics handle itself stays valid.

Call this once each time you prepare a frame to draw, not in a loop. guide-images-animation explains how to schedule redraws with the returned time and includes an example.

` kitty_graphics`

# Arguments
* `graphics`: The kitty graphics handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `now_ms`: The current time in milliseconds
* `next_ms`:\\[out\\] Set to the time the next frame is due, in milliseconds on the same clock as `now_ms`. Only written when the function returns GHOSTTY\\_SUCCESS.
# Returns
GHOSTTY\\_SUCCESS if an animation is playing and `next_ms` was set, GHOSTTY\\_NO\\_VALUE if nothing is playing, GHOSTTY\\_UNSUPPORTED if Kitty graphics are disabled at build time, GHOSTTY\\_INVALID\\_VALUE if `next_ms` is NULL
"""
function ghostty_kitty_graphics_animation_tick(graphics, now_ms, next_ms)
    @ccall libghostty_vt.ghostty_kitty_graphics_animation_tick(graphics::GhosttyKittyGraphics, now_ms::UInt64, next_ms::Ptr{UInt64})::GhosttyResult
end

"""
    ghostty_kitty_graphics_image(graphics, image_id)

Look up a Kitty graphics image by its image ID.

Returns NULL if no image with the given ID exists or if Kitty graphics are disabled at build time.

` kitty_graphics`

# Arguments
* `graphics`: The kitty graphics handle (NULL returns NULL)
* `image_id`: The image ID to look up
# Returns
An opaque image handle, or NULL if not found
"""
function ghostty_kitty_graphics_image(graphics, image_id)
    @ccall libghostty_vt.ghostty_kitty_graphics_image(graphics::GhosttyKittyGraphics, image_id::UInt32)::GhosttyKittyGraphicsImage
end

"""
    ghostty_kitty_graphics_image_get(image, data, out)

Get data from a Kitty graphics image.

The output pointer must be of the appropriate type for the requested data kind.

` kitty_graphics`

# Arguments
* `image`: The image handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: The data kind to query
* `out`:\\[out\\] Pointer to receive the queried value
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `out` is NULL, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library or Kitty graphics are disabled at build time
"""
function ghostty_kitty_graphics_image_get(image, data, out)
    @ccall libghostty_vt.ghostty_kitty_graphics_image_get(image::GhosttyKittyGraphicsImage, data::GhosttyKittyGraphicsImageData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_kitty_graphics_image_get_multi(image, count, keys, values, out_written)

Get multiple data fields from a Kitty graphics image in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_kitty_graphics_image_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result. The type of each values[i] pointer must match the output type documented for keys[i].

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` kitty_graphics`

# Arguments
* `image`: The image handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_kitty_graphics_image_get_multi(image, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_kitty_graphics_image_get_multi(image::GhosttyKittyGraphicsImage, count::Csize_t, keys::Ptr{GhosttyKittyGraphicsImageData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_iterator_new(allocator, out_iterator)

Create a new placement iterator instance.

All fields except the allocator are left undefined until populated via [`ghostty_kitty_graphics_get`](@ref)() with GHOSTTY\\_KITTY\\_GRAPHICS\\_DATA\\_PLACEMENT\\_ITERATOR.

` kitty_graphics`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `out_iterator`:\\[out\\] On success, receives the created iterator handle
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY on allocation failure, GHOSTTY\\_INVALID\\_VALUE if `out_iterator` is NULL
"""
function ghostty_kitty_graphics_placement_iterator_new(allocator, out_iterator)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_iterator_new(allocator::Ptr{GhosttyAllocator}, out_iterator::Ptr{GhosttyKittyGraphicsPlacementIterator})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_iterator_free(iterator)

Free a placement iterator.

` kitty_graphics`

# Arguments
* `iterator`: The iterator handle to free (may be NULL)
"""
function ghostty_kitty_graphics_placement_iterator_free(iterator)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_iterator_free(iterator::GhosttyKittyGraphicsPlacementIterator)::Cvoid
end

"""
    ghostty_kitty_graphics_placement_iterator_set(iterator, option, value)

Set an option on a placement iterator.

Use GHOSTTY\\_KITTY\\_GRAPHICS\\_PLACEMENT\\_ITERATOR\\_OPT\\_LAYER to visit only the placements in some layers. [`ghostty_kitty_graphics_placement_next`](@ref)() then skips every placement outside those layers. By default, the iterator visits every placement.

` kitty_graphics`

# Arguments
* `iterator`: The iterator handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to set
* `value`: Pointer to the value. Its type depends on the option. NULL resets the option to its default.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the value is out of range, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library or Kitty graphics are disabled at build time
"""
function ghostty_kitty_graphics_placement_iterator_set(iterator, option, value)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_iterator_set(iterator::GhosttyKittyGraphicsPlacementIterator, option::GhosttyKittyGraphicsPlacementIteratorOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_next(iterator)

Advance the placement iterator to the next placement.

If a layer filter has been set via [`ghostty_kitty_graphics_placement_iterator_set`](@ref)(), only placements matching that layer are returned.

` kitty_graphics`

# Arguments
* `iterator`: The iterator handle (may be NULL)
# Returns
true if advanced to the next placement, false if at the end
"""
function ghostty_kitty_graphics_placement_next(iterator)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_next(iterator::GhosttyKittyGraphicsPlacementIterator)::Bool
end

"""
    ghostty_kitty_graphics_placement_get(iterator, data, out)

Get data from the current placement in a placement iterator.

Call [`ghostty_kitty_graphics_placement_next`](@ref)() at least once before calling this function.

` kitty_graphics`

# Arguments
* `iterator`: The iterator handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: The data kind to query
* `out`:\\[out\\] Pointer to receive the queried value
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the iterator is NULL or not positioned on a placement or `out` is NULL, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_kitty_graphics_placement_get(iterator, data, out)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_get(iterator::GhosttyKittyGraphicsPlacementIterator, data::GhosttyKittyGraphicsPlacementData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_get_multi(iterator, count, keys, values, out_written)

Get multiple data fields from the current placement in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_kitty_graphics_placement_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result. The type of each values[i] pointer must match the output type documented for keys[i].

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` kitty_graphics`

# Arguments
* `iterator`: The iterator handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_kitty_graphics_placement_get_multi(iterator, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_get_multi(iterator::GhosttyKittyGraphicsPlacementIterator, count::Csize_t, keys::Ptr{GhosttyKittyGraphicsPlacementData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_rect(iterator, image, terminal, out_selection)

Compute the grid rectangle occupied by the current placement.

Uses the placement's pin, the image dimensions, and the terminal's cell/pixel geometry to calculate the bounding rectangle. Virtual placements (unicode placeholders) return GHOSTTY\\_NO\\_VALUE.

` kitty_graphics`

# Arguments
* `iterator`: The placement iterator positioned on a placement
* `image`: The image handle for this placement's image
* `terminal`: The terminal handle
* `out_selection`:\\[out\\] On success, receives the bounding rectangle as a selection with rectangle=true
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if any handle or output pointer is NULL or the iterator is not positioned, GHOSTTY\\_NO\\_VALUE for virtual placements, GHOSTTY\\_UNSUPPORTED when Kitty graphics are disabled at build time
"""
function ghostty_kitty_graphics_placement_rect(iterator, image, terminal, out_selection)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_rect(iterator::GhosttyKittyGraphicsPlacementIterator, image::GhosttyKittyGraphicsImage, terminal::GhosttyTerminal, out_selection::Ptr{GhosttySelection})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_pixel_size(iterator, image, terminal, out_width, out_height)

Compute the rendered pixel size of the current placement.

Takes into account the placement's source rectangle, specified columns/rows, and aspect ratio to calculate the final rendered pixel dimensions.

` kitty_graphics`

# Arguments
* `iterator`: The placement iterator positioned on a placement
* `image`: The image handle for this placement's image
* `terminal`: The terminal handle
* `out_width`:\\[out\\] On success, receives the width in pixels
* `out_height`:\\[out\\] On success, receives the height in pixels
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if any handle or output pointer is NULL or the iterator is not positioned, GHOSTTY\\_UNSUPPORTED when Kitty graphics are disabled at build time
"""
function ghostty_kitty_graphics_placement_pixel_size(iterator, image, terminal, out_width, out_height)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_pixel_size(iterator::GhosttyKittyGraphicsPlacementIterator, image::GhosttyKittyGraphicsImage, terminal::GhosttyTerminal, out_width::Ptr{UInt32}, out_height::Ptr{UInt32})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_grid_size(iterator, image, terminal, out_cols, out_rows)

Compute the grid cell size of the current placement.

Returns the number of columns and rows that the placement occupies in the terminal grid. If the placement specifies explicit columns and rows, those are returned directly; otherwise they are calculated from the pixel size and cell dimensions.

` kitty_graphics`

# Arguments
* `iterator`: The placement iterator positioned on a placement
* `image`: The image handle for this placement's image
* `terminal`: The terminal handle
* `out_cols`:\\[out\\] On success, receives the number of columns
* `out_rows`:\\[out\\] On success, receives the number of rows
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if any handle or output pointer is NULL or the iterator is not positioned, GHOSTTY\\_UNSUPPORTED when Kitty graphics are disabled at build time
"""
function ghostty_kitty_graphics_placement_grid_size(iterator, image, terminal, out_cols, out_rows)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_grid_size(iterator::GhosttyKittyGraphicsPlacementIterator, image::GhosttyKittyGraphicsImage, terminal::GhosttyTerminal, out_cols::Ptr{UInt32}, out_rows::Ptr{UInt32})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_viewport_pos(iterator, image, terminal, out_col, out_row)

Get the top-left cell of the current placement, relative to the viewport.

This is for inspecting the storage. To draw, use the render state's image list instead. It positions every image on screen, including virtual placements and placements relative to them, and covers overscan rows. If you draw from both, images are drawn twice. See guide-images-drawing.

The row is negative when the top of the placement scrolled above the viewport. For example, an image 4 rows tall that scrolled up by 2 rows has a row of -2. Its top 2 rows are above the viewport and its bottom 2 rows are still visible.

` kitty_graphics`

# Arguments
* `iterator`: The placement iterator, moved to a placement
* `image`: The image of this placement
* `terminal`: The terminal the storage belongs to
* `out_col`:\\[out\\] On success, receives the column
* `out_row`:\\[out\\] On success, receives the row, which can be negative
# Returns
GHOSTTY\\_SUCCESS if any part of the placement is in the viewport. GHOSTTY\\_NO\\_VALUE if it is entirely outside the viewport or if it is a virtual placement or relative to one. GHOSTTY\\_UNSUPPORTED if Kitty graphics are disabled at build time. GHOSTTY\\_INVALID\\_VALUE if any handle or output pointer is NULL or the iterator is not on a placement.
"""
function ghostty_kitty_graphics_placement_viewport_pos(iterator, image, terminal, out_col, out_row)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_viewport_pos(iterator::GhosttyKittyGraphicsPlacementIterator, image::GhosttyKittyGraphicsImage, terminal::GhosttyTerminal, out_col::Ptr{Int32}, out_row::Ptr{Int32})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_source_rect(iterator, image, out_x, out_y, out_width, out_height)

Get the resolved source rectangle for the current placement.

Applies kitty protocol semantics: a width or height of 0 in the placement means "use the full image dimension", and the resulting rectangle is clamped to the actual image bounds. The returned values are in pixels and are ready to use for texture sampling.

` kitty_graphics`

# Arguments
* `iterator`: The placement iterator positioned on a placement
* `image`: The image handle for this placement's image
* `out_x`:\\[out\\] Source rect x origin in pixels
* `out_y`:\\[out\\] Source rect y origin in pixels
* `out_width`:\\[out\\] Source rect width in pixels
* `out_height`:\\[out\\] Source rect height in pixels
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if any handle or output pointer is NULL or the iterator is not positioned
"""
function ghostty_kitty_graphics_placement_source_rect(iterator, image, out_x, out_y, out_width, out_height)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_source_rect(iterator::GhosttyKittyGraphicsPlacementIterator, image::GhosttyKittyGraphicsImage, out_x::Ptr{UInt32}, out_y::Ptr{UInt32}, out_width::Ptr{UInt32}, out_height::Ptr{UInt32})::GhosttyResult
end

"""
    ghostty_kitty_graphics_placement_render_info(iterator, image, terminal, out_info)

Get all of the geometry of the current placement in one call.

This fills in a [`GhosttyKittyGraphicsPlacementRenderInfo`](@ref) with the pixel size, grid size, viewport position and source rectangle. Set its `size` with [`GHOSTTY_INIT_SIZED`](@ref) first.

This is for inspecting the storage. To draw, use the render state's image list instead. It gives the same values for every image on screen, including virtual placements and placements relative to them. If you draw from both, images are drawn twice. See guide-images-drawing.

The call succeeds even when the placement isn't in the viewport. Check `viewport_visible` before using `viewport_col` and `viewport_row`.

` kitty_graphics`

# Arguments
* `iterator`: The placement iterator, moved to a placement
* `image`: The image of this placement
* `terminal`: The terminal the storage belongs to
* `out_info`:\\[out\\] Receives the geometry
# Returns
GHOSTTY\\_SUCCESS on success. GHOSTTY\\_INVALID\\_VALUE if any handle or output pointer or `out_info` is NULL, the iterator is not on a placement, or `out\\_info->size` is too small. GHOSTTY\\_UNSUPPORTED if Kitty graphics are disabled at build time.
"""
function ghostty_kitty_graphics_placement_render_info(iterator, image, terminal, out_info)
    @ccall libghostty_vt.ghostty_kitty_graphics_placement_render_info(iterator::GhosttyKittyGraphicsPlacementIterator, image::GhosttyKittyGraphicsImage, terminal::GhosttyTerminal, out_info::Ptr{GhosttyKittyGraphicsPlacementRenderInfo})::GhosttyResult
end

"""
    GhosttyTerminalCompressionMode

Amount of compression work to perform before returning.

` terminal`

| Enumerator                                            | Note                                                                |
| :---------------------------------------------------- | :------------------------------------------------------------------ |
| GHOSTTY\\_TERMINAL\\_COMPRESSION\\_MODE\\_INCREMENTAL | Perform one bounded compression step suitable for idle scheduling.  |
| GHOSTTY\\_TERMINAL\\_COMPRESSION\\_MODE\\_FULL        | Synchronously inspect every currently eligible page.                |
| GHOSTTY\\_TERMINAL\\_COMPRESSION\\_MODE\\_MAX\\_VALUE |                                                                     |
"""
@cenum GhosttyTerminalCompressionMode::UInt32 begin
    GHOSTTY_TERMINAL_COMPRESSION_MODE_INCREMENTAL = 0
    GHOSTTY_TERMINAL_COMPRESSION_MODE_FULL = 1
    GHOSTTY_TERMINAL_COMPRESSION_MODE_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalCompressionResult

Scheduling result from terminal compression.

` terminal`

| Enumerator                                              | Note                                                         |
| :------------------------------------------------------ | :----------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_COMPRESSION\\_RESULT\\_UNSUPPORTED | Retained-mapping reclamation is unavailable on this target.  |
| GHOSTTY\\_TERMINAL\\_COMPRESSION\\_RESULT\\_PENDING     | More incremental compression work remains.                   |
| GHOSTTY\\_TERMINAL\\_COMPRESSION\\_RESULT\\_COMPLETE    | The pass has no continuation to schedule.                    |
| GHOSTTY\\_TERMINAL\\_COMPRESSION\\_RESULT\\_MAX\\_VALUE |                                                              |
"""
@cenum GhosttyTerminalCompressionResult::UInt32 begin
    GHOSTTY_TERMINAL_COMPRESSION_RESULT_UNSUPPORTED = 0
    GHOSTTY_TERMINAL_COMPRESSION_RESULT_PENDING = 1
    GHOSTTY_TERMINAL_COMPRESSION_RESULT_COMPLETE = 2
    GHOSTTY_TERMINAL_COMPRESSION_RESULT_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalScrollViewportTag

Scroll viewport behavior tag.

` terminal`

| Enumerator                                              | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| :------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_TOP            | Scroll to the top of the scrollback.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_BOTTOM         | Scroll to the bottom (active area).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_DELTA          | Scroll by a delta amount (up is negative).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_ROW            | Scroll to an absolute row offset from the top of the scrollable area. Row 0 is the top of the scrollback and the requested row becomes the first visible row of the viewport. The value is clamped so the viewport never scrolls beyond the top of the active area. If the terminal has no scrollback (e.g. the alternate screen is active), the viewport always remains on the active area.  This is the same row space as the offset field of [`GhosttyTerminalScrollbar`](@ref), so a scrollbar position obtained from GHOSTTY\\_TERMINAL\\_DATA\\_SCROLLBAR round-trips cleanly.  |
| GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_DELTA\\_PROMPT | Scroll by a number of prompts relative to the viewport top. Negative values move backward and positive values move forward. Requires semantic prompt markers from the shell. Zero or no matching prompt is a no-op. If fewer prompts remain than requested, move to the last matching prompt, clamped to the active area.  Moving forward through a final prompt continuation can snap to the active area even when there is no newer prompt.                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_MAX\\_VALUE    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
"""
@cenum GhosttyTerminalScrollViewportTag::UInt32 begin
    GHOSTTY_TERMINAL_SCROLL_VIEWPORT_TOP = 0
    GHOSTTY_TERMINAL_SCROLL_VIEWPORT_BOTTOM = 1
    GHOSTTY_TERMINAL_SCROLL_VIEWPORT_DELTA = 2
    GHOSTTY_TERMINAL_SCROLL_VIEWPORT_ROW = 3
    GHOSTTY_TERMINAL_SCROLL_VIEWPORT_DELTA_PROMPT = 4
    GHOSTTY_TERMINAL_SCROLL_VIEWPORT_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalScrollViewportValue

Scroll viewport value.

` terminal`
"""
struct GhosttyTerminalScrollViewportValue
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyTerminalScrollViewportValue}, f::Symbol)
    f === :delta && return Ptr{Cptrdiff_t}(x + 0)
    f === :row && return Ptr{Csize_t}(x + 0)
    f === :delta_prompt && return Ptr{Cptrdiff_t}(x + 0)
    f === :_padding && return Ptr{NTuple{2, UInt64}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyTerminalScrollViewportValue, f::Symbol)
    r = Ref{GhosttyTerminalScrollViewportValue}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyTerminalScrollViewportValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyTerminalScrollViewportValue}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyTerminalScrollViewportValue, private::Bool = false)
    (:delta, :row, :delta_prompt, :_padding, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttyTerminalScrollViewport

Tagged union for scroll viewport behavior.

` terminal`
"""
struct GhosttyTerminalScrollViewport
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyTerminalScrollViewport}, f::Symbol)
    f === :tag && return Ptr{GhosttyTerminalScrollViewportTag}(x + 0)
    f === :value && return Ptr{GhosttyTerminalScrollViewportValue}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyTerminalScrollViewport, f::Symbol)
    r = Ref{GhosttyTerminalScrollViewport}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyTerminalScrollViewport}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyTerminalScrollViewport}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyTerminalScrollViewport, private::Bool = false)
    (:tag, :value, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttyTerminalScreen

Terminal screen identifier.

Identifies which screen buffer is active in the terminal.

` terminal`

| Enumerator                                | Note                          |
| :---------------------------------------- | :---------------------------- |
| GHOSTTY\\_TERMINAL\\_SCREEN\\_PRIMARY     | The primary (normal) screen.  |
| GHOSTTY\\_TERMINAL\\_SCREEN\\_ALTERNATE   | The alternate screen.         |
| GHOSTTY\\_TERMINAL\\_SCREEN\\_MAX\\_VALUE |                               |
"""
@cenum GhosttyTerminalScreen::UInt32 begin
    GHOSTTY_TERMINAL_SCREEN_PRIMARY = 0
    GHOSTTY_TERMINAL_SCREEN_ALTERNATE = 1
    GHOSTTY_TERMINAL_SCREEN_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalBoundary

A point in the VT stream where [`ghostty_terminal_vt_write_until`](@ref)() can stop.

The values are bit flags. Combine them with `|` to stop at any of several boundaries.

Most boundaries mark the first or last byte of a control string: an APC, DCS or OSC sequence, made of an introducer, some content, and a terminator. GROUND is different. It marks the state between sequences rather than a byte inside one.

Terminal protocols spell control bytes two ways, and both are recognized. A 7-bit introducer is ESC followed by one byte, such as `ESC ]` for OSC. The 8-bit form is a single byte in the range 0x80 to 0x9F, such as 0x9D for OSC. The string terminator ST is `ESC \\` or the single byte 0x9C.

` terminal`

| Enumerator                                  | Note                                                                                                                                                                                                                                                                                                                                            |
| :------------------------------------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_GROUND      | The stream is not inside any escape sequence or partial UTF-8 character. This is a safe point to insert your own sequences.  Ground is a state, not an event. If the stream is already at ground, the call stops immediately and consumes nothing.                                                                                              |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_APC\\_START | The byte that started an APC string: `_` after ESC, or 0x9F.  SOS (`X` or 0x98) and PM (`^` or 0x9E) strings also report this boundary, because the parser handles all three the same way. Check [`GhosttyTerminalWriteStop`](@ref).byte to tell them apart.                                                                                    |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_APC\\_END   | The byte that ended an APC, SOS or PM string.                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_DCS\\_START | The byte that started a DCS string: `P` after ESC, or 0x90.  A DCS has a header before its payload: parameters, intermediates and a final byte, in the same shape as a CSI sequence. The stop lands on the introducer, so the header follows it. A 0x90 inside the header restarts the header without leaving the string, so it does not stop.  |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_DCS\\_END   | The byte that ended a DCS string, whether it was still in its header or already in its payload. A DCS cut short in its header reports this without ever having had a payload.                                                                                                                                                                   |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_OSC\\_START | The byte that started an OSC string: `]` after ESC, or 0x9D.                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_OSC\\_END   | The byte that ended an OSC string. This is reported for every OSC, including ones the terminal does not understand.                                                                                                                                                                                                                             |
| GHOSTTY\\_TERMINAL\\_BOUNDARY\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                 |
"""
@cenum GhosttyTerminalBoundary::UInt32 begin
    GHOSTTY_TERMINAL_BOUNDARY_GROUND = 1
    GHOSTTY_TERMINAL_BOUNDARY_APC_START = 2
    GHOSTTY_TERMINAL_BOUNDARY_APC_END = 4
    GHOSTTY_TERMINAL_BOUNDARY_DCS_START = 8
    GHOSTTY_TERMINAL_BOUNDARY_DCS_END = 16
    GHOSTTY_TERMINAL_BOUNDARY_OSC_START = 32
    GHOSTTY_TERMINAL_BOUNDARY_OSC_END = 64
    GHOSTTY_TERMINAL_BOUNDARY_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalStringKind

The kind of control string that started or ended.

` terminal`

| Enumerator                                       | Note                                                                                                                                                                                                                                                              |
| :----------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_STRING\\_KIND\\_APC         | An APC, SOS or PM string. [`GhosttyTerminalWriteStop`](@ref).byte at the start of the string tells you which one it is:  | Byte | String | |--------------------|--------| | `_` (0x5F) or 0x9F | APC | | `X` (0x58) or 0x98 | SOS | | `^` (0x5E) or 0x9E | PM |  |
| GHOSTTY\\_TERMINAL\\_STRING\\_KIND\\_DCS         | A DCS string, started by `P` (0x50) after ESC or by 0x90.                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_STRING\\_KIND\\_OSC         | An OSC string, started by `]` (0x5D) after ESC or by 0x9D.                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_STRING\\_KIND\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                   |
"""
@cenum GhosttyTerminalStringKind::UInt32 begin
    GHOSTTY_TERMINAL_STRING_KIND_APC = 0
    GHOSTTY_TERMINAL_STRING_KIND_DCS = 1
    GHOSTTY_TERMINAL_STRING_KIND_OSC = 2
    GHOSTTY_TERMINAL_STRING_KIND_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalStringIntroducer

How a control string started.

` terminal`

| Enumerator                                             | Note                                                                                                                                                                                                                                                                                |
| :----------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_STRING\\_INTRODUCER\\_ESC         | ESC followed by `_`, `X`, `^`, `P` or `]`. The stop's `consumed` count includes only the final byte, because the ESC may have arrived in an earlier call.                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_STRING\\_INTRODUCER\\_C1          | A single 8-bit byte: 0x9F (APC), 0x98 (SOS), 0x9E (PM), 0x90 (DCS) or 0x9D (OSC).  When the stream is at ground, these bytes are decoded as UTF-8 and do not start a string. They only start a string when they arrive while the stream is already inside another escape sequence.  |
| GHOSTTY\\_TERMINAL\\_STRING\\_INTRODUCER\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                     |
"""
@cenum GhosttyTerminalStringIntroducer::UInt32 begin
    GHOSTTY_TERMINAL_STRING_INTRODUCER_ESC = 0
    GHOSTTY_TERMINAL_STRING_INTRODUCER_C1 = 1
    GHOSTTY_TERMINAL_STRING_INTRODUCER_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalStringEnd

How a control string ended.

` terminal`

| Enumerator                                      | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| :---------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_STRING\\_END\\_ST\\_ESC    | ESC, the first byte of the string terminator `ESC \\`.  The ESC is consumed but the `\\` after it is not. Pass the `\\` as the first byte of your next write, where it completes the terminator. If you forward the stream elsewhere, forward the ESC along with the string.                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_TERMINAL\\_STRING\\_END\\_ST\\_C1     | 0x9C, the 8-bit string terminator. The stream is now at ground.  Inside an OSC, and inside a DCS once its header is complete, 0x9C is content rather than a terminator. So this is only reported for an APC or for a DCS still in its header.                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_TERMINAL\\_STRING\\_END\\_CANCELLED   | CAN (0x18) or SUB (0x1A) cancelled the string. The stream is now at ground.  The terminal discards a cancelled APC or OSC. Its command does not run and it is not passed to the unknown sequence callback. For example, `ESC \\_ G a=t,i=7;AAAA` followed by CAN stores no image.                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_STRING\\_END\\_ABORTED     | Another 8-bit control byte cut the string short. Most of these return the stream to ground. CSI (0x9B) starts a CSI sequence instead. The introducers DCS (0x90), OSC (0x9D), APC (0x9F), SOS (0x98) and PM (0x9E) start a new string on the same byte, which the stop reports with a START flag as well. See [`GhosttyTerminalWriteStop`](@ref).reached.  Inside an OSC, and inside a DCS once its header is complete, 8-bit bytes are content. So this is only reported for an APC or for a DCS still in its header.  The terminal discards an aborted APC, just like a cancelled one.  |
| GHOSTTY\\_TERMINAL\\_STRING\\_END\\_BEL         | BEL (0x07) terminated the string. Only an OSC ends this way.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_TERMINAL\\_STRING\\_END\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
"""
@cenum GhosttyTerminalStringEnd::UInt32 begin
    GHOSTTY_TERMINAL_STRING_END_ST_ESC = 0
    GHOSTTY_TERMINAL_STRING_END_ST_C1 = 1
    GHOSTTY_TERMINAL_STRING_END_CANCELLED = 2
    GHOSTTY_TERMINAL_STRING_END_ABORTED = 3
    GHOSTTY_TERMINAL_STRING_END_BEL = 4
    GHOSTTY_TERMINAL_STRING_END_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalWriteStop

Where [`ghostty_terminal_vt_write_until`](@ref)() stopped, and why.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)() before the first call. See sized-structs. Each call resets every field except `size` before it writes the result, so you can reuse one struct across calls.

Fields that don't apply to a stop are zero. Zero is also a valid value for `kind`, `introducer` and `end`, so always check `reached` first to see which fields apply.

` terminal`

| Field      | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| :--------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| size       | Size of this struct in bytes. Set by [`GHOSTTY_INIT_SIZED`](@ref)().                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| consumed   | Number of input bytes consumed, including the byte that reached the boundary. This is 0 when the stream was already at ground and you asked for GHOSTTY\\_TERMINAL\\_BOUNDARY\\_GROUND.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| reached    | The [`GhosttyTerminalBoundary`](@ref) flags that the stopping byte reached. Only flags you asked for are set, and this is 0 when no boundary was reached.  This is usually one flag. It holds two when a single byte does two things:  - It ends a string and returns to ground. BEL, CAN, SUB, 0x9C and the other 8-bit control bytes all do this. So if you asked for both OSC\\_END and GROUND, an OSC\\_END stop can include GROUND too. - It ends one string and starts another. An 8-bit introducer of a different kind does this inside an APC, or inside a DCS header: 0x90 or 0x9D in an APC ends it and starts a DCS or OSC, and 0x9F, 0x98, 0x9E or 0x9D in a DCS header ends it and starts an APC or OSC. The stop has an END flag and a START flag, `end` is ABORTED and `introducer` is C1. See [`ghostty_terminal_vt_write_until`](@ref)() for an example.  A START flag and an END flag of the same kind are never set together.  |
| kind       | The kind of string. Valid when `reached` has a START or END flag.  When one byte both ends a string and starts another, this is the kind of the string that ended. The START flag in `reached` names the kind that started, since APC\\_START, DCS\\_START and OSC\\_START each belong to one kind.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| introducer | How the string started. Valid when `reached` has a START flag.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| end        | How the string ended. Valid when `reached` has an END flag.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| byte       | The byte that started or ended the string, such as `]`, 0x90, ESC or BEL. Valid when `reached` has a START or END flag.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
"""
struct GhosttyTerminalWriteStop
    size::Csize_t
    consumed::Csize_t
    reached::UInt32
    kind::GhosttyTerminalStringKind
    introducer::GhosttyTerminalStringIntroducer
    _end::GhosttyTerminalStringEnd
    byte::UInt8
end

"""
    GhosttyTerminalScrollbar

Scrollbar state for the terminal viewport.

Represents the scrollable area dimensions needed to render a scrollbar.

` terminal`

| Field  | Note                                                 |
| :----- | :--------------------------------------------------- |
| total  | Total size of the scrollable area in rows.           |
| offset | Offset into the total area that the viewport is at.  |
| len    | Length of the visible area in rows.                  |
"""
struct GhosttyTerminalScrollbar
    total::UInt64
    offset::UInt64
    len::UInt64
end

"""
    GhosttyTerminalMemoryUsage

Memory held by a terminal.

Read with [`ghostty_terminal_get`](@ref)() and `GHOSTTY_TERMINAL_DATA_MEMORY_USAGE`.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)() before passing it to [`ghostty_terminal_get`](@ref)(). See sized-structs.

Each screen has its own set of fields, named with a `primary_` or `alternate_` prefix. Add the two sets together for the terminal's total. The alternate fields are all zero until a program first switches to that screen.

See guide-scrollback-memory for what these figures cover and which one to budget against.

` terminal`

| Field                          | Note                                                                                                                                                                                                                                                                                                                          |
| :----------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| size                           | Size of this struct in bytes. Set by you.                                                                                                                                                                                                                                                                                     |
| compression\\_supported        | Whether compressing scrollback can free memory on this platform. When false, [`ghostty_terminal_compress`](@ref)() reports `GHOSTTY_TERMINAL_COMPRESSION_RESULT_UNSUPPORTED` and the compressed fields are always zero. To reduce a terminal's memory on such a platform, you have to do something else, such as closing it.  |
| primary\\_pages                | Number of pages in the primary screen, including compressed pages.                                                                                                                                                                                                                                                            |
| primary\\_virtual\\_bytes      | Bytes of address space reserved for the primary screen's pages. This includes compressed pages and spare pages kept ready for reuse. Always at least `primary_resident_bytes`.                                                                                                                                                |
| primary\\_resident\\_bytes     | Bytes of physical memory used by the primary screen's pages. A compressed page counts only its compressed size. Use this figure for memory budgets.                                                                                                                                                                           |
| primary\\_compressed\\_pages   | Number of the primary screen's pages that are compressed.                                                                                                                                                                                                                                                                     |
| primary\\_compressed\\_bytes   | Bytes of compressed data held for the primary screen's compressed pages. This is already included in `primary_resident_bytes`.                                                                                                                                                                                                |
| primary\\_image\\_bytes        | Bytes of image data stored for the primary screen through the Kitty graphics protocol. This is not included in `primary_resident_bytes`. Always zero when libghostty-vt is built without Kitty graphics.                                                                                                                      |
| alternate\\_pages              | The same as `primary_pages`, for the alternate screen.                                                                                                                                                                                                                                                                        |
| alternate\\_virtual\\_bytes    | The same as `primary_virtual_bytes`, for the alternate screen.                                                                                                                                                                                                                                                                |
| alternate\\_resident\\_bytes   | The same as `primary_resident_bytes`, for the alternate screen.                                                                                                                                                                                                                                                               |
| alternate\\_compressed\\_pages | The same as `primary_compressed_pages`, for the alternate screen.                                                                                                                                                                                                                                                             |
| alternate\\_compressed\\_bytes | The same as `primary_compressed_bytes`, for the alternate screen.                                                                                                                                                                                                                                                             |
| alternate\\_image\\_bytes      | The same as `primary_image_bytes`, for the alternate screen.                                                                                                                                                                                                                                                                  |
"""
struct GhosttyTerminalMemoryUsage
    size::Csize_t
    compression_supported::Bool
    primary_pages::UInt64
    primary_virtual_bytes::UInt64
    primary_resident_bytes::UInt64
    primary_compressed_pages::UInt64
    primary_compressed_bytes::UInt64
    primary_image_bytes::UInt64
    alternate_pages::UInt64
    alternate_virtual_bytes::UInt64
    alternate_resident_bytes::UInt64
    alternate_compressed_pages::UInt64
    alternate_compressed_bytes::UInt64
    alternate_image_bytes::UInt64
end

# typedef void ( * GhosttyTerminalBellFn ) ( GhosttyTerminal terminal , void * userdata )
"""
Callback function type for bell.

Called when the terminal receives a BEL character (0x07).

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
"""
const GhosttyTerminalBellFn = Ptr{Cvoid}

"""
    GhosttyTerminalUnknownSequenceTag

The kind of unsupported sequence passed to a [`GhosttyTerminalUnknownSequenceFn`](@ref) callback.

New kinds may be added in later versions. Callbacks should ignore any tag they don't handle.

` effects`

| Enumerator                                            | Note                                                          |
| :---------------------------------------------------- | :------------------------------------------------------------ |
| GHOSTTY\\_TERMINAL\\_UNKNOWN\\_SEQUENCE\\_APC         | Application Program Command (APC).                            |
| GHOSTTY\\_TERMINAL\\_UNKNOWN\\_SEQUENCE\\_OSC         | Operating System Command (OSC). The value is in `value.osc`.  |
| GHOSTTY\\_TERMINAL\\_UNKNOWN\\_SEQUENCE\\_MAX\\_VALUE |                                                               |
"""
@cenum GhosttyTerminalUnknownSequenceTag::UInt32 begin
    GHOSTTY_TERMINAL_UNKNOWN_SEQUENCE_APC = 0
    GHOSTTY_TERMINAL_UNKNOWN_SEQUENCE_OSC = 1
    GHOSTTY_TERMINAL_UNKNOWN_SEQUENCE_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalUnknownStringSequence

An unsupported string terminal sequence.

The content is borrowed and valid only for the callback duration. It contains the bytes between the sequence introducer and terminator, may contain arbitrary binary data, and is not null-terminated.

` effects`

| Field     | Note                                                                    |
| :-------- | :---------------------------------------------------------------------- |
| truncated | Whether content was shortened by the byte limit or allocation failure.  |
| content   | Retained sequence content.                                              |
"""
struct GhosttyTerminalUnknownStringSequence
    truncated::Bool
    content::GhosttyString
end

"""
    GhosttyTerminalUnknownOscSequence

An OSC sequence whose number libghostty-vt does not implement.

OSC sequences start with `ESC ]`, followed by a number that identifies the command, usually a `;`, and then the command's data. The sequence ends with either BEL or ESC followed by a backslash. For example, a program might write:

```c++
 ESC ] 7400;status=busy BEL
```

For that sequence, `content` is `7400;status=busy` and `terminator` is GHOSTTY\\_OSC\\_TERMINATOR\\_BEL. See guide-custom-sequences-unknown for a complete example.

` effects`

| Field      | Note                                                                                                                                                                                                  |
| :--------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| truncated  | True if the sequence was longer than GHOSTTY\\_TERMINAL\\_OPT\\_UNKNOWN\\_MAX\\_BYTES, or memory ran out while reading it. In that case `content` holds only the beginning of the sequence.           |
| content    | Everything between `ESC ]` and the terminator, including the number at the start. The bytes are not null-terminated and are only valid until the callback returns. Copy them if you need them later.  |
| terminator | How the program ended the sequence. If you send a reply, end it the same way.                                                                                                                         |
"""
struct GhosttyTerminalUnknownOscSequence
    truncated::Bool
    content::GhosttyString
    terminator::GhosttyOscTerminator
end

"""
    GhosttyTerminalUnknownSequenceValue

Unsupported terminal sequence value.

` effects`
"""
struct GhosttyTerminalUnknownSequenceValue
    data::NTuple{128, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyTerminalUnknownSequenceValue}, f::Symbol)
    f === :apc && return Ptr{GhosttyTerminalUnknownStringSequence}(x + 0)
    f === :osc && return Ptr{GhosttyTerminalUnknownOscSequence}(x + 0)
    f === :_padding && return Ptr{NTuple{16, UInt64}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyTerminalUnknownSequenceValue, f::Symbol)
    r = Ref{GhosttyTerminalUnknownSequenceValue}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyTerminalUnknownSequenceValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyTerminalUnknownSequenceValue}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyTerminalUnknownSequenceValue, private::Bool = false)
    (:apc, :osc, :_padding, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttyTerminalUnknownSequence

An unsupported terminal sequence.

` effects`
"""
struct GhosttyTerminalUnknownSequence
    data::NTuple{136, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyTerminalUnknownSequence}, f::Symbol)
    f === :tag && return Ptr{GhosttyTerminalUnknownSequenceTag}(x + 0)
    f === :value && return Ptr{GhosttyTerminalUnknownSequenceValue}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyTerminalUnknownSequence, f::Symbol)
    r = Ref{GhosttyTerminalUnknownSequence}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyTerminalUnknownSequence}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyTerminalUnknownSequence}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyTerminalUnknownSequence, private::Bool = false)
    (:tag, :value, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

# typedef void ( * GhosttyTerminalUnknownSequenceFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyTerminalUnknownSequence * sequence )
"""
Callback function type for unsupported terminal sequences.

Called once for each complete sequence that libghostty-vt does not implement. Check `sequence->tag` first, because more kinds of sequences may be reported in later versions.

These are not reported:

- Sequences cut short before their terminator, either cancelled by CAN or SUB or aborted by another 8-bit control byte. - Sequences libghostty-vt implements, even when their contents are malformed. - Supported protocols that you turned off.

The callback runs during [`ghostty_terminal_vt_write`](@ref)(). It may write a reply to the pty, and that reply stays in order with the terminal's own replies. It must not call [`ghostty_terminal_vt_write`](@ref)() on the same terminal.

Nothing is reported until GHOSTTY\\_TERMINAL\\_OPT\\_UNKNOWN\\_MAX\\_BYTES is also set to a nonzero value. Installing the callback by itself keeps no data and allocates no memory.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `sequence`: Borrowed unsupported sequence
"""
const GhosttyTerminalUnknownSequenceFn = Ptr{Cvoid}

"""
    GhosttyClipboardLocation

Clipboard destination for a clipboard write.

Protocol-specific destination identifiers are normalized to these values before the clipboard write callback is invoked.

` effects`

| Enumerator                                   | Note                              |
| :------------------------------------------- | :-------------------------------- |
| GHOSTTY\\_CLIPBOARD\\_LOCATION\\_STANDARD    | The standard system clipboard.    |
| GHOSTTY\\_CLIPBOARD\\_LOCATION\\_SELECTION   | The selection clipboard.          |
| GHOSTTY\\_CLIPBOARD\\_LOCATION\\_PRIMARY     | The primary selection clipboard.  |
| GHOSTTY\\_CLIPBOARD\\_LOCATION\\_MAX\\_VALUE |                                   |
"""
@cenum GhosttyClipboardLocation::UInt32 begin
    GHOSTTY_CLIPBOARD_LOCATION_STANDARD = 0
    GHOSTTY_CLIPBOARD_LOCATION_SELECTION = 1
    GHOSTTY_CLIPBOARD_LOCATION_PRIMARY = 2
    GHOSTTY_CLIPBOARD_LOCATION_MAX_VALUE = 2147483647
end

"""
    GhosttyClipboardContent

One MIME representation in a clipboard write.

Both strings are borrowed and valid only for the duration of the callback. The data is binary-safe and has already been decoded from any protocol-level encoding. A zero-length data string is an explicit empty representation; it does not clear the clipboard.

This struct has a frozen layout and will not gain fields in future versions.

` effects`

| Field | Note                                       |
| :---- | :----------------------------------------- |
| mime  | MIME type of the representation.           |
| data  | Decoded, binary-safe representation data.  |
"""
struct GhosttyClipboardContent
    mime::GhosttyString
    data::GhosttyString
end

"""
    GhosttyClipboardWriteResult

Result of a clipboard write reply.

` effects`

| Enumerator                                            | Note                                                             |
| :---------------------------------------------------- | :--------------------------------------------------------------- |
| GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_SUCCESS        | The clipboard write completed successfully.                      |
| GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_DENIED         | The clipboard write was denied by policy or the user.            |
| GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_UNSUPPORTED    | The destination or one or more representations are unsupported.  |
| GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_BUSY           | The clipboard is temporarily unavailable.                        |
| GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_INVALID\\_DATA | One or more representations contain invalid data.                |
| GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_IO\\_ERROR     | The clipboard write failed due to an I/O error.                  |
| GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_MAX\\_VALUE    |                                                                  |
"""
@cenum GhosttyClipboardWriteResult::UInt32 begin
    GHOSTTY_CLIPBOARD_WRITE_RESULT_SUCCESS = 0
    GHOSTTY_CLIPBOARD_WRITE_RESULT_DENIED = 1
    GHOSTTY_CLIPBOARD_WRITE_RESULT_UNSUPPORTED = 2
    GHOSTTY_CLIPBOARD_WRITE_RESULT_BUSY = 3
    GHOSTTY_CLIPBOARD_WRITE_RESULT_INVALID_DATA = 4
    GHOSTTY_CLIPBOARD_WRITE_RESULT_IO_ERROR = 5
    GHOSTTY_CLIPBOARD_WRITE_RESULT_MAX_VALUE = 2147483647
end

"""
    GhosttyClipboardWriteReply

The reply to a clipboard write request.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)(), then set the fields you need. See sized-structs. If `size` is not valid, the library ignores the rest of the reply and answers as if you had replied with GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_UNSUPPORTED.

The reply is borrowed only for the duration of the reply call and may be freed as soon as it returns.

The result answers the program with the matching protocol status for protocols with a write acknowledgement (OSC 5522: DONE, EPERM, ENOSYS, EBUSY, EINVAL, EIO); protocols without one (OSC 52, OSC 1337 Copy) discard the reply. `remember` is ignored on any result other than GHOSTTY\\_CLIPBOARD\\_WRITE\\_RESULT\\_SUCCESS.

` effects`

| Field    | Note                                                                                                                                                                              |
| :------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| size     | Size of this struct in bytes.                                                                                                                                                     |
| result   | Outcome of the write.                                                                                                                                                             |
| remember | Record a session grant so future requests from the same program skip the permission prompt. Only honored on success when [`GhosttyClipboardWrite`](@ref)::can\\_remember is set.  |
"""
struct GhosttyClipboardWriteReply
    size::Csize_t
    result::GhosttyClipboardWriteResult
    remember::Bool
end

# typedef void ( * GhosttyClipboardWriteReplyFn ) ( const GhosttyClipboardWrite * write , const GhosttyClipboardWriteReply * reply )
"""
Function type used to answer a clipboard write request. Obtained from [`GhosttyClipboardWrite`](@ref)::reply; see that struct for the contract.

` effects`

# Arguments
* `write`: The request being answered
* `reply`: The reply, borrowed only for the duration of this call
"""
const GhosttyClipboardWriteReplyFn = Ptr{Cvoid}

"""
    GhosttyClipboardWrite

A synchronous request to write clipboard contents.

The request and everything it points to, including the contents array and its strings, are borrowed. They are only valid until the callback returns.

All entries in `contents` are representations of the same logical value and must be committed atomically. A `contents_len` of zero requests that the destination be cleared. This is distinct from a content entry whose data has zero length.

The write is answered by calling `reply` with this request and a [`GhosttyClipboardWriteReply`](@ref). This must happen within the clipboard write request callback. This struct is only valid during that time. Calling  `reply` more than once is safely ignored. Returning without replying  denies the write.

This struct has a frozen layout and will never gain fields. It is 64 bytes on 64-bit targets and 32 bytes on wasm32. If a later version of libghostty-vt has more to report, it will add a new option with a new struct, and this callback will keep receiving this struct unchanged.

` effects`

| Field          | Note                                                                                                                                                                                 |
| :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| location       | Clipboard destination.                                                                                                                                                               |
| contents       | Borrowed array of MIME representations.                                                                                                                                              |
| contents\\_len | Number of entries in contents; zero means clear the destination.                                                                                                                     |
| name           | Name of the writing program for permission prompts, if the protocol carries one. Empty otherwise.                                                                                    |
| granted        | True if the terminal already holds a session grant for this request You should skip any permission prompt and perform the write.                                                     |
| can\\_remember | True if the program supplied a session password, so you may offer to remember the decision through [`GhosttyClipboardWriteReply`](@ref)::remember. When false, remember is ignored.  |
| ctx            | Terminal-owned reply state. Do not access.                                                                                                                                           |
| reply          | Answer the write; see the struct documentation.                                                                                                                                      |
"""
struct GhosttyClipboardWrite
    location::GhosttyClipboardLocation
    contents::Ptr{GhosttyClipboardContent}
    contents_len::Csize_t
    name::GhosttyString
    granted::Bool
    can_remember::Bool
    ctx::Ptr{Cvoid}
    reply::GhosttyClipboardWriteReplyFn
end

# typedef void ( * GhosttyTerminalClipboardWriteFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyClipboardWrite * write )
"""
Callback function type for clipboard\\_write.

You may ask for permission to write or perform the write  async, but the callback itself is synchronous and the reply function must be called during the lifetime of this function. While this callback is active the VT stream is paused.

Answer by calling `write->reply(write, &reply)` before returning. See [`GhosttyClipboardWrite`](@ref) for the full contract.

The request may carry an optional program name requesting the write and the state of prior permission granted. If `can_remember` is set the response may set the `remember` flag and future requests from this same program will be "granted" and you can skip permission requests.

Clipboard read requests (OSC 52 "?" and OSC 5522 reads) are delivered to [`GhosttyTerminalClipboardReadFn`](@ref) instead.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `write`: Borrowed atomic clipboard write request
"""
const GhosttyTerminalClipboardWriteFn = Ptr{Cvoid}

"""
    GhosttyClipboardReadResult

Result of a clipboard read reply.

` effects`

| Enumerator                                        | Note                                                     |
| :------------------------------------------------ | :------------------------------------------------------- |
| GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_SUCCESS     | The clipboard was read; the reply carries its contents.  |
| GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_DENIED      | The clipboard read was denied by policy or the user.     |
| GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_UNSUPPORTED | You cannot read this clipboard.                          |
| GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_BUSY        | The clipboard is temporarily unavailable.                |
| GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_IO\\_ERROR  | Reading the clipboard failed due to an I/O error.        |
| GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_MAX\\_VALUE |                                                          |
"""
@cenum GhosttyClipboardReadResult::UInt32 begin
    GHOSTTY_CLIPBOARD_READ_RESULT_SUCCESS = 0
    GHOSTTY_CLIPBOARD_READ_RESULT_DENIED = 1
    GHOSTTY_CLIPBOARD_READ_RESULT_UNSUPPORTED = 2
    GHOSTTY_CLIPBOARD_READ_RESULT_BUSY = 3
    GHOSTTY_CLIPBOARD_READ_RESULT_IO_ERROR = 4
    GHOSTTY_CLIPBOARD_READ_RESULT_MAX_VALUE = 2147483647
end

"""
    GhosttyClipboardReadReply

The reply to a clipboard read request.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)(), then set the fields you need. See sized-structs. If `size` is not valid, the library ignores the rest of the reply and answers as if you had replied with GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_UNSUPPORTED.

All arrays and the strings they point to are borrowed only for the duration of the reply call and may be freed as soon as it returns.

Any result other than GHOSTTY\\_CLIPBOARD\\_READ\\_RESULT\\_SUCCESS answers the program with an empty clipboard (OSC 52) or the matching protocol status (OSC 5522: EPERM, ENOSYS, EBUSY, EIO); the other fields are ignored in that case. On success, `contents` should carry one representation per requested MIME type ([`GhosttyClipboardRead`](@ref)::mimes) that the clipboard has; unrequested representations are ignored. Protocols that carry a single text value (OSC 52) use the first entry with a text MIME type such as "text/plain".

` effects`

| Field           | Note                                                                                                                                                                             |
| :-------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| size            | Size of this struct in bytes.                                                                                                                                                    |
| result          | Outcome of the read.                                                                                                                                                             |
| contents        | Borrowed array of MIME representations of the clipboard contents.                                                                                                                |
| contents\\_len  | Number of entries in contents.                                                                                                                                                   |
| available       | Borrowed array of all MIME types available on the clipboard. Only used when [`GhosttyClipboardRead`](@ref)::list is set; may be NULL otherwise.                                  |
| available\\_len | Number of entries in available.                                                                                                                                                  |
| remember        | Record a session grant so future requests from the same program skip the permission prompt. Only honored on success when [`GhosttyClipboardRead`](@ref)::can\\_remember is set.  |
"""
struct GhosttyClipboardReadReply
    size::Csize_t
    result::GhosttyClipboardReadResult
    contents::Ptr{GhosttyClipboardContent}
    contents_len::Csize_t
    available::Ptr{GhosttyString}
    available_len::Csize_t
    remember::Bool
end

# typedef void ( * GhosttyClipboardReadReplyFn ) ( const GhosttyClipboardRead * read , const GhosttyClipboardReadReply * reply )
"""
Function type used to answer a clipboard read request. Obtained from [`GhosttyClipboardRead`](@ref)::reply; see that struct for the contract.

` effects`

# Arguments
* `read`: The request being answered
* `reply`: The reply, borrowed only for the duration of this call
"""
const GhosttyClipboardReadReplyFn = Ptr{Cvoid}

"""
    GhosttyClipboardRead

A synchronous request to read clipboard contents.

The request is borrowed and only valid until the callback returns.

The read is answered by calling `reply` with this request and a [`GhosttyClipboardReadReply`](@ref). This must happen before the callback returns; the request is invalid afterwards. Calling `reply` more than once is ignored. Returning without replying answers the program with an empty clipboard (OSC 52) or EPERM (OSC 5522).

This struct has a frozen layout and will never gain fields. It is 72 bytes on 64-bit targets and 36 bytes on wasm32. If a later version of libghostty-vt has more to report, it will add a new option with a new struct, and this callback will keep receiving this struct unchanged.

` effects`

| Field          | Note                                                                                                                                                                                                                                                                                                                                                                                           |
| :------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| location       | Clipboard to read.                                                                                                                                                                                                                                                                                                                                                                             |
| mimes          | Borrowed array of the MIME types the program wants, in order of preference. Protocols that only carry text (OSC 52) request "text/plain". NULL when mimes\\_len is zero.                                                                                                                                                                                                                       |
| mimes\\_len    | Number of entries in mimes.                                                                                                                                                                                                                                                                                                                                                                    |
| list           | True if the program also wants the list of MIME types available on the clipboard, delivered through [`GhosttyClipboardReadReply`](@ref)::available.                                                                                                                                                                                                                                            |
| name           | Name of the requesting program for permission prompts, if the protocol carries one. Empty otherwise.                                                                                                                                                                                                                                                                                           |
| granted        | True if the terminal already holds a session grant for this request (kitty clipboard protocol passwords). You should skip any permission prompt and serve the read.  Always false when mimes\\_len is zero: such a request is served without a prompt (see the callback docs), so the terminal never consults grants for it and a one-time password is preserved for the follow-up data read.  |
| can\\_remember | True if the program supplied a session password, so you may offer to remember the decision through [`GhosttyClipboardReadReply`](@ref)::remember. When false, remember is ignored.                                                                                                                                                                                                             |
| ctx            | Terminal-owned reply state. Do not access.                                                                                                                                                                                                                                                                                                                                                     |
| reply          | Answer the read; see the struct documentation.                                                                                                                                                                                                                                                                                                                                                 |
"""
struct GhosttyClipboardRead
    location::GhosttyClipboardLocation
    mimes::Ptr{GhosttyString}
    mimes_len::Csize_t
    list::Bool
    name::GhosttyString
    granted::Bool
    can_remember::Bool
    ctx::Ptr{Cvoid}
    reply::GhosttyClipboardReadReplyFn
end

# typedef void ( * GhosttyTerminalClipboardReadFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyClipboardRead * read )
"""
Callback function type for clipboard\\_read.

Called synchronously when the running program requests clipboard contents via OSC 52 with a "?" payload or a Kitty clipboard (OSC 5522) read. Answering lets the program read the clipboard of the person using your terminal, so you are expected to mediate consent. Because the read is synchronous, an embedder that needs to ask them must block (for example by running a modal prompt) until it has an answer; the VT stream waits until the callback returns.

Answer by calling `read->reply(read, &reply)` before returning. See [`GhosttyClipboardRead`](@ref) for the full contract.

OSC 5522 requests carry the program's MIME list, name, and password grant state; a reply that sets `remember` records a session grant so later requests with the same password arrive with `granted` set. Kitty itself serves a request for only the targets listing (`list` with no `mimes`) without prompting, and embedders are expected to do the same; the terminal never consults grants for such requests (`granted` is false and one-time passwords are not consumed).

Installing this callback also enables Kitty paste events (mode 5522): [`ghostty_terminal_paste`](@ref)() sends the program an event instead of the text, and the program's follow-up read arrives here with `granted` set since the user already pasted. See [`ghostty_terminal_paste`](@ref)().

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `read`: Borrowed clipboard read request
"""
const GhosttyTerminalClipboardReadFn = Ptr{Cvoid}

"""
    GhosttyTerminalDesktopNotification

A request to show a desktop notification.

Both strings are borrowed and only valid until the callback returns. Copy them if you need them later.

This struct has a frozen layout and will never gain fields. It is 32 bytes on 64-bit targets and 16 bytes on wasm32. If a later version of libghostty-vt has more to report, it will add a new option with a new struct, and this callback will keep receiving this struct unchanged.

` effects`

| Field | Note                                                                |
| :---- | :------------------------------------------------------------------ |
| title | Notification title, or an empty string when the protocol omits it.  |
| body  | Notification body.                                                  |
"""
struct GhosttyTerminalDesktopNotification
    title::GhosttyString
    body::GhosttyString
end

# typedef void ( * GhosttyTerminalDesktopNotificationFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyTerminalDesktopNotification * notification )
"""
Callback function type for desktop notifications.

Called synchronously when the terminal receives OSC 9 or OSC 777.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `notification`: Borrowed desktop notification request
"""
const GhosttyTerminalDesktopNotificationFn = Ptr{Cvoid}

"""
    GhosttyTerminalProgressState

State of a terminal progress report.

` effects`

| Enumerator                                            | Note                                     |
| :---------------------------------------------------- | :--------------------------------------- |
| GHOSTTY\\_TERMINAL\\_PROGRESS\\_STATE\\_REMOVE        | Remove any visible progress indication.  |
| GHOSTTY\\_TERMINAL\\_PROGRESS\\_STATE\\_SET           | Show determinate progress.               |
| GHOSTTY\\_TERMINAL\\_PROGRESS\\_STATE\\_ERROR         | Show a failed progress state.            |
| GHOSTTY\\_TERMINAL\\_PROGRESS\\_STATE\\_INDETERMINATE | Show indeterminate progress.             |
| GHOSTTY\\_TERMINAL\\_PROGRESS\\_STATE\\_PAUSE         | Show paused progress.                    |
| GHOSTTY\\_TERMINAL\\_PROGRESS\\_STATE\\_MAX\\_VALUE   |                                          |
"""
@cenum GhosttyTerminalProgressState::UInt32 begin
    GHOSTTY_TERMINAL_PROGRESS_STATE_REMOVE = 0
    GHOSTTY_TERMINAL_PROGRESS_STATE_SET = 1
    GHOSTTY_TERMINAL_PROGRESS_STATE_ERROR = 2
    GHOSTTY_TERMINAL_PROGRESS_STATE_INDETERMINATE = 3
    GHOSTTY_TERMINAL_PROGRESS_STATE_PAUSE = 4
    GHOSTTY_TERMINAL_PROGRESS_STATE_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalProgressReport

A progress report emitted by the running program.

This struct has a frozen layout and will never gain fields. It is 8 bytes on every target. If a later version of libghostty-vt has more to report, it will add a new option with a new struct, and this callback will keep receiving this struct unchanged.

` effects`

| Field    | Note                                                         |
| :------- | :----------------------------------------------------------- |
| state    | Literal progress state reported by the running program.      |
| progress | Progress percentage from 0 through 100, or -1 when omitted.  |
"""
struct GhosttyTerminalProgressReport
    state::GhosttyTerminalProgressState
    progress::Int8
end

# typedef void ( * GhosttyTerminalProgressReportFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyTerminalProgressReport * report )
"""
Callback function type for progress reports.

Called synchronously when the terminal receives OSC 9;4.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `report`: Borrowed progress report
"""
const GhosttyTerminalProgressReportFn = Ptr{Cvoid}

"""
    GhosttyProgramStatusState

What a program says it is doing, in a program status report (OSC 7501).

See [`GhosttyTerminalProgramStatus`](@ref) for an overview of the protocol.

` effects`

| Enumerator                                       | Note                                                                                                                                                    |
| :----------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_IDLE        | At rest, waiting for the user's next instruction. For example, an interactive tool sitting at its own prompt.                                           |
| GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_WORKING     | Running on its own. The report may include a progress percentage.                                                                                       |
| GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_DONE        | Finished a piece of work, and the result is ready for the user to look at.                                                                              |
| GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_BLOCKED     | Can't continue until the user does something. `kind` says what the program needs and `message` says why. The report may include a progress percentage.  |
| GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_ERROR       | Failed and stopped.                                                                                                                                     |
| GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_CLEAR       | Not a real state. Remove the record with this report's id and every record beneath it. If the id is empty, remove every record.                         |
| GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_MAX\\_VALUE |                                                                                                                                                         |
"""
@cenum GhosttyProgramStatusState::UInt32 begin
    GHOSTTY_PROGRAM_STATUS_STATE_IDLE = 0
    GHOSTTY_PROGRAM_STATUS_STATE_WORKING = 1
    GHOSTTY_PROGRAM_STATUS_STATE_DONE = 2
    GHOSTTY_PROGRAM_STATUS_STATE_BLOCKED = 3
    GHOSTTY_PROGRAM_STATUS_STATE_ERROR = 4
    GHOSTTY_PROGRAM_STATUS_STATE_CLEAR = 5
    GHOSTTY_PROGRAM_STATUS_STATE_MAX_VALUE = 2147483647
end

"""
    GhosttyProgramStatusKind

What a blocked program needs from the user, in a program status report (OSC 7501).

` effects`

| Enumerator                                      | Note                                                                                      |
| :---------------------------------------------- | :---------------------------------------------------------------------------------------- |
| GHOSTTY\\_PROGRAM\\_STATUS\\_KIND\\_NONE        | The program didn't say, or the state isn't GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_BLOCKED.  |
| GHOSTTY\\_PROGRAM\\_STATUS\\_KIND\\_PERMISSION  | Approval to do something, such as "Apply these changes?".                                 |
| GHOSTTY\\_PROGRAM\\_STATUS\\_KIND\\_QUESTION    | An answer the user has to type.                                                           |
| GHOSTTY\\_PROGRAM\\_STATUS\\_KIND\\_AUTH        | A login, password, token, or other credential.                                            |
| GHOSTTY\\_PROGRAM\\_STATUS\\_KIND\\_MAX\\_VALUE |                                                                                           |
"""
@cenum GhosttyProgramStatusKind::UInt32 begin
    GHOSTTY_PROGRAM_STATUS_KIND_NONE = 0
    GHOSTTY_PROGRAM_STATUS_KIND_PERMISSION = 1
    GHOSTTY_PROGRAM_STATUS_KIND_QUESTION = 2
    GHOSTTY_PROGRAM_STATUS_KIND_AUTH = 3
    GHOSTTY_PROGRAM_STATUS_KIND_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalProgramStatus

A program status report (OSC 7501).

The program status protocol lets a program tell the terminal what it is doing: idle, working, done, waiting on the user, or failed, and why. It is meant for long-running work like builds, deploys, and coding agents, where the user is often looking at something else and wants to know when the work finishes or needs them. The protocol only describes state. How to show it, if at all, is up to your application.

The full specification is at https://www.superlogical.com/rex/docs/build/program-status

For example, a program waiting for the user to approve a change sends this, where ST is the string terminator (ESC \\ or BEL):

```c++
 ESC ] 7501 ; state=blocked:kind=permission:app=terraform:msg=QXBwbHk/ ST
```

The callback then receives a report with:

- `state`: GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_BLOCKED - `kind`: GHOSTTY\\_PROGRAM\\_STATUS\\_KIND\\_PERMISSION - `progress`: -1, because the program didn't send one, so the work is indeterminate - `id`: empty, because this is the root record - `app`: "terraform" - `title`: empty - `message`: "Apply?", decoded from the base64 in `msg`

Only reports that pass every check in the specification reach the callback. Text that the program didn't send is an empty string (len=0), never NULL. All strings are only valid during the callback, so copy any you want to keep.

This struct has a frozen layout and will never gain fields. It is 80 bytes on 64-bit targets and 44 bytes on wasm32. If a later version of libghostty-vt has more to report, it will add a new option with a new struct, and this callback will keep receiving this struct unchanged.

` effects`

| Field    | Note                                                                                                                                                                                                                                                                                                                                                                                           |
| :------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| state    | What the program is doing.                                                                                                                                                                                                                                                                                                                                                                     |
| kind     | What the program needs from the user. Only set for GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_BLOCKED. It is GHOSTTY\\_PROGRAM\\_STATUS\\_KIND\\_NONE for other states, when the program didn't say, or when it sent a kind this version doesn't know.                                                                                                                                               |
| progress | How far along the work is, from 0 through 100, or -1 when there is no percentage. Only set for GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_WORKING and GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_BLOCKED. For those states, -1 means the work is indeterminate: the program is busy but has no percentage to report. It is also -1 for other states and when the program sent a value outside that range.  |
| id       | Which record this report is about. Empty for the root record.  A program that only reports on itself leaves this empty. A program that reports on several things at once gives each its own id, such as "us-east" and "eu-west" for a deploy to two regions. A "/" makes one record the child of another, so "build/test" is a child of "build". The parent record doesn't have to exist.      |
| app      | A stable name for the program that a machine can match on, such as "cargo", "terraform", or "claude-code". Use it as a key for grouping, filtering, or choosing an icon. It is not a label. The label is `title`. Empty when the report didn't include one. See [`GhosttyTerminalProgramStatusFn`](@ref) for how an empty app is filled in from a parent record.                               |
| title    | A short label for the record, meant for people. Programs that report several records use this to tell them apart.                                                                                                                                                                                                                                                                              |
| message  | One line of text for people, saying what the record is doing, waiting for, or has finished. You may shorten it to fit, but don't try to read meaning into it.                                                                                                                                                                                                                                  |
"""
struct GhosttyTerminalProgramStatus
    state::GhosttyProgramStatusState
    kind::GhosttyProgramStatusKind
    progress::Int8
    id::GhosttyString
    app::GhosttyString
    title::GhosttyString
    message::GhosttyString
end

# typedef void ( * GhosttyTerminalProgramStatusFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyTerminalProgramStatus * report )
"""
Callback function type for program status reports (OSC 7501).

Called synchronously each time the running program sends a valid report. See [`GhosttyTerminalProgramStatus`](@ref) for what a report contains.

The terminal doesn't store reports, so your application keeps them. To follow the specification, keep one record per id. A report with an empty id is about the root record, the program itself. The records follow these rules:

- A report replaces its record completely. A value the report leaves out is gone from the record afterwards. It doesn't keep its old value. - A GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_CLEAR report removes the record with its id and every record beneath it, so clearing "build" also removes "build/test". A clear report with an empty id removes every record. - A record without an app takes it from its nearest ancestor that has one. If the root record has app "deploy" and the record "us-east" has none, show "us-east" with app "deploy" too. - When a new shell prompt starts (GHOSTTY\\_SEMANTIC\\_PROMPT\\_PROMPT\\_START from the GHOSTTY\\_TERMINAL\\_OPT\\_SEMANTIC\\_PROMPT callback) or the program running in the terminal exits, remove `working` and `blocked` records. You may remove `idle` records too. Keep `done` and `error` records until the user has seen them, for example until they next focus the terminal. - Keep at most 256 records, and allow at least 64. When a new record would go over your limit, remove the one that was updated longest ago.

A full reset (RIS, `ESC c`) removes every record. When that happens, the terminal calls this with a GHOSTTY\\_PROGRAM\\_STATUS\\_STATE\\_CLEAR report and an empty id, and then calls the GHOSTTY\\_TERMINAL\\_OPT\\_RESET callback.

`title` and `message` are already decoded and contain no control characters, but they are still untrusted text from the program. Don't treat them as markup. If you show them outside the terminal, such as in a tab or a notification, remove invisible formatting characters like text direction overrides, and say which terminal the text came from so a program can't pretend to be one running elsewhere.

Example, where `Records`, `records_clear`, and `records_put` stand in for your application's own storage:

```c++
 void on_program_status(GhosttyTerminal terminal,
                        void* userdata,
                        const GhosttyTerminalProgramStatus* report) {
   (void)terminal;
   Records* records = userdata;

   if (report->state == GHOSTTY_PROGRAM_STATUS_STATE_CLEAR) {
     // Remove this record and every record beneath it. An empty id
     // removes every record.
     records_clear(records, report->id);
     return;
   }

   // Replace the whole record. The strings are only valid during this
   // call, so records_put must copy them.
   records_put(records, report->id, report->state, report->message);
 }

 // Set write_pty too, so programs that check for support get a reply.
 ghostty_terminal_set(terminal, GHOSTTY_TERMINAL_OPT_USERDATA, records);
 ghostty_terminal_set(terminal, GHOSTTY_TERMINAL_OPT_WRITE_PTY,
                      (const void*)on_write_pty);
 ghostty_terminal_set(terminal, GHOSTTY_TERMINAL_OPT_PROGRAM_STATUS,
                      (const void*)on_program_status);
```

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `report`: The report. It and its strings are only valid during the call.
"""
const GhosttyTerminalProgramStatusFn = Ptr{Cvoid}

"""
    GhosttySemanticPromptKind

The step of a command that a shell integration event reports.

More kinds may be added in later versions, so ignore any kind you don't handle.

` effects`

| Enumerator                                   | Note                                                                                                                       |
| :------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_INVALID        | Never reported. This exists so that a zeroed value is not mistaken for a real event.                                       |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_PROMPT\\_START | The shell started drawing a prompt. `prompt_kind` says which one.                                                          |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_INPUT\\_START  | The prompt is drawn and the user can start typing a command.                                                               |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_OUTPUT\\_START | The user submitted the command and it started running. Anything the terminal receives after this is the command's output.  |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_COMMAND\\_END  | The command finished running.                                                                                              |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_MAX\\_VALUE    |                                                                                                                            |
"""
@cenum GhosttySemanticPromptKind::UInt32 begin
    GHOSTTY_SEMANTIC_PROMPT_INVALID = 0
    GHOSTTY_SEMANTIC_PROMPT_PROMPT_START = 1
    GHOSTTY_SEMANTIC_PROMPT_INPUT_START = 2
    GHOSTTY_SEMANTIC_PROMPT_OUTPUT_START = 3
    GHOSTTY_SEMANTIC_PROMPT_COMMAND_END = 4
    GHOSTTY_SEMANTIC_PROMPT_MAX_VALUE = 2147483647
end

"""
    GhosttySemanticPromptPromptKind

Which prompt a `GHOSTTY_SEMANTIC_PROMPT_PROMPT_START` event starts.

Most shells only draw a primary prompt. Some also draw a prompt on the right side of the line, or a prompt at the start of each extra line when a command spans several lines.

` effects`

| Enumerator                                          | Note                                                                                                                                                                                                       |
| :-------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_PROMPT\\_PRIMARY      | The main prompt shown before each command. This is used when the shell doesn't say which prompt it is drawing.                                                                                             |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_PROMPT\\_RIGHT        | A prompt drawn at the right edge of the line, such as zsh's RPROMPT.                                                                                                                                       |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_PROMPT\\_CONTINUATION | A prompt at the start of an extra line of a command that spans several lines.                                                                                                                              |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_PROMPT\\_SECONDARY    | Another prompt for an extra line of input, such as bash's PS2. Shells differ in whether they report extra lines as continuation or secondary prompts, so most applications should treat the two the same.  |
| GHOSTTY\\_SEMANTIC\\_PROMPT\\_PROMPT\\_MAX\\_VALUE  |                                                                                                                                                                                                            |
"""
@cenum GhosttySemanticPromptPromptKind::UInt32 begin
    GHOSTTY_SEMANTIC_PROMPT_PROMPT_PRIMARY = 0
    GHOSTTY_SEMANTIC_PROMPT_PROMPT_RIGHT = 1
    GHOSTTY_SEMANTIC_PROMPT_PROMPT_CONTINUATION = 2
    GHOSTTY_SEMANTIC_PROMPT_PROMPT_SECONDARY = 3
    GHOSTTY_SEMANTIC_PROMPT_PROMPT_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalSemanticPrompt

A shell integration event, passed to the `GHOSTTY_TERMINAL_OPT_SEMANTIC_PROMPT` callback.

`kind` says which step of the command this is. The other fields only carry information for the kinds listed on each field, and are zero or empty otherwise.

Strings are only valid during the callback. Copy them if you need them later.

This struct has a frozen layout and will never gain fields. It is 48 bytes on 64-bit targets and 32 bytes on wasm32. If a later version of libghostty-vt has more to report, it will add a new option with a new struct, and this callback will keep receiving this struct unchanged.

Two fields are likely to be added this way in the future:

- An identifier the shell assigns to each command. - A flag on `GHOSTTY_SEMANTIC_PROMPT_PROMPT_START` that says the shell redrew a prompt it had already drawn, instead of starting a new one.

Neither exists yet.

` effects`

| Field             | Note                                                                                                                                                                                                                  |
| :---------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| kind              | Which step of the command this event reports.                                                                                                                                                                         |
| prompt\\_kind     | Which prompt is starting. Set for `GHOSTTY_SEMANTIC_PROMPT_PROMPT_START`. Always `GHOSTTY_SEMANTIC_PROMPT_PROMPT_PRIMARY` for other kinds.                                                                            |
| has\\_exit\\_code | True if the shell reported the command's exit code. Only ever true for `GHOSTTY_SEMANTIC_PROMPT_COMMAND_END`.                                                                                                         |
| exit\\_code       | The command's exit code. Only meaningful when `has_exit_code` is true. Exit codes can be negative, for example on Windows, so use `has_exit_code` rather than a special value to tell whether one was reported.       |
| command           | The command line that is about to run, for `GHOSTTY_SEMANTIC_PROMPT_OUTPUT_START`. The shell sends it encoded, and this is the decoded text. Empty (len=0) if the shell didn't send one or it couldn't be decoded.    |
| error             | A description of what went wrong, for `GHOSTTY_SEMANTIC_PROMPT_COMMAND_END` when the shell sent one. Empty (len=0) otherwise. Few shells send this. The exit code is the usual way to tell whether a command failed.  |
"""
struct GhosttyTerminalSemanticPrompt
    kind::GhosttySemanticPromptKind
    prompt_kind::GhosttySemanticPromptPromptKind
    has_exit_code::Bool
    exit_code::Int32
    command::GhosttyString
    error::GhosttyString
end

# typedef void ( * GhosttyTerminalSemanticPromptFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyTerminalSemanticPrompt * event )
"""
Callback function type for semantic\\_prompt.

Called when the shell reports a step of a command. Each command goes through four steps, in this order: the prompt starts, input starts, output starts, and the command ends. Then the next prompt starts.

Shells differ in what they report. Many don't send the command line or the exit code, and some skip steps, so handle each event on its own instead of expecting a strict order. A shell may also start the same prompt more than once, for example when it redraws the prompt after a resize, so treat a repeated `GHOSTTY_SEMANTIC_PROMPT_PROMPT_START` as harmless.

The terminal has already updated its screen when this is called. A sequence the terminal rejects as malformed is never reported.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `event`: The event. It and its strings are only valid during the call.
"""
const GhosttyTerminalSemanticPromptFn = Ptr{Cvoid}

# typedef void ( * GhosttyTerminalResetFn ) ( GhosttyTerminal terminal , void * userdata )
"""
Callback function type for reset.

Called when the running program performs a full reset (RIS, `ESC c`). A full reset clears the screen and scrollback, returns modes to their defaults, and clears the title and working directory. Use this callback to reset any state your application keeps about what's running in the terminal, such as the current command.

The terminal has already reset itself when this is called. The GHOSTTY\\_TERMINAL\\_OPT\\_TITLE\\_CHANGED and GHOSTTY\\_TERMINAL\\_OPT\\_PWD\\_CHANGED callbacks are not called for the cleared title and working directory, so update anything you show for them here. A full reset also removes any progress report and program status records. If you set GHOSTTY\\_TERMINAL\\_OPT\\_PROGRESS\\_REPORT or GHOSTTY\\_TERMINAL\\_OPT\\_PROGRAM\\_STATUS, those callbacks are called before this one.

A soft reset (DECSTR, `CSI ! p`) keeps the screen, title and working directory, and doesn't call this.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
"""
const GhosttyTerminalResetFn = Ptr{Cvoid}

"""
    GhosttyTerminalResizeWindowTag

The kind of window resize request passed to a [`GhosttyTerminalResizeWindowFn`](@ref) callback.

New kinds may be added in later versions. Callbacks should ignore any tag they don't handle.

` effects`

| Enumerator                                         | Note                                                                                                                   |
| :------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_RESIZE\\_WINDOW\\_GRID        | Resize the window's text area to a size in rows and columns (CSI 8 ; rows ; columns t). The value is in `value.grid`.  |
| GHOSTTY\\_TERMINAL\\_RESIZE\\_WINDOW\\_MAX\\_VALUE |                                                                                                                        |
"""
@cenum GhosttyTerminalResizeWindowTag::UInt32 begin
    GHOSTTY_TERMINAL_RESIZE_WINDOW_GRID = 0
    GHOSTTY_TERMINAL_RESIZE_WINDOW_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalResizeWindowGrid

A request to resize the window's text area to a size in rows and columns.

` effects`

| Field   | Note                                                         |
| :------ | :----------------------------------------------------------- |
| rows    | Requested height in rows, or 0 to keep the current height.   |
| columns | Requested width in columns, or 0 to keep the current width.  |
"""
struct GhosttyTerminalResizeWindowGrid
    rows::UInt16
    columns::UInt16
end

"""
    GhosttyTerminalResizeWindowValue

Window resize request value.

` effects`
"""
struct GhosttyTerminalResizeWindowValue
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyTerminalResizeWindowValue}, f::Symbol)
    f === :grid && return Ptr{GhosttyTerminalResizeWindowGrid}(x + 0)
    f === :_padding && return Ptr{NTuple{2, UInt64}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyTerminalResizeWindowValue, f::Symbol)
    r = Ref{GhosttyTerminalResizeWindowValue}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyTerminalResizeWindowValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyTerminalResizeWindowValue}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyTerminalResizeWindowValue, private::Bool = false)
    (:grid, :_padding, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttyTerminalResizeWindow

A request from the running program to resize the window.

` effects`
"""
struct GhosttyTerminalResizeWindow
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{GhosttyTerminalResizeWindow}, f::Symbol)
    f === :tag && return Ptr{GhosttyTerminalResizeWindowTag}(x + 0)
    f === :value && return Ptr{GhosttyTerminalResizeWindowValue}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttyTerminalResizeWindow, f::Symbol)
    r = Ref{GhosttyTerminalResizeWindow}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttyTerminalResizeWindow}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttyTerminalResizeWindow}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttyTerminalResizeWindow, private::Bool = false)
    (:tag, :value, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

# typedef void ( * GhosttyTerminalResizeWindowFn ) ( GhosttyTerminal terminal , void * userdata , const GhosttyTerminalResizeWindow * request )
"""
Callback function type for window resize requests.

Called synchronously when the running program asks to resize the window, such as with CSI 8 ; rows ; columns t. Check `request->tag` first, because more kinds of requests may be reported in later versions. The terminal is not resized by this: you decide whether to allow the request, and if so resizes its window and the terminal. Letting any program resize the window is a nuisance at best, so consider making this opt-in for users.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `request`: Borrowed resize request
"""
const GhosttyTerminalResizeWindowFn = Ptr{Cvoid}

# typedef bool ( * GhosttyTerminalColorSchemeFn ) ( GhosttyTerminal terminal , void * userdata , GhosttyColorScheme * out_scheme )
"""
Callback function type for color scheme queries (CSI ? 996 n).

Called when the terminal receives a color scheme device status report query. Return true and fill *out\\_scheme with the current color scheme, or return false to silently ignore the query.

The library sets *out\\_scheme to GHOSTTY\\_COLOR\\_SCHEME\\_LIGHT (zero) before the call, so returning true without writing it reports light. If the callback writes a value that isn't a [`GhosttyColorScheme`](@ref), the library ignores the query, the same as if the callback returned false.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `out_scheme`:\\[out\\] Pointer to store the current color scheme
# Returns
true if the color scheme was filled, false to ignore the query
"""
const GhosttyTerminalColorSchemeFn = Ptr{Cvoid}

# typedef bool ( * GhosttyTerminalDeviceAttributesFn ) ( GhosttyTerminal terminal , void * userdata , GhosttyDeviceAttributes * out_attrs )
"""
Callback function type for device attributes queries (DA1/DA2/DA3).

Called when the terminal receives a device attributes query (CSI c, CSI > c, or CSI = c). Return true and fill *out\\_attrs with the response data, or return false to answer with the library's default attributes, which GHOSTTY\\_TERMINAL\\_OPT\\_DEVICE\\_ATTRIBUTES describes.

The terminal uses whichever sub-struct (primary, secondary, tertiary) matches the request type, but all three should be filled for simplicity.

The library zeroes *out\\_attrs before the call, so you only need to set the fields you want to report. Every field you leave alone is reported as zero. This callback reports a VT220 with color and clipboard support, and leaves the tertiary unit ID at zero:

```c++
 static bool on_device_attributes(GhosttyTerminal terminal,
                                  void* userdata,
                                  GhosttyDeviceAttributes* out_attrs) {
   out_attrs->primary.conformance_level = GHOSTTY_DA_CONFORMANCE_VT220;
   out_attrs->primary.features[0] = GHOSTTY_DA_FEATURE_ANSI_COLOR;
   out_attrs->primary.features[1] = GHOSTTY_DA_FEATURE_CLIPBOARD;
   out_attrs->primary.num_features = 2;
   out_attrs->secondary.device_type = GHOSTTY_DA_DEVICE_TYPE_VT220;
   return true;
 }
```

[`GhosttyDeviceAttributes`](@ref) is frozen. If a later version of libghostty-vt needs more fields, it adds a new callback typedef and a new option key, and keeps calling this callback with [`GhosttyDeviceAttributes`](@ref) forever. A callback written against this header keeps working with every later version of the library.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `out_attrs`:\\[out\\] Pointer to store the device attributes response
# Returns
true if attributes were filled, false to use the defaults
"""
const GhosttyTerminalDeviceAttributesFn = Ptr{Cvoid}

# typedef GhosttyString ( * GhosttyTerminalEnquiryFn ) ( GhosttyTerminal terminal , void * userdata )
"""
Callback function type for enquiry (ENQ, 0x05).

Called when the terminal receives an ENQ character. Return the response bytes as a [`GhosttyString`](@ref). The memory must remain valid until the callback returns. Return a zero-length string to send no response.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
# Returns
The response bytes to write back to the pty
"""
const GhosttyTerminalEnquiryFn = Ptr{Cvoid}

# typedef bool ( * GhosttyTerminalSizeFn ) ( GhosttyTerminal terminal , void * userdata , GhosttySizeReportSize * out_size )
"""
Callback function type for terminal size reports.

Called in response to XTWINOPS size queries (CSI 14/16/18/19 t) and when VT input enables in-band size reports (mode 2048). Return true and fill *out\\_size with the current terminal geometry, or return false to suppress the report.

The library zeroes *out\\_size before the call, so any field you don't write reads as zero. A typical callback copies the geometry from your own window state, passed in through GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA:

```c++
 static bool on_size(GhosttyTerminal terminal,
                     void* userdata,
                     GhosttySizeReportSize* out_size) {
   const MyWindow* window = userdata;
   out_size->rows = window->rows;
   out_size->columns = window->columns;
   out_size->cell_width = window->cell_width;
   out_size->cell_height = window->cell_height;
   return true;
 }
```

[`GhosttySizeReportSize`](@ref) is frozen. If a later version of libghostty-vt needs more fields, it adds a new callback typedef and a new option key, and keeps calling this callback with [`GhosttySizeReportSize`](@ref) forever. A callback written against this header keeps working with every later version of the library.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `out_size`:\\[out\\] Pointer to store the terminal size information
# Returns
true if size was filled, false to suppress the XTWINOPS response or mode 2048 report
"""
const GhosttyTerminalSizeFn = Ptr{Cvoid}

# typedef void ( * GhosttyTerminalTitleChangedFn ) ( GhosttyTerminal terminal , void * userdata )
"""
Callback function type for title\\_changed.

Called when the terminal title changes via escape sequences (e.g. OSC 0 or OSC 2). Use [`ghostty_terminal_get`](@ref)() with GHOSTTY\\_TERMINAL\\_DATA\\_TITLE inside the callback to read the new value.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
"""
const GhosttyTerminalTitleChangedFn = Ptr{Cvoid}

# typedef void ( * GhosttyTerminalRenderHoldFn ) ( GhosttyTerminal terminal , void * userdata , bool held )
"""
Callback function type for render\\_hold.

Called when the running program asks the terminal to stop updating the screen, and again when it lets the screen update again. We call the time in between a "render hold". See guide-rendering-holds for what to do about one.

`held` is true when the program sets mode 2026 ([`GHOSTTY_MODE_SYNCHRONIZED_OUTPUT`](@ref)), which is the only way to start a hold today.

`held` is false when the hold ends, which happens when:

- the program resets mode 2026 - the terminal is fully reset, by the program (RIS) or by [`ghostty_terminal_reset`](@ref)() - the terminal is resized with [`ghostty_terminal_resize`](@ref)()

The two calls always come in pairs. Setting the mode while a hold is already active does nothing, and neither does resetting it when there is no hold. Changing the mode yourself with GHOSTTY\\_TERMINAL\\_OPT\\_MODE never invokes the callback.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `held`: True when a hold begins, false when it ends
"""
const GhosttyTerminalRenderHoldFn = Ptr{Cvoid}

# typedef void ( * GhosttyTerminalPwdChangedFn ) ( GhosttyTerminal terminal , void * userdata )
"""
Callback function type for pwd\\_changed.

Called when the terminal pwd (current working directory) changes via escape sequences: OSC 7 (file:// URI), OSC 9 (ConEmu CurrentDir), or OSC 1337 CurrentDir (iTerm2). Use [`ghostty_terminal_get`](@ref)() with GHOSTTY\\_TERMINAL\\_DATA\\_PWD inside the callback to read the new value.

The terminal stores whatever bytes the shell emitted, without parsing. That means for OSC 7 the value is the raw URI (typically file://...); for OSC 9/OSC 1337 it is typically a bare path. You are responsible for decoding any URI scheme or host if it cares about them.

The callback also fires when the shell clears the pwd (e.g. an empty OSC 7). In that case GHOSTTY\\_TERMINAL\\_DATA\\_PWD returns a zero-length string.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
"""
const GhosttyTerminalPwdChangedFn = Ptr{Cvoid}

# typedef void ( * GhosttyTerminalWritePtyFn ) ( GhosttyTerminal terminal , void * userdata , const uint8_t * data , size_t len )
"""
Callback function type for write\\_pty.

Called when the terminal needs to write data back to the pty, for example in response to a device status report, mode query, or VT-driven mode 2048 enable. The data is only valid for the duration of the call; you must copy it if it needs to persist.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
* `data`: Pointer to the response bytes
* `len`: Length of the response in bytes
"""
const GhosttyTerminalWritePtyFn = Ptr{Cvoid}

# typedef GhosttyString ( * GhosttyTerminalXtversionFn ) ( GhosttyTerminal terminal , void * userdata )
"""
Callback function type for XTVERSION.

Called when the terminal receives an XTVERSION query (CSI > q). Return the version string (e.g. "myterm 1.0") as a [`GhosttyString`](@ref). The memory must remain valid until the callback returns. Return a zero-length string to report the default "libghostty" version.

` effects`

# Arguments
* `terminal`: The terminal handle
* `userdata`: The userdata pointer set via GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA
# Returns
The version string to report
"""
const GhosttyTerminalXtversionFn = Ptr{Cvoid}

"""
    GhosttyTerminalModeConfig

A terminal mode and boolean value used for mode configuration and queries.

For GHOSTTY\\_TERMINAL\\_DATA\\_MODE, initialize `mode` before calling [`ghostty_terminal_get`](@ref)(). On success, `value` contains the current mode value.

This struct has a frozen layout and will not gain fields in future versions.

` terminal`

| Field | Note                                                     |
| :---- | :------------------------------------------------------- |
| mode  | Mode to configure or query.                              |
| value | Value to set, or the current value returned by a query.  |
"""
struct GhosttyTerminalModeConfig
    mode::GhosttyMode
    value::Bool
end

"""
    GhosttyTerminalOption

Terminal option identifiers.

These values are used with [`ghostty_terminal_set`](@ref)() to configure terminal callbacks and associated state.

` terminal`

| Enumerator                                                       | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| :--------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_OPT\\_INVALID                               | Not a real option. [`ghostty_terminal_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_USERDATA                              | Opaque userdata pointer passed to all callbacks. NULL by default.  Input type: void*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_TERMINAL\\_OPT\\_WRITE\\_PTY                           | Callback invoked when the terminal needs to write data back to the pty (e.g. in response to a DECRQM query, device status report, or VT-driven mode 2048 enable). Set to NULL to ignore such sequences.  Input type: [`GhosttyTerminalWritePtyFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_BELL                                  | Callback invoked when the terminal receives a BEL character (0x07). Set to NULL to ignore bell events.  Input type: [`GhosttyTerminalBellFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_TERMINAL\\_OPT\\_ENQUIRY                               | Callback invoked when the terminal receives an ENQ character (0x05). Set to NULL to send no response.  Input type: [`GhosttyTerminalEnquiryFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_OPT\\_XTVERSION                             | Callback invoked when the terminal receives an XTVERSION query (CSI > q). Set to NULL to report the default "libghostty" string.  Input type: [`GhosttyTerminalXtversionFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_TERMINAL\\_OPT\\_TITLE\\_CHANGED                       | Callback invoked when the terminal title changes via escape sequences (e.g. OSC 0 or OSC 2). Set to NULL to ignore title change events.  Input type: [`GhosttyTerminalTitleChangedFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_TERMINAL\\_OPT\\_SIZE                                  | Callback invoked in response to XTWINOPS size queries (CSI 14/16/18/19 t). Set to NULL to silently ignore size queries.  Input type: [`GhosttyTerminalSizeFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_TERMINAL\\_OPT\\_COLOR\\_SCHEME                        | Callback invoked in response to a color scheme device status report query (CSI ? 996 n). Return true and fill the out pointer to report the current scheme, or return false to silently ignore. Set to NULL to ignore color scheme queries.  Input type: [`GhosttyTerminalColorSchemeFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_TERMINAL\\_OPT\\_DEVICE\\_ATTRIBUTES                   | Callback invoked in response to a device attributes query (CSI c, CSI > c, or CSI = c). Return true and fill the out pointer with response data, or return false to answer with the library's default attributes.  Set to NULL to answer with the library's default attributes (a VT220 with ANSI color). The default replies are CSI ? 62 ; 22 c to CSI c, CSI > 1 ; 0 ; 0 c to CSI > c, and DCS ! | 00000000 ST to CSI = c.  Input type: [`GhosttyTerminalDeviceAttributesFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_OPT\\_TITLE                                 | Set the terminal title manually.  The string data is copied into the terminal. A NULL value pointer clears the title (equivalent to setting an empty string).  Input type: [`GhosttyString`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_TERMINAL\\_OPT\\_PWD                                   | Set the terminal working directory manually.  The string data is copied into the terminal. A NULL value pointer clears the pwd (equivalent to setting an empty string).  Input type: [`GhosttyString`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_TERMINAL\\_OPT\\_COLOR\\_FOREGROUND                    | Set the default foreground color.  A NULL value pointer clears the default (unset).  Input type: [`GhosttyColorRgb`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| GHOSTTY\\_TERMINAL\\_OPT\\_COLOR\\_BACKGROUND                    | Set the default background color.  A NULL value pointer clears the default (unset).  Input type: [`GhosttyColorRgb`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| GHOSTTY\\_TERMINAL\\_OPT\\_COLOR\\_CURSOR                        | Set the default cursor color.  A NULL value pointer clears the default (unset).  Input type: [`GhosttyColorRgb`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_OPT\\_COLOR\\_PALETTE                       | Set the default 256-color palette.  The value must point to an array of exactly 256 [`GhosttyColorRgb`](@ref) values. A NULL value pointer resets to the built-in default palette.  Input type: [`GhosttyColorRgb`](@ref)[256]*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_TERMINAL\\_OPT\\_KITTY\\_IMAGE\\_STORAGE\\_LIMIT       | Set the Kitty image storage limit in bytes.  Applied to all initialized screens (primary and alternate). A value of zero disables the Kitty graphics protocol entirely, deleting all stored images and placements. The default is 10 MB (10,000,000 bytes), and a NULL value pointer restores it. Values too large for the platform's address space are treated as the largest possible limit. [`ghostty_terminal_set`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this option when Kitty graphics are disabled at build time.  Input type: uint64\\_t*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_OPT\\_KITTY\\_IMAGE\\_MEDIUM\\_FILE         | Enable or disable Kitty image loading via the file medium.  Disabled by default, and a NULL value pointer disables it again. [`ghostty_terminal_set`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this option when Kitty graphics are disabled at build time.  Input type: bool*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_TERMINAL\\_OPT\\_KITTY\\_IMAGE\\_MEDIUM\\_TEMP\\_FILE  | Enable Kitty image loading via the temporary file medium, restricted to the provided directory. The string data is copied into the terminal.  Disabled by default, and a NULL value pointer disables it again. [`ghostty_terminal_set`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this option when Kitty graphics are disabled at build time.  Input type: [`GhosttyString`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_TERMINAL\\_OPT\\_KITTY\\_IMAGE\\_MEDIUM\\_SHARED\\_MEM | Enable or disable Kitty image loading via the shared memory medium.  Disabled by default, and a NULL value pointer disables it again. [`ghostty_terminal_set`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this option when Kitty graphics are disabled at build time.  Input type: bool*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_OPT\\_APC\\_MAX\\_BYTES                     | Set the maximum bytes the APC handler will buffer for all protocols. This prevents malicious input from causing unbounded memory allocation. A NULL value pointer removes all overrides, reverting to the built-in defaults.  Input type: size\\_t*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_TERMINAL\\_OPT\\_APC\\_MAX\\_BYTES\\_KITTY             | Set the maximum bytes the APC handler will buffer for Kitty graphics protocol data. A NULL value pointer removes the override, reverting to the built-in default.  Input type: size\\_t*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_SELECTION                             | Set the active screen selection.  The value must point to a [`GhosttySelection`](@ref) whose grid references are valid for this terminal's active screen at the time of the call. The terminal copies the selection immediately and converts it to terminal-owned tracked state, so the [`GhosttySelection`](@ref) struct and its untracked grid references do not need to outlive this call.  Passing NULL clears the active screen selection.  Input type: [`GhosttySelection`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_DEFAULT\\_CURSOR\\_STYLE              | Set the default cursor style used by DECSCUSR reset (CSI 0 q).  A NULL value pointer resets to the built-in default block cursor.  Input type: [`GhosttyCursorStyle`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_TERMINAL\\_OPT\\_DEFAULT\\_CURSOR\\_BLINK              | Set whether the default cursor should blink when reset by DECSCUSR (CSI 0 q).  A NULL value pointer resets to the built-in default of not blinking.  Input type: bool*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_OPT\\_GLYPH\\_PROTOCOL                      | Enable or disable Glyph Protocol APC handling.  When disabled, Glyph Protocol APC sequences are ignored and no support/query/register/clear responses are emitted. Disabling also clears the terminal session's glyph glossary.  Disabled by default, and a NULL value pointer disables it again. An application opts in because registered glyphs change what the terminal draws.  Input type: bool*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_OPT\\_PWD\\_CHANGED                         | Callback invoked when the terminal pwd changes via escape sequences (OSC 7, OSC 9, or OSC 1337 CurrentDir). Set to NULL to ignore pwd change events.  Input type: [`GhosttyTerminalPwdChangedFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_OPT\\_CLIPBOARD\\_WRITE                     | Callback invoked when the running program performs a clipboard write. OSC 52, iTerm2 OSC 1337 Copy, and Kitty clipboard (OSC 5522) writes are normalized to an atomic set of decoded MIME representations. Set to NULL to ignore clipboard writes (Kitty clipboard writes are then refused with ENOSYS). Clipboard read requests are delivered to GHOSTTY\\_TERMINAL\\_OPT\\_CLIPBOARD\\_READ instead.  Input type: [`GhosttyTerminalClipboardWriteFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_TERMINAL\\_OPT\\_SCROLLBACK\\_MAX\\_BYTES              | Set the maximum scrollback allocation in bytes.  This is an estimate. Internally, libghostty only prunes bytes up  to a "page"-granularity. A page is the minimum allocated unit of grid space within Ghostty. A page at the time of writing these docs is about 400KB, so the byte limit will be within this delta.  This works alongside the line limit configuration. If both are set, the first-reached limit is used first. Both limits are dependent on external state (byte limit can be reached with less lines if more styles are used for example, line limit can be reached with a narrower terminal viewport). So, they are useful together.  Lowering the limit immediately removes eligible complete historical pages. A value of zero disables scrollback and erases retained history.  The default is 10,000 bytes. Because history is kept in whole pages, this is rounded up to one page in practice. Pass SIZE\\_MAX for no byte limit, or NULL to restore the default:  ```c++ {.c}  size_t unlimited = SIZE_MAX;  ghostty_terminal_set(terminal,      GHOSTTY_TERMINAL_OPT_SCROLLBACK_MAX_BYTES, &unlimited);   // Back to the default of 10,000 bytes.  ghostty_terminal_set(terminal,      GHOSTTY_TERMINAL_OPT_SCROLLBACK_MAX_BYTES, NULL); ```  Input type: size\\_t*  |
| GHOSTTY\\_TERMINAL\\_OPT\\_SCROLLBACK\\_MAX\\_LINES              | Set the maximum number of physical lines retained in scrollback.  This is an estimate. Internally, libghostty only prunes lines up  to a "page"-granularity. A page is the minimum allocated unit of grid space within Ghostty. As a result, the actual available scrollback lines will almost always be higher than configured. The magnitude  of the difference depends on the number of used styles, graphemes, etc. since the row-count in a page is dynamic based on that. In general, it ranges from dozens to a hundred or so lines.  This works alongside the line limit configuration. If both are set, the first-reached limit is used first. Both limits are dependent on external state (byte limit can be reached with less lines if more styles are used for example, line limit can be reached with a narrower terminal viewport). So, they are useful together.  Lowering the limit immediately removes eligible complete historical pages.  There is no line limit by default. Pass SIZE\\_MAX or NULL to remove a line limit you set earlier.  Input type: size\\_t*                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_OPT\\_DESKTOP\\_NOTIFICATION                | Callback invoked when the running program requests a desktop notification via OSC 9 or OSC 777. Set to NULL to ignore desktop notification requests.  Input type: [`GhosttyTerminalDesktopNotificationFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_TERMINAL\\_OPT\\_PROGRESS\\_REPORT                     | Callback invoked when the running program reports progress via OSC 9;4. Set to NULL to ignore progress reports.  Input type: [`GhosttyTerminalProgressReportFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_OPT\\_CONTINUATION\\_MAX\\_BYTES            | Set the maximum number of replay-safe VT continuation bytes retained.  Continuation bytes reconstruct an escape sequence or UTF-8 codepoint which was unfinished at the end of the most recent VT write call. They are used automatically by terminal snapshots and may also be exported directly with the continuation APIs.  Tracking is disabled by default. A nonzero value enables tracking and sets its byte limit. Passing NULL or a pointer to zero disables tracking. Lowering the limit below an already-retained continuation, or enabling tracking while the parser is already unfinished, makes the current continuation unavailable because earlier bytes cannot be reconstructed. Tracking recovers automatically after a later write reaches the ground state or contains a fresh replay start.  Input type: size\\_t*                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_OPT\\_TITLE\\_REPORT                        | Enable window title reports in response to CSI 21 t.  This is disabled by default because a running program can set a title and query it back into the pty input stream, potentially injecting commands that execute after user interaction. Passing NULL or a pointer to false disables title reporting.  Input type: bool*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_TERMINAL\\_OPT\\_MODE\\_DEFAULT                        | Set the reset default for a terminal mode.  This unconditionally updates both the current value and the value restored by a terminal reset. RIS restores every mode, and DECSTR only a subset.  Some recognized modes represent transitions or mirror additional terminal state and cannot safely be configured as reset defaults. Those modes return GHOSTTY\\_INVALID\\_VALUE. A NULL value pointer also returns GHOSTTY\\_INVALID\\_VALUE.  Input type: [`GhosttyTerminalModeConfig`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_TERMINAL\\_OPT\\_MODE                                  | Set the current value of a terminal mode.  This does not change the value restored by a reset (RIS or DECSTR). A NULL value pointer or unknown mode returns GHOSTTY\\_INVALID\\_VALUE.  Input type: [`GhosttyTerminalModeConfig`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_UNKNOWN\\_SEQUENCE                    | Callback for escape sequences that libghostty-vt does not implement. Set to NULL to stop receiving them.  GHOSTTY\\_TERMINAL\\_OPT\\_UNKNOWN\\_MAX\\_BYTES must also be set, or the callback is never called. See guide-custom-sequences-unknown for an example.  Input type: [`GhosttyTerminalUnknownSequenceFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_UNKNOWN\\_MAX\\_BYTES                 | The most bytes of each unsupported sequence to keep and pass to the GHOSTTY\\_TERMINAL\\_OPT\\_UNKNOWN\\_SEQUENCE callback. The same limit applies to APC and OSC sequences.  Zero, the default, turns unsupported sequence reporting off. A NULL value pointer also sets it to zero.  A sequence longer than the limit is still reported. Its content holds the first bytes up to the limit, and `truncated` is true.  Choose a limit that fits the largest sequence you expect. Unknown OSC sequences up to 2048 bytes are kept in a buffer the terminal already owns, so limits up to 2048 add no memory allocations for OSC. Larger limits allocate memory for each unknown OSC sequence. Unknown APC sequences are always kept in allocated memory.  Input type: size\\_t*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_TERMINAL\\_OPT\\_TERMINFO\\_NAME                       | Set the name of the terminfo entry this terminal runs as, reported in response to an XTGETTCAP query for "TN" (e.g. "xterm-256color").  The string data is copied into the terminal. A NULL value pointer clears the name (equivalent to setting an empty string). A name longer than 128 bytes returns GHOSTTY\\_INVALID\\_VALUE.  If this is unset then we don't report anything for an XTGETTCAP TN query, because we don't know what the embedding terminal around libghostty is advertising itself as.  Input type: [`GhosttyString`](@ref)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_TERMINAL\\_OPT\\_CLIPBOARD\\_READ                      | Callback invoked when the running program requests clipboard contents via OSC 52 with a "?" payload or a Kitty clipboard (OSC 5522) read. The read is synchronous and must be answered before the callback returns. Set to NULL (the default) to ignore OSC 52 read requests and refuse OSC 5522 reads with EPERM.  Input type: [`GhosttyTerminalClipboardReadFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_CLIPBOARD\\_WRITE\\_MAX\\_BYTES       | Set the maximum total decoded bytes a single Kitty clipboard protocol (OSC 5522) write transaction may accumulate. The limit is captured when a transaction begins; an in-flight transaction keeps the limit it started with.  Data beyond the limit fails the whole transaction with EFBIG. The transaction is discarded, later write-related packets are ignored until a new write begins, and nothing reaches the clipboard write callback.  Transactions are buffered in memory, so this limit bounds how much memory a single write can make the terminal allocate. Pass SIZE\\_MAX to remove the limit. A NULL value pointer reverts to the built-in default of 64MiB, the minimum required by the protocol.  This limit doesn't apply to OSC 52 writes, which are bounded by the maximum length of an escape sequence instead.  Input type: size\\_t*                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_TERMINAL\\_OPT\\_RESIZE\\_PULL\\_SCROLLBACK            | Set whether a resize may pull rows out of scrollback back into the active area.  When true, growing rows reveals scrollback if the cursor is on the bottom row, and a column reflow that needs fewer rows reveals scrollback as well. When false, growing rows always appends blank rows at the bottom and a column reflow keeps the top of the active area on the same content, so a line that is fully in scrollback stays there. A soft-wrapped line with at least one row still in the active area may still unwrap back into view.  Set this to false when the pty keeps its own screen buffer without scrollback, since it cannot pull rows back and will otherwise disagree with the terminal about the screen contents after a resize. Windows ConPTY is the motivating case.  This is preserved across a full reset (RIS).  A NULL value pointer resets to the built-in default of true.  Input type: bool*                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_TERMINAL\\_OPT\\_RENDER\\_HOLD                         | Callback invoked when the running program asks the terminal to stop updating the screen and when it allows updates again. Today this is driven by synchronized output (mode 2026). Set to NULL to ignore these events.  See guide-rendering-holds for how to use this in a renderer.  Input type: [`GhosttyTerminalRenderHoldFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_OPT\\_SEMANTIC\\_PROMPT                     | Callback invoked when the shell reports a step of a command: a prompt starts, input starts, output starts, or the command ends. Set to NULL to ignore these events.  Input type: [`GhosttyTerminalSemanticPromptFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_TERMINAL\\_OPT\\_RESET                                 | Callback invoked after the running program performs a full reset (RIS, ESC c). Set to NULL to ignore resets.  Input type: [`GhosttyTerminalResetFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_TERMINAL\\_OPT\\_XT\\_CHECKSUM\\_REPORT                | Enable checksum reports in response to DECRQCRA (CSI Pi ; Pg ; Pt ; Pl ; Pb ; Pr * y).  This is disabled by default because a running program can checksum the screen one cell at a time and so read back everything on it, including output from other programs. Passing NULL or a pointer to false disables checksum reporting.  While this is disabled, XTCHECKSUM (CSI Ps # y), which changes how the checksum is calculated, is ignored as well.  Input type: bool*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_OPT\\_XT\\_CHECKSUM\\_EXTENSION             | Set how the DECRQCRA checksum is calculated after a reset (RIS or DECSTR). This also changes the current calculation.  The value holds the same bits as XTCHECKSUM (CSI Ps # y) and xterm's checksumExtension resource, which a running program can still use to change the calculation until the next reset:  - 1: don't negate the result - 2: don't add the video attributes of each cell - 4: don't omit blanks - 8: count cells that were never written to as spaces - 16: use full codepoints instead of the DEC 8-bit values  Zero, or passing NULL, is the calculation of a real DEC terminal. Values above 31 return GHOSTTY\\_INVALID\\_VALUE.  Input type: uint8\\_t*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_TERMINAL\\_OPT\\_PROGRAM\\_STATUS                      | Callback invoked when the running program sends a program status report via OSC 7501. Set to NULL to ignore these reports.  Programs may ask whether the terminal supports the protocol by sending `OSC 7501 ; ?`. While this callback is set, the terminal answers through GHOSTTY\\_TERMINAL\\_OPT\\_WRITE\\_PTY with `?` followed by the states and kinds it accepts:  ```c++  program:  ESC ] 7501 ; ? ST  terminal: ESC ] 7501 ; ?:states=idle,working,done,blocked,error:kinds=permission,question,auth ST ```  While this callback is NULL, the query gets no reply, so a program that asks sees the protocol as unsupported. Asking is optional, so programs may send reports anyway. Those are dropped. Set a write\\_pty callback too, or programs never see the reply.  Input type: [`GhosttyTerminalProgramStatusFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_OPT\\_RESIZE\\_WINDOW                       | Callback invoked when the running program asks to resize the window, such as with CSI 8 ; rows ; columns t. Set to NULL to ignore resize requests.  Input type: [`GhosttyTerminalResizeWindowFn`](@ref)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_OPT\\_MAX\\_VALUE                           |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
"""
@cenum GhosttyTerminalOption::UInt32 begin
    GHOSTTY_TERMINAL_OPT_INVALID = 0
    GHOSTTY_TERMINAL_OPT_USERDATA = 1
    GHOSTTY_TERMINAL_OPT_WRITE_PTY = 2
    GHOSTTY_TERMINAL_OPT_BELL = 3
    GHOSTTY_TERMINAL_OPT_ENQUIRY = 4
    GHOSTTY_TERMINAL_OPT_XTVERSION = 5
    GHOSTTY_TERMINAL_OPT_TITLE_CHANGED = 6
    GHOSTTY_TERMINAL_OPT_SIZE = 7
    GHOSTTY_TERMINAL_OPT_COLOR_SCHEME = 8
    GHOSTTY_TERMINAL_OPT_DEVICE_ATTRIBUTES = 9
    GHOSTTY_TERMINAL_OPT_TITLE = 10
    GHOSTTY_TERMINAL_OPT_PWD = 11
    GHOSTTY_TERMINAL_OPT_COLOR_FOREGROUND = 12
    GHOSTTY_TERMINAL_OPT_COLOR_BACKGROUND = 13
    GHOSTTY_TERMINAL_OPT_COLOR_CURSOR = 14
    GHOSTTY_TERMINAL_OPT_COLOR_PALETTE = 15
    GHOSTTY_TERMINAL_OPT_KITTY_IMAGE_STORAGE_LIMIT = 16
    GHOSTTY_TERMINAL_OPT_KITTY_IMAGE_MEDIUM_FILE = 17
    GHOSTTY_TERMINAL_OPT_KITTY_IMAGE_MEDIUM_TEMP_FILE = 18
    GHOSTTY_TERMINAL_OPT_KITTY_IMAGE_MEDIUM_SHARED_MEM = 19
    GHOSTTY_TERMINAL_OPT_APC_MAX_BYTES = 20
    GHOSTTY_TERMINAL_OPT_APC_MAX_BYTES_KITTY = 21
    GHOSTTY_TERMINAL_OPT_SELECTION = 22
    GHOSTTY_TERMINAL_OPT_DEFAULT_CURSOR_STYLE = 23
    GHOSTTY_TERMINAL_OPT_DEFAULT_CURSOR_BLINK = 24
    GHOSTTY_TERMINAL_OPT_GLYPH_PROTOCOL = 25
    GHOSTTY_TERMINAL_OPT_PWD_CHANGED = 26
    GHOSTTY_TERMINAL_OPT_CLIPBOARD_WRITE = 27
    GHOSTTY_TERMINAL_OPT_SCROLLBACK_MAX_BYTES = 28
    GHOSTTY_TERMINAL_OPT_SCROLLBACK_MAX_LINES = 29
    GHOSTTY_TERMINAL_OPT_DESKTOP_NOTIFICATION = 30
    GHOSTTY_TERMINAL_OPT_PROGRESS_REPORT = 31
    GHOSTTY_TERMINAL_OPT_CONTINUATION_MAX_BYTES = 32
    GHOSTTY_TERMINAL_OPT_TITLE_REPORT = 33
    GHOSTTY_TERMINAL_OPT_MODE_DEFAULT = 34
    GHOSTTY_TERMINAL_OPT_MODE = 35
    GHOSTTY_TERMINAL_OPT_UNKNOWN_SEQUENCE = 36
    GHOSTTY_TERMINAL_OPT_UNKNOWN_MAX_BYTES = 37
    GHOSTTY_TERMINAL_OPT_TERMINFO_NAME = 38
    GHOSTTY_TERMINAL_OPT_CLIPBOARD_READ = 39
    GHOSTTY_TERMINAL_OPT_CLIPBOARD_WRITE_MAX_BYTES = 40
    GHOSTTY_TERMINAL_OPT_RESIZE_PULL_SCROLLBACK = 41
    GHOSTTY_TERMINAL_OPT_RENDER_HOLD = 42
    GHOSTTY_TERMINAL_OPT_SEMANTIC_PROMPT = 43
    GHOSTTY_TERMINAL_OPT_RESET = 44
    GHOSTTY_TERMINAL_OPT_XT_CHECKSUM_REPORT = 45
    GHOSTTY_TERMINAL_OPT_XT_CHECKSUM_EXTENSION = 46
    GHOSTTY_TERMINAL_OPT_PROGRAM_STATUS = 47
    GHOSTTY_TERMINAL_OPT_RESIZE_WINDOW = 48
    GHOSTTY_TERMINAL_OPT_MAX_VALUE = 2147483647
end

"""
    GhosttyTerminalData

Terminal data types.

These values specify what type of data to extract from a terminal using [`ghostty_terminal_get`](@ref).

` terminal`

| Enumerator                                                        | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| :---------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_TERMINAL\\_DATA\\_INVALID                               | Invalid data type. Never results in any data extraction.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLS                                  | Terminal width in cells.  Output type: uint16\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_TERMINAL\\_DATA\\_ROWS                                  | Terminal height in cells.  Output type: uint16\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_TERMINAL\\_DATA\\_CURSOR\\_X                            | Cursor column position (0-indexed).  Output type: uint16\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| GHOSTTY\\_TERMINAL\\_DATA\\_CURSOR\\_Y                            | Cursor row position within the active area (0-indexed).  Output type: uint16\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_TERMINAL\\_DATA\\_CURSOR\\_PENDING\\_WRAP               | Whether the cursor has a pending wrap (next print will soft-wrap).  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_TERMINAL\\_DATA\\_ACTIVE\\_SCREEN                       | The currently active screen.  Output type: [`GhosttyTerminalScreen`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_TERMINAL\\_DATA\\_CURSOR\\_VISIBLE                      | Whether the cursor is visible (DEC mode 25).  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_TERMINAL\\_DATA\\_KITTY\\_KEYBOARD\\_FLAGS              | Current Kitty keyboard protocol flags.  Output type: [`GhosttyKittyKeyFlags`](@ref) * (uint8\\_t *)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_TERMINAL\\_DATA\\_SCROLLBAR                             | Scrollbar state for the terminal viewport.  This is amortized O(1): the total is maintained incrementally as the terminal is modified and the viewport offset is cached. The first read after the viewport moves to an arbitrary position that isn't an absolute row (e.g. scrolling to a selection) may cost O(pages) to compute the offset, after which it is cached again.  There is intentionally no change notification for scroll state. Callers building scrollbars should poll this once per frame or per write batch and diff the result to detect changes; this is what Ghostty's own renderer does.  Output type: [`GhosttyTerminalScrollbar`](@ref) *  |
| GHOSTTY\\_TERMINAL\\_DATA\\_CURSOR\\_SGR\\_STYLE                  | The current SGR style of the cursor.  This is the style that will be applied to newly printed characters, such as bold or a foreground color. It isn't the shape of the cursor. For that, see [`GhosttyCursorStyle`](@ref).  Output type: [`GhosttyStyle`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_TERMINAL\\_DATA\\_MOUSE\\_TRACKING                      | Whether any mouse tracking mode is active.  Returns true if any of the mouse tracking modes (X10, normal, button, or any-event) are enabled.  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_TERMINAL\\_DATA\\_TITLE                                 | The terminal title as set by escape sequences (e.g. OSC 0/2).  Returns a borrowed string. The pointer is valid until the next mutating terminal call. An empty string (len=0) is returned when no title has been set.  Output type: [`GhosttyString`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_TERMINAL\\_DATA\\_PWD                                   | The terminal's current working directory as set by escape sequences (e.g. OSC 7).  Returns a borrowed string. The pointer is valid until the next mutating terminal call. An empty string (len=0) is returned when no pwd has been set.  Output type: [`GhosttyString`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_TERMINAL\\_DATA\\_TOTAL\\_ROWS                          | The total number of rows in the active screen including scrollback.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_TERMINAL\\_DATA\\_SCROLLBACK\\_ROWS                     | The number of scrollback rows (total rows minus viewport rows).  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_DATA\\_WIDTH\\_PX                            | The total width of the terminal in pixels.  This is cols * cell\\_width\\_px as set by [`ghostty_terminal_resize`](@ref)().  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_TERMINAL\\_DATA\\_HEIGHT\\_PX                           | The total height of the terminal in pixels.  This is rows * cell\\_height\\_px as set by [`ghostty_terminal_resize`](@ref)().  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_FOREGROUND                    | The effective foreground color (override or default).  Returns GHOSTTY\\_NO\\_VALUE if no foreground color is set.  Output type: [`GhosttyColorRgb`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_BACKGROUND                    | The effective background color (override or default).  Returns GHOSTTY\\_NO\\_VALUE if no background color is set.  Output type: [`GhosttyColorRgb`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_CURSOR                        | The effective cursor color (override or default).  Returns GHOSTTY\\_NO\\_VALUE if no cursor color is set.  Output type: [`GhosttyColorRgb`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_PALETTE                       | The current 256-color palette.  Output type: [`GhosttyColorRgb`](@ref)[256] *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_FOREGROUND\\_DEFAULT          | The default foreground color (ignoring any OSC override).  Returns GHOSTTY\\_NO\\_VALUE if no default foreground color is set.  Output type: [`GhosttyColorRgb`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_BACKGROUND\\_DEFAULT          | The default background color (ignoring any OSC override).  Returns GHOSTTY\\_NO\\_VALUE if no default background color is set.  Output type: [`GhosttyColorRgb`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_CURSOR\\_DEFAULT              | The default cursor color (ignoring any OSC override).  Returns GHOSTTY\\_NO\\_VALUE if no default cursor color is set.  Output type: [`GhosttyColorRgb`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_TERMINAL\\_DATA\\_COLOR\\_PALETTE\\_DEFAULT             | The default 256-color palette (ignoring any OSC overrides).  Output type: [`GhosttyColorRgb`](@ref)[256] *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_DATA\\_KITTY\\_IMAGE\\_STORAGE\\_LIMIT       | The Kitty image storage limit in bytes for the active screen.  A value of zero means the Kitty graphics protocol is disabled. [`ghostty_terminal_get`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this data when Kitty graphics are disabled at build time.  Output type: uint64\\_t *                                                                                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_TERMINAL\\_DATA\\_KITTY\\_IMAGE\\_MEDIUM\\_FILE         | Whether the file medium is enabled for Kitty image loading on the active screen.  [`ghostty_terminal_get`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this data when Kitty graphics are disabled at build time.  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_TERMINAL\\_DATA\\_KITTY\\_IMAGE\\_MEDIUM\\_TEMP\\_FILE  | The directory allowed for Kitty image loading via the temporary file medium on the active screen. The string is empty when the medium is disabled.  [`ghostty_terminal_get`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this data when Kitty graphics are disabled at build time.  Output type: [`GhosttyString`](@ref) *                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_DATA\\_KITTY\\_IMAGE\\_MEDIUM\\_SHARED\\_MEM | Whether the shared memory medium is enabled for Kitty image loading on the active screen.  [`ghostty_terminal_get`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this data when Kitty graphics are disabled at build time.  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_TERMINAL\\_DATA\\_KITTY\\_GRAPHICS                      | The Kitty graphics image storage for the active screen.  Returns a borrowed pointer to the image storage. The pointer is valid until the next mutating terminal call (e.g. [`ghostty_terminal_vt_write`](@ref)() or [`ghostty_terminal_reset`](@ref)()).  [`ghostty_terminal_get`](@ref)() returns GHOSTTY\\_UNSUPPORTED for this data when Kitty graphics are disabled at build time.  Output type: [`GhosttyKittyGraphics`](@ref) *                                                                                                                                                                                                                              |
| GHOSTTY\\_TERMINAL\\_DATA\\_SELECTION                             | The active screen's current selection.  On success, writes an untracked snapshot of the terminal-owned selection to your [`GhosttySelection`](@ref). The [`GhosttySelection`](@ref) struct is caller-owned and may be kept, but the grid references inside it are untracked borrowed references into the active screen. They are only valid until the next mutating terminal call, such as [`ghostty_terminal_set`](@ref)(), [`ghostty_terminal_vt_write`](@ref)(), [`ghostty_terminal_resize`](@ref)(), or [`ghostty_terminal_reset`](@ref)().  Returns GHOSTTY\\_NO\\_VALUE when there is no active selection.  Output type: [`GhosttySelection`](@ref) *        |
| GHOSTTY\\_TERMINAL\\_DATA\\_VIEWPORT\\_ACTIVE                     | Whether the viewport is currently pinned to the active area.  This is true when the viewport is following the active terminal area, and false when the user has scrolled into history.  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_DATA\\_VT\\_PROCESSING\\_ERROR               | Whether VT processing encountered a non-gracefully handled error that may have prevented a terminal-owned semantic update.  Processing remains best-effort, and [`ghostty_terminal_reset`](@ref)() does not  clear it. Gracefully handled protocol failures, configured limits,  malformed or unsupported input, and failures limited to external effects  or query responses do not set it.  This can't currently be unset. This is purely informational to consumers if there was some error that happened at some point during VT processing.  Output type: bool *                                                                                              |
| GHOSTTY\\_TERMINAL\\_DATA\\_SCROLLBACK\\_MAX\\_BYTES              | The configured maximum scrollback allocation in bytes.  This always reports the primary screen's configured value, including while an alternate screen is active. Returns GHOSTTY\\_NO\\_VALUE when the configured byte limit is unlimited.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_TERMINAL\\_DATA\\_SCROLLBACK\\_MAX\\_LINES              | The configured maximum number of physical scrollback lines.  This always reports the primary screen's configured value, including while an alternate screen is active. Returns GHOSTTY\\_NO\\_VALUE when the configured line limit is unlimited.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_DATA\\_CONTINUATION\\_MAX\\_BYTES            | The configured maximum retained VT continuation size in bytes.  A value of zero means continuation tracking is disabled. This reports the configured limit even when a current unfinished continuation is temporarily unavailable.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_TERMINAL\\_DATA\\_MODE                                  | Get the current value of a terminal mode.  You must initialize the `mode` field. On success, the `value` field is updated with the current value. A NULL pointer or unknown mode returns GHOSTTY\\_INVALID\\_VALUE.  Input/output type: [`GhosttyTerminalModeConfig`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_TERMINAL\\_DATA\\_VT\\_GROUND                           | Whether VT processing is at ground.  Ground is when the stream isn't in the middle of any type of sequence: UTF-8, ESC, CSI, OSC, etc. It is the stateless point of the stream.  This is useful to know because it is a point at which you can safely insert out-of-band VT sequences. For example, while reading from a pty if you want to make your own changes, you can wait until the pty input reaches ground, then write yours.  Output type: bool *                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_DATA\\_CURSOR\\_AT\\_PROMPT                  | Whether the cursor is currently at a semantic shell prompt or input area.  This depends on semantic prompt markers such as OSC 133. Returns false when semantic prompt information is unavailable or the alternate screen is active.  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_DATA\\_CLIPBOARD\\_WRITE\\_MAX\\_BYTES       | The configured maximum decoded bytes per Kitty clipboard protocol (OSC 5522) write transaction. See GHOSTTY\\_TERMINAL\\_OPT\\_CLIPBOARD\\_WRITE\\_MAX\\_BYTES.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_TERMINAL\\_DATA\\_MOUSE\\_SHAPE                         | The mouse pointer shape requested by the application through OSC 22.  Initially GHOSTTY\\_MOUSE\\_SHAPE\\_TEXT. Excludes host hover overrides.  Output type: [`GhosttyMouseShape`](@ref) *                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_TERMINAL\\_DATA\\_MEMORY\\_USAGE                        | How much memory the terminal holds. See [`GhosttyTerminalMemoryUsage`](@ref) for what each field means.  Set the struct's `size` field before the call, for example with [`GHOSTTY_INIT_SIZED`](@ref)(). If `size` is too small, this returns GHOSTTY\\_INVALID\\_VALUE and leaves the struct unchanged.  This never decompresses scrollback, but it does look at every page, so avoid reading it after every write.  Output type: [`GhosttyTerminalMemoryUsage`](@ref) *                                                                                                                                                                                          |
| GHOSTTY\\_TERMINAL\\_DATA\\_MAX\\_VALUE                           |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
"""
@cenum GhosttyTerminalData::UInt32 begin
    GHOSTTY_TERMINAL_DATA_INVALID = 0
    GHOSTTY_TERMINAL_DATA_COLS = 1
    GHOSTTY_TERMINAL_DATA_ROWS = 2
    GHOSTTY_TERMINAL_DATA_CURSOR_X = 3
    GHOSTTY_TERMINAL_DATA_CURSOR_Y = 4
    GHOSTTY_TERMINAL_DATA_CURSOR_PENDING_WRAP = 5
    GHOSTTY_TERMINAL_DATA_ACTIVE_SCREEN = 6
    GHOSTTY_TERMINAL_DATA_CURSOR_VISIBLE = 7
    GHOSTTY_TERMINAL_DATA_KITTY_KEYBOARD_FLAGS = 8
    GHOSTTY_TERMINAL_DATA_SCROLLBAR = 9
    GHOSTTY_TERMINAL_DATA_CURSOR_SGR_STYLE = 10
    GHOSTTY_TERMINAL_DATA_MOUSE_TRACKING = 11
    GHOSTTY_TERMINAL_DATA_TITLE = 12
    GHOSTTY_TERMINAL_DATA_PWD = 13
    GHOSTTY_TERMINAL_DATA_TOTAL_ROWS = 14
    GHOSTTY_TERMINAL_DATA_SCROLLBACK_ROWS = 15
    GHOSTTY_TERMINAL_DATA_WIDTH_PX = 16
    GHOSTTY_TERMINAL_DATA_HEIGHT_PX = 17
    GHOSTTY_TERMINAL_DATA_COLOR_FOREGROUND = 18
    GHOSTTY_TERMINAL_DATA_COLOR_BACKGROUND = 19
    GHOSTTY_TERMINAL_DATA_COLOR_CURSOR = 20
    GHOSTTY_TERMINAL_DATA_COLOR_PALETTE = 21
    GHOSTTY_TERMINAL_DATA_COLOR_FOREGROUND_DEFAULT = 22
    GHOSTTY_TERMINAL_DATA_COLOR_BACKGROUND_DEFAULT = 23
    GHOSTTY_TERMINAL_DATA_COLOR_CURSOR_DEFAULT = 24
    GHOSTTY_TERMINAL_DATA_COLOR_PALETTE_DEFAULT = 25
    GHOSTTY_TERMINAL_DATA_KITTY_IMAGE_STORAGE_LIMIT = 26
    GHOSTTY_TERMINAL_DATA_KITTY_IMAGE_MEDIUM_FILE = 27
    GHOSTTY_TERMINAL_DATA_KITTY_IMAGE_MEDIUM_TEMP_FILE = 28
    GHOSTTY_TERMINAL_DATA_KITTY_IMAGE_MEDIUM_SHARED_MEM = 29
    GHOSTTY_TERMINAL_DATA_KITTY_GRAPHICS = 30
    GHOSTTY_TERMINAL_DATA_SELECTION = 31
    GHOSTTY_TERMINAL_DATA_VIEWPORT_ACTIVE = 32
    GHOSTTY_TERMINAL_DATA_VT_PROCESSING_ERROR = 33
    GHOSTTY_TERMINAL_DATA_SCROLLBACK_MAX_BYTES = 34
    GHOSTTY_TERMINAL_DATA_SCROLLBACK_MAX_LINES = 35
    GHOSTTY_TERMINAL_DATA_CONTINUATION_MAX_BYTES = 36
    GHOSTTY_TERMINAL_DATA_MODE = 37
    GHOSTTY_TERMINAL_DATA_VT_GROUND = 38
    GHOSTTY_TERMINAL_DATA_CURSOR_AT_PROMPT = 39
    GHOSTTY_TERMINAL_DATA_CLIPBOARD_WRITE_MAX_BYTES = 40
    GHOSTTY_TERMINAL_DATA_MOUSE_SHAPE = 41
    GHOSTTY_TERMINAL_DATA_MEMORY_USAGE = 42
    GHOSTTY_TERMINAL_DATA_MAX_VALUE = 2147483647
end

"""
    ghostty_terminal_new(allocator, terminal, cols, rows)

Create a new terminal instance.

The terminal starts with various reasonable defaults e.g. around scrollback limits. Use [`ghostty_terminal_set`](@ref)() to change any options prior to using the terminal.

` terminal`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `terminal`: Pointer to store the created terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `cols`: Terminal width in cells (must be greater than zero)
* `rows`: Terminal height in cells (must be greater than zero)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_terminal_new(allocator, terminal, cols, rows)
    @ccall libghostty_vt.ghostty_terminal_new(allocator::Ptr{GhosttyAllocator}, terminal::Ptr{GhosttyTerminal}, cols::UInt16, rows::UInt16)::GhosttyResult
end

"""
    ghostty_terminal_free(terminal)

Free a terminal instance.

Releases all resources associated with the terminal. After this call, the terminal handle becomes invalid and must not be used.

` terminal`

# Arguments
* `terminal`: The terminal handle to free (may be NULL)
"""
function ghostty_terminal_free(terminal)
    @ccall libghostty_vt.ghostty_terminal_free(terminal::GhosttyTerminal)::Cvoid
end

"""
    ghostty_terminal_reset(terminal)

Perform a full reset of the terminal (RIS).

Resets all terminal state back to its initial configuration, including modes, scrollback, scrolling region, and screen contents. The terminal dimensions are preserved.

If synchronized output was enabled, the GHOSTTY\\_TERMINAL\\_OPT\\_RENDER\\_HOLD callback is invoked to report that the hold ended.

` terminal`

# Arguments
* `terminal`: The terminal handle (may be NULL, in which case this is a no-op)
"""
function ghostty_terminal_reset(terminal)
    @ccall libghostty_vt.ghostty_terminal_reset(terminal::GhosttyTerminal)::Cvoid
end

"""
    ghostty_terminal_resize(terminal, cols, rows, cell_width_px, cell_height_px)

Resize the terminal to the given dimensions.

Changes the number of columns and rows in the terminal. The primary screen will reflow content if wraparound mode is enabled; the alternate screen does not reflow. If the dimensions are unchanged, the grid is left as is, but everything below still applies.

This also updates the terminal's pixel dimensions (used for image protocols and size reports), disables synchronized output mode (allowed by the spec so that resize results are shown immediately), and sends an in-band size report if mode 2048 is enabled.

If synchronized output was enabled, the GHOSTTY\\_TERMINAL\\_OPT\\_RENDER\\_HOLD callback is invoked to report that the hold ended.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `cols`: New width in cells (must be greater than zero)
* `rows`: New height in cells (must be greater than zero)
* `cell_width_px`: Width of a single cell in pixels
* `cell_height_px`: Height of a single cell in pixels
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_terminal_resize(terminal, cols, rows, cell_width_px, cell_height_px)
    @ccall libghostty_vt.ghostty_terminal_resize(terminal::GhosttyTerminal, cols::UInt16, rows::UInt16, cell_width_px::UInt32, cell_height_px::UInt32)::GhosttyResult
end

"""
    ghostty_terminal_set(terminal, option, value)

Set an option on the terminal.

Configures terminal callbacks and associated state such as the write\\_pty callback and userdata pointer. The value is passed directly for pointer types (callbacks, userdata) or as a pointer to the value for non-pointer types (e.g. [`GhosttyString`](@ref)*).

Passing NULL for `value` restores the option's default, the same value a new terminal starts with. Each [`GhosttyTerminalOption`](@ref) value documents its default. Callbacks and the userdata pointer default to NULL, so passing NULL removes them. GHOSTTY\\_TERMINAL\\_OPT\\_MODE and GHOSTTY\\_TERMINAL\\_OPT\\_MODE\\_DEFAULT have no default to restore, so they return GHOSTTY\\_INVALID\\_VALUE for NULL.

```c++
{.c}
 bool enabled = true;
 ghostty_terminal_set(terminal, GHOSTTY_TERMINAL_OPT_GLYPH_PROTOCOL,
                      &enabled);

 // Later, turn it back off by restoring the default.
 ghostty_terminal_set(terminal, GHOSTTY_TERMINAL_OPT_GLYPH_PROTOCOL, NULL);
```

Callbacks are invoked synchronously during VT writes. Callbacks must not call [`ghostty_terminal_vt_write`](@ref)() or [`ghostty_terminal_vt_write_until`](@ref)() on the same terminal. The terminal is not reentrant, and nothing checks for this or reports an error. The bytes go into the parser in the middle of the sequence that called you, so they can be lost or make that sequence run a second time. See guide-effects-rules.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to set
* `value`: Pointer to the value to set (type depends on the option), or NULL to restore the option's default
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `terminal` is NULL or the value is invalid for the option, GHOSTTY\\_OUT\\_OF\\_MEMORY if copying the value fails, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_terminal_set(terminal, option, value)
    @ccall libghostty_vt.ghostty_terminal_set(terminal::GhosttyTerminal, option::GhosttyTerminalOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_terminal_vt_write(terminal, data, len)

Write VT-encoded data to the terminal for processing.

Feeds raw bytes through the terminal's VT stream parser, updating terminal state accordingly. By default, sequences that require output (queries, device status reports) are silently ignored. Use [`ghostty_terminal_set`](@ref)() with GHOSTTY\\_TERMINAL\\_OPT\\_WRITE\\_PTY to install a callback that receives response data.

This never fails. Any erroneous input or errors in processing the input are logged internally but do not cause this function to fail because this input is assumed to be untrusted and from an external source; so the primary goal is to keep the terminal state consistent and  not allow malformed input to corrupt or crash.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL does nothing)
* `data`: Pointer to the data to write (NULL does nothing)
* `len`: Length of the data in bytes
"""
function ghostty_terminal_vt_write(terminal, data, len)
    @ccall libghostty_vt.ghostty_terminal_vt_write(terminal::GhosttyTerminal, data::Ptr{UInt8}, len::Csize_t)::Cvoid
end

"""
    ghostty_terminal_vt_write_until(terminal, data, len, boundaries, out)

Write VT-encoded data to the terminal, stopping right after the first byte that reaches one of the requested boundaries.

This works like [`ghostty_terminal_vt_write`](@ref)(), but it can pause at points you care about. It tells you exactly where a control string starts or ends, using the same parse that updates the terminal. For example, a program that sits between a shell and a terminal can use it to:

- Find the exact bytes of each APC, DCS or OSC string, such as a Kitty graphics command, a tmux control mode message or a clipboard write, so it can forward, rewrite or drop that string. - Wait until the stream is at ground before inserting its own sequences, so it never splits a sequence from the program.

Pass the boundaries to stop at as [`GhosttyTerminalBoundary`](@ref) flags. The call consumes input up to and including the first byte that reaches one of them, and reports that point in `out`. The terminal only processes the consumed bytes, and callbacks only run for those bytes. Pass the remaining bytes in your next call.

Every byte you pass is eventually consumed in order, so the terminal ends up in the same state as if you had called [`ghostty_terminal_vt_write`](@ref)() with all of it.

See guide-custom-sequences-write-until for how to find string content, the cases that need care, and waiting for ground.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: Pointer to the data to write, or NULL when len is zero
* `len`: Length of the data in bytes
* `boundaries`: [`GhosttyTerminalBoundary`](@ref) flags to stop at. Must be nonzero and contain only defined flags.
* `out`:\\[out\\] Where the call stopped. NULL returns GHOSTTY\\_INVALID\\_VALUE. Its `size` must be set with [`GHOSTTY_INIT_SIZED`](@ref)().
# Returns
GHOSTTY\\_SUCCESS if a boundary was reached. GHOSTTY\\_NO\\_VALUE if all input was consumed without reaching a boundary. In that case `out->consumed` is `len` and `out->reached` is 0. GHOSTTY\\_INVALID\\_VALUE if an argument is invalid. No input is consumed.
"""
function ghostty_terminal_vt_write_until(terminal, data, len, boundaries, out)
    @ccall libghostty_vt.ghostty_terminal_vt_write_until(terminal::GhosttyTerminal, data::Ptr{UInt8}, len::Csize_t, boundaries::UInt32, out::Ptr{GhosttyTerminalWriteStop})::GhosttyResult
end

"""
    ghostty_terminal_continuation_write(terminal, writer)

Write the terminal's replay-safe VT continuation to a callback writer.

The continuation is the exact byte suffix needed to reconstruct unfinished VT parser or UTF-8 decoder state in an equivalent terminal. It is empty when the stream is at ground. The callback is invoked synchronously and may be called more than once. It must not call terminal APIs with the same terminal handle.

Continuation tracking must have been enabled by setting GHOSTTY\\_TERMINAL\\_OPT\\_CONTINUATION\\_MAX\\_BYTES to a nonzero value before the input that produced the continuation was written.

You must serialize this operation with both VT write functions and all other access to the same terminal.

` terminal`

# Arguments
* `terminal`: Terminal to read from (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `writer`: Destination writer whose write callback must not be NULL
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_IO\\_ERROR if the callback rejects a write, GHOSTTY\\_LIMIT\\_EXCEEDED if output accounting overflows, or GHOSTTY\\_INVALID\\_VALUE if an argument is invalid, tracking is disabled, or the current continuation is unavailable
"""
function ghostty_terminal_continuation_write(terminal, writer)
    @ccall libghostty_vt.ghostty_terminal_continuation_write(terminal::GhosttyTerminal, writer::GhosttyWriter)::GhosttyResult
end

"""
    ghostty_terminal_continuation_buf(terminal, buf, buf_len, out_written)

Copy the terminal's replay-safe VT continuation into a caller buffer.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets `out_written` to the size needed. To get the size first, pass NULL for `buf` and 0 for `buf_len`. When no escape sequence or UTF-8 character is left unfinished, the continuation is empty and needs no space, so this returns GHOSTTY\\_SUCCESS with `out_written` set to 0, even for a size query.

Continuation tracking must have been enabled by setting GHOSTTY\\_TERMINAL\\_OPT\\_CONTINUATION\\_MAX\\_BYTES to a nonzero value before the input that produced the continuation was written.

You must serialize this operation with all other access to the same terminal.

` terminal`

# Arguments
* `terminal`: Terminal to read from (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `buf`: Buffer to write the continuation into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE. NULL returns GHOSTTY\\_INVALID\\_VALUE.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if the continuation does not fit in `buf`, or GHOSTTY\\_INVALID\\_VALUE if an argument is invalid, tracking is disabled, or the current continuation is unavailable
"""
function ghostty_terminal_continuation_buf(terminal, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_terminal_continuation_buf(terminal::GhosttyTerminal, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_terminal_continuation_alloc(terminal, allocator, out_ptr, out_len)

Return an allocated copy of the terminal's replay-safe VT continuation.

The returned bytes are allocated with allocator, or the default allocator when allocator is NULL. You must release them with [`ghostty_free`](@ref)(), passing the same allocator and returned length. An empty continuation is a successful result with *out\\_ptr set to NULL and *out\\_len set to zero, which can also be passed to [`ghostty_free`](@ref)(). Continuation tracking must have been enabled by setting GHOSTTY\\_TERMINAL\\_OPT\\_CONTINUATION\\_MAX\\_BYTES to a nonzero value before the input that produced the continuation was written.

You must serialize this operation with all other access to the same terminal.

` terminal`

# Arguments
* `terminal`: Terminal to read from (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `allocator`: Allocator for the output, or NULL for the default allocator
* `out_ptr`:\\[out\\] Allocated continuation bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_len`:\\[out\\] Number of continuation bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY on allocation failure, or GHOSTTY\\_INVALID\\_VALUE if an argument is invalid, tracking is disabled, or the current continuation is unavailable
"""
function ghostty_terminal_continuation_alloc(terminal, allocator, out_ptr, out_len)
    @ccall libghostty_vt.ghostty_terminal_continuation_alloc(terminal::GhosttyTerminal, allocator::Ptr{GhosttyAllocator}, out_ptr::Ptr{Ptr{UInt8}}, out_len::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_terminal_scroll_viewport(terminal, behavior)

Scroll the terminal viewport.

Scrolls the terminal's viewport according to the given behavior. When using GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_DELTA, set the delta field in the value union to specify the number of rows to scroll (negative for up, positive for down). When using GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_ROW, set the row field to the absolute row offset from the top of the scrollable area (the same row space as the offset field of [`GhosttyTerminalScrollbar`](@ref)). When using GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_DELTA\\_PROMPT, set delta\\_prompt to the signed number of prompts to move. See GHOSTTY\\_TERMINAL\\_SCROLL\\_VIEWPORT\\_DELTA\\_PROMPT for the navigation behavior. For other behaviors, the value is ignored.

```c++
{.c}
 GhosttyTerminalScrollViewport behavior = {
   .tag = GHOSTTY_TERMINAL_SCROLL_VIEWPORT_DELTA,
   .value = { .delta = -5 },
 };
 ghostty_terminal_scroll_viewport(terminal, behavior); // up 5 rows
```

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `behavior`: The scroll behavior as a tagged union
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `terminal` is NULL or `behavior.tag` is not a [`GhosttyTerminalScrollViewportTag`](@ref) value known to this version of the library. The viewport does not move on failure.
"""
function ghostty_terminal_scroll_viewport(terminal, behavior)
    @ccall libghostty_vt.ghostty_terminal_scroll_viewport(terminal::GhosttyTerminal, behavior::GhosttyTerminalScrollViewport)::GhosttyResult
end

"""
    ghostty_terminal_compression_activity(terminal, out_activity)

Return the current compression activity token.

The token is opaque and only equality comparisons are meaningful. An embedding application should cache it and restart its compression idle delay whenever the value changes. The value may wrap and changes in either direction have the same meaning.

This function only observes terminal state. It does not perform or schedule compression.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_activity`:\\[out\\] Receives the current activity token
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if an argument is NULL
"""
function ghostty_terminal_compression_activity(terminal, out_activity)
    @ccall libghostty_vt.ghostty_terminal_compression_activity(terminal::GhosttyTerminal, out_activity::Ptr{UInt64})::GhosttyResult
end

"""
    ghostty_terminal_compress(terminal, mode, out_result)

Compress eligible terminal scrollback.

Incremental mode performs bounded work suitable for an idle callback. A pending result means the application should invoke another step while the terminal remains idle. A complete result means no continuation is needed until [`ghostty_terminal_compression_activity`](@ref)() changes. Full mode performs one synchronous scan and can stall on large scrollback buffers.

Compression is opportunistic. Complete means the pass has finished, not that every page was compressed: pages may be unprofitable or encounter an allocation or reclamation failure. Compression changes only the terminal's storage representation and never its logical contents or scrollback limit. Accessing compressed history restores it transparently.

This function is not thread-safe with other operations on the same terminal. You must serialize it with writes, rendering, searches, and other terminal access.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `mode`: The amount of compression work to perform
* `out_result`:\\[out\\] Receives the compression scheduling result
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if an argument or mode is invalid
"""
function ghostty_terminal_compress(terminal, mode, out_result)
    @ccall libghostty_vt.ghostty_terminal_compress(terminal::GhosttyTerminal, mode::GhosttyTerminalCompressionMode, out_result::Ptr{GhosttyTerminalCompressionResult})::GhosttyResult
end

"""
    ghostty_terminal_get(terminal, data, out)

Get data from a terminal instance.

Extracts typed data from the given terminal based on the specified data type. The output pointer must be of the appropriate type for the requested data kind. Valid data types and output types are documented in the [`GhosttyTerminalData`](@ref) enum.

` terminal`

# Arguments
* `terminal`: The terminal handle (may be NULL)
* `data`: The type of data to extract
* `out`: Pointer to store the extracted data (type depends on data parameter)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal is NULL or `data` is GHOSTTY\\_TERMINAL\\_DATA\\_INVALID, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_terminal_get(terminal, data, out)
    @ccall libghostty_vt.ghostty_terminal_get(terminal::GhosttyTerminal, data::GhosttyTerminalData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_terminal_get_multi(terminal, count, keys, values, out_written)

Get multiple data fields from a terminal in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_terminal_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result. The type of each values[i] pointer must match the output type documented for keys[i].

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` terminal`

# Arguments
* `terminal`: The terminal handle (may be NULL)
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_terminal_get_multi(terminal, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_terminal_get_multi(terminal::GhosttyTerminal, count::Csize_t, keys::Ptr{GhosttyTerminalData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_terminal_grid_ref(terminal, point, out_ref)

Resolve a point in the terminal grid to a grid reference.

Resolves the given point (which can be in active, viewport, screen, or history coordinates) to a grid reference for that location. Use [`ghostty_grid_ref_cell`](@ref)() and [`ghostty_grid_ref_row`](@ref)() to extract the cell and row.

Lookups using the `active` and `viewport` tags are fast. The `screen` and `history` tags may require traversing the full scrollback page list to resolve the y coordinate, so they can be expensive for large scrollback buffers.

This function isn't meant to be used as the core of render loop. It isn't built to sustain the framerates needed for rendering large screens. Use the render state API for that. This API is instead meant for less strictly performance-sensitive use cases.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `point`: The point specifying which cell to look up
* `out_ref`:\\[out\\] On success, set to the grid reference at the given point (may be NULL)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal is NULL or the point is out of bounds
"""
function ghostty_terminal_grid_ref(terminal, point, out_ref)
    @ccall libghostty_vt.ghostty_terminal_grid_ref(terminal::GhosttyTerminal, point::GhosttyPoint, out_ref::Ptr{GhosttyGridRef})::GhosttyResult
end

"""
    ghostty_terminal_grid_ref_track(terminal, point, out_ref)

Create an owned tracked grid reference for a terminal point.

This is the tracked variant of [`ghostty_terminal_grid_ref`](@ref)(). The returned handle follows the referenced cell as the terminal's page list is modified: scrolling, pruning, resize/reflow, and other page-list operations update the tracked reference automatically.

The reference is attached to the terminal screen/page-list that is active at creation time.

If the point is outside the requested coordinate space, this returns GHOSTTY\\_INVALID\\_VALUE and writes NULL to out\\_ref.

The returned handle must be freed with [`ghostty_tracked_grid_ref_free`](@ref)(). If the terminal is freed first, the handle remains valid only for tracked-grid-ref APIs: it reports no value and can still be freed.

` terminal`

# Arguments
* `terminal`: Terminal instance.
* `point`: Point to track.
* `out_ref`:\\[out\\] On success, receives the tracked reference handle.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if terminal, point, or out\\_ref is invalid, or GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails.
"""
function ghostty_terminal_grid_ref_track(terminal, point, out_ref)
    @ccall libghostty_vt.ghostty_terminal_grid_ref_track(terminal::GhosttyTerminal, point::GhosttyPoint, out_ref::Ptr{GhosttyTrackedGridRef})::GhosttyResult
end

"""
    ghostty_terminal_point_from_grid_ref(terminal, ref, tag, out)

Convert a grid reference back to a point in the given coordinate system.

This is the inverse of [`ghostty_terminal_grid_ref`](@ref)(): given a grid reference, it returns the x/y coordinates in the requested coordinate system (active, viewport, screen, or history).

The grid reference must have been obtained from the same terminal instance. Like all grid references, it is only valid until the next mutating terminal call.

Not every grid reference is representable in every coordinate system. For example, a cell in scrollback history cannot be expressed in active coordinates, and a cell that has scrolled off the visible area cannot be expressed in viewport coordinates. In these cases, the function returns GHOSTTY\\_NO\\_VALUE.

` terminal`

# Arguments
* `terminal`: The terminal handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `ref`: Pointer to the grid reference to convert (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `tag`: The target coordinate system
* `out`:\\[out\\] On success, set to the coordinate in the requested system (may be NULL)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if the terminal or ref is NULL/invalid, GHOSTTY\\_NO\\_VALUE if the ref falls outside the requested coordinate system
"""
function ghostty_terminal_point_from_grid_ref(terminal, ref, tag, out)
    @ccall libghostty_vt.ghostty_terminal_point_from_grid_ref(terminal::GhosttyTerminal, ref::Ptr{GhosttyGridRef}, tag::GhosttyPointTag, out::Ptr{GhosttyPointCoordinate})::GhosttyResult
end

"""
Terminal state to add to VT output, as a bitmask of GHOSTTY\\_FORMATTER\\_EXTRA\\_* values.

VT output is meant to be written to another terminal to recreate the screen. Without extras, it reproduces the text and how each cell is styled. Each extra adds sequences that restore one more piece of terminal state, such as the cursor position or the colors in the palette. Extras are only written when the format is GHOSTTY\\_FORMATTER\\_FORMAT\\_VT. Plain text and HTML output ignore them.

Set extras with GHOSTTY\\_FORMATTER\\_OPT\\_EXTRAS. A new formatter uses [`GHOSTTY_FORMATTER_EXTRAS_DEFAULT`](@ref). Use [`GHOSTTY_FORMATTER_EXTRAS_ALL`](@ref) to recreate the terminal as closely as possible.

The bits combine with `|`. To change one extra and keep the rest, read the current value first:

```c++
{.c}
 GhosttyFormatterExtras extras;
 ghostty_formatter_get(formatter, GHOSTTY_FORMATTER_OPT_EXTRAS, &extras);

 // Also restore the cursor position, but not the palette.
 extras |= GHOSTTY_FORMATTER_EXTRA_CURSOR;
 extras &= ~GHOSTTY_FORMATTER_EXTRA_PALETTE;

 ghostty_formatter_set(formatter, GHOSTTY_FORMATTER_OPT_EXTRAS, &extras);
```

` formatter`
"""
const GhosttyFormatterExtras = UInt32

"""
    GhosttyFormatterOption

Formatter options, set with [`ghostty_formatter_set`](@ref)() and read with [`ghostty_formatter_get`](@ref)().

A new formatter emits plain text with trailing whitespace trimmed. To change that, call [`ghostty_formatter_set`](@ref)() with a [`GhosttyFormatterOption`](@ref) and a pointer to the new value. Options stay set across format calls, and a change takes effect on the next one. [`ghostty_formatter_get`](@ref)() reads an option back.

| Option | Value type | Default | | --------------------------------- | ------------------------ | ---------------------------------- | | `GHOSTTY_FORMATTER_OPT_EMIT` | [`GhosttyFormatterFormat`](@ref) | `GHOSTTY_FORMATTER_FORMAT_PLAIN` | | `GHOSTTY_FORMATTER_OPT_UNWRAP` | `bool` | `false` | | `GHOSTTY_FORMATTER_OPT_TRIM` | `bool` | `true` | | `GHOSTTY_FORMATTER_OPT_SELECTION` | [`GhosttySelection`](@ref) | None (the whole screen) | | `GHOSTTY_FORMATTER_OPT_EXTRAS` | [`GhosttyFormatterExtras`](@ref) | [`GHOSTTY_FORMATTER_EXTRAS_DEFAULT`](@ref) |

Each option lists the type its value points to. To set an option, pass a pointer to a value of that type. To read one, pass a pointer to a variable of that type and the formatter writes the current value there.

` formatter`

| Enumerator                              | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| :-------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_FORMATTER\\_OPT\\_INVALID     | Not an option. Setting or reading it returns GHOSTTY\\_INVALID\\_VALUE.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_FORMATTER\\_OPT\\_EMIT        | The output format: plain text, VT sequences, or HTML.  Value type: [`GhosttyFormatterFormat`](@ref). Default: GHOSTTY\\_FORMATTER\\_FORMAT\\_PLAIN.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_FORMATTER\\_OPT\\_UNWRAP      | Join lines that wrapped because they were too long for the screen.  When false, each row of the screen is its own line in the output. When true, a line the terminal wrapped onto several rows comes out as one line, the way the program originally wrote it.  Value type: bool. Default: false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_FORMATTER\\_OPT\\_TRIM        | Remove spaces from the end of each line that has other text.  Blank lines at the end of the output are always removed. The one exception is VT output with trimming turned off, which keeps them so the output fills the same rows as the screen.  Value type: bool. Default: true.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_FORMATTER\\_OPT\\_SELECTION   | Format only the content inside a selection.  The formatter keeps its own copy of the selection, so the [`GhosttySelection`](@ref) you pass doesn't need to stay around. Like any selection, the copy is only valid until the next call that changes the terminal. After the terminal changes, set the selection again before you format, or clear it.  Set NULL to clear the selection and format the whole screen again. When no selection is set, [`ghostty_formatter_get`](@ref)() returns GHOSTTY\\_NO\\_VALUE.  To format the terminal's active selection, read it with GHOSTTY\\_TERMINAL\\_DATA\\_SELECTION and set it here. For the same text Ghostty copies to the clipboard, use plain output with GHOSTTY\\_FORMATTER\\_OPT\\_UNWRAP and GHOSTTY\\_FORMATTER\\_OPT\\_TRIM both true.  ```c++ {.c}  // Format only the selected text.  ghostty_formatter_set(formatter, GHOSTTY_FORMATTER_OPT_SELECTION, &selection);  ghostty_formatter_format_alloc(formatter, NULL, &buf, &len);   // Go back to formatting the whole screen.  ghostty_formatter_set(formatter, GHOSTTY_FORMATTER_OPT_SELECTION, NULL); ```  Value type: [`GhosttySelection`](@ref). Default: none, so the whole screen is formatted.  |
| GHOSTTY\\_FORMATTER\\_OPT\\_EXTRAS      | Terminal state to add to VT output. See [`GhosttyFormatterExtras`](@ref).  Value type: [`GhosttyFormatterExtras`](@ref). Default: [`GHOSTTY_FORMATTER_EXTRAS_DEFAULT`](@ref).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_FORMATTER\\_OPT\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
"""
@cenum GhosttyFormatterOption::UInt32 begin
    GHOSTTY_FORMATTER_OPT_INVALID = 0
    GHOSTTY_FORMATTER_OPT_EMIT = 1
    GHOSTTY_FORMATTER_OPT_UNWRAP = 2
    GHOSTTY_FORMATTER_OPT_TRIM = 3
    GHOSTTY_FORMATTER_OPT_SELECTION = 4
    GHOSTTY_FORMATTER_OPT_EXTRAS = 5
    GHOSTTY_FORMATTER_OPT_MAX_VALUE = 2147483647
end

"""
    ghostty_formatter_terminal_new(allocator, formatter, terminal)

Create a formatter for a terminal's active screen.

The terminal must outlive the formatter. The formatter stores a borrowed reference to the terminal and reads its current state on each format call.

The new formatter starts with the default for every option, as listed on [`GhosttyFormatterOption`](@ref). Change them with [`ghostty_formatter_set`](@ref)().

` formatter`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `formatter`: Pointer to store the created formatter handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`: The terminal to format (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_formatter_terminal_new(allocator, formatter, terminal)
    @ccall libghostty_vt.ghostty_formatter_terminal_new(allocator::Ptr{GhosttyAllocator}, formatter::Ptr{GhosttyFormatter}, terminal::GhosttyTerminal)::GhosttyResult
end

"""
    ghostty_formatter_set(formatter, option, value)

Set a formatter option.

`value` points to the option's new value. Its type is listed on each [`GhosttyFormatterOption`](@ref). The formatter copies the value, so it only has to be valid during the call. The change applies to every format call after this one.

Passing NULL for `value` puts the option back to its default, the same value a new formatter starts with.

```c++
{.c}
 GhosttyFormatterFormat emit = GHOSTTY_FORMATTER_FORMAT_HTML;
 ghostty_formatter_set(formatter, GHOSTTY_FORMATTER_OPT_EMIT, &emit);

 // Later, go back to the default (plain text).
 ghostty_formatter_set(formatter, GHOSTTY_FORMATTER_OPT_EMIT, NULL);
```

If the call fails, the option keeps its previous value.

` formatter`

# Arguments
* `formatter`: The formatter handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to set
* `value`: Pointer to the new value, or NULL to reset the option to its default
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `formatter` is NULL or the value is not valid for the option (such as an unknown format, an extras bit with no meaning, or a selection with a zeroed grid reference), or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_formatter_set(formatter, option, value)
    @ccall libghostty_vt.ghostty_formatter_set(formatter::GhosttyFormatter, option::GhosttyFormatterOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_formatter_get(formatter, option, out)

Read the current value of a formatter option.

`out` points to a variable of the type listed on the option. On success the formatter writes the option's value there.

```c++
{.c}
 bool trim;
 ghostty_formatter_get(formatter, GHOSTTY_FORMATTER_OPT_TRIM, &trim);
```

` formatter`

# Arguments
* `formatter`: The formatter handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to read
* `out`: Pointer that receives the value (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the option is not set (only possible for GHOSTTY\\_FORMATTER\\_OPT\\_SELECTION), GHOSTTY\\_INVALID\\_VALUE if `formatter` or `out` is NULL, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_formatter_get(formatter, option, out)
    @ccall libghostty_vt.ghostty_formatter_get(formatter::GhosttyFormatter, option::GhosttyFormatterOption, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_formatter_format(formatter, writer)

Run the formatter and stream output to a writer.

Each call formats the current terminal state and invokes the writer synchronously as output becomes available. The callback may be called more than once and must not call formatter or terminal APIs using the same formatter or its terminal.

If an error occurs, the writer may already contain a partial formatted output. The operation cannot be resumed from that partial output. This function does not flush or make your destination durable.

` formatter`

# Arguments
* `formatter`: The formatter handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `writer`: Destination writer whose write callback must not be NULL
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_IO\\_ERROR if the writer rejects output, GHOSTTY\\_LIMIT\\_EXCEEDED if output accounting overflows, or GHOSTTY\\_INVALID\\_VALUE if an argument is invalid
"""
function ghostty_formatter_format(formatter, writer)
    @ccall libghostty_vt.ghostty_formatter_format(formatter::GhosttyFormatter, writer::GhosttyWriter)::GhosttyResult
end

"""
    ghostty_formatter_format_buf(formatter, buf, buf_len, out_written)

Run the formatter and produce output into your buffer.

Each call formats the current terminal state. Pass NULL for buf to query the required buffer size without writing any output. out\\_written receives the required size and the return value is GHOSTTY\\_OUT\\_OF\\_SPACE.

Empty output needs no space, so that query returns GHOSTTY\\_SUCCESS with a size of 0 instead. Handle both results:

```c++
{.c}
 size_t needed = 0;
 GhosttyResult result = ghostty_formatter_format_buf(formatter, NULL, 0, &needed);
 if (result == GHOSTTY_SUCCESS) return; // Nothing to format.
 if (result != GHOSTTY_OUT_OF_SPACE) return; // A real error.

 uint8_t* buf = malloc(needed);
 size_t written = 0;
 result = ghostty_formatter_format_buf(formatter, buf, needed, &written);
```

If the buffer is too small, returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets out\\_written to the required size. You can then retry with a larger buffer.

` formatter`

# Arguments
* `formatter`: The formatter handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `buf`: Pointer to the output buffer, or NULL to query size
* `buf_len`: Length of the output buffer in bytes
* `out_written`: Pointer to receive the number of bytes written, or the required size on failure (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_formatter_format_buf(formatter, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_formatter_format_buf(formatter::GhosttyFormatter, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_formatter_format_alloc(formatter, allocator, out_ptr, out_len)

Run the formatter and return an allocated buffer with the output.

Each call formats the current terminal state. The buffer is allocated using the provided allocator (or the default allocator if NULL). You are responsible for freeing the returned buffer with [`ghostty_free`](@ref)(), passing the same allocator (or NULL for the default) that was used for the allocation. Empty output returns GHOSTTY\\_SUCCESS with *out\\_ptr set to NULL and *out\\_len set to zero. This result can be passed to [`ghostty_free`](@ref)().

` formatter`

# Arguments
* `formatter`: The formatter handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `out_ptr`: Pointer to receive the allocated buffer (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_len`: Pointer to receive the length of the output in bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY on allocation failure, GHOSTTY\\_INVALID\\_VALUE if an output pointer is NULL
"""
function ghostty_formatter_format_alloc(formatter, allocator, out_ptr, out_len)
    @ccall libghostty_vt.ghostty_formatter_format_alloc(formatter::GhosttyFormatter, allocator::Ptr{GhosttyAllocator}, out_ptr::Ptr{Ptr{UInt8}}, out_len::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_formatter_free(formatter)

Free a formatter instance.

Releases all resources associated with the formatter. After this call, the formatter handle becomes invalid.

` formatter`

# Arguments
* `formatter`: The formatter handle to free (may be NULL)
"""
function ghostty_formatter_free(formatter)
    @ccall libghostty_vt.ghostty_formatter_free(formatter::GhosttyFormatter)::Cvoid
end

"""
    GhosttyRenderStateDirty

Dirty state of a render state after update.

` render`

| Enumerator                                     | Note                                                      |
| :--------------------------------------------- | :-------------------------------------------------------- |
| GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_FALSE       | Not dirty at all; rendering can be skipped.               |
| GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_PARTIAL     | Some rows changed; renderer can redraw incrementally.     |
| GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_FULL        | Global state changed; renderer should redraw everything.  |
| GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_MAX\\_VALUE |                                                           |
"""
@cenum GhosttyRenderStateDirty::UInt32 begin
    GHOSTTY_RENDER_STATE_DIRTY_FALSE = 0
    GHOSTTY_RENDER_STATE_DIRTY_PARTIAL = 1
    GHOSTTY_RENDER_STATE_DIRTY_FULL = 2
    GHOSTTY_RENDER_STATE_DIRTY_MAX_VALUE = 2147483647
end

"""
    GhosttyRenderStateOverscan

A number of rows above and below the viewport.

This is used both to request overscan with GHOSTTY\\_RENDER\\_STATE\\_OPT\\_OVERSCAN and to report how many rows an update captured with GHOSTTY\\_RENDER\\_STATE\\_DATA\\_OVERSCAN. See guide-rendering-overscan for how the extra rows are used.

` render`

| Field | Note                                    |
| :---- | :-------------------------------------- |
| above | Rows above the top of the viewport.     |
| below | Rows below the bottom of the viewport.  |
"""
struct GhosttyRenderStateOverscan
    above::UInt16
    below::UInt16
end

"""
    GhosttyRenderStateRowId

The identity of a row across render state updates.

Treat this value as opaque. Two ids are the same when both words are equal. No other comparison or interpretation is meaningful, and the contents may change between library versions. A zero-initialized id is never valid, so it can be used to mean "no row".

```c++
{.c}
 bool same = a.bits[0] == b.bits[0] && a.bits[1] == b.bits[1];
```

See guide-rendering-row-identity for how to use ids.

` render`

| Field | Note                                              |
| :---- | :------------------------------------------------ |
| bits  | Opaque id data. Compare both words for equality.  |
"""
struct GhosttyRenderStateRowId
    bits::NTuple{2, UInt64}
end

"""
    GhosttyRenderStateData

Queryable data kinds for [`ghostty_render_state_get`](@ref)().

` render`

| Enumerator                                                        | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| :---------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_INVALID                         | Invalid / sentinel value.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLS                            | Viewport width in cells (uint16\\_t).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_ROWS                            | Viewport height in cells (uint16\\_t). This does not include overscan rows.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_DIRTY                           | Current dirty state ([`GhosttyRenderStateDirty`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_ROW\\_ITERATOR                  | Populate a pre-allocated [`GhosttyRenderStateRowIterator`](@ref) with row data from the render state ([`GhosttyRenderStateRowIterator`](@ref)). Row data is only valid as long as the underlying render state is not updated. It is unsafe to use row data after updating the render state.  The iterator visits every row the last update captured, from top to bottom. This is exactly the viewport unless overscan was requested with GHOSTTY\\_RENDER\\_STATE\\_OPT\\_OVERSCAN.                                                                                                                                  |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLOR\\_BACKGROUND              | Default/current background color ([`GhosttyColorRgb`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLOR\\_FOREGROUND              | Default/current foreground color ([`GhosttyColorRgb`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLOR\\_CURSOR                  | Cursor color when explicitly set by terminal state ([`GhosttyColorRgb`](@ref)). Returns GHOSTTY\\_NO\\_VALUE if no explicit cursor color is set.                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLOR\\_CURSOR\\_HAS\\_VALUE    | Whether an explicit cursor color is set (bool).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLOR\\_PALETTE                 | The active 256-color palette ([`GhosttyColorRgb`](@ref)[256]).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_VISUAL\\_STYLE         | The visual style of the cursor ([`GhosttyCursorStyle`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_VISIBLE                | Whether the cursor is visible based on terminal modes (bool).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_BLINKING               | Whether the cursor should blink based on terminal modes (bool).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_PASSWORD\\_INPUT       | Whether the cursor is at a password input field (bool).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_VIEWPORT\\_HAS\\_VALUE | Whether the cursor is visible within the viewport (bool). If false, querying the cursor viewport position values returns GHOSTTY\\_NO\\_VALUE.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_VIEWPORT\\_X           | Cursor viewport x position in cells (uint16\\_t). Returns GHOSTTY\\_NO\\_VALUE when CURSOR\\_VIEWPORT\\_HAS\\_VALUE is false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_VIEWPORT\\_Y           | Cursor viewport y position in cells (uint16\\_t). Returns GHOSTTY\\_NO\\_VALUE when CURSOR\\_VIEWPORT\\_HAS\\_VALUE is false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR\\_VIEWPORT\\_WIDE\\_TAIL | Whether the cursor is on the tail of a wide character (bool). Returns GHOSTTY\\_NO\\_VALUE when CURSOR\\_VIEWPORT\\_HAS\\_VALUE is false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR                          | All cursor state in one sized struct ([`GhosttyRenderStateCursor`](@ref)). Initialize the output with [`GHOSTTY_INIT_SIZED`](@ref) before querying.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLORS                          | All render-state colors in one sized struct ([`GhosttyRenderStateColors`](@ref)). Initialize the output with [`GHOSTTY_INIT_SIZED`](@ref) before querying.                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_OVERSCAN                        | How many overscan rows the last update captured on each side ([`GhosttyRenderStateOverscan`](@ref)). This is never more than the request. It is less when those rows don't exist: `above` is smaller near the top of the scrollback, and `below` is zero while the viewport is scrolled to the bottom.                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_OVERSCAN\\_REQUEST              | The overscan request most recently set with GHOSTTY\\_RENDER\\_STATE\\_OPT\\_OVERSCAN ([`GhosttyRenderStateOverscan`](@ref)). The next update uses this request. Both sides are zero if it was never set.                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_IMAGE\\_ITERATOR                | Populate an existing [`GhosttyRenderStateImageIterator`](@ref) with the image placements found by the last update. See guide-images-drawing.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_IMAGE\\_PLACEMENTS\\_GENERATION | A value (uint64\\_t) that changes whenever an update changes the placements that GHOSTTY\\_RENDER\\_STATE\\_DATA\\_IMAGE\\_ITERATOR returns. If it matches the value from the last time you read the iterator, the placements are the same and you don't need to read them again. See guide-images-changes for an example and for exactly when the value changes.  The value belongs to the whole list. To know when the pixels of a single image changed, use GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_IMAGE\\_GENERATION.  Only compare the value for equality. It is always 0 when Kitty graphics are disabled.  |
| GHOSTTY\\_RENDER\\_STATE\\_DATA\\_MAX\\_VALUE                     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
"""
@cenum GhosttyRenderStateData::UInt32 begin
    GHOSTTY_RENDER_STATE_DATA_INVALID = 0
    GHOSTTY_RENDER_STATE_DATA_COLS = 1
    GHOSTTY_RENDER_STATE_DATA_ROWS = 2
    GHOSTTY_RENDER_STATE_DATA_DIRTY = 3
    GHOSTTY_RENDER_STATE_DATA_ROW_ITERATOR = 4
    GHOSTTY_RENDER_STATE_DATA_COLOR_BACKGROUND = 5
    GHOSTTY_RENDER_STATE_DATA_COLOR_FOREGROUND = 6
    GHOSTTY_RENDER_STATE_DATA_COLOR_CURSOR = 7
    GHOSTTY_RENDER_STATE_DATA_COLOR_CURSOR_HAS_VALUE = 8
    GHOSTTY_RENDER_STATE_DATA_COLOR_PALETTE = 9
    GHOSTTY_RENDER_STATE_DATA_CURSOR_VISUAL_STYLE = 10
    GHOSTTY_RENDER_STATE_DATA_CURSOR_VISIBLE = 11
    GHOSTTY_RENDER_STATE_DATA_CURSOR_BLINKING = 12
    GHOSTTY_RENDER_STATE_DATA_CURSOR_PASSWORD_INPUT = 13
    GHOSTTY_RENDER_STATE_DATA_CURSOR_VIEWPORT_HAS_VALUE = 14
    GHOSTTY_RENDER_STATE_DATA_CURSOR_VIEWPORT_X = 15
    GHOSTTY_RENDER_STATE_DATA_CURSOR_VIEWPORT_Y = 16
    GHOSTTY_RENDER_STATE_DATA_CURSOR_VIEWPORT_WIDE_TAIL = 17
    GHOSTTY_RENDER_STATE_DATA_CURSOR = 18
    GHOSTTY_RENDER_STATE_DATA_COLORS = 19
    GHOSTTY_RENDER_STATE_DATA_OVERSCAN = 20
    GHOSTTY_RENDER_STATE_DATA_OVERSCAN_REQUEST = 21
    GHOSTTY_RENDER_STATE_DATA_IMAGE_ITERATOR = 22
    GHOSTTY_RENDER_STATE_DATA_IMAGE_PLACEMENTS_GENERATION = 23
    GHOSTTY_RENDER_STATE_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttyRenderStateOption

Settable options for [`ghostty_render_state_set`](@ref)().

` render`

| Enumerator                                   | Note                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| :------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_RENDER\\_STATE\\_OPT\\_INVALID     | Not a real option. [`ghostty_render_state_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                                                                                                                                                                                                                      |
| GHOSTTY\\_RENDER\\_STATE\\_OPT\\_DIRTY       | Set dirty state ([`GhosttyRenderStateDirty`](@ref)). Each update sets this value itself, so there is no default to restore and a NULL value returns GHOSTTY\\_INVALID\\_VALUE.                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_RENDER\\_STATE\\_OPT\\_OVERSCAN    | Request overscan rows above and below the viewport ([`GhosttyRenderStateOverscan`](@ref)). The request takes effect on the next update and stays in effect until it is changed. Both sides are zero by default, which captures only the viewport. A NULL value restores that default. The rows of the last update can still be read after changing the request. Expect a full redraw on the update after a change. See guide-rendering-overscan.  |
| GHOSTTY\\_RENDER\\_STATE\\_OPT\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
"""
@cenum GhosttyRenderStateOption::UInt32 begin
    GHOSTTY_RENDER_STATE_OPT_INVALID = 0
    GHOSTTY_RENDER_STATE_OPT_DIRTY = 1
    GHOSTTY_RENDER_STATE_OPT_OVERSCAN = 2
    GHOSTTY_RENDER_STATE_OPT_MAX_VALUE = 2147483647
end

"""
    GhosttyImageProtocol

The image protocols that a terminal supports.

The render state uses this to say which protocol each image placement came from (see GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_PROTOCOL). Use it to decide where to read the image's pixels. Unlike the other image types here, the name has no RenderState prefix, because the protocol isn't specific to the render state.

New protocols may be added in later versions. Skip placements with a protocol you don't support.

` render`

| Enumerator                               | Note                                                                                        |
| :--------------------------------------- | :------------------------------------------------------------------------------------------ |
| GHOSTTY\\_IMAGE\\_PROTOCOL\\_KITTY       | The Kitty graphics protocol. Read the image with [`ghostty_kitty_graphics_image`](@ref)().  |
| GHOSTTY\\_IMAGE\\_PROTOCOL\\_MAX\\_VALUE |                                                                                             |
"""
@cenum GhosttyImageProtocol::UInt32 begin
    GHOSTTY_IMAGE_PROTOCOL_KITTY = 0
    GHOSTTY_IMAGE_PROTOCOL_MAX_VALUE = 2147483647
end

"""
    GhosttyRenderStateKittyPlacementKind

The kinds of Kitty graphics placements in a render state's image list.

Read with GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_KITTY\\_KIND. Most renderers can draw every kind the same way. The kind is useful when you need to tell them apart, for example for debugging.

` render`

| Enumerator                                                        | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| :---------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_RENDER\\_STATE\\_KITTY\\_PLACEMENT\\_KIND\\_VIRTUAL     | Part of a virtual placement: one run of neighboring placeholder cells in a single row. It is always one row tall.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_RENDER\\_STATE\\_KITTY\\_PLACEMENT\\_KIND\\_RELATIVE    | A placement that a program positioned relative to another placement, its parent. Kitty graphics lets a program attach one image to another so that they move together. The parent is either a virtual or a fixed placement, possibly through a chain of other relative placements.  With a virtual parent, the position depends on the placeholder cells. It is measured from the top-left corner of the parent's cells on screen. That is the leftmost column and the topmost row that any of its cells use, which matches Kitty. If none of those cells are in the captured rows (the viewport plus any overscan), the relative placement is not included.  With a fixed parent, the position is measured from the parent's cell. The relative placement is included at its full size when any part of it is in the captured rows, even if the parent isn't, so it may need to be clipped when drawn.  See guide-images-relative.  |
| GHOSTTY\\_RENDER\\_STATE\\_KITTY\\_PLACEMENT\\_KIND\\_FIXED       | A placement at a cell on the screen. It scrolls with the text, like a line of output would. Its z-index is the one the program chose, so it can be in any layer.  It is included at its full size when any part of it is in the captured rows, so it may need to be clipped when drawn. See guide-images-clipping.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_RENDER\\_STATE\\_KITTY\\_PLACEMENT\\_KIND\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
"""
@cenum GhosttyRenderStateKittyPlacementKind::UInt32 begin
    GHOSTTY_RENDER_STATE_KITTY_PLACEMENT_KIND_VIRTUAL = 0
    GHOSTTY_RENDER_STATE_KITTY_PLACEMENT_KIND_RELATIVE = 1
    GHOSTTY_RENDER_STATE_KITTY_PLACEMENT_KIND_FIXED = 2
    GHOSTTY_RENDER_STATE_KITTY_PLACEMENT_KIND_MAX_VALUE = 2147483647
end

"""
    GhosttyRenderStateImageData

Data you can read about the current placement of an image iterator with [`ghostty_render_state_image_get`](@ref)().

The type in parentheses is the type that the `out` pointer must point to. All pixel values use the cell size set with [`ghostty_terminal_resize`](@ref)().

Some values only apply to one protocol, and have the protocol in their name. For example, GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_KITTY\\_KIND only applies to Kitty graphics placements. Reading one of these for a placement from another protocol returns GHOSTTY\\_NO\\_VALUE.

` render`

| Enumerator                                                       | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| :--------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_INVALID                | Invalid value. Querying it returns GHOSTTY\\_INVALID\\_VALUE.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_PROTOCOL               | The protocol the image came from ([`GhosttyImageProtocol`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_IMAGE\\_ID             | The ID of the image to draw (uint32\\_t). IDs are only unique within one protocol, so look the image up in the storage of its protocol. For Kitty graphics, use [`ghostty_kitty_graphics_image`](@ref)().                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_IMAGE\\_GENERATION     | The generation of the image's contents (uint64\\_t). It changes whenever the image's pixels change, including when an animation moves to a new frame. Use it as part of your texture cache key, with the protocol and image ID: if it matches the texture you have, you don't need to read the pixels again. For Kitty graphics, this is the same value as GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_GENERATION.  To know when the list of placements as a whole changed, use GHOSTTY\\_RENDER\\_STATE\\_DATA\\_IMAGE\\_PLACEMENTS\\_GENERATION.  |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_LAYER                  | The layer to draw the image in ([`GhosttyImageLayer`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_Z                      | The z-index (int32\\_t), which orders images within a layer. Images with a lower z-index are drawn first. The value comes from the image's protocol. For Kitty graphics, it is the z-index the program asked for, and virtual placements are always -1.                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_VIEWPORT\\_COL         | The column of the top-left cell (int32\\_t), where 0 is the leftmost column of the viewport. Fixed and relative placements are reported at their full size, so they can start to the left of the viewport, which gives a negative value. Virtual placements never do. See guide-images-clipping.                                                                                                                                                                                                                                                    |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_VIEWPORT\\_ROW         | The row of the top-left cell (int32\\_t), where 0 is the top row of the viewport. A placement in an overscan row above the viewport has a negative row, the same as GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_VIEWPORT\\_Y. Fixed and relative placements are reported at their full size, so they can also start above the first overscan row. Virtual placements are always inside the captured rows. See guide-images-clipping.                                                                                                                    |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_GRID\\_COLS            | The number of columns of cells the placement covers (uint32\\_t).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_GRID\\_ROWS            | The number of rows of cells the placement covers (uint32\\_t).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_CELL\\_OFFSET\\_X      | How far the image starts from the left edge of the top-left cell, in pixels (uint32\\_t). For a virtual placement, an image that is narrower than its cells is centered, so this can be larger than a cell is wide. For fixed and relative placements, this is the offset the program asked for, limited to less than one cell.                                                                                                                                                                                                                     |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_CELL\\_OFFSET\\_Y      | How far the image starts from the top edge of the top-left cell, in pixels (uint32\\_t). For a virtual placement, an image that is shorter than its cells is centered, so this can be larger than a cell is tall. For fixed and relative placements, this is the offset the program asked for, limited to less than one cell.                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_PIXEL\\_WIDTH          | The width to draw the image at, in pixels (uint32\\_t).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_PIXEL\\_HEIGHT         | The height to draw the image at, in pixels (uint32\\_t).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_SOURCE\\_X             | The left edge of the part of the image to draw, in image pixels (uint32\\_t).                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_SOURCE\\_Y             | The top edge of the part of the image to draw, in image pixels (uint32\\_t).                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_SOURCE\\_WIDTH         | The width of the part of the image to draw, in image pixels (uint32\\_t). Scale it to PIXEL\\_WIDTH when drawing.                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_SOURCE\\_HEIGHT        | The height of the part of the image to draw, in image pixels (uint32\\_t). Scale it to PIXEL\\_HEIGHT when drawing.                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_KITTY\\_PLACEMENT\\_ID | Kitty graphics only: the placement ID (uint32\\_t), or 0 if there isn't one.  For a virtual placement, this is the placement ID that the placeholder cells ask for. Cells that don't ask for one show the image's virtual placement, whichever it is, and report 0. For a fixed or relative placement, this is the ID the program gave it, or 0 if it didn't give one.                                                                                                                                                                              |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_KITTY\\_KIND           | Kitty graphics only: the kind of placement ([`GhosttyRenderStateKittyPlacementKind`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_MAX\\_VALUE            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
"""
@cenum GhosttyRenderStateImageData::UInt32 begin
    GHOSTTY_RENDER_STATE_IMAGE_DATA_INVALID = 0
    GHOSTTY_RENDER_STATE_IMAGE_DATA_PROTOCOL = 1
    GHOSTTY_RENDER_STATE_IMAGE_DATA_IMAGE_ID = 2
    GHOSTTY_RENDER_STATE_IMAGE_DATA_IMAGE_GENERATION = 3
    GHOSTTY_RENDER_STATE_IMAGE_DATA_LAYER = 4
    GHOSTTY_RENDER_STATE_IMAGE_DATA_Z = 5
    GHOSTTY_RENDER_STATE_IMAGE_DATA_VIEWPORT_COL = 6
    GHOSTTY_RENDER_STATE_IMAGE_DATA_VIEWPORT_ROW = 7
    GHOSTTY_RENDER_STATE_IMAGE_DATA_GRID_COLS = 8
    GHOSTTY_RENDER_STATE_IMAGE_DATA_GRID_ROWS = 9
    GHOSTTY_RENDER_STATE_IMAGE_DATA_CELL_OFFSET_X = 10
    GHOSTTY_RENDER_STATE_IMAGE_DATA_CELL_OFFSET_Y = 11
    GHOSTTY_RENDER_STATE_IMAGE_DATA_PIXEL_WIDTH = 12
    GHOSTTY_RENDER_STATE_IMAGE_DATA_PIXEL_HEIGHT = 13
    GHOSTTY_RENDER_STATE_IMAGE_DATA_SOURCE_X = 14
    GHOSTTY_RENDER_STATE_IMAGE_DATA_SOURCE_Y = 15
    GHOSTTY_RENDER_STATE_IMAGE_DATA_SOURCE_WIDTH = 16
    GHOSTTY_RENDER_STATE_IMAGE_DATA_SOURCE_HEIGHT = 17
    GHOSTTY_RENDER_STATE_IMAGE_DATA_KITTY_PLACEMENT_ID = 18
    GHOSTTY_RENDER_STATE_IMAGE_DATA_KITTY_KIND = 19
    GHOSTTY_RENDER_STATE_IMAGE_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttyRenderStateRowData

Queryable data kinds for [`ghostty_render_state_row_get`](@ref)().

` render`

| Enumerator                                           | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_INVALID      | Invalid / sentinel value.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_DIRTY        | Whether the current row is dirty (bool).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_RAW          | The raw row value ([`GhosttyRow`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_CELLS        | Populate a pre-allocated [`GhosttyRenderStateRowCells`](@ref) with cell data for the current row ([`GhosttyRenderStateRowCells`](@ref)). Cell data is only  valid as long as the underlying render state is not updated.  It is unsafe to use cell data after updating the render state.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_SELECTION    | Row-local selected cell range ([`GhosttyRenderStateRowSelection`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_CELLS\\_RAW  | A borrowed view of the raw cell values for the current row ([`GhosttyCellsView`](@ref)). One value per column, identical to querying GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_RAW for each cell. The view is only valid as long as the underlying render state is not updated; it is unsafe to use after updating the render state.  This is the bulk alternative to iterating cells one at a time. It lets callers with expensive call boundaries (e.g. WebAssembly embedders) read an entire row with a single call.  Bit positions aren't protected by ABI, so callers should parse them out of the manifest from [`ghostty_type_json`](@ref). Callers with access to the C header or without high FFI costs should use [`ghostty_cell_get`](@ref).  |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_VIEWPORT\\_Y | The row's position relative to the top of the viewport (int32\\_t). Viewport rows are 0 through rows - 1. Overscan rows above the viewport are negative, and overscan rows below it start at rows. Without overscan, this equals the y reported by [`ghostty_render_state_row_iterator_next_dirty`](@ref)().                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_ID           | The row's identity across updates ([`GhosttyRenderStateRowId`](@ref)). This works with or without overscan. See guide-rendering-row-identity.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_MAX\\_VALUE  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
"""
@cenum GhosttyRenderStateRowData::UInt32 begin
    GHOSTTY_RENDER_STATE_ROW_DATA_INVALID = 0
    GHOSTTY_RENDER_STATE_ROW_DATA_DIRTY = 1
    GHOSTTY_RENDER_STATE_ROW_DATA_RAW = 2
    GHOSTTY_RENDER_STATE_ROW_DATA_CELLS = 3
    GHOSTTY_RENDER_STATE_ROW_DATA_SELECTION = 4
    GHOSTTY_RENDER_STATE_ROW_DATA_CELLS_RAW = 5
    GHOSTTY_RENDER_STATE_ROW_DATA_VIEWPORT_Y = 6
    GHOSTTY_RENDER_STATE_ROW_DATA_ID = 7
    GHOSTTY_RENDER_STATE_ROW_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttyRenderStateRowOption

Settable options for [`ghostty_render_state_row_set`](@ref)().

` render`

| Enumerator                                         | Note                                                                                                                                                                                              |
| :------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_OPT\\_INVALID     | Not a real option. [`ghostty_render_state_row_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.  |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_OPT\\_DIRTY       | Set dirty state for the current row (bool). Each update sets this value itself, so there is no default to restore and a NULL value returns GHOSTTY\\_INVALID\\_VALUE.                             |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_OPT\\_MAX\\_VALUE |                                                                                                                                                                                                   |
"""
@cenum GhosttyRenderStateRowOption::UInt32 begin
    GHOSTTY_RENDER_STATE_ROW_OPT_INVALID = 0
    GHOSTTY_RENDER_STATE_ROW_OPT_DIRTY = 1
    GHOSTTY_RENDER_STATE_ROW_OPT_MAX_VALUE = 2147483647
end

"""
    GhosttyRenderStateRowSelection

Row-local selection range.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)() before querying GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_SELECTION. See sized-structs.

Querying GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_SELECTION returns GHOSTTY\\_NO\\_VALUE if the current row does not intersect the current selection.

` render`

| Field     | Note                                                                                            |
| :-------- | :---------------------------------------------------------------------------------------------- |
| size      | Size of this struct in bytes. Must be set to sizeof([`GhosttyRenderStateRowSelection`](@ref)).  |
| start\\_x | Start column of the row-local selection range, inclusive.                                       |
| end\\_x   | End column of the row-local selection range, inclusive.                                         |
"""
struct GhosttyRenderStateRowSelection
    size::Csize_t
    start_x::UInt16
    end_x::UInt16
end

"""
    GhosttyRenderStateCursor

Render-state cursor information.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)() before querying GHOSTTY\\_RENDER\\_STATE\\_DATA\\_CURSOR. See sized-structs.

When viewport\\_has\\_value is false, viewport\\_x, viewport\\_y, and wide\\_tail contain undefined data and must not be read.

` render`

| Field                  | Note                                                                                      |
| :--------------------- | :---------------------------------------------------------------------------------------- |
| size                   | Size of this struct in bytes. Must be set to sizeof([`GhosttyRenderStateCursor`](@ref)).  |
| viewport\\_has\\_value | Whether the cursor is visible within the viewport.                                        |
| viewport\\_x           | Cursor viewport x position in cells.                                                      |
| viewport\\_y           | Cursor viewport y position in cells.                                                      |
| wide\\_tail            | Whether the cursor is on the tail of a wide character.                                    |
| visible                | Whether the cursor is visible based on terminal modes.                                    |
| blinking               | Whether the cursor should blink based on terminal modes.                                  |
| password\\_input       | Whether the cursor is at a password input field.                                          |
| visual\\_style         | The visual style of the cursor.                                                           |
"""
struct GhosttyRenderStateCursor
    size::Csize_t
    viewport_has_value::Bool
    viewport_x::UInt16
    viewport_y::UInt16
    wide_tail::Bool
    visible::Bool
    blinking::Bool
    password_input::Bool
    visual_style::GhosttyCursorStyle
end

"""
    GhosttyRenderStateColors

Render-state color information.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)() before querying GHOSTTY\\_RENDER\\_STATE\\_DATA\\_COLORS. See sized-structs.

Example:

```c++
 GhosttyRenderStateColors colors = GHOSTTY_INIT_SIZED(GhosttyRenderStateColors);
 GhosttyResult result = ghostty_render_state_get(
     state, GHOSTTY_RENDER_STATE_DATA_COLORS, &colors);
```

` render`

| Field                | Note                                                                                                                                                    |
| :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| size                 | Size of this struct in bytes. Must be set to sizeof([`GhosttyRenderStateColors`](@ref)).                                                                |
| background           | The default/current background color for the render state.                                                                                              |
| foreground           | The default/current foreground color for the render state.                                                                                              |
| cursor               | The cursor color when explicitly set by terminal state.                                                                                                 |
| cursor\\_has\\_value | True when cursor contains a valid explicit cursor color value.  If this is false, the cursor color should be ignored; it will  contain undefined data.  |
| palette              | The active 256-color palette for this render state.                                                                                                     |
"""
struct GhosttyRenderStateColors
    size::Csize_t
    background::GhosttyColorRgb
    foreground::GhosttyColorRgb
    cursor::GhosttyColorRgb
    cursor_has_value::Bool
    palette::NTuple{256, GhosttyColorRgb}
end

"""
    ghostty_render_state_new(allocator, state)

Create a new render state instance.

` render`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `state`: Pointer to store the created render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY on allocation failure
"""
function ghostty_render_state_new(allocator, state)
    @ccall libghostty_vt.ghostty_render_state_new(allocator::Ptr{GhosttyAllocator}, state::Ptr{GhosttyRenderState})::GhosttyResult
end

"""
    ghostty_render_state_free(state)

Free a render state instance.

Releases all resources associated with the render state. After this call, the render state handle becomes invalid.

` render`

# Arguments
* `state`: The render state handle to free (may be NULL)
"""
function ghostty_render_state_free(state)
    @ccall libghostty_vt.ghostty_render_state_free(state::GhosttyRenderState)::Cvoid
end

"""
    ghostty_render_state_update(state, terminal)

Update a render state instance from a terminal.

This consumes terminal/screen dirty state in the same way as the internal render state update path.

This is a convenience function that performs a full update in one call, equivalent to [`ghostty_render_state_begin_update`](@ref) immediately followed by [`ghostty_render_state_end_update`](@ref). Callers that hold a lock over the terminal state should prefer calling the two phases directly so that the lock is only held for the begin phase.

` render`

# Arguments
* `state`: The render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`: The terminal handle to read from (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `state` or `terminal` is NULL, GHOSTTY\\_OUT\\_OF\\_MEMORY if updating the state requires allocation and that allocation fails
"""
function ghostty_render_state_update(state, terminal)
    @ccall libghostty_vt.ghostty_render_state_update(state::GhosttyRenderState, terminal::GhosttyTerminal)::GhosttyResult
end

"""
    ghostty_render_state_begin_update(state, terminal)

Begin an update of a render state instance from a terminal.

Every begin must be completed with a [`ghostty_render_state_end_update`](@ref) call before the render state is read.

This two-phase structure exists for callers that synchronize access to the terminal state (e.g. with a lock shared with an IO thread): only this function requires terminal access, so a caller can hold its lock for this call only and then call [`ghostty_render_state_end_update`](@ref) after releasing it. The end phase exclusively reads and writes memory owned by the render state, so it is safe to call while the terminal is being modified.

Work that doesn't require terminal access may be deferred to the end phase to keep this call (and therefore lock hold time) as short as possible. You must treat the render state as incomplete until [`ghostty_render_state_end_update`](@ref) is called.

This consumes terminal/screen dirty state in the same way as the internal render state update path.

` render`

# Arguments
* `state`: The render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`: The terminal handle to read from (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `state` or `terminal` is NULL, GHOSTTY\\_OUT\\_OF\\_MEMORY if updating the state requires allocation and that allocation fails
"""
function ghostty_render_state_begin_update(state, terminal)
    @ccall libghostty_vt.ghostty_render_state_begin_update(state::GhosttyRenderState, terminal::GhosttyTerminal)::GhosttyResult
end

"""
    ghostty_render_state_end_update(state)

Complete a prior [`ghostty_render_state_begin_update`](@ref) call by performing any deferred work.

This only reads and writes memory owned by the render state, so it is safe to call while the terminal is being modified (no terminal synchronization is required). Calling this without a prior begin is a safe no-op.

` render`

# Arguments
* `state`: The render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `state` is NULL
"""
function ghostty_render_state_end_update(state)
    @ccall libghostty_vt.ghostty_render_state_end_update(state::GhosttyRenderState)::GhosttyResult
end

"""
    ghostty_render_state_clean(state)

Mark all dirty render-state data as consumed.

This sets the global dirty state to GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_FALSE and clears every per-row dirty flag. It is idempotent and does not modify cell contents or dirty state owned by the terminal. Call this only after a complete frame has been rendered successfully; partial consumers should use [`ghostty_render_state_set`](@ref)() and [`ghostty_render_state_row_set`](@ref)() instead.

` render`

# Arguments
* `state`: The render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `state` is NULL
"""
function ghostty_render_state_clean(state)
    @ccall libghostty_vt.ghostty_render_state_clean(state::GhosttyRenderState)::GhosttyResult
end

"""
    ghostty_render_state_get(state, data, out)

Get a value from a render state.

The `out` pointer must point to a value of the type corresponding to the requested data kind (see [`GhosttyRenderStateData`](@ref)).

` render`

# Arguments
* `state`: The render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: The data kind to query
* `out`:\\[out\\] Pointer to receive the queried value
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if `data` has no value right now, GHOSTTY\\_INVALID\\_VALUE if `state` or `out` is NULL or a sized output struct is smaller than its base layout, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_render_state_get(state, data, out)
    @ccall libghostty_vt.ghostty_render_state_get(state::GhosttyRenderState, data::GhosttyRenderStateData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_render_state_get_multi(state, count, keys, values, out_written)

Get multiple data fields from a render state in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_render_state_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result.

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` render`

# Arguments
* `state`: The render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_render_state_get_multi(state, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_render_state_get_multi(state::GhosttyRenderState, count::Csize_t, keys::Ptr{GhosttyRenderStateData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_render_state_set(state, option, value)

Set an option on a render state.

The `value` pointer must point to a value of the type corresponding to the requested option kind (see [`GhosttyRenderStateOption`](@ref)).

Passing NULL for `value` restores the option's default. Options that have no default, such as GHOSTTY\\_RENDER\\_STATE\\_OPT\\_DIRTY, return GHOSTTY\\_INVALID\\_VALUE for NULL instead.

```c++
{.c}
 GhosttyRenderStateOverscan overscan = { .above = 4, .below = 4 };
 ghostty_render_state_set(state, GHOSTTY_RENDER_STATE_OPT_OVERSCAN,
                          &overscan);

 // Later, go back to capturing only the viewport.
 ghostty_render_state_set(state, GHOSTTY_RENDER_STATE_OPT_OVERSCAN, NULL);
```

` render`

# Arguments
* `state`: The render state handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to set
* `value`:\\[in\\] Pointer to the value to set, or NULL to restore the option's default
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `state` is NULL, `value` is out of range, or `value` is NULL for an option with no default, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_render_state_set(state, option, value)
    @ccall libghostty_vt.ghostty_render_state_set(state::GhosttyRenderState, option::GhosttyRenderStateOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_render_state_row_iterator_new(allocator, out_iterator)

Create a new row iterator instance.

All fields except the allocator are left undefined until populated via [`ghostty_render_state_get`](@ref)() with GHOSTTY\\_RENDER\\_STATE\\_DATA\\_ROW\\_ITERATOR.

` render`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `out_iterator`:\\[out\\] On success, receives the created iterator handle
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY on allocation failure, GHOSTTY\\_INVALID\\_VALUE if `out_iterator` is NULL
"""
function ghostty_render_state_row_iterator_new(allocator, out_iterator)
    @ccall libghostty_vt.ghostty_render_state_row_iterator_new(allocator::Ptr{GhosttyAllocator}, out_iterator::Ptr{GhosttyRenderStateRowIterator})::GhosttyResult
end

"""
    ghostty_render_state_row_iterator_free(iterator)

Free a render-state row iterator.

` render`

# Arguments
* `iterator`: The iterator handle to free (may be NULL)
"""
function ghostty_render_state_row_iterator_free(iterator)
    @ccall libghostty_vt.ghostty_render_state_row_iterator_free(iterator::GhosttyRenderStateRowIterator)::Cvoid
end

"""
    ghostty_render_state_row_iterator_next(iterator)

Move a render-state row iterator to the next row.

Rows are visited in order from top to bottom with no gaps. Without overscan, the first row is the top row of the viewport. With overscan, the first row is the highest captured row above the viewport (see GHOSTTY\\_RENDER\\_STATE\\_OPT\\_OVERSCAN). Returns true if the iterator moved successfully and row data is available to read at the new position.

` render`

# Arguments
* `iterator`: The iterator handle to advance (may be NULL)
# Returns
true if advanced to the next row, false if `iterator` is NULL or if the iterator has reached the end
"""
function ghostty_render_state_row_iterator_next(iterator)
    @ccall libghostty_vt.ghostty_render_state_row_iterator_next(iterator::GhosttyRenderStateRowIterator)::Bool
end

"""
    ghostty_render_state_row_iterator_next_dirty(iterator, out_y)

Move a render-state row iterator to the next row requiring a redraw.

If the global dirty state is GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_FALSE, this returns false. If it is GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_PARTIAL, clean rows are skipped. If it is GHOSTTY\\_RENDER\\_STATE\\_DIRTY\\_FULL, every remaining row is returned regardless of its per-row dirty flag. Rows are returned in ascending viewport order. This function does not clear any dirty state.

` render`

# Arguments
* `iterator`: The iterator handle to advance (NULL returns false)
* `out_y`:\\[out\\] Receives the row's position in the iterator when true is returned (NULL returns false). It is not modified when false is returned. Without overscan, this is the viewport y. With overscan, it counts from the highest captured row, so use GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_VIEWPORT\\_Y to place the row.
# Returns
true if advanced to a row requiring a redraw, false if an argument is NULL or the iterator has reached the end of the effective dirty rows
"""
function ghostty_render_state_row_iterator_next_dirty(iterator, out_y)
    @ccall libghostty_vt.ghostty_render_state_row_iterator_next_dirty(iterator::GhosttyRenderStateRowIterator, out_y::Ptr{UInt16})::Bool
end

"""
    ghostty_render_state_row_get(iterator, data, out)

Get a value from the current row in a render-state row iterator.

The `out` pointer must point to a value of the type corresponding to the requested data kind (see [`GhosttyRenderStateRowData`](@ref)). Call [`ghostty_render_state_row_iterator_next`](@ref)() or [`ghostty_render_state_row_iterator_next_dirty`](@ref)() at least once before calling this function.

` render`

# Arguments
* `iterator`: The iterator handle to query (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: The data kind to query
* `out`:\\[out\\] Pointer to receive the queried value
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `iterator` or `out` is NULL or the iterator is not positioned on a row, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_render_state_row_get(iterator, data, out)
    @ccall libghostty_vt.ghostty_render_state_row_get(iterator::GhosttyRenderStateRowIterator, data::GhosttyRenderStateRowData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_render_state_row_get_multi(iterator, count, keys, values, out_written)

Get multiple data fields from the current row in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_render_state_row_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result.

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` render`

# Arguments
* `iterator`: The iterator handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_render_state_row_get_multi(iterator, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_render_state_row_get_multi(iterator::GhosttyRenderStateRowIterator, count::Csize_t, keys::Ptr{GhosttyRenderStateRowData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_render_state_row_set(iterator, option, value)

Set an option on the current row in a render-state row iterator.

The `value` pointer must point to a value of the type corresponding to the requested option kind (see [`GhosttyRenderStateRowOption`](@ref)). Call [`ghostty_render_state_row_iterator_next`](@ref)() or [`ghostty_render_state_row_iterator_next_dirty`](@ref)() at least once before calling this function.

` render`

# Arguments
* `iterator`: The iterator handle to update (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to set
* `value`:\\[in\\] Pointer to the value to set. Row options have no default to restore, so NULL returns GHOSTTY\\_INVALID\\_VALUE.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `iterator` or `value` is NULL or the iterator is not positioned on a row, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_render_state_row_set(iterator, option, value)
    @ccall libghostty_vt.ghostty_render_state_row_set(iterator::GhosttyRenderStateRowIterator, option::GhosttyRenderStateRowOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    GhosttyRenderStateRowCellsData

Queryable data kinds for [`ghostty_render_state_row_cells_get`](@ref)().

` render`

| Enumerator                                                       | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| :--------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_INVALID          | Invalid / sentinel value.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_RAW              | The raw cell value ([`GhosttyCell`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_STYLE            | The style for the current cell ([`GhosttyStyle`](@ref)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_GRAPHEMES\\_LEN  | The total number of grapheme codepoints including the base codepoint (uint32\\_t). Returns 0 if the cell has no text.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_GRAPHEMES\\_BUF  | Copy the cell's grapheme codepoints into a buffer you provide ([`GhosttyCodepointBuffer`](@ref)).  The base codepoint comes first, followed by any extra codepoints. Up to cap codepoints are written, and len is set to the total number of codepoints in the cell. If they do not all fit, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and the buffer holds the first cap of them. A cell with no text returns GHOSTTY\\_SUCCESS with len set to 0.  ```c++ {.c}  uint32_t codepoints[16];  GhosttyCodepointBuffer graphemes = {.ptr = codepoints, .cap = 16};  GhosttyResult result = ghostty_render_state_row_cells_get(      cells, GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_GRAPHEMES_BUF, &graphemes);  if (result == GHOSTTY_OUT_OF_SPACE) {    // The cell has graphemes.len codepoints, but only the first 16    // were written. Retry with a larger buffer to get the rest.  } ```  |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_BG\\_COLOR       | The resolved background color of the cell ([`GhosttyColorRgb`](@ref)). Flattens the three possible sources: content-tag bg\\_color\\_rgb, content-tag bg\\_color\\_palette (looked up in the palette), or the style's bg\\_color.  Returns GHOSTTY\\_NO\\_VALUE if the cell has no background color of its own. Draw it with your default background, such as the terminal's:  ```c++ {.c}   GhosttyColorRgb bg;   GhosttyResult result = ghostty_render_state_row_cells_get(       cells, GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_BG_COLOR, &bg);   if (result == GHOSTTY_NO_VALUE) bg = colors.background; ```                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_FG\\_COLOR       | The resolved foreground color of the cell ([`GhosttyColorRgb`](@ref)). Resolves palette indices through the palette. Bold color handling is not applied; you should handle bold styling separately. Returns GHOSTTY\\_NO\\_VALUE if the cell has no foreground color of its own. Draw it with your default foreground, such as the terminal's.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_SELECTED         | Whether the cell is contained within the current selection (bool). This returns true when the cell's column is within the current row's row-local selection range, and false otherwise. Rendering policy for selected cells (colors, inversion, etc.) is left to you.  Renderers that can draw cells in spans may be more efficient querying GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_SELECTION once per row and applying that range directly, avoiding one C API call per cell for selection state.                                                                                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_HAS\\_STYLING    | Whether the cell has any explicit styling (bool). This is equivalent to querying the raw cell's GHOSTTY\\_CELL\\_DATA\\_HAS\\_STYLING value, but avoids materializing the raw [`GhosttyCell`](@ref) for renderers that only need to know whether fetching the full style is necessary.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_GRAPHEMES\\_UTF8 | Encode the current cell's full grapheme cluster as UTF-8 into a caller-provided buffer ([`GhosttyBuffer`](@ref)).  The base codepoint is encoded first, followed by any extra grapheme codepoints. Returns GHOSTTY\\_SUCCESS with len=0 when the cell has no text.  If ptr is NULL or cap is too small for a non-empty cell, returns GHOSTTY\\_OUT\\_OF\\_SPACE without writing any bytes and sets len to the required buffer size in bytes.                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_RENDER\\_STATE\\_ROW\\_CELLS\\_DATA\\_MAX\\_VALUE      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
"""
@cenum GhosttyRenderStateRowCellsData::UInt32 begin
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_INVALID = 0
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_RAW = 1
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_STYLE = 2
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_GRAPHEMES_LEN = 3
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_GRAPHEMES_BUF = 4
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_BG_COLOR = 5
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_FG_COLOR = 6
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_SELECTED = 7
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_HAS_STYLING = 8
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_GRAPHEMES_UTF8 = 9
    GHOSTTY_RENDER_STATE_ROW_CELLS_DATA_MAX_VALUE = 2147483647
end

"""
    ghostty_render_state_row_cells_new(allocator, out_cells)

Create a new row cells instance.

All fields except the allocator are left undefined until populated via [`ghostty_render_state_row_get`](@ref)() with GHOSTTY\\_RENDER\\_STATE\\_ROW\\_DATA\\_CELLS.

You can reuse this value repeatedly with [`ghostty_render_state_row_get`](@ref)() to  avoid allocating a new cells container for every row.

` render`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `out_cells`:\\[out\\] On success, receives the created row cells handle
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY on allocation failure, GHOSTTY\\_INVALID\\_VALUE if `out_cells` is NULL
"""
function ghostty_render_state_row_cells_new(allocator, out_cells)
    @ccall libghostty_vt.ghostty_render_state_row_cells_new(allocator::Ptr{GhosttyAllocator}, out_cells::Ptr{GhosttyRenderStateRowCells})::GhosttyResult
end

"""
    ghostty_render_state_row_cells_next(cells)

Move a render-state row cells iterator to the next cell.

Returns true if the iterator moved successfully and cell data is available to read at the new position.

` render`

# Arguments
* `cells`: The row cells handle to advance (may be NULL)
# Returns
true if advanced to the next cell, false if `cells` is NULL or if the iterator has reached the end
"""
function ghostty_render_state_row_cells_next(cells)
    @ccall libghostty_vt.ghostty_render_state_row_cells_next(cells::GhosttyRenderStateRowCells)::Bool
end

"""
    ghostty_render_state_row_cells_select(cells, x)

Move a render-state row cells iterator to a specific column.

Positions the iterator at the given x (column) index so that subsequent reads return data for that cell.

` render`

# Arguments
* `cells`: The row cells handle to reposition (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `x`: The zero-based column index to select
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `cells` is NULL or `x` is out of range
"""
function ghostty_render_state_row_cells_select(cells, x)
    @ccall libghostty_vt.ghostty_render_state_row_cells_select(cells::GhosttyRenderStateRowCells, x::UInt16)::GhosttyResult
end

"""
    ghostty_render_state_row_cells_get(cells, data, out)

Get a value from the current cell in a render-state row cells iterator.

The `out` pointer must point to a value of the type corresponding to the requested data kind (see [`GhosttyRenderStateRowCellsData`](@ref)). Call [`ghostty_render_state_row_cells_next`](@ref)() or [`ghostty_render_state_row_cells_select`](@ref)() at least once before calling this function.

` render`

# Arguments
* `cells`: The row cells handle to query (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: The data kind to query
* `out`:\\[out\\] Pointer to receive the queried value
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the cell has no value for `data`, GHOSTTY\\_INVALID\\_VALUE if `cells` is NULL or the iterator is not positioned on a cell, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_render_state_row_cells_get(cells, data, out)
    @ccall libghostty_vt.ghostty_render_state_row_cells_get(cells::GhosttyRenderStateRowCells, data::GhosttyRenderStateRowCellsData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_render_state_row_cells_get_multi(cells, count, keys, values, out_written)

Get multiple data fields from the current cell in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_render_state_row_cells_get`](@ref)() once per key, so use whichever reads better.

Each element in the keys array specifies a data kind, and the corresponding element in the values array receives the result.

Processing stops at the first error; on success out\\_written is set to count, on error it is set to the index of the failing key (i.e. the number of values successfully written).

` render`

# Arguments
* `cells`: The row cells handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers (types must match each key's documented output type)
* `out_written`:\\[out\\] On return, receives the number of values successfully written (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_render_state_row_cells_get_multi(cells, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_render_state_row_cells_get_multi(cells::GhosttyRenderStateRowCells, count::Csize_t, keys::Ptr{GhosttyRenderStateRowCellsData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_render_state_row_cells_free(cells)

Free a row cells instance.

` render`

# Arguments
* `cells`: The row cells handle to free (may be NULL)
"""
function ghostty_render_state_row_cells_free(cells)
    @ccall libghostty_vt.ghostty_render_state_row_cells_free(cells::GhosttyRenderStateRowCells)::Cvoid
end

"""
    ghostty_render_state_image_iterator_new(allocator, out_iterator)

Create a new image iterator.

The iterator starts out empty. Fill it from a render state with [`ghostty_render_state_get`](@ref)() and GHOSTTY\\_RENDER\\_STATE\\_DATA\\_IMAGE\\_ITERATOR. You can keep one iterator for the lifetime of your renderer and fill it again after every update. See guide-images-drawing for a complete example.

` render`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `out_iterator`:\\[out\\] On success, receives the created iterator handle
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY on allocation failure, GHOSTTY\\_INVALID\\_VALUE if `out_iterator` is NULL
"""
function ghostty_render_state_image_iterator_new(allocator, out_iterator)
    @ccall libghostty_vt.ghostty_render_state_image_iterator_new(allocator::Ptr{GhosttyAllocator}, out_iterator::Ptr{GhosttyRenderStateImageIterator})::GhosttyResult
end

"""
    ghostty_render_state_image_iterator_free(iterator)

Free an image iterator.

` render`

# Arguments
* `iterator`: The iterator handle to free (may be NULL)
"""
function ghostty_render_state_image_iterator_free(iterator)
    @ccall libghostty_vt.ghostty_render_state_image_iterator_free(iterator::GhosttyRenderStateImageIterator)::Cvoid
end

"""
    ghostty_render_state_image_iterator_next(iterator)

Move an image iterator to the next image placement.

Call this before reading the first placement, and keep calling it until it returns false.

The order of placements is not the order to draw them in. Sort them by layer (GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_LAYER) and then by z-index (GHOSTTY\\_RENDER\\_STATE\\_IMAGE\\_DATA\\_Z) first.

Only placements with something to draw are returned. For example, placements of an image the terminal hasn't fully received yet are skipped.

The iterator reads from the render state that filled it. After the next update of that render state, fill the iterator again before using it.

` render`

# Arguments
* `iterator`: The iterator handle (NULL returns false)
# Returns
true if the iterator moved to a placement, false if there are no more placements
"""
function ghostty_render_state_image_iterator_next(iterator)
    @ccall libghostty_vt.ghostty_render_state_image_iterator_next(iterator::GhosttyRenderStateImageIterator)::Bool
end

"""
    ghostty_render_state_image_get(iterator, data, out)

Read one value from the current placement of an image iterator.

The `out` pointer must point to a value of the type listed for `data` in [`GhosttyRenderStateImageData`](@ref). To read several values at once, use [`ghostty_render_state_image_get_multi`](@ref)().

` render`

# Arguments
* `iterator`: The iterator handle, moved to a placement with [`ghostty_render_state_image_iterator_next`](@ref)()
* `data`: The value to read
* `out`:\\[out\\] Pointer that receives the value
# Returns
GHOSTTY\\_SUCCESS on success. GHOSTTY\\_NO\\_VALUE if `data` only applies to another protocol. GHOSTTY\\_INVALID\\_VALUE if the iterator is NULL or is not on a placement. GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library.
"""
function ghostty_render_state_image_get(iterator, data, out)
    @ccall libghostty_vt.ghostty_render_state_image_get(iterator::GhosttyRenderStateImageIterator, data::GhosttyRenderStateImageData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_render_state_image_get_multi(iterator, count, keys, values, out_written)

Read several values from the current placement of an image iterator in one call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_render_state_image_get`](@ref)() once per key, so use whichever reads better.

`values[i]` receives the value for `keys[i]`. The keys are read in order, and reading stops at the first error.

` render`

# Arguments
* `iterator`: The iterator handle, moved to a placement with [`ghostty_render_state_image_iterator_next`](@ref)()
* `count`: The number of keys and values
* `keys`: The values to read
* `values`: Output pointers, one for each key
* `out_written`:\\[out\\] If not NULL, receives the number of values written before any error
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_render_state_image_get_multi(iterator, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_render_state_image_get_multi(iterator::GhosttyRenderStateImageIterator, count::Csize_t, keys::Ptr{GhosttyRenderStateImageData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_tracked_grid_ref_free(ref)

Free a tracked grid reference.

Passing NULL is allowed and has no effect. A tracked reference may be freed after the terminal that created it is freed.

` grid_ref`

# Arguments
* `ref`: Tracked grid reference to free.
"""
function ghostty_tracked_grid_ref_free(ref)
    @ccall libghostty_vt.ghostty_tracked_grid_ref_free(ref::GhosttyTrackedGridRef)::Cvoid
end

"""
    ghostty_tracked_grid_ref_has_value(ref)

Return whether a tracked grid reference currently has a meaningful value.

If the terminal that created the tracked reference has been freed, this returns false.

` grid_ref`

# Arguments
* `ref`: Tracked grid reference.
# Returns
true if the reference currently has a meaningful value.
"""
function ghostty_tracked_grid_ref_has_value(ref)
    @ccall libghostty_vt.ghostty_tracked_grid_ref_has_value(ref::GhosttyTrackedGridRef)::Bool
end

"""
    ghostty_tracked_grid_ref_point(ref, tag, out_point)

Convert a tracked grid reference to a point in the requested coordinate space.

This is the tracked equivalent of [`ghostty_terminal_point_from_grid_ref`](@ref)(). Unlike snapshotting, this does not expose an intermediate untracked [`GhosttyGridRef`](@ref).

A tracked reference is resolved against the terminal screen/page-list that currently owns the reference. If the terminal has switched between primary and alternate screens since the reference was created or last set, this may be different from the terminal's currently active screen.

If the tracked reference no longer has a meaningful value, this returns GHOSTTY\\_NO\\_VALUE. GHOSTTY\\_NO\\_VALUE is also returned when the reference cannot be represented in the requested coordinate space, including after the terminal that created the tracked reference has been freed.

` grid_ref`

# Arguments
* `ref`: Tracked grid reference.
* `tag`: Coordinate space to convert into.
* `out_point`:\\[out\\] On success, receives the coordinate. May be NULL.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if ref is invalid, or GHOSTTY\\_NO\\_VALUE if there is no representable value.
"""
function ghostty_tracked_grid_ref_point(ref, tag, out_point)
    @ccall libghostty_vt.ghostty_tracked_grid_ref_point(ref::GhosttyTrackedGridRef, tag::GhosttyPointTag, out_point::Ptr{GhosttyPointCoordinate})::GhosttyResult
end

"""
    ghostty_tracked_grid_ref_set(ref, terminal, point)

Move an existing tracked grid reference to a new terminal point.

On success, the tracked reference begins tracking the new point and any prior "no value" state is cleared. On GHOSTTY\\_OUT\\_OF\\_MEMORY, the original tracked reference is left unchanged.

The terminal must be the same terminal that created the tracked reference. The point is resolved against the terminal screen/page-list that is active at the time this function is called. If the terminal has switched between primary and alternate screens, this may move the tracked reference from one screen/page-list to the other.

` grid_ref`

# Arguments
* `ref`: Tracked grid reference.
* `terminal`: Terminal instance that owns the reference.
* `point`: New point to track.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if ref, terminal, or point is invalid, or GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails.
"""
function ghostty_tracked_grid_ref_set(ref, terminal, point)
    @ccall libghostty_vt.ghostty_tracked_grid_ref_set(ref::GhosttyTrackedGridRef, terminal::GhosttyTerminal, point::GhosttyPoint)::GhosttyResult
end

"""
    ghostty_tracked_grid_ref_snapshot(ref, out_ref)

Snapshot a tracked grid reference into a regular [`GhosttyGridRef`](@ref).

The returned [`GhosttyGridRef`](@ref) is an untracked snapshot and has the same lifetime rules as [`ghostty_terminal_grid_ref`](@ref)(): it is only valid until the next terminal update. Snapshot immediately before calling [`ghostty_grid_ref_cell`](@ref)(), [`ghostty_grid_ref_row`](@ref)(), [`ghostty_grid_ref_graphemes`](@ref)(), [`ghostty_grid_ref_hyperlink_uri`](@ref)(), or [`ghostty_grid_ref_style`](@ref)().

If the tracked reference no longer has a meaningful value, this returns GHOSTTY\\_NO\\_VALUE. This includes references whose owning terminal has been freed.

` grid_ref`

# Arguments
* `ref`: Tracked grid reference.
* `out_ref`:\\[out\\] On success, receives an untracked snapshot. May be NULL.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if ref is invalid, or GHOSTTY\\_NO\\_VALUE if the tracked location was discarded.
"""
function ghostty_tracked_grid_ref_snapshot(ref, out_ref)
    @ccall libghostty_vt.ghostty_tracked_grid_ref_snapshot(ref::GhosttyTrackedGridRef, out_ref::Ptr{GhosttyGridRef})::GhosttyResult
end

"""
    GhosttySgrAttributeTag

SGR attribute tags.

These values identify the type of an SGR attribute in a tagged union. Use the tag to determine which field in the attribute value union to access.

` sgr`
"""
@cenum GhosttySgrAttributeTag::UInt32 begin
    GHOSTTY_SGR_ATTR_UNSET = 0
    GHOSTTY_SGR_ATTR_UNKNOWN = 1
    GHOSTTY_SGR_ATTR_BOLD = 2
    GHOSTTY_SGR_ATTR_RESET_BOLD = 3
    GHOSTTY_SGR_ATTR_ITALIC = 4
    GHOSTTY_SGR_ATTR_RESET_ITALIC = 5
    GHOSTTY_SGR_ATTR_FAINT = 6
    GHOSTTY_SGR_ATTR_UNDERLINE = 7
    GHOSTTY_SGR_ATTR_UNDERLINE_COLOR = 8
    GHOSTTY_SGR_ATTR_UNDERLINE_COLOR_256 = 9
    GHOSTTY_SGR_ATTR_RESET_UNDERLINE_COLOR = 10
    GHOSTTY_SGR_ATTR_OVERLINE = 11
    GHOSTTY_SGR_ATTR_RESET_OVERLINE = 12
    GHOSTTY_SGR_ATTR_BLINK = 13
    GHOSTTY_SGR_ATTR_RESET_BLINK = 14
    GHOSTTY_SGR_ATTR_INVERSE = 15
    GHOSTTY_SGR_ATTR_RESET_INVERSE = 16
    GHOSTTY_SGR_ATTR_INVISIBLE = 17
    GHOSTTY_SGR_ATTR_RESET_INVISIBLE = 18
    GHOSTTY_SGR_ATTR_STRIKETHROUGH = 19
    GHOSTTY_SGR_ATTR_RESET_STRIKETHROUGH = 20
    GHOSTTY_SGR_ATTR_DIRECT_COLOR_FG = 21
    GHOSTTY_SGR_ATTR_DIRECT_COLOR_BG = 22
    GHOSTTY_SGR_ATTR_BG_8 = 23
    GHOSTTY_SGR_ATTR_FG_8 = 24
    GHOSTTY_SGR_ATTR_RESET_FG = 25
    GHOSTTY_SGR_ATTR_RESET_BG = 26
    GHOSTTY_SGR_ATTR_BRIGHT_BG_8 = 27
    GHOSTTY_SGR_ATTR_BRIGHT_FG_8 = 28
    GHOSTTY_SGR_ATTR_BG_256 = 29
    GHOSTTY_SGR_ATTR_FG_256 = 30
    GHOSTTY_SGR_ATTR_MAX_VALUE = 2147483647
end

"""
    GhosttySgrUnderline

Underline style types.

` sgr`
"""
@cenum GhosttySgrUnderline::UInt32 begin
    GHOSTTY_SGR_UNDERLINE_NONE = 0
    GHOSTTY_SGR_UNDERLINE_SINGLE = 1
    GHOSTTY_SGR_UNDERLINE_DOUBLE = 2
    GHOSTTY_SGR_UNDERLINE_CURLY = 3
    GHOSTTY_SGR_UNDERLINE_DOTTED = 4
    GHOSTTY_SGR_UNDERLINE_DASHED = 5
    GHOSTTY_SGR_UNDERLINE_MAX_VALUE = 2147483647
end

"""
    GhosttySgrUnknown

Unknown SGR attribute data.

Contains the full parameter list and the partial list where parsing encountered an unknown or invalid sequence.

` sgr`
"""
struct GhosttySgrUnknown
    full_ptr::Ptr{UInt16}
    full_len::Csize_t
    partial_ptr::Ptr{UInt16}
    partial_len::Csize_t
end

"""
    GhosttySgrAttributeValue

SGR attribute value union.

This union contains all possible attribute values. Use the tag field to determine which union member is active. Attributes without associated data (like bold, italic) don't use the union value.

` sgr`
"""
struct GhosttySgrAttributeValue
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{GhosttySgrAttributeValue}, f::Symbol)
    f === :unknown && return Ptr{GhosttySgrUnknown}(x + 0)
    f === :underline && return Ptr{GhosttySgrUnderline}(x + 0)
    f === :underline_color && return Ptr{GhosttyColorRgb}(x + 0)
    f === :underline_color_256 && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :direct_color_fg && return Ptr{GhosttyColorRgb}(x + 0)
    f === :direct_color_bg && return Ptr{GhosttyColorRgb}(x + 0)
    f === :bg_8 && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :fg_8 && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :bright_bg_8 && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :bright_fg_8 && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :bg_256 && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :fg_256 && return Ptr{GhosttyColorPaletteIndex}(x + 0)
    f === :_padding && return Ptr{NTuple{8, UInt64}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttySgrAttributeValue, f::Symbol)
    r = Ref{GhosttySgrAttributeValue}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttySgrAttributeValue}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttySgrAttributeValue}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttySgrAttributeValue, private::Bool = false)
    (:unknown, :underline, :underline_color, :underline_color_256, :direct_color_fg, :direct_color_bg, :bg_8, :fg_8, :bright_bg_8, :bright_fg_8, :bg_256, :fg_256, :_padding, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    GhosttySgrAttribute

SGR attribute (tagged union).

A complete SGR attribute with both its type tag and associated value. Always check the tag field to determine which value union member is valid.

The parser handles SGR color attributes including 8-color, 16-color, 256-color, direct RGB, underline color, and reset forms. Color values use the shared color types.

Attributes without associated data (e.g., GHOSTTY\\_SGR\\_ATTR\\_BOLD) can be identified by tag alone; the value union is not used for these and the memory in the value field is undefined.

` sgr`
"""
struct GhosttySgrAttribute
    data::NTuple{72, UInt8}
end

function Base.getproperty(x::Ptr{GhosttySgrAttribute}, f::Symbol)
    f === :tag && return Ptr{GhosttySgrAttributeTag}(x + 0)
    f === :value && return Ptr{GhosttySgrAttributeValue}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::GhosttySgrAttribute, f::Symbol)
    r = Ref{GhosttySgrAttribute}(x)
    ptr = Base.unsafe_convert(Ptr{GhosttySgrAttribute}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{GhosttySgrAttribute}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::GhosttySgrAttribute, private::Bool = false)
    (:tag, :value, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    ghostty_sgr_new(allocator, parser)

Create a new SGR parser instance.

Creates a new SGR (Select Graphic Rendition) parser using the provided allocator. The parser must be freed using [`ghostty_sgr_free`](@ref)() when no longer needed.

` sgr`

# Arguments
* `allocator`: Pointer to the allocator to use for memory management, or NULL to use the default allocator
* `parser`: Pointer to store the created parser handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_sgr_new(allocator, parser)
    @ccall libghostty_vt.ghostty_sgr_new(allocator::Ptr{GhosttyAllocator}, parser::Ptr{GhosttySgrParser})::GhosttyResult
end

"""
    ghostty_sgr_free(parser)

Free an SGR parser instance.

Releases all resources associated with the SGR parser. After this call, the parser handle becomes invalid and must not be used. This includes any attributes previously returned by [`ghostty_sgr_next`](@ref)().

` sgr`

# Arguments
* `parser`: The parser handle to free (may be NULL)
"""
function ghostty_sgr_free(parser)
    @ccall libghostty_vt.ghostty_sgr_free(parser::GhosttySgrParser)::Cvoid
end

"""
    ghostty_sgr_reset(parser)

Reset an SGR parser instance to the beginning of the parameter list.

Resets the parser's iteration state without clearing the parameters. After calling this, [`ghostty_sgr_next`](@ref)() will start from the beginning of the parameter list again.

` sgr`

# Arguments
* `parser`: The parser handle to reset (NULL does nothing)
"""
function ghostty_sgr_reset(parser)
    @ccall libghostty_vt.ghostty_sgr_reset(parser::GhosttySgrParser)::Cvoid
end

"""
    ghostty_sgr_set_params(parser, params, separators, len)

Set SGR parameters for parsing.

Sets the SGR parameter list to parse. Parameters are the numeric values from a CSI SGR sequence (e.g., for `ESC[1;31m`, params would be {1, 31}).

The separators array optionally specifies the separator type for each parameter position. Each byte should be either ';' for semicolon or ':' for colon. This is needed for certain color formats that use colon separators (e.g., `ESC[4:3m` for curly underline). Any invalid separator values are treated as semicolons. The separators array must have the same length as the params array, if it is not NULL.

If separators is NULL, all parameters are assumed to be semicolon-separated.

This function makes an internal copy of the parameter and separator data, so you can safely free or modify the input arrays after this call.

After calling this function, the parser is automatically reset and ready to iterate from the beginning.

` sgr`

# Arguments
* `parser`: The parser handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `params`: Array of SGR parameter values (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `separators`: Optional array of separator characters (';' or ':'), or NULL
* `len`: Number of parameters (and separators if provided)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_sgr_set_params(parser, params, separators, len)
    @ccall libghostty_vt.ghostty_sgr_set_params(parser::GhosttySgrParser, params::Ptr{UInt16}, separators::Cstring, len::Csize_t)::GhosttyResult
end

"""
    ghostty_sgr_next(parser, attr)

Get the next SGR attribute.

Parses and returns the next attribute from the parameter list. Call this function repeatedly until it returns false to process all attributes in the sequence.

` sgr`

# Arguments
* `parser`: The parser handle (NULL returns false)
* `attr`: Pointer to store the next attribute (NULL returns false)
# Returns
true if an attribute was returned, false if no more attributes
"""
function ghostty_sgr_next(parser, attr)
    @ccall libghostty_vt.ghostty_sgr_next(parser::GhosttySgrParser, attr::Ptr{GhosttySgrAttribute})::Bool
end

"""
    ghostty_sgr_unknown_full(unknown, ptr)

Get the full parameter list from an unknown SGR attribute.

This function retrieves the full parameter list that was provided to the parser when an unknown attribute was encountered. Primarily useful in WebAssembly environments where accessing struct fields directly is difficult.

` sgr`

# Arguments
* `unknown`: The unknown attribute data
* `ptr`: Pointer to store the pointer to the parameter array (may be NULL)
# Returns
The length of the full parameter array
"""
function ghostty_sgr_unknown_full(unknown, ptr)
    @ccall libghostty_vt.ghostty_sgr_unknown_full(unknown::GhosttySgrUnknown, ptr::Ptr{Ptr{UInt16}})::Csize_t
end

"""
    ghostty_sgr_unknown_partial(unknown, ptr)

Get the partial parameter list from an unknown SGR attribute.

This function retrieves the partial parameter list where parsing stopped when an unknown attribute was encountered. Primarily useful in WebAssembly environments where accessing struct fields directly is difficult.

` sgr`

# Arguments
* `unknown`: The unknown attribute data
* `ptr`: Pointer to store the pointer to the parameter array (may be NULL)
# Returns
The length of the partial parameter array
"""
function ghostty_sgr_unknown_partial(unknown, ptr)
    @ccall libghostty_vt.ghostty_sgr_unknown_partial(unknown::GhosttySgrUnknown, ptr::Ptr{Ptr{UInt16}})::Csize_t
end

"""
    ghostty_sgr_attribute_tag(attr)

Get the tag from an SGR attribute.

This function extracts the tag that identifies which type of attribute this is. Primarily useful in WebAssembly environments where accessing struct fields directly is difficult.

` sgr`

# Arguments
* `attr`: Pointer to the SGR attribute (may be NULL)
# Returns
The attribute tag, or GHOSTTY\\_SGR\\_ATTR\\_UNSET if `attr` is NULL
"""
function ghostty_sgr_attribute_tag(attr)
    @ccall libghostty_vt.ghostty_sgr_attribute_tag(attr::Ptr{GhosttySgrAttribute})::GhosttySgrAttributeTag
end

"""
    ghostty_sgr_attribute_value(attr)

Get the value from an SGR attribute.

This function returns a pointer to the value union from an SGR attribute. Use the tag to determine which field of the union is valid. Primarily useful in WebAssembly environments where accessing struct fields directly is difficult.

` sgr`

# Arguments
* `attr`: Pointer to the SGR attribute (NULL returns NULL)
# Returns
Pointer to the attribute value union
"""
function ghostty_sgr_attribute_value(attr)
    @ccall libghostty_vt.ghostty_sgr_attribute_value(attr::Ptr{GhosttySgrAttribute})::Ptr{GhosttySgrAttributeValue}
end

"""
    GhosttySysImage

A decoded image, filled in by a decode callback such as [`GhosttySysDecodePngFn`](@ref).

Pixels are 8-bit RGBA: four bytes per pixel, stored row by row starting at the top-left corner, with no padding between rows. A complete image is therefore `width * height * 4` bytes long.

The pixel buffer must be allocated with the allocator passed to the decode callback. When the callback returns true, the library takes ownership of the buffer and frees it with that same allocator.

| Field      | Note                                                                                                                                           |
| :--------- | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| width      | Image width in pixels.                                                                                                                         |
| height     | Image height in pixels.                                                                                                                        |
| data       | The decoded RGBA pixels, allocated with the allocator passed to the decode callback.                                                           |
| data\\_len | Length of `data` in bytes. This must be the exact size that was requested from the allocator, because the library uses it to free the buffer.  |
"""
struct GhosttySysImage
    width::UInt32
    height::UInt32
    data::Ptr{UInt8}
    data_len::Csize_t
end

"""
    GhosttySysLogLevel

Log severity levels for the log callback.
"""
@cenum GhosttySysLogLevel::UInt32 begin
    GHOSTTY_SYS_LOG_LEVEL_ERROR = 0
    GHOSTTY_SYS_LOG_LEVEL_WARNING = 1
    GHOSTTY_SYS_LOG_LEVEL_INFO = 2
    GHOSTTY_SYS_LOG_LEVEL_DEBUG = 3
    GHOSTTY_SYS_LOG_LEVEL_MAX_VALUE = 2147483647
end

# typedef void ( * GhosttySysLogFn ) ( void * userdata , GhosttySysLogLevel level , const uint8_t * scope , size_t scope_len , const uint8_t * message , size_t message_len )
"""
Callback type for logging.

When installed, internal library log messages are delivered through this callback instead of being discarded. You are responsible for formatting and routing log output.

`scope` is the log scope name as UTF-8 bytes (e.g. "osc", "kitty"). When the log is unscoped (default scope), `scope_len` is 0.

All pointer arguments are only valid for the duration of the callback. The callback must be safe to call from any thread.

# Arguments
* `userdata`: The userdata pointer set via GHOSTTY\\_SYS\\_OPT\\_USERDATA
* `level`: The severity level of the log message
* `scope`: Pointer to the scope name bytes
* `scope_len`: Length of the scope name in bytes
* `message`: Pointer to the log message bytes
* `message_len`: Length of the log message in bytes
"""
const GhosttySysLogFn = Ptr{Cvoid}

# typedef bool ( * GhosttySysDecodePngFn ) ( void * userdata , const GhosttyAllocator * allocator , const uint8_t * data , size_t data_len , GhosttySysImage * out )
"""
Callback type for PNG decoding.

The library calls this when it receives a PNG image and needs the raw pixels. The callback decodes the PNG bytes in `data` and describes the result in `out`. See the example in the sys overview for a complete callback.

### On success

Allocate the pixel buffer with [`ghostty_alloc`](@ref)() and `allocator`, write the decoded pixels into it, set `width`, `height`, `data` and `data_len` in `out`, and return true. The library then owns the buffer and frees it with the same allocator. See [`GhosttySysImage`](@ref) for the expected pixel layout.

The allocator limits how much memory a single image may use, so [`ghostty_alloc`](@ref)() can return NULL for very large images. Treat that as a failure.

### On failure

Free anything that was allocated and return false. The library does not read `out` in this case, and the image is rejected.

### The output struct starts zeroed

The library sets every field of `out` to zero before it calls the callback, so any field the callback does not write reads as zero. This has two practical effects:

- If the callback returns true but `data` is still NULL, the library treats the call as a failure. - Language bindings can store a pointer into `out` directly. Some runtimes, such as Go, require memory to be initialized before a pointer is written into it, and this guarantee satisfies that requirement.

Only `out` is zeroed. Memory returned by [`ghostty_alloc`](@ref)() is not.

### The output struct never changes

[`GhosttySysImage`](@ref) is frozen. If a later version of libghostty-vt needs more fields, it adds a new callback typedef and a new option key, and keeps calling this callback with [`GhosttySysImage`](@ref) forever. A callback written against this header keeps working with every later version of the library.

`data` and `allocator` are only valid for the duration of the callback.

Use `allocator` only through [`ghostty_alloc`](@ref)() and [`ghostty_free`](@ref)(). Dereferencing its vtable is not supported.

# Arguments
* `userdata`: The userdata pointer set via GHOSTTY\\_SYS\\_OPT\\_USERDATA
* `allocator`: The allocator to use for the output pixel buffer
* `data`: Pointer to the raw PNG data
* `data_len`: Length of the raw PNG data in bytes
* `out`:\\[out\\] The decoded image. Zeroed by the library before the call, and filled in by the callback on success.
# Returns
true if the image was decoded and `out` was filled in, false on failure
"""
const GhosttySysDecodePngFn = Ptr{Cvoid}

# typedef bool ( * GhosttySysRandomSecureFn ) ( void * userdata , uint8_t * buf , size_t len )
"""
Callback type for secure random bytes.

Fills `buf` with `len` cryptographically secure random bytes. The library uses this for secrets, so it must be a real CSPRNG (getrandom, arc4random\\_buf, BCryptGenRandom, crypto.getRandomValues, ...); a predictable source is a security hole.

# Arguments
* `userdata`: The userdata pointer set via GHOSTTY\\_SYS\\_OPT\\_USERDATA
* `buf`: Buffer to fill
* `len`: Number of bytes to fill
# Returns
true if the buffer was filled, false if no entropy is available
"""
const GhosttySysRandomSecureFn = Ptr{Cvoid}

"""
    GhosttySysOption

System option identifiers for [`ghostty_sys_set`](@ref)().

| Enumerator                            | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| :------------------------------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SYS\\_OPT\\_INVALID         | Not a real option. [`ghostty_sys_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_SYS\\_OPT\\_USERDATA        | Set the userdata pointer passed to all sys callbacks.  Input type: void* (or NULL)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_SYS\\_OPT\\_DECODE\\_PNG    | Set the PNG decode function.  When set, the terminal can accept PNG images via the Kitty Graphics Protocol. When cleared (NULL value), PNG decoding is unsupported and PNG image data will be rejected.  Input type: [`GhosttySysDecodePngFn`](@ref) (function pointer, or NULL)                                                                                                                                                                                                                                                                                                                                              |
| GHOSTTY\\_SYS\\_OPT\\_LOG             | Set the log callback.  When set, internal library log messages are delivered to this callback. When cleared (NULL value), log messages are silently discarded.  Use [`ghostty_sys_log_stderr`](@ref) as a convenience callback that writes formatted messages to stderr.  Which log levels are emitted depends on the build mode of the library and is not configurable at runtime. Debug builds emit all levels (debug and above). Release builds emit info and above; debug-level messages are compiled out entirely and will never reach the callback.  Input type: [`GhosttySysLogFn`](@ref) (function pointer, or NULL)  |
| GHOSTTY\\_SYS\\_OPT\\_RANDOM\\_SECURE | Override the secure random source.  By default the library draws secure random bytes from the platform (getrandom or arc4random\\_buf on POSIX, CNG on Windows). Targets without one, such as wasm32-freestanding, have no default and operations that need entropy fail with GHOSTTY\\_IO\\_ERROR until this is set. When set, it is used instead of the platform source on every target. When cleared (NULL value), the platform default is restored.  Input type: [`GhosttySysRandomSecureFn`](@ref) (function pointer, or NULL)                                                                                           |
| GHOSTTY\\_SYS\\_OPT\\_MAX\\_VALUE     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
"""
@cenum GhosttySysOption::UInt32 begin
    GHOSTTY_SYS_OPT_INVALID = 0
    GHOSTTY_SYS_OPT_USERDATA = 1
    GHOSTTY_SYS_OPT_DECODE_PNG = 2
    GHOSTTY_SYS_OPT_LOG = 3
    GHOSTTY_SYS_OPT_RANDOM_SECURE = 4
    GHOSTTY_SYS_OPT_MAX_VALUE = 2147483647
end

"""
    ghostty_sys_set(option, value)

Set a system-level option.

Configures a process-global implementation function. These should be set once at startup before using any terminal functionality that depends on them.

# Arguments
* `option`: The option to set
* `value`: Pointer to the value (type depends on the option), or NULL to clear it
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_UNSUPPORTED if the option is not known to this build (see [`GhosttyResult`](@ref))
"""
function ghostty_sys_set(option, value)
    @ccall libghostty_vt.ghostty_sys_set(option::GhosttySysOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_sys_log_stderr(userdata, level, scope, scope_len, message, message_len)

Built-in log callback that writes to stderr.

Formats each message as "[level](scope): message\\n". Can be passed directly to [`ghostty_sys_set`](@ref)():

```c++
 ghostty_sys_set(GHOSTTY_SYS_OPT_LOG, &ghostty_sys_log_stderr);
```
"""
function ghostty_sys_log_stderr(userdata, level, scope, scope_len, message, message_len)
    @ccall libghostty_vt.ghostty_sys_log_stderr(userdata::Ptr{Cvoid}, level::GhosttySysLogLevel, scope::Ptr{UInt8}, scope_len::Csize_t, message::Ptr{UInt8}, message_len::Csize_t)::Cvoid
end

mutable struct GhosttyKeyEventImpl end

"""
Opaque handle to a key event.

This handle represents a keyboard input event containing information about the physical key pressed, modifiers, and generated text.

` key`
"""
const GhosttyKeyEvent = Ptr{GhosttyKeyEventImpl}

"""
    GhosttyKeyAction

Keyboard input event types.

` key`

| Enumerator                           | Note                               |
| :----------------------------------- | :--------------------------------- |
| GHOSTTY\\_KEY\\_ACTION\\_RELEASE     | Key was released                   |
| GHOSTTY\\_KEY\\_ACTION\\_PRESS       | Key was pressed                    |
| GHOSTTY\\_KEY\\_ACTION\\_REPEAT      | Key is being repeated (held down)  |
| GHOSTTY\\_KEY\\_ACTION\\_MAX\\_VALUE |                                    |
"""
@cenum GhosttyKeyAction::UInt32 begin
    GHOSTTY_KEY_ACTION_RELEASE = 0
    GHOSTTY_KEY_ACTION_PRESS = 1
    GHOSTTY_KEY_ACTION_REPEAT = 2
    GHOSTTY_KEY_ACTION_MAX_VALUE = 2147483647
end

"""
Keyboard modifier keys bitmask.

A bitmask representing all keyboard modifiers. This tracks which modifier keys  are pressed and, where supported by the platform, which side (left or right)  of each modifier is active.

Use the GHOSTTY\\_MODS\\_* constants to test and set individual modifiers.

Modifier side bits are only meaningful when the corresponding modifier bit is set. Not all platforms support distinguishing between left and right modifier  keys and Ghostty is built to expect that some platforms may not provide this information.

` key`
"""
const GhosttyMods = UInt16

"""
    GhosttyKey

Physical key codes.

The set of key codes that Ghostty is aware of. These represent physical keys  on the keyboard and are layout-independent. For example, the "a" key on a US  keyboard is the same as the "ф" key on a Russian keyboard, but both will  report the same key\\_a value.

Layout-dependent strings are provided separately as UTF-8 text and are produced  by the platform. These values are based on the W3C UI Events KeyboardEvent code  standard. See: https://www.w3.org/TR/uievents-code

` key`
"""
@cenum GhosttyKey::UInt32 begin
    GHOSTTY_KEY_UNIDENTIFIED = 0
    GHOSTTY_KEY_BACKQUOTE = 1
    GHOSTTY_KEY_BACKSLASH = 2
    GHOSTTY_KEY_BRACKET_LEFT = 3
    GHOSTTY_KEY_BRACKET_RIGHT = 4
    GHOSTTY_KEY_COMMA = 5
    GHOSTTY_KEY_DIGIT_0 = 6
    GHOSTTY_KEY_DIGIT_1 = 7
    GHOSTTY_KEY_DIGIT_2 = 8
    GHOSTTY_KEY_DIGIT_3 = 9
    GHOSTTY_KEY_DIGIT_4 = 10
    GHOSTTY_KEY_DIGIT_5 = 11
    GHOSTTY_KEY_DIGIT_6 = 12
    GHOSTTY_KEY_DIGIT_7 = 13
    GHOSTTY_KEY_DIGIT_8 = 14
    GHOSTTY_KEY_DIGIT_9 = 15
    GHOSTTY_KEY_EQUAL = 16
    GHOSTTY_KEY_INTL_BACKSLASH = 17
    GHOSTTY_KEY_INTL_RO = 18
    GHOSTTY_KEY_INTL_YEN = 19
    GHOSTTY_KEY_A = 20
    GHOSTTY_KEY_B = 21
    GHOSTTY_KEY_C = 22
    GHOSTTY_KEY_D = 23
    GHOSTTY_KEY_E = 24
    GHOSTTY_KEY_F = 25
    GHOSTTY_KEY_G = 26
    GHOSTTY_KEY_H = 27
    GHOSTTY_KEY_I = 28
    GHOSTTY_KEY_J = 29
    GHOSTTY_KEY_K = 30
    GHOSTTY_KEY_L = 31
    GHOSTTY_KEY_M = 32
    GHOSTTY_KEY_N = 33
    GHOSTTY_KEY_O = 34
    GHOSTTY_KEY_P = 35
    GHOSTTY_KEY_Q = 36
    GHOSTTY_KEY_R = 37
    GHOSTTY_KEY_S = 38
    GHOSTTY_KEY_T = 39
    GHOSTTY_KEY_U = 40
    GHOSTTY_KEY_V = 41
    GHOSTTY_KEY_W = 42
    GHOSTTY_KEY_X = 43
    GHOSTTY_KEY_Y = 44
    GHOSTTY_KEY_Z = 45
    GHOSTTY_KEY_MINUS = 46
    GHOSTTY_KEY_PERIOD = 47
    GHOSTTY_KEY_QUOTE = 48
    GHOSTTY_KEY_SEMICOLON = 49
    GHOSTTY_KEY_SLASH = 50
    GHOSTTY_KEY_ALT_LEFT = 51
    GHOSTTY_KEY_ALT_RIGHT = 52
    GHOSTTY_KEY_BACKSPACE = 53
    GHOSTTY_KEY_CAPS_LOCK = 54
    GHOSTTY_KEY_CONTEXT_MENU = 55
    GHOSTTY_KEY_CONTROL_LEFT = 56
    GHOSTTY_KEY_CONTROL_RIGHT = 57
    GHOSTTY_KEY_ENTER = 58
    GHOSTTY_KEY_META_LEFT = 59
    GHOSTTY_KEY_META_RIGHT = 60
    GHOSTTY_KEY_SHIFT_LEFT = 61
    GHOSTTY_KEY_SHIFT_RIGHT = 62
    GHOSTTY_KEY_SPACE = 63
    GHOSTTY_KEY_TAB = 64
    GHOSTTY_KEY_CONVERT = 65
    GHOSTTY_KEY_KANA_MODE = 66
    GHOSTTY_KEY_NON_CONVERT = 67
    GHOSTTY_KEY_DELETE = 68
    GHOSTTY_KEY_END = 69
    GHOSTTY_KEY_HELP = 70
    GHOSTTY_KEY_HOME = 71
    GHOSTTY_KEY_INSERT = 72
    GHOSTTY_KEY_PAGE_DOWN = 73
    GHOSTTY_KEY_PAGE_UP = 74
    GHOSTTY_KEY_ARROW_DOWN = 75
    GHOSTTY_KEY_ARROW_LEFT = 76
    GHOSTTY_KEY_ARROW_RIGHT = 77
    GHOSTTY_KEY_ARROW_UP = 78
    GHOSTTY_KEY_NUM_LOCK = 79
    GHOSTTY_KEY_NUMPAD_0 = 80
    GHOSTTY_KEY_NUMPAD_1 = 81
    GHOSTTY_KEY_NUMPAD_2 = 82
    GHOSTTY_KEY_NUMPAD_3 = 83
    GHOSTTY_KEY_NUMPAD_4 = 84
    GHOSTTY_KEY_NUMPAD_5 = 85
    GHOSTTY_KEY_NUMPAD_6 = 86
    GHOSTTY_KEY_NUMPAD_7 = 87
    GHOSTTY_KEY_NUMPAD_8 = 88
    GHOSTTY_KEY_NUMPAD_9 = 89
    GHOSTTY_KEY_NUMPAD_ADD = 90
    GHOSTTY_KEY_NUMPAD_BACKSPACE = 91
    GHOSTTY_KEY_NUMPAD_CLEAR = 92
    GHOSTTY_KEY_NUMPAD_CLEAR_ENTRY = 93
    GHOSTTY_KEY_NUMPAD_COMMA = 94
    GHOSTTY_KEY_NUMPAD_DECIMAL = 95
    GHOSTTY_KEY_NUMPAD_DIVIDE = 96
    GHOSTTY_KEY_NUMPAD_ENTER = 97
    GHOSTTY_KEY_NUMPAD_EQUAL = 98
    GHOSTTY_KEY_NUMPAD_MEMORY_ADD = 99
    GHOSTTY_KEY_NUMPAD_MEMORY_CLEAR = 100
    GHOSTTY_KEY_NUMPAD_MEMORY_RECALL = 101
    GHOSTTY_KEY_NUMPAD_MEMORY_STORE = 102
    GHOSTTY_KEY_NUMPAD_MEMORY_SUBTRACT = 103
    GHOSTTY_KEY_NUMPAD_MULTIPLY = 104
    GHOSTTY_KEY_NUMPAD_PAREN_LEFT = 105
    GHOSTTY_KEY_NUMPAD_PAREN_RIGHT = 106
    GHOSTTY_KEY_NUMPAD_SUBTRACT = 107
    GHOSTTY_KEY_NUMPAD_SEPARATOR = 108
    GHOSTTY_KEY_NUMPAD_UP = 109
    GHOSTTY_KEY_NUMPAD_DOWN = 110
    GHOSTTY_KEY_NUMPAD_RIGHT = 111
    GHOSTTY_KEY_NUMPAD_LEFT = 112
    GHOSTTY_KEY_NUMPAD_BEGIN = 113
    GHOSTTY_KEY_NUMPAD_HOME = 114
    GHOSTTY_KEY_NUMPAD_END = 115
    GHOSTTY_KEY_NUMPAD_INSERT = 116
    GHOSTTY_KEY_NUMPAD_DELETE = 117
    GHOSTTY_KEY_NUMPAD_PAGE_UP = 118
    GHOSTTY_KEY_NUMPAD_PAGE_DOWN = 119
    GHOSTTY_KEY_ESCAPE = 120
    GHOSTTY_KEY_F1 = 121
    GHOSTTY_KEY_F2 = 122
    GHOSTTY_KEY_F3 = 123
    GHOSTTY_KEY_F4 = 124
    GHOSTTY_KEY_F5 = 125
    GHOSTTY_KEY_F6 = 126
    GHOSTTY_KEY_F7 = 127
    GHOSTTY_KEY_F8 = 128
    GHOSTTY_KEY_F9 = 129
    GHOSTTY_KEY_F10 = 130
    GHOSTTY_KEY_F11 = 131
    GHOSTTY_KEY_F12 = 132
    GHOSTTY_KEY_F13 = 133
    GHOSTTY_KEY_F14 = 134
    GHOSTTY_KEY_F15 = 135
    GHOSTTY_KEY_F16 = 136
    GHOSTTY_KEY_F17 = 137
    GHOSTTY_KEY_F18 = 138
    GHOSTTY_KEY_F19 = 139
    GHOSTTY_KEY_F20 = 140
    GHOSTTY_KEY_F21 = 141
    GHOSTTY_KEY_F22 = 142
    GHOSTTY_KEY_F23 = 143
    GHOSTTY_KEY_F24 = 144
    GHOSTTY_KEY_F25 = 145
    GHOSTTY_KEY_FN = 146
    GHOSTTY_KEY_FN_LOCK = 147
    GHOSTTY_KEY_PRINT_SCREEN = 148
    GHOSTTY_KEY_SCROLL_LOCK = 149
    GHOSTTY_KEY_PAUSE = 150
    GHOSTTY_KEY_BROWSER_BACK = 151
    GHOSTTY_KEY_BROWSER_FAVORITES = 152
    GHOSTTY_KEY_BROWSER_FORWARD = 153
    GHOSTTY_KEY_BROWSER_HOME = 154
    GHOSTTY_KEY_BROWSER_REFRESH = 155
    GHOSTTY_KEY_BROWSER_SEARCH = 156
    GHOSTTY_KEY_BROWSER_STOP = 157
    GHOSTTY_KEY_EJECT = 158
    GHOSTTY_KEY_LAUNCH_APP_1 = 159
    GHOSTTY_KEY_LAUNCH_APP_2 = 160
    GHOSTTY_KEY_LAUNCH_MAIL = 161
    GHOSTTY_KEY_MEDIA_PLAY_PAUSE = 162
    GHOSTTY_KEY_MEDIA_SELECT = 163
    GHOSTTY_KEY_MEDIA_STOP = 164
    GHOSTTY_KEY_MEDIA_TRACK_NEXT = 165
    GHOSTTY_KEY_MEDIA_TRACK_PREVIOUS = 166
    GHOSTTY_KEY_POWER = 167
    GHOSTTY_KEY_SLEEP = 168
    GHOSTTY_KEY_AUDIO_VOLUME_DOWN = 169
    GHOSTTY_KEY_AUDIO_VOLUME_MUTE = 170
    GHOSTTY_KEY_AUDIO_VOLUME_UP = 171
    GHOSTTY_KEY_WAKE_UP = 172
    GHOSTTY_KEY_COPY = 173
    GHOSTTY_KEY_CUT = 174
    GHOSTTY_KEY_PASTE = 175
    GHOSTTY_KEY_MAX_VALUE = 2147483647
end

"""
    ghostty_key_event_new(allocator, event)

Create a new key event instance.

Creates a new key event with default values. The event must be freed using [`ghostty_key_event_free`](@ref)() when no longer needed.

` key`

# Arguments
* `allocator`: Pointer to the allocator to use for memory management, or NULL to use the default allocator
* `event`: Pointer to store the created key event handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_key_event_new(allocator, event)
    @ccall libghostty_vt.ghostty_key_event_new(allocator::Ptr{GhosttyAllocator}, event::Ptr{GhosttyKeyEvent})::GhosttyResult
end

"""
    ghostty_key_event_free(event)

Free a key event instance.

Releases all resources associated with the key event. After this call, the event handle becomes invalid and must not be used.

` key`

# Arguments
* `event`: The key event handle to free (may be NULL)
"""
function ghostty_key_event_free(event)
    @ccall libghostty_vt.ghostty_key_event_free(event::GhosttyKeyEvent)::Cvoid
end

"""
    ghostty_key_event_set_action(event, action)

Set the key action (press, release, repeat).

` key`

# Arguments
* `event`: The key event handle
* `action`: The action to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL or `action` is not a [`GhosttyKeyAction`](@ref) value this version of the library knows. On error the event is not changed.
"""
function ghostty_key_event_set_action(event, action)
    @ccall libghostty_vt.ghostty_key_event_set_action(event::GhosttyKeyEvent, action::GhosttyKeyAction)::GhosttyResult
end

"""
    ghostty_key_event_get_action(event)

Get the key action (press, release, repeat).

` key`

# Arguments
* `event`: The key event handle
# Returns
The key action, or GHOSTTY\\_KEY\\_ACTION\\_RELEASE if `event` is NULL
"""
function ghostty_key_event_get_action(event)
    @ccall libghostty_vt.ghostty_key_event_get_action(event::GhosttyKeyEvent)::GhosttyKeyAction
end

"""
    ghostty_key_event_set_key(event, key)

Set the physical key code.

` key`

# Arguments
* `event`: The key event handle
* `key`: The physical key code to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL or `key` is not a [`GhosttyKey`](@ref) value this version of the library knows. On error the event is not changed.
"""
function ghostty_key_event_set_key(event, key)
    @ccall libghostty_vt.ghostty_key_event_set_key(event::GhosttyKeyEvent, key::GhosttyKey)::GhosttyResult
end

"""
    ghostty_key_event_get_key(event)

Get the physical key code.

` key`

# Arguments
* `event`: The key event handle
# Returns
The physical key code, or GHOSTTY\\_KEY\\_UNIDENTIFIED if `event` is NULL
"""
function ghostty_key_event_get_key(event)
    @ccall libghostty_vt.ghostty_key_event_get_key(event::GhosttyKeyEvent)::GhosttyKey
end

"""
    ghostty_key_event_set_mods(event, mods)

Set the modifier keys bitmask.

` key`

# Arguments
* `event`: The key event handle
* `mods`: The modifier keys bitmask to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_key_event_set_mods(event, mods)
    @ccall libghostty_vt.ghostty_key_event_set_mods(event::GhosttyKeyEvent, mods::GhosttyMods)::GhosttyResult
end

"""
    ghostty_key_event_get_mods(event)

Get the modifier keys bitmask.

` key`

# Arguments
* `event`: The key event handle
# Returns
The modifier keys bitmask, or 0 (no modifiers) if `event` is NULL
"""
function ghostty_key_event_get_mods(event)
    @ccall libghostty_vt.ghostty_key_event_get_mods(event::GhosttyKeyEvent)::GhosttyMods
end

"""
    ghostty_key_event_set_consumed_mods(event, consumed_mods)

Set the consumed modifiers bitmask.

` key`

# Arguments
* `event`: The key event handle
* `consumed_mods`: The consumed modifiers bitmask to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_key_event_set_consumed_mods(event, consumed_mods)
    @ccall libghostty_vt.ghostty_key_event_set_consumed_mods(event::GhosttyKeyEvent, consumed_mods::GhosttyMods)::GhosttyResult
end

"""
    ghostty_key_event_get_consumed_mods(event)

Get the consumed modifiers bitmask.

` key`

# Arguments
* `event`: The key event handle
# Returns
The consumed modifiers bitmask, or 0 (no modifiers) if `event` is NULL
"""
function ghostty_key_event_get_consumed_mods(event)
    @ccall libghostty_vt.ghostty_key_event_get_consumed_mods(event::GhosttyKeyEvent)::GhosttyMods
end

"""
    ghostty_key_event_set_composing(event, composing)

Set whether the key event is part of a composition sequence.

` key`

# Arguments
* `event`: The key event handle
* `composing`: Whether the key event is part of a composition sequence
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_key_event_set_composing(event, composing)
    @ccall libghostty_vt.ghostty_key_event_set_composing(event::GhosttyKeyEvent, composing::Bool)::GhosttyResult
end

"""
    ghostty_key_event_get_composing(event)

Get whether the key event is part of a composition sequence.

` key`

# Arguments
* `event`: The key event handle
# Returns
Whether the key event is part of a composition sequence, or false if `event` is NULL
"""
function ghostty_key_event_get_composing(event)
    @ccall libghostty_vt.ghostty_key_event_get_composing(event::GhosttyKeyEvent)::Bool
end

"""
    ghostty_key_event_set_utf8(event, utf8)

Set the UTF-8 text generated by the key for the current keyboard layout.

Must contain the unmodified character before any Ctrl/Meta transformations. The encoder derives modifier sequences from the logical key and mods bitmask, not from this text. Do not pass C0 control characters (U+0000-U+001F, U+007F) or platform function key codes (e.g. macOS PUA U+F700-U+F8FF). For those keys, pass an empty string and the encoder will use the logical key instead.

A string with a length of zero clears the text. The library does not read its pointer, so the pointer may be NULL.

The key event does not copy the text. The bytes must stay valid until the event is freed or its text is set again. String literals and buffers that outlive the event are both fine.

```c++
{.c}
 // Set the text for a key that produced "a".
 const char *text = "a";
 GhosttyString utf8 = {
     .ptr = (const uint8_t *)text,
     .len = strlen(text),
 };
 GhosttyResult result = ghostty_key_event_set_utf8(event, utf8);

 // Clear the text, for example for a function key.
 result = ghostty_key_event_set_utf8(event, (GhosttyString){0});
```

` key`

# Arguments
* `event`: The key event handle
* `utf8`: The UTF-8 text to set. It does not need to be null-terminated.
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_key_event_set_utf8(event, utf8)
    @ccall libghostty_vt.ghostty_key_event_set_utf8(event::GhosttyKeyEvent, utf8::GhosttyString)::GhosttyResult
end

"""
    ghostty_key_event_get_utf8(event)

Get the UTF-8 text generated by the key event.

The event does not copy its text, so the returned string points at the same bytes that were passed to [`ghostty_key_event_set_utf8`](@ref)(). It stays valid while those bytes do, until the event is freed or its text is set again.

The bytes are not null-terminated. Always use the length:

```c++
{.c}
 GhosttyString text = ghostty_key_event_get_utf8(event);
 printf("%.*s\\n", (int)text.len, (const char *)text.ptr);
```

` key`

# Arguments
* `event`: The key event handle
# Returns
The UTF-8 text. If the event has no text or `event` is NULL, the string has a length of zero.
"""
function ghostty_key_event_get_utf8(event)
    @ccall libghostty_vt.ghostty_key_event_get_utf8(event::GhosttyKeyEvent)::GhosttyString
end

"""
    ghostty_key_event_set_unshifted_codepoint(event, codepoint)

Set the unshifted Unicode codepoint.

` key`

# Arguments
* `event`: The key event handle
* `codepoint`: The unshifted Unicode codepoint to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_key_event_set_unshifted_codepoint(event, codepoint)
    @ccall libghostty_vt.ghostty_key_event_set_unshifted_codepoint(event::GhosttyKeyEvent, codepoint::UInt32)::GhosttyResult
end

"""
    ghostty_key_event_get_unshifted_codepoint(event)

Get the unshifted Unicode codepoint.

` key`

# Arguments
* `event`: The key event handle
# Returns
The unshifted Unicode codepoint, or 0 if `event` is NULL
"""
function ghostty_key_event_get_unshifted_codepoint(event)
    @ccall libghostty_vt.ghostty_key_event_get_unshifted_codepoint(event::GhosttyKeyEvent)::UInt32
end

mutable struct GhosttyKeyEncoderImpl end

"""
Opaque handle to a key encoder instance.

This handle represents a key encoder that converts key events into terminal escape sequences.

` key`
"""
const GhosttyKeyEncoder = Ptr{GhosttyKeyEncoderImpl}

"""
Kitty keyboard protocol flags.

Bitflags representing the various modes of the Kitty keyboard protocol. These can be combined using bitwise OR operations. Valid values all start with `GHOSTTY_KITTY_KEY_`.

` key`
"""
const GhosttyKittyKeyFlags = UInt8

"""
    GhosttyOptionAsAlt

macOS option key behavior.

Determines whether the "option" key on macOS is treated as "alt" or not. See the Ghostty `macos-option-as-alt` configuration option for more details.

` key`

| Enumerator                                | Note                                     |
| :---------------------------------------- | :--------------------------------------- |
| GHOSTTY\\_OPTION\\_AS\\_ALT\\_FALSE       | Option key is not treated as alt         |
| GHOSTTY\\_OPTION\\_AS\\_ALT\\_TRUE        | Option key is treated as alt             |
| GHOSTTY\\_OPTION\\_AS\\_ALT\\_LEFT        | Only left option key is treated as alt   |
| GHOSTTY\\_OPTION\\_AS\\_ALT\\_RIGHT       | Only right option key is treated as alt  |
| GHOSTTY\\_OPTION\\_AS\\_ALT\\_MAX\\_VALUE |                                          |
"""
@cenum GhosttyOptionAsAlt::UInt32 begin
    GHOSTTY_OPTION_AS_ALT_FALSE = 0
    GHOSTTY_OPTION_AS_ALT_TRUE = 1
    GHOSTTY_OPTION_AS_ALT_LEFT = 2
    GHOSTTY_OPTION_AS_ALT_RIGHT = 3
    GHOSTTY_OPTION_AS_ALT_MAX_VALUE = 2147483647
end

"""
    GhosttyKeyEncoderOption

Key encoder option identifiers.

These values are used with [`ghostty_key_encoder_set`](@ref)() to configure the behavior of the key encoder.

` key`

| Enumerator                                                        | Note                                                                                                                                                                                         |
| :---------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_INVALID                           | Not a real option. [`ghostty_key_encoder_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.  |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_CURSOR\\_KEY\\_APPLICATION        | Terminal DEC mode 1: cursor key application mode (value: bool, default: false)                                                                                                               |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_KEYPAD\\_KEY\\_APPLICATION        | Terminal DEC mode 66: keypad key application mode (value: bool, default: false)                                                                                                              |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_IGNORE\\_KEYPAD\\_WITH\\_NUMLOCK  | Terminal DEC mode 1035: ignore keypad with numlock (value: bool, default: false)                                                                                                             |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_ALT\\_ESC\\_PREFIX                | Terminal DEC mode 1036: alt sends escape prefix (value: bool, default: false)                                                                                                                |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_MODIFY\\_OTHER\\_KEYS\\_STATE\\_2 | xterm modifyOtherKeys mode 2 (value: bool, default: false)                                                                                                                                   |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_KITTY\\_FLAGS                     | Kitty keyboard protocol flags (value: [`GhosttyKittyKeyFlags`](@ref) bitmask, default: [`GHOSTTY_KITTY_KEY_DISABLED`](@ref))                                                                 |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_MACOS\\_OPTION\\_AS\\_ALT         | macOS option-as-alt setting (value: [`GhosttyOptionAsAlt`](@ref), default: GHOSTTY\\_OPTION\\_AS\\_ALT\\_FALSE)                                                                              |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_BACKARROW\\_KEY\\_MODE            | Backarrow key mode (value: bool) See https://vt100.net/dec/ek-vt3xx-tp-002.pdf page 170 If `false` (the default), `backspace` emits 0x7f If `true`, `backspace` emits 0x08                   |
| GHOSTTY\\_KEY\\_ENCODER\\_OPT\\_MAX\\_VALUE                       |                                                                                                                                                                                              |
"""
@cenum GhosttyKeyEncoderOption::UInt32 begin
    GHOSTTY_KEY_ENCODER_OPT_INVALID = 0
    GHOSTTY_KEY_ENCODER_OPT_CURSOR_KEY_APPLICATION = 1
    GHOSTTY_KEY_ENCODER_OPT_KEYPAD_KEY_APPLICATION = 2
    GHOSTTY_KEY_ENCODER_OPT_IGNORE_KEYPAD_WITH_NUMLOCK = 3
    GHOSTTY_KEY_ENCODER_OPT_ALT_ESC_PREFIX = 4
    GHOSTTY_KEY_ENCODER_OPT_MODIFY_OTHER_KEYS_STATE_2 = 5
    GHOSTTY_KEY_ENCODER_OPT_KITTY_FLAGS = 6
    GHOSTTY_KEY_ENCODER_OPT_MACOS_OPTION_AS_ALT = 7
    GHOSTTY_KEY_ENCODER_OPT_BACKARROW_KEY_MODE = 8
    GHOSTTY_KEY_ENCODER_OPT_MAX_VALUE = 2147483647
end

"""
    ghostty_key_encoder_new(allocator, encoder)

Create a new key encoder instance.

Creates a new key encoder with default options. The encoder can be configured using [`ghostty_key_encoder_set`](@ref)() and must be freed using [`ghostty_key_encoder_free`](@ref)() when no longer needed.

` key`

# Arguments
* `allocator`: Pointer to the allocator to use for memory management, or NULL to use the default allocator
* `encoder`: Pointer to store the created encoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_key_encoder_new(allocator, encoder)
    @ccall libghostty_vt.ghostty_key_encoder_new(allocator::Ptr{GhosttyAllocator}, encoder::Ptr{GhosttyKeyEncoder})::GhosttyResult
end

"""
    ghostty_key_encoder_free(encoder)

Free a key encoder instance.

Releases all resources associated with the key encoder. After this call, the encoder handle becomes invalid and must not be used.

` key`

# Arguments
* `encoder`: The encoder handle to free (may be NULL)
"""
function ghostty_key_encoder_free(encoder)
    @ccall libghostty_vt.ghostty_key_encoder_free(encoder::GhosttyKeyEncoder)::Cvoid
end

"""
    ghostty_key_encoder_set(encoder, option, value)

Set an option on the key encoder.

Configures the behavior of the key encoder. Options control various aspects of encoding such as terminal modes (cursor key application mode, keypad mode), protocol selection (Kitty keyboard protocol flags), and platform-specific behaviors (macOS option-as-alt).

If you are using a terminal instance, you can set the key encoding options based on the active terminal state (e.g. legacy vs Kitty mode and associated flags) with [`ghostty_key_encoder_set_from_terminal`](@ref)().

Passing NULL for `value` resets the option to its default, the same value a new encoder starts with. Each option's default is listed on [`GhosttyKeyEncoderOption`](@ref).

```c++
{.c}
 bool enabled = true;
 ghostty_key_encoder_set(
     encoder, GHOSTTY_KEY_ENCODER_OPT_CURSOR_KEY_APPLICATION, &enabled);

 // Later, put the option back to its default (false).
 ghostty_key_encoder_set(
     encoder, GHOSTTY_KEY_ENCODER_OPT_CURSOR_KEY_APPLICATION, NULL);
```

` key`

# Arguments
* `encoder`: The encoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to set
* `value`: Pointer to the value to set (type depends on the option), or NULL to reset the option to its default
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `encoder` is NULL or the value is out of range (such as an unknown [`GhosttyOptionAsAlt`](@ref)), or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_key_encoder_set(encoder, option, value)
    @ccall libghostty_vt.ghostty_key_encoder_set(encoder::GhosttyKeyEncoder, option::GhosttyKeyEncoderOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_key_encoder_set_from_terminal(encoder, terminal)

Set encoder options from a terminal's current state.

Reads the terminal's current modes and flags and applies them to the encoder's options. This sets cursor key application mode, keypad mode, backarrow key mode, ignore-keypad-with-numlock, alt escape prefix, modifyOtherKeys state, and Kitty keyboard protocol flags from the terminal state.

Note that the `macos_option_as_alt` option cannot be determined from terminal state and is reset to `GHOSTTY_OPTION_AS_ALT_FALSE` by this call. Use [`ghostty_key_encoder_set`](@ref)() to set it afterward if needed.

` key`

# Arguments
* `encoder`: The encoder handle
* `terminal`: The terminal handle
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `encoder` or `terminal` is NULL. On error the encoder is not changed.
"""
function ghostty_key_encoder_set_from_terminal(encoder, terminal)
    @ccall libghostty_vt.ghostty_key_encoder_set_from_terminal(encoder::GhosttyKeyEncoder, terminal::GhosttyTerminal)::GhosttyResult
end

"""
    ghostty_key_encoder_encode(encoder, event, buf, buf_len, out_written)

Encode a key event into a terminal escape sequence.

Converts a key event into the appropriate terminal escape sequence based on the encoder's current options. The sequence is written to the provided buffer.

Not all key events produce output. For example, unmodified modifier keys typically don't generate escape sequences. For those events this returns GHOSTTY\\_SUCCESS with `out_written` set to 0.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets `out_written` to the size needed. The buffer may then hold part of the sequence, which you should discard. To get the size without encoding anything, pass NULL for `buf` and 0 for `buf_len`. An event with no output still returns GHOSTTY\\_SUCCESS in that case, because it needs no space.

## Example: Calculate required buffer size

```c++
{.c}
 // Query the required size with a NULL buffer
 size_t required = 0;
 GhosttyResult result = ghostty_key_encoder_encode(encoder, event, NULL, 0, &required);
 if (result == GHOSTTY_SUCCESS) {
   // This event produces no output, so there is nothing to send
   return;
 }
 assert(result == GHOSTTY_OUT_OF_SPACE);

 // Allocate buffer of required size
 uint8_t *buf = malloc(required);

 // Encode with properly sized buffer
 size_t written = 0;
 result = ghostty_key_encoder_encode(encoder, event, buf, required, &written);
 assert(result == GHOSTTY_SUCCESS);

 // Use the encoded sequence...

 free(buf);
```

## Example: Direct encoding with static buffer

```c++
{.c}
 // Most escape sequences are short, so a static buffer often suffices
 uint8_t buf[128];
 size_t written = 0;
 GhosttyResult result = ghostty_key_encoder_encode(encoder, event, buf, sizeof(buf), &written);

 if (result == GHOSTTY_SUCCESS) {
   // Write the encoded sequence to the terminal
   write(pty_fd, buf, written);
 } else if (result == GHOSTTY_OUT_OF_SPACE) {
   // Buffer too small, written contains required size
   uint8_t *dynamic_buf = malloc(written);
   result = ghostty_key_encoder_encode(encoder, event, dynamic_buf, written, &written);
   assert(result == GHOSTTY_SUCCESS);
   write(pty_fd, dynamic_buf, written);
   free(dynamic_buf);
 }
```

` key`

# Arguments
* `encoder`: The encoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `event`: The key event to encode (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `buf`: Buffer to write the sequence into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE. NULL returns GHOSTTY\\_INVALID\\_VALUE.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if buffer too small, or other error code
"""
function ghostty_key_encoder_encode(encoder, event, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_key_encoder_encode(encoder::GhosttyKeyEncoder, event::GhosttyKeyEvent, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

mutable struct GhosttyMouseEventImpl end

"""
Opaque handle to a mouse event.

This handle represents a normalized mouse input event containing action, button, modifiers, and surface-space position.

` mouse`
"""
const GhosttyMouseEvent = Ptr{GhosttyMouseEventImpl}

"""
    GhosttyMouseAction

Mouse event action type.

` mouse`

| Enumerator                             | Note                        |
| :------------------------------------- | :-------------------------- |
| GHOSTTY\\_MOUSE\\_ACTION\\_PRESS       | Mouse button was pressed.   |
| GHOSTTY\\_MOUSE\\_ACTION\\_RELEASE     | Mouse button was released.  |
| GHOSTTY\\_MOUSE\\_ACTION\\_MOTION      | Mouse moved.                |
| GHOSTTY\\_MOUSE\\_ACTION\\_MAX\\_VALUE |                             |
"""
@cenum GhosttyMouseAction::UInt32 begin
    GHOSTTY_MOUSE_ACTION_PRESS = 0
    GHOSTTY_MOUSE_ACTION_RELEASE = 1
    GHOSTTY_MOUSE_ACTION_MOTION = 2
    GHOSTTY_MOUSE_ACTION_MAX_VALUE = 2147483647
end

"""
    GhosttyMouseButton

Mouse button identity.

` mouse`
"""
@cenum GhosttyMouseButton::UInt32 begin
    GHOSTTY_MOUSE_BUTTON_UNKNOWN = 0
    GHOSTTY_MOUSE_BUTTON_LEFT = 1
    GHOSTTY_MOUSE_BUTTON_RIGHT = 2
    GHOSTTY_MOUSE_BUTTON_MIDDLE = 3
    GHOSTTY_MOUSE_BUTTON_FOUR = 4
    GHOSTTY_MOUSE_BUTTON_FIVE = 5
    GHOSTTY_MOUSE_BUTTON_SIX = 6
    GHOSTTY_MOUSE_BUTTON_SEVEN = 7
    GHOSTTY_MOUSE_BUTTON_EIGHT = 8
    GHOSTTY_MOUSE_BUTTON_NINE = 9
    GHOSTTY_MOUSE_BUTTON_TEN = 10
    GHOSTTY_MOUSE_BUTTON_ELEVEN = 11
    GHOSTTY_MOUSE_BUTTON_MAX_VALUE = 2147483647
end

"""
    GhosttyMousePosition

Mouse position in surface-space pixels.

` mouse`
"""
struct GhosttyMousePosition
    x::Cfloat
    y::Cfloat
end

"""
    ghostty_mouse_event_new(allocator, event)

Create a new mouse event instance.

` mouse`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `event`: Pointer to store the created event handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_mouse_event_new(allocator, event)
    @ccall libghostty_vt.ghostty_mouse_event_new(allocator::Ptr{GhosttyAllocator}, event::Ptr{GhosttyMouseEvent})::GhosttyResult
end

"""
    ghostty_mouse_event_free(event)

Free a mouse event instance.

` mouse`

# Arguments
* `event`: The mouse event handle to free (may be NULL)
"""
function ghostty_mouse_event_free(event)
    @ccall libghostty_vt.ghostty_mouse_event_free(event::GhosttyMouseEvent)::Cvoid
end

"""
    ghostty_mouse_event_set_action(event, action)

Set the event action.

` mouse`

# Arguments
* `event`: The event handle
* `action`: The action to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL or `action` is not a [`GhosttyMouseAction`](@ref) value this version of the library knows. On error the event is not changed.
"""
function ghostty_mouse_event_set_action(event, action)
    @ccall libghostty_vt.ghostty_mouse_event_set_action(event::GhosttyMouseEvent, action::GhosttyMouseAction)::GhosttyResult
end

"""
    ghostty_mouse_event_get_action(event)

Get the event action.

` mouse`

# Arguments
* `event`: The event handle
# Returns
The event action, or GHOSTTY\\_MOUSE\\_ACTION\\_PRESS if `event` is NULL
"""
function ghostty_mouse_event_get_action(event)
    @ccall libghostty_vt.ghostty_mouse_event_get_action(event::GhosttyMouseEvent)::GhosttyMouseAction
end

"""
    ghostty_mouse_event_set_button(event, button)

Set the event button.

This sets a concrete button identity for the event. To represent "no button" (for motion events), use [`ghostty_mouse_event_clear_button`](@ref)().

` mouse`

# Arguments
* `event`: The event handle
* `button`: The button to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL or `button` is not a [`GhosttyMouseButton`](@ref) value this version of the library knows. On error the event is not changed.
"""
function ghostty_mouse_event_set_button(event, button)
    @ccall libghostty_vt.ghostty_mouse_event_set_button(event::GhosttyMouseEvent, button::GhosttyMouseButton)::GhosttyResult
end

"""
    ghostty_mouse_event_clear_button(event)

Clear the event button.

This sets the event button to "none".

` mouse`

# Arguments
* `event`: The event handle
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_mouse_event_clear_button(event)
    @ccall libghostty_vt.ghostty_mouse_event_clear_button(event::GhosttyMouseEvent)::GhosttyResult
end

"""
    ghostty_mouse_event_get_button(event, out_button)

Get the event button.

A new event has no button, and [`ghostty_mouse_event_clear_button`](@ref)() removes the button from an event. Having no button is normal, for example when the mouse moves with no button held. It is not an error, so check for GHOSTTY\\_NO\\_VALUE separately:

```c++
{.c}
 GhosttyMouseButton button;
 switch (ghostty_mouse_event_get_button(event, &button)) {
 case GHOSTTY_SUCCESS:
     // `button` holds the event's button.
     break;
 case GHOSTTY_NO_VALUE:
     // The event has no button. `button` was not written.
     break;
 default:
     // `event` or the output pointer was NULL.
     break;
 }
```

` mouse`

# Arguments
* `event`: The event handle
* `out_button`: Where to write the button. NULL returns GHOSTTY\\_INVALID\\_VALUE.
# Returns
GHOSTTY\\_SUCCESS if the event has a button, GHOSTTY\\_NO\\_VALUE if it has none, or GHOSTTY\\_INVALID\\_VALUE if `event` or `out_button` is NULL. `out_button` is written only on GHOSTTY\\_SUCCESS.
"""
function ghostty_mouse_event_get_button(event, out_button)
    @ccall libghostty_vt.ghostty_mouse_event_get_button(event::GhosttyMouseEvent, out_button::Ptr{GhosttyMouseButton})::GhosttyResult
end

"""
    ghostty_mouse_event_set_mods(event, mods)

Set keyboard modifiers held during the event.

` mouse`

# Arguments
* `event`: The event handle
* `mods`: Modifier bitmask
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_mouse_event_set_mods(event, mods)
    @ccall libghostty_vt.ghostty_mouse_event_set_mods(event::GhosttyMouseEvent, mods::GhosttyMods)::GhosttyResult
end

"""
    ghostty_mouse_event_get_mods(event)

Get keyboard modifiers held during the event.

` mouse`

# Arguments
* `event`: The event handle
# Returns
Modifier bitmask, or 0 (no modifiers) if `event` is NULL
"""
function ghostty_mouse_event_get_mods(event)
    @ccall libghostty_vt.ghostty_mouse_event_get_mods(event::GhosttyMouseEvent)::GhosttyMods
end

"""
    ghostty_mouse_event_set_position(event, position)

Set the event position in surface-space pixels.

` mouse`

# Arguments
* `event`: The event handle
* `position`: The position to set
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `event` is NULL. On error the event is not changed.
"""
function ghostty_mouse_event_set_position(event, position)
    @ccall libghostty_vt.ghostty_mouse_event_set_position(event::GhosttyMouseEvent, position::GhosttyMousePosition)::GhosttyResult
end

"""
    ghostty_mouse_event_get_position(event)

Get the event position in surface-space pixels.

` mouse`

# Arguments
* `event`: The event handle
# Returns
The current event position, or (0, 0) if `event` is NULL
"""
function ghostty_mouse_event_get_position(event)
    @ccall libghostty_vt.ghostty_mouse_event_get_position(event::GhosttyMouseEvent)::GhosttyMousePosition
end

mutable struct GhosttyMouseEncoderImpl end

"""
Opaque handle to a mouse encoder instance.

This handle represents a mouse encoder that converts normalized mouse events into terminal escape sequences.

` mouse`
"""
const GhosttyMouseEncoder = Ptr{GhosttyMouseEncoderImpl}

"""
    GhosttyMouseTrackingMode

Mouse tracking mode.

` mouse`

| Enumerator                               | Note                                            |
| :--------------------------------------- | :---------------------------------------------- |
| GHOSTTY\\_MOUSE\\_TRACKING\\_NONE        | Mouse reporting disabled.                       |
| GHOSTTY\\_MOUSE\\_TRACKING\\_X10         | X10 mouse mode.                                 |
| GHOSTTY\\_MOUSE\\_TRACKING\\_NORMAL      | Normal mouse mode (button press/release only).  |
| GHOSTTY\\_MOUSE\\_TRACKING\\_BUTTON      | Button-event tracking mode.                     |
| GHOSTTY\\_MOUSE\\_TRACKING\\_ANY         | Any-event tracking mode.                        |
| GHOSTTY\\_MOUSE\\_TRACKING\\_MAX\\_VALUE |                                                 |
"""
@cenum GhosttyMouseTrackingMode::UInt32 begin
    GHOSTTY_MOUSE_TRACKING_NONE = 0
    GHOSTTY_MOUSE_TRACKING_X10 = 1
    GHOSTTY_MOUSE_TRACKING_NORMAL = 2
    GHOSTTY_MOUSE_TRACKING_BUTTON = 3
    GHOSTTY_MOUSE_TRACKING_ANY = 4
    GHOSTTY_MOUSE_TRACKING_MAX_VALUE = 2147483647
end

"""
    GhosttyMouseFormat

Mouse output format.

` mouse`
"""
@cenum GhosttyMouseFormat::UInt32 begin
    GHOSTTY_MOUSE_FORMAT_X10 = 0
    GHOSTTY_MOUSE_FORMAT_UTF8 = 1
    GHOSTTY_MOUSE_FORMAT_SGR = 2
    GHOSTTY_MOUSE_FORMAT_URXVT = 3
    GHOSTTY_MOUSE_FORMAT_SGR_PIXELS = 4
    GHOSTTY_MOUSE_FORMAT_MAX_VALUE = 2147483647
end

"""
    GhosttyMouseEncoderSize

Mouse encoder size and geometry context.

This describes the rendered terminal geometry used to convert surface-space positions into encoded coordinates.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)(), then set the fields you need. See sized-structs.

` mouse`

| Field            | Note                                                                                     |
| :--------------- | :--------------------------------------------------------------------------------------- |
| size             | Size of this struct in bytes. Must be set to sizeof([`GhosttyMouseEncoderSize`](@ref)).  |
| screen\\_width   | Full screen width in pixels.                                                             |
| screen\\_height  | Full screen height in pixels.                                                            |
| cell\\_width     | Cell width in pixels. Must be non-zero.                                                  |
| cell\\_height    | Cell height in pixels. Must be non-zero.                                                 |
| padding\\_top    | Top padding in pixels.                                                                   |
| padding\\_bottom | Bottom padding in pixels.                                                                |
| padding\\_right  | Right padding in pixels.                                                                 |
| padding\\_left   | Left padding in pixels.                                                                  |
"""
struct GhosttyMouseEncoderSize
    size::Csize_t
    screen_width::UInt32
    screen_height::UInt32
    cell_width::UInt32
    cell_height::UInt32
    padding_top::UInt32
    padding_bottom::UInt32
    padding_right::UInt32
    padding_left::UInt32
end

"""
    GhosttyMouseEncoderOption

Mouse encoder option identifiers.

These values are used with [`ghostty_mouse_encoder_set`](@ref)() to configure the behavior of the mouse encoder.

` mouse`

| Enumerator                                               | Note                                                                                                                                                                                           |
| :------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_MOUSE\\_ENCODER\\_OPT\\_INVALID                | Not a real option. [`ghostty_mouse_encoder_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.  |
| GHOSTTY\\_MOUSE\\_ENCODER\\_OPT\\_EVENT                  | Mouse tracking mode (value: [`GhosttyMouseTrackingMode`](@ref), default: GHOSTTY\\_MOUSE\\_TRACKING\\_NONE).                                                                                   |
| GHOSTTY\\_MOUSE\\_ENCODER\\_OPT\\_FORMAT                 | Mouse output format (value: [`GhosttyMouseFormat`](@ref), default: GHOSTTY\\_MOUSE\\_FORMAT\\_X10).                                                                                            |
| GHOSTTY\\_MOUSE\\_ENCODER\\_OPT\\_SIZE                   | Renderer size context (value: [`GhosttyMouseEncoderSize`](@ref), default: a 1x1 pixel screen with 1x1 pixel cells and no padding).                                                             |
| GHOSTTY\\_MOUSE\\_ENCODER\\_OPT\\_ANY\\_BUTTON\\_PRESSED | Whether any mouse button is currently pressed (value: bool, default: false).                                                                                                                   |
| GHOSTTY\\_MOUSE\\_ENCODER\\_OPT\\_TRACK\\_LAST\\_CELL    | Whether to enable motion deduplication by last cell (value: bool, default: false).                                                                                                             |
| GHOSTTY\\_MOUSE\\_ENCODER\\_OPT\\_MAX\\_VALUE            |                                                                                                                                                                                                |
"""
@cenum GhosttyMouseEncoderOption::UInt32 begin
    GHOSTTY_MOUSE_ENCODER_OPT_INVALID = 0
    GHOSTTY_MOUSE_ENCODER_OPT_EVENT = 1
    GHOSTTY_MOUSE_ENCODER_OPT_FORMAT = 2
    GHOSTTY_MOUSE_ENCODER_OPT_SIZE = 3
    GHOSTTY_MOUSE_ENCODER_OPT_ANY_BUTTON_PRESSED = 4
    GHOSTTY_MOUSE_ENCODER_OPT_TRACK_LAST_CELL = 5
    GHOSTTY_MOUSE_ENCODER_OPT_MAX_VALUE = 2147483647
end

"""
    ghostty_mouse_encoder_new(allocator, encoder)

Create a new mouse encoder instance.

` mouse`

# Arguments
* `allocator`: Pointer to allocator, or NULL to use the default allocator
* `encoder`: Pointer to store the created encoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_mouse_encoder_new(allocator, encoder)
    @ccall libghostty_vt.ghostty_mouse_encoder_new(allocator::Ptr{GhosttyAllocator}, encoder::Ptr{GhosttyMouseEncoder})::GhosttyResult
end

"""
    ghostty_mouse_encoder_free(encoder)

Free a mouse encoder instance.

` mouse`

# Arguments
* `encoder`: The encoder handle to free (may be NULL)
"""
function ghostty_mouse_encoder_free(encoder)
    @ccall libghostty_vt.ghostty_mouse_encoder_free(encoder::GhosttyMouseEncoder)::Cvoid
end

"""
    ghostty_mouse_encoder_set(encoder, option, value)

Set an option on the mouse encoder.

Passing NULL for `value` resets the option to its default, the same value a new encoder starts with. Each option's default is listed on [`GhosttyMouseEncoderOption`](@ref).

```c++
{.c}
 GhosttyMouseFormat format = GHOSTTY_MOUSE_FORMAT_SGR;
 GhosttyResult result = ghostty_mouse_encoder_set(
     encoder, GHOSTTY_MOUSE_ENCODER_OPT_FORMAT, &format);
```

` mouse`

# Arguments
* `encoder`: The encoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: The option to set
* `value`: Pointer to option value (type depends on option), or NULL to reset the option to its default
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if `encoder` is NULL or the value is not valid (an unknown tracking mode or format, or a size that is too small or has a zero cell dimension), or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_mouse_encoder_set(encoder, option, value)
    @ccall libghostty_vt.ghostty_mouse_encoder_set(encoder::GhosttyMouseEncoder, option::GhosttyMouseEncoderOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_mouse_encoder_set_from_terminal(encoder, terminal)

Set encoder options from a terminal's current state.

This sets tracking mode and output format from terminal state. It also clears the last-cell state, as [`ghostty_mouse_encoder_reset`](@ref)() does, so the next motion event isn't dropped as a repeat of the last cell. It does not modify size or any-button state.

` mouse`

# Arguments
* `encoder`: The encoder handle
* `terminal`: The terminal handle
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `encoder` or `terminal` is NULL. On error the encoder is not changed.
"""
function ghostty_mouse_encoder_set_from_terminal(encoder, terminal)
    @ccall libghostty_vt.ghostty_mouse_encoder_set_from_terminal(encoder::GhosttyMouseEncoder, terminal::GhosttyTerminal)::GhosttyResult
end

"""
    ghostty_mouse_encoder_reset(encoder)

Reset internal encoder state.

This clears motion deduplication state (last tracked cell).

` mouse`

# Arguments
* `encoder`: The encoder handle
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if `encoder` is NULL.
"""
function ghostty_mouse_encoder_reset(encoder)
    @ccall libghostty_vt.ghostty_mouse_encoder_reset(encoder::GhosttyMouseEncoder)::GhosttyResult
end

"""
    ghostty_mouse_encoder_encode(encoder, event, buf, buf_len, out_written)

Encode a mouse event into a terminal escape sequence.

Not all mouse events produce output. In such cases this returns GHOSTTY\\_SUCCESS with `out_written` set to 0.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and sets `out_written` to the size needed. The buffer may then hold part of the sequence, which you should discard. To get the size without encoding anything, pass NULL for `buf` and 0 for `buf_len`. An event with no output still returns GHOSTTY\\_SUCCESS in that case, because it needs no space.

A 128-byte buffer is enough for typical events:

```c++
{.c}
 uint8_t buf[128];
 size_t written = 0;
 if (ghostty_mouse_encoder_encode(encoder, event, buf, sizeof(buf),
                                  &written) == GHOSTTY_SUCCESS &&
     written > 0) {
   write(pty_fd, buf, written);
 }
```

` mouse`

# Arguments
* `encoder`: The encoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `event`: The mouse event to encode (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `buf`: Buffer to write the sequence into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE. NULL returns GHOSTTY\\_INVALID\\_VALUE.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if buffer is too small, or another error code
"""
function ghostty_mouse_encoder_encode(encoder, event, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_mouse_encoder_encode(encoder::GhosttyMouseEncoder, event::GhosttyMouseEvent, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    GhosttyMouseShape

Mouse pointer shapes based on the W3C cursor names.

Hosts map these values to their native pointer shapes; not every platform supports every shape. These are pointer shapes, not terminal text cursors.

` mouse`
"""
@cenum GhosttyMouseShape::UInt32 begin
    GHOSTTY_MOUSE_SHAPE_DEFAULT = 0
    GHOSTTY_MOUSE_SHAPE_CONTEXT_MENU = 1
    GHOSTTY_MOUSE_SHAPE_HELP = 2
    GHOSTTY_MOUSE_SHAPE_POINTER = 3
    GHOSTTY_MOUSE_SHAPE_PROGRESS = 4
    GHOSTTY_MOUSE_SHAPE_WAIT = 5
    GHOSTTY_MOUSE_SHAPE_CELL = 6
    GHOSTTY_MOUSE_SHAPE_CROSSHAIR = 7
    GHOSTTY_MOUSE_SHAPE_TEXT = 8
    GHOSTTY_MOUSE_SHAPE_VERTICAL_TEXT = 9
    GHOSTTY_MOUSE_SHAPE_ALIAS = 10
    GHOSTTY_MOUSE_SHAPE_COPY = 11
    GHOSTTY_MOUSE_SHAPE_MOVE = 12
    GHOSTTY_MOUSE_SHAPE_NO_DROP = 13
    GHOSTTY_MOUSE_SHAPE_NOT_ALLOWED = 14
    GHOSTTY_MOUSE_SHAPE_GRAB = 15
    GHOSTTY_MOUSE_SHAPE_GRABBING = 16
    GHOSTTY_MOUSE_SHAPE_ALL_SCROLL = 17
    GHOSTTY_MOUSE_SHAPE_COL_RESIZE = 18
    GHOSTTY_MOUSE_SHAPE_ROW_RESIZE = 19
    GHOSTTY_MOUSE_SHAPE_N_RESIZE = 20
    GHOSTTY_MOUSE_SHAPE_E_RESIZE = 21
    GHOSTTY_MOUSE_SHAPE_S_RESIZE = 22
    GHOSTTY_MOUSE_SHAPE_W_RESIZE = 23
    GHOSTTY_MOUSE_SHAPE_NE_RESIZE = 24
    GHOSTTY_MOUSE_SHAPE_NW_RESIZE = 25
    GHOSTTY_MOUSE_SHAPE_SE_RESIZE = 26
    GHOSTTY_MOUSE_SHAPE_SW_RESIZE = 27
    GHOSTTY_MOUSE_SHAPE_EW_RESIZE = 28
    GHOSTTY_MOUSE_SHAPE_NS_RESIZE = 29
    GHOSTTY_MOUSE_SHAPE_NESW_RESIZE = 30
    GHOSTTY_MOUSE_SHAPE_NWSE_RESIZE = 31
    GHOSTTY_MOUSE_SHAPE_ZOOM_IN = 32
    GHOSTTY_MOUSE_SHAPE_ZOOM_OUT = 33
    GHOSTTY_MOUSE_SHAPE_MAX_VALUE = 2147483647
end

"""
    GhosttyPasteSource

Why a paste happened.

| Enumerator                             | Note                                                                                                                                                                                                                                                                    |
| :------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_PASTE\\_SOURCE\\_CLIPBOARD   | The user pasted from a clipboard: keybind, menu, middle click.                                                                                                                                                                                                          |
| GHOSTTY\\_PASTE\\_SOURCE\\_TEXT        | Text inserted some other way: IME commit, drag and drop, scripted input. Always written as text, never as a paste event, matching kitty. This is not a way to opt out of paste events; an embedder that doesn't want them doesn't install a clipboard\\_read callback.  |
| GHOSTTY\\_PASTE\\_SOURCE\\_MAX\\_VALUE |                                                                                                                                                                                                                                                                         |
"""
@cenum GhosttyPasteSource::UInt32 begin
    GHOSTTY_PASTE_SOURCE_CLIPBOARD = 0
    GHOSTTY_PASTE_SOURCE_TEXT = 1
    GHOSTTY_PASTE_SOURCE_MAX_VALUE = 2147483647
end

"""
    GhosttyPaste

A paste of clipboard contents into the terminal.

This is a sized struct. Initialize it with [`GHOSTTY_INIT_SIZED`](@ref)(), then set the fields you need. See sized-structs.

The MIME type array and the strings it points to are borrowed only for the duration of the [`ghostty_terminal_paste`](@ref)() call, as is everything the reader produces.

| Field          | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| size           | Size of this struct in bytes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| location       | The clipboard the contents came from. Reported to the program on a paste event (the selection and primary locations are both reported as the primary selection, the protocol knows only two); no effect on a text paste.                                                                                                                                                                                                                                                                                                 |
| source         | Why this paste happened.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| mimes          | Borrowed array of the MIME types of the representations available, in preferred order. A text paste reads and writes the first entry with a text MIME type such as "text/plain" and ignores the rest. A paste event lists every entry and reads none. May be NULL when mimes\\_len is zero, which is nothing to paste.                                                                                                                                                                                                   |
| mimes\\_len    | Number of entries in mimes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| reader         | Produces the data of a representation on demand. Required when mimes\\_len is nonzero.  Called at most once per [`ghostty_terminal_paste`](@ref)() call: for the text representation being pasted, never for anything else and never for a paste event. The MIME type requested is always an entry of `mimes`, passed through exactly as given there (the same pointer and length), so the callback may identify the representation by pointer or by content. A false return fails the paste with GHOSTTY\\_IO\\_ERROR.  |
| allow\\_unsafe | Write text that could inject commands. Call with false, confirm with the person using your terminal on GHOSTTY\\_REJECTED, and call again with true.                                                                                                                                                                                                                                                                                                                                                                     |
"""
struct GhosttyPaste
    size::Csize_t
    location::GhosttyClipboardLocation
    source::GhosttyPasteSource
    mimes::Ptr{GhosttyString}
    mimes_len::Csize_t
    reader::GhosttyMimeReader
    allow_unsafe::Bool
end

"""
    ghostty_terminal_paste(terminal, paste, out_pasted)

Paste into the terminal according to its current state: a Kitty clipboard protocol paste event if mode 5522 is enabled and a clipboard\\_read callback is installed, otherwise the text framed per mode 2004. See guide-input-paste for the full behavior. Output streams through the write\\_pty callback in chunks. The viewport is not scrolled; that is up to you, as for key input.

A paste event records a session grant for its one-time password only once the event is written; a failed call never leaves a grant for an event that was never sent.

# Arguments
* `terminal`: The terminal handle
* `paste`: The paste request, borrowed for the duration of the call
* `out_pasted`:\\[out\\] On success, whether anything was written to the pty (the encoded text or a paste event). False means there was nothing to paste: no non-empty text representation. May be NULL.
# Returns
GHOSTTY\\_SUCCESS on success (see `out_pasted`). GHOSTTY\\_REJECTED if the text could inject commands and [`GhosttyPaste`](@ref)::allow\\_unsafe is false. GHOSTTY\\_INVALID\\_VALUE for a NULL terminal or paste, an unknown [`GhosttyPaste`](@ref)::source, MIME types without a reader, or when no write\\_pty callback is installed. GHOSTTY\\_OUT\\_OF\\_MEMORY if an allocation fails. GHOSTTY\\_IO\\_ERROR if the reader failed or there is no secure entropy source to create a paste event password (wasm32-freestanding without GHOSTTY\\_SYS\\_OPT\\_RANDOM\\_SECURE set). Errors write nothing.
"""
function ghostty_terminal_paste(terminal, paste, out_pasted)
    @ccall libghostty_vt.ghostty_terminal_paste(terminal::GhosttyTerminal, paste::Ptr{GhosttyPaste}, out_pasted::Ptr{Bool})::GhosttyResult
end

"""
    ghostty_paste_is_safe(data, len)

Check if paste data is safe to paste into the terminal.

Data is considered unsafe if it contains: - Line terminators (`` or ``) which can inject commands. A carriage return is what the Enter key sends, so it is as dangerous as a newline on an unbracketed paste. - The bracketed paste end sequence (`[201~`) which can be used to exit bracketed paste mode and inject commands

This check is conservative and considers data unsafe regardless of current terminal state. [`ghostty_terminal_paste`](@ref)() applies the terminal-state-aware rule itself (line terminators are safe inside a bracketed paste); use this to apply the stricter rule on top.

# Arguments
* `data`: The paste data to check (NULL is the same as empty data)
* `len`: The length of the data in bytes
# Returns
true if the data is safe to paste, false otherwise
"""
function ghostty_paste_is_safe(data, len)
    @ccall libghostty_vt.ghostty_paste_is_safe(data::Cstring, len::Csize_t)::Bool
end

"""
    ghostty_paste_encode(data, data_len, bracketed, buf, buf_len, out_written)

Encode paste data for writing to the terminal pty.

This function prepares paste data for terminal input by: - Stripping unsafe control bytes (NUL, ESC, DEL, etc.) by replacing them with spaces - Wrapping the data in bracketed paste sequences if `bracketed` is true - Replacing newlines with carriage returns if `bracketed` is false

The input `data` buffer is modified in place during encoding. The encoded result (potentially with bracketed paste prefix/suffix) is written to the output buffer.

If `buf` is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE, sets `out_written` to the size needed, and leaves `buf` unchanged. To get the size first, pass NULL for `buf` and 0 for `buf_len`. An empty result needs no space, so empty input with `bracketed` false returns GHOSTTY\\_SUCCESS with `out_written` set to 0.

The function modifies `data` even when it returns GHOSTTY\\_OUT\\_OF\\_SPACE. Encoding the modified data again gives the same result, so you can retry with the same `data` and a larger buffer:

```c++
{.c}
 size_t needed = 0;
 GhosttyResult result = ghostty_paste_encode(data, data_len, bracketed,
                                             NULL, 0, &needed);
 if (result == GHOSTTY_OUT_OF_SPACE) {
   uint8_t *buf = malloc(needed);
   size_t written = 0;
   result = ghostty_paste_encode(data, data_len, bracketed, buf, needed,
                                 &written);
   if (result == GHOSTTY_SUCCESS) write(pty_fd, buf, written);
   free(buf);
 }
```

This is the encoder [`ghostty_terminal_paste`](@ref)() uses for a text paste; use it directly when there is no terminal to paste into.

# Arguments
* `data`: The paste data to encode (modified in place, may be NULL)
* `data_len`: The length of the input data in bytes
* `bracketed`: Whether bracketed paste mode is active
* `buf`: Buffer to write the encoded result into. May be NULL if `buf_len` is 0.
* `buf_len`: Size of `buf` in bytes
* `out_written`:\\[out\\] The number of bytes written, or the size needed if the result is GHOSTTY\\_OUT\\_OF\\_SPACE
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_SPACE if the buffer is too small, or GHOSTTY\\_INVALID\\_VALUE if `out_written` is NULL
"""
function ghostty_paste_encode(data, data_len, bracketed, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_paste_encode(data::Cstring, data_len::Csize_t, bracketed::Bool, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    GhosttySearchStatus

Progress state of a search.

` search`

| Enumerator                                  | Note                                                                                                                                                                                                                                           |
| :------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SEARCH\\_STATUS\\_RUNNING         | [`ghostty_search_tick`](@ref)() can make progress without terminal access.                                                                                                                                                                     |
| GHOSTTY\\_SEARCH\\_STATUS\\_FEED\\_REQUIRED | Blocked until [`ghostty_search_feed`](@ref)(). This is also the state right after a needle is set, since the search has not yet seen the terminal.                                                                                             |
| GHOSTTY\\_SEARCH\\_STATUS\\_COMPLETE        | Caught up with the terminal state as of the last feed. This never means finished forever, since later terminal writes require another feed to be seen. A search with no needle set also reports complete, since there is nothing to look for.  |
| GHOSTTY\\_SEARCH\\_STATUS\\_MAX\\_VALUE     |                                                                                                                                                                                                                                                |
"""
@cenum GhosttySearchStatus::UInt32 begin
    GHOSTTY_SEARCH_STATUS_RUNNING = 0
    GHOSTTY_SEARCH_STATUS_FEED_REQUIRED = 1
    GHOSTTY_SEARCH_STATUS_COMPLETE = 2
    GHOSTTY_SEARCH_STATUS_MAX_VALUE = 2147483647
end

"""
    GhosttySearchScroll

Scroll policy applied when a match becomes selected via [`ghostty_search_select_next`](@ref)() or [`ghostty_search_select_prev`](@ref)().

` search`

| Enumerator                              | Note                                                                                                  |
| :-------------------------------------- | :---------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SEARCH\\_SCROLL\\_IF\\_NEEDED | Scroll the viewport so the match is visible, only if it is not already visible. This is the default.  |
| GHOSTTY\\_SEARCH\\_SCROLL\\_NONE        | Never scroll the viewport.                                                                            |
| GHOSTTY\\_SEARCH\\_SCROLL\\_MAX\\_VALUE |                                                                                                       |
"""
@cenum GhosttySearchScroll::UInt32 begin
    GHOSTTY_SEARCH_SCROLL_IF_NEEDED = 0
    GHOSTTY_SEARCH_SCROLL_NONE = 1
    GHOSTTY_SEARCH_SCROLL_MAX_VALUE = 2147483647
end

"""
    GhosttySearchData

Data fields readable with [`ghostty_search_get`](@ref)(). The output value type is documented per field.

All reads reflect the terminal's active screen as of the last feed. When the running application switches to the alternate screen, the next feed switches counts, matches, and selection to that screen's results. Primary screen results, including completed scrollback searches, are retained and restored on the way back.

` search`

| Enumerator                                   | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| :------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SEARCH\\_DATA\\_INVALID            | Not a real data type. [`ghostty_search_get`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real data type.                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_SEARCH\\_DATA\\_STATUS             | Current search status: [`GhosttySearchStatus`](@ref)*.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_SEARCH\\_DATA\\_NEEDLE             | The needle this search is looking for: [`GhosttyString`](@ref)*. The bytes are borrowed from the search and remain valid until the needle is changed or the search is freed. Returns GHOSTTY\\_NO\\_VALUE when no needle is set.                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_SEARCH\\_DATA\\_TOTAL\\_MATCHES    | Total matches found so far on the active screen: size\\_t*. Zero until the first feed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_SEARCH\\_DATA\\_SELECTED\\_INDEX   | Index of the selected match: size\\_t*. This indexes the newest to oldest ordering of GHOSTTY\\_SEARCH\\_DATA\\_MATCHES, where 0 is the newest match, so a "k of n" find bar renders index + 1 of GHOSTTY\\_SEARCH\\_DATA\\_TOTAL\\_MATCHES. Returns GHOSTTY\\_NO\\_VALUE when nothing is selected.                                                                                                                                                                                                                                                                                                                    |
| GHOSTTY\\_SEARCH\\_DATA\\_SELECTED\\_MATCH   | The selected match: [`GhosttySelection`](@ref)*. This is an untracked snapshot with standard [`GhosttySelection`](@ref) lifetime rules. Returns GHOSTTY\\_NO\\_VALUE when nothing is selected.                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_SEARCH\\_DATA\\_MATCHES            | All matches on the active screen, ordered newest to oldest, from the bottom of the active area up through scrollback: [`GhosttySelectionBuffer`](@ref)*. Set ptr to NULL with cap 0 to query the required capacity. An undersized buffer returns GHOSTTY\\_OUT\\_OF\\_SPACE with the required capacity in len.                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_SEARCH\\_DATA\\_VIEWPORT\\_MATCHES | Matches on the pages covering the viewport, for drawing highlight rectangles: [`GhosttySelectionBuffer`](@ref)*. The list is computed during feeds and cached, so it reflects the viewport as of the last feed.  Matches are found a page at a time, so the list can include matches slightly outside the visible viewport when they share a page with it. Ghostty's own renderer behaves the same way. Converting each match to viewport coordinates with [`ghostty_terminal_point_from_grid_ref`](@ref)() clips this naturally: skip matches that fail the conversion or whose row is beyond the visible row count.  |
| GHOSTTY\\_SEARCH\\_DATA\\_SELECT\\_SCROLL    | Current scroll policy: [`GhosttySearchScroll`](@ref)*.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| GHOSTTY\\_SEARCH\\_DATA\\_MAX\\_VALUE        |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
"""
@cenum GhosttySearchData::UInt32 begin
    GHOSTTY_SEARCH_DATA_INVALID = 0
    GHOSTTY_SEARCH_DATA_STATUS = 1
    GHOSTTY_SEARCH_DATA_NEEDLE = 2
    GHOSTTY_SEARCH_DATA_TOTAL_MATCHES = 3
    GHOSTTY_SEARCH_DATA_SELECTED_INDEX = 4
    GHOSTTY_SEARCH_DATA_SELECTED_MATCH = 5
    GHOSTTY_SEARCH_DATA_MATCHES = 6
    GHOSTTY_SEARCH_DATA_VIEWPORT_MATCHES = 7
    GHOSTTY_SEARCH_DATA_SELECT_SCROLL = 8
    GHOSTTY_SEARCH_DATA_MAX_VALUE = 2147483647
end

"""
    GhosttySearchOption

Options writable with [`ghostty_search_set`](@ref)(). The value type, and what a NULL value means, is documented per option.

` search`

| Enumerator                               | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| :--------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SEARCH\\_OPT\\_INVALID         | Not a real option. [`ghostty_search_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_SEARCH\\_OPT\\_NEEDLE          | Set the needle to search for: const [`GhosttyString`](@ref)*. The bytes are copied, so your memory does not need to outlive the call. Matching is byte-exact except ASCII letters, which compare case-insensitively.  Changing the needle restarts the search from scratch and drops all results. As an exception, setting a needle equal to the current one (compared the same way as matching) keeps existing results, so find bars can resubmit freely. A NULL or empty value clears the needle and returns the search to idle.  Replacing or clearing a needle releases tracked state held within the terminal, so you must serialize this with all other access to the same terminal. Returns GHOSTTY\\_INVALID\\_VALUE after the terminal was freed.  |
| GHOSTTY\\_SEARCH\\_OPT\\_SELECT\\_SCROLL | Set the scroll policy applied by [`ghostty_search_select_next`](@ref)() and [`ghostty_search_select_prev`](@ref)(): const [`GhosttySearchScroll`](@ref)*. The policy persists until changed. A NULL value resets it to GHOSTTY\\_SEARCH\\_SCROLL\\_IF\\_NEEDED. This only modifies search-owned state and never reads the terminal.                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_SEARCH\\_OPT\\_MAX\\_VALUE     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
"""
@cenum GhosttySearchOption::UInt32 begin
    GHOSTTY_SEARCH_OPT_INVALID = 0
    GHOSTTY_SEARCH_OPT_NEEDLE = 1
    GHOSTTY_SEARCH_OPT_SELECT_SCROLL = 4
    GHOSTTY_SEARCH_OPT_MAX_VALUE = 2147483647
end

"""
    ghostty_search_new(allocator, out_search, terminal)

Create a search bound to a terminal.

The search borrows the terminal and never frees it. The search and the terminal can be freed in either order; see [`ghostty_search_free`](@ref)().

The search starts idle with no needle: it reports GHOSTTY\\_SEARCH\\_STATUS\\_COMPLETE and finds nothing. Set GHOSTTY\\_SEARCH\\_OPT\\_NEEDLE to start searching.

Creation is cheap and does not read terminal contents, but it registers the search with the terminal so the two can be freed in any order. You must serialize this call with all other access to the same terminal.

` search`

# Arguments
* `allocator`: Allocator, or NULL for the default allocator
* `out_search`: Receives the created search handle
* `terminal`: Terminal to bind the search to
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if out\\_search or terminal is invalid, or GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails
"""
function ghostty_search_new(allocator, out_search, terminal)
    @ccall libghostty_vt.ghostty_search_new(allocator::Ptr{GhosttyAllocator}, out_search::Ptr{GhosttySearch}, terminal::GhosttyTerminal)::GhosttyResult
end

"""
    ghostty_search_free(search)

Free a search.

If the bound terminal is still alive, this releases tracked state the search holds within it, so you must serialize this call with all other access to the same terminal. If the terminal was already freed, the search has been detached and this releases only search-owned memory. Passing NULL is allowed and is a no-op.

` search`

# Arguments
* `search`: Search handle to free
"""
function ghostty_search_free(search)
    @ccall libghostty_vt.ghostty_search_free(search::GhosttySearch)::Cvoid
end

"""
    ghostty_search_tick(search, out_status)

Make a bounded amount of search progress.

This only works on data the search has already copied and never reads the terminal, so it is safe to call while another thread modifies the terminal. Call it in a loop while the status is GHOSTTY\\_SEARCH\\_STATUS\\_RUNNING. When the status becomes GHOSTTY\\_SEARCH\\_STATUS\\_FEED\\_REQUIRED, call [`ghostty_search_feed`](@ref)() to unblock it.

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_status`:\\[out\\] Receives the status after the tick (may be NULL)
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if search is NULL or the terminal was freed
"""
function ghostty_search_tick(search, out_status)
    @ccall libghostty_vt.ghostty_search_tick(search::GhosttySearch, out_status::Ptr{GhosttySearchStatus})::GhosttyResult
end

"""
    ghostty_search_feed(search)

Read the terminal to update the search.

Each feed catches the search up with the terminal: it reconciles the tracked screens against the live ones, re-scans the active area, refreshes the viewport match list, gives the scrollback searcher its next chunk of data, and prunes results that scrollback eviction invalidated. Feeding is also the only way the search learns about terminal changes, so keep feeding periodically while the search is in use, even after it reports complete.

This reads the terminal, so you must serialize it with all other access to the same terminal. Each call does a bounded amount of work so that any caller-held terminal lock is held only briefly.

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if search is NULL or the terminal was freed
"""
function ghostty_search_feed(search)
    @ccall libghostty_vt.ghostty_search_feed(search::GhosttySearch)::GhosttyResult
end

"""
    ghostty_search_run(search)

Feed and tick until the search is caught up with the terminal.

This is a blocking convenience for one-shot and single-threaded embedders. It always performs at least one feed, so it also picks up any terminal changes since the last feed, then loops until the status is GHOSTTY\\_SEARCH\\_STATUS\\_COMPLETE. Searching a large scrollback can take a while, so interactive embedders should drive [`ghostty_search_tick`](@ref)() and [`ghostty_search_feed`](@ref)() themselves.

This reads the terminal for the entire call, so you must serialize it with all other access to the same terminal.

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or GHOSTTY\\_INVALID\\_VALUE if search is NULL or the terminal was freed
"""
function ghostty_search_run(search)
    @ccall libghostty_vt.ghostty_search_run(search::GhosttySearch)::GhosttyResult
end

"""
    ghostty_search_select_next(search)

Select the next match, moving toward older content.

"Next" goes from the bottom of the screen upward into history, the direction a search from the prompt usually wants. After the oldest match, selection wraps around to the newest one.

You can call this at any time, even if the terminal changed since the last feed, because it first brings the search up to date with the terminal. The viewport then scrolls to the selected match as set by GHOSTTY\\_SEARCH\\_OPT\\_SELECT\\_SCROLL. This reads the terminal, so you must serialize it with all other access to the same terminal.

A find bar typically calls this when the user presses Enter, then reads the selected match to highlight it:

```c++
{.c}
 if (ghostty_search_select_next(search) == GHOSTTY_SUCCESS) {
   GhosttySelection match = {0};
   ghostty_search_get(search, GHOSTTY_SEARCH_DATA_SELECTED_MATCH, &match);
   // Highlight `match` and show its position in the find bar.
 }
```

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS if a match is now selected, GHOSTTY\\_NO\\_VALUE if there are no matches, GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails, or GHOSTTY\\_INVALID\\_VALUE if `search` is NULL or the terminal was freed
"""
function ghostty_search_select_next(search)
    @ccall libghostty_vt.ghostty_search_select_next(search::GhosttySearch)::GhosttyResult
end

"""
    ghostty_search_select_prev(search)

Select the previous match, moving toward newer content.

This is the opposite direction of [`ghostty_search_select_next`](@ref)(). After the newest match, selection wraps around to the oldest one. Everything else, including scrolling and thread safety, works the same as [`ghostty_search_select_next`](@ref)().

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS if a match is now selected, GHOSTTY\\_NO\\_VALUE if there are no matches, GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails, or GHOSTTY\\_INVALID\\_VALUE if `search` is NULL or the terminal was freed
"""
function ghostty_search_select_prev(search)
    @ccall libghostty_vt.ghostty_search_select_prev(search::GhosttySearch)::GhosttyResult
end

"""
    ghostty_search_set(search, option, value)

Write an option to a search.

The value type, and what a NULL value means, depends on the option and is documented by [`GhosttySearchOption`](@ref). GHOSTTY\\_SEARCH\\_OPT\\_NEEDLE touches the terminal, so you must serialize it with all other access to the same terminal. GHOSTTY\\_SEARCH\\_OPT\\_SELECT\\_SCROLL only modifies search-owned state.

To move between matches, use [`ghostty_search_select_next`](@ref)() and [`ghostty_search_select_prev`](@ref)().

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: Option to write
* `value`: Pointer to the input value for the option. The meaning of NULL is documented per option.
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_OUT\\_OF\\_MEMORY if allocation fails, GHOSTTY\\_INVALID\\_VALUE if `search` or `value` is invalid or the option needs a terminal that was already freed, or GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library
"""
function ghostty_search_set(search, option, value)
    @ccall libghostty_vt.ghostty_search_set(search::GhosttySearch, option::GhosttySearchOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_search_get(search, data, value)

Read a data field from a search.

The output value type depends on data and is documented by [`GhosttySearchData`](@ref). This never reads the terminal, so it is safe to call while another thread modifies the terminal. Returned selections are untracked snapshots with standard [`GhosttySelection`](@ref) lifetime rules.

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: Data field to read
* `value`: Output pointer whose type depends on data
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the requested data has no value, GHOSTTY\\_OUT\\_OF\\_SPACE if a provided [`GhosttySelectionBuffer`](@ref) is too small (required capacity in its len), GHOSTTY\\_OUT\\_OF\\_MEMORY if collecting viewport matches fails, GHOSTTY\\_INVALID\\_VALUE if `search` or `value` is invalid, or GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library
"""
function ghostty_search_get(search, data, value)
    @ccall libghostty_vt.ghostty_search_get(search::GhosttySearch, data::GhosttySearchData, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_search_get_multi(search, count, keys, values, out_written)

Read multiple data fields from a search in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_search_get`](@ref)() once per key, so use whichever reads better.

Each entry in values must point to storage of the type documented by the corresponding [`GhosttySearchData`](@ref) key.

If any individual read fails, the function returns that error and writes the index of the failing key to out\\_written when out\\_written is non-NULL. Earlier keys have already been written. On success, out\\_written receives count when non-NULL. A too-small [`GhosttySelectionBuffer`](@ref) stops the batch with GHOSTTY\\_OUT\\_OF\\_SPACE at that key's index with the required capacity in its len, so order buffer-valued keys after scalar keys.

` search`

# Arguments
* `search`: Search handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `count`: Number of data fields to read
* `keys`: Data fields to read (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `values`: Output pointers corresponding to keys (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_written`: Optional number of fields read, or failing index on error
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_search_get_multi(search, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_search_get_multi(search::GhosttySearch, count::Csize_t, keys::Ptr{GhosttySearchData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    GhosttySnapshotDecoderOption

Configurable snapshot decoder options.

Options may only be changed before decoding starts. Calling [`ghostty_snapshot_decoder_set`](@ref)() after [`ghostty_snapshot_decoder_ready`](@ref)() or [`ghostty_snapshot_decoder_decode`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE.

| Enumerator                                                           | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| :------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_INVALID                         | Not a real option. [`ghostty_snapshot_decoder_set`](@ref)() returns GHOSTTY\\_INVALID\\_VALUE for it. Its value is 0, so a zeroed or uninitialized variable is never mistaken for a real option.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_MAX\\_CONTINUATION\\_BYTES      | Largest non-ground continuation the decoder will accept.  A value of zero accepts only snapshots whose VT parser is in the ground state. The decoder default matches the largest built-in APC protocol buffer limit, currently 65 MiB. A NULL value restores the default.  This is primarily an input validation limit. When GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_RETAIN\\_CONTINUATION is true, the same value also becomes the continuation tracking limit on the returned terminal.  Input type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_RETAIN\\_CONTINUATION           | Retain the decoded continuation on the returned terminal.  When true, terminals returned by [`ghostty_snapshot_decoder_ready`](@ref)() and [`ghostty_snapshot_decoder_decode`](@ref)() use GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_MAX\\_CONTINUATION\\_BYTES as their continuation tracking limit. The existing ghostty\\_terminal\\_continuation\\_* APIs can then export the exact unfinished VT or UTF-8 input restored from the snapshot.  This is false by default, and a NULL value restores false. A maximum continuation size of zero leaves tracking disabled. With a nonzero maximum, tracking remains enabled even when the decoded continuation is empty. Exporting an empty continuation does not disable it. Callers that do not need ongoing tracking must still set GHOSTTY\\_TERMINAL\\_OPT\\_CONTINUATION\\_MAX\\_BYTES to zero after export and before writing post-snapshot input.  Input type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_COMPRESS\\_HISTORY              | Compress scrollback history while it is restored.  By default, restoring a snapshot leaves all of its scrollback history uncompressed, even if the terminal that produced the snapshot had compressed it. The history stays that size until the application calls [`ghostty_terminal_compress`](@ref)(). For a terminal with a lot of scrollback, that can be many times more memory than the terminal needed before.  When this option is true, the decoder compresses each history page right after restoring it. The restored terminal starts out compressed, and the decode never holds more than one uncompressed history page at a time. The result is the same as decoding normally and then calling [`ghostty_terminal_compress`](@ref)() with GHOSTTY\\_TERMINAL\\_COMPRESSION\\_MODE\\_FULL, without the memory spike in between.  A history page that is on screen when it is restored stays uncompressed. This only happens if the viewport is scrolled to the top of the scrollback during an incremental decode. Compressed history is uncompressed automatically when it is accessed later, for example by scrolling or searching.  This only changes how the restored terminal stores its history in memory. The snapshot format is unchanged, so it works with any snapshot. On platforms that do not support scrollback compression, this option is accepted and has no effect.  This is false by default, and a NULL value restores false.  Input type: bool *  |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_KITTY\\_IMAGE\\_STORAGE\\_LIMIT | Kitty graphics image storage limit, in bytes, for each restored screen.  The limit of the terminal that wrote the snapshot is not part of the snapshot, so the decoder always applies this one. Images are restored oldest first, and an image that does not fit evicts older images, exactly as a live transmission would. The newest images are kept, and the placements of evicted images are dropped with them. Zero disables Kitty graphics on the restored terminal.  The default is the storage limit of a new terminal, and a NULL value restores it. Change the limit of a restored terminal later with GHOSTTY\\_TERMINAL\\_OPT\\_KITTY\\_IMAGE\\_STORAGE\\_LIMIT.  Input type: uint64\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_MAX\\_VALUE                     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
"""
@cenum GhosttySnapshotDecoderOption::UInt32 begin
    GHOSTTY_SNAPSHOT_DECODER_OPT_INVALID = 0
    GHOSTTY_SNAPSHOT_DECODER_OPT_MAX_CONTINUATION_BYTES = 1
    GHOSTTY_SNAPSHOT_DECODER_OPT_RETAIN_CONTINUATION = 2
    GHOSTTY_SNAPSHOT_DECODER_OPT_COMPRESS_HISTORY = 3
    GHOSTTY_SNAPSHOT_DECODER_OPT_KITTY_IMAGE_STORAGE_LIMIT = 4
    GHOSTTY_SNAPSHOT_DECODER_OPT_MAX_VALUE = 2147483647
end

"""
    GhosttySnapshotDecoderProgressKind

What the most recent successful [`ghostty_snapshot_decoder_next`](@ref)() call decoded.

Query it with GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_KIND, then read the progress values that apply to that kind.

| Enumerator                                                   | Note                                                                                                                                                                                                           |
| :----------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_PAGE        | One history page, together with the Kitty graphics placements pinned to it. GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_ROWS and GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_REMAINING describe it.  |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_IMAGE       | The pixels of one Kitty graphics image or animation frame. The GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_IMAGE\\_* values describe it.                                                                  |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_MAX\\_VALUE |                                                                                                                                                                                                                |
"""
@cenum GhosttySnapshotDecoderProgressKind::UInt32 begin
    GHOSTTY_SNAPSHOT_DECODER_PROGRESS_KIND_PAGE = 0
    GHOSTTY_SNAPSHOT_DECODER_PROGRESS_KIND_IMAGE = 1
    GHOSTTY_SNAPSHOT_DECODER_PROGRESS_KIND_MAX_VALUE = 2147483647
end

"""
    GhosttySnapshotDecoderData

Queryable snapshot decoder data.

Each variant documents the output pointer type expected by [`ghostty_snapshot_decoder_get`](@ref)().

| Enumerator                                                                | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| :------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_INVALID                             | Invalid data type. Never results in data extraction.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_MAX\\_CONTINUATION\\_BYTES          | Current maximum accepted continuation size.  This value is available in every non-failed decoder state.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_SOURCE\\_OFFSET                     | Number of snapshot source bytes consumed so far.  At FINISH this identifies the first byte after the snapshot. Trailing bytes are not consumed. This value is unavailable after a decoding error, because the decoder can no longer guarantee its source position.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                                     |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_HISTORY\\_ROWS\\_PRIMARY            | Advisory complete logical history extent for the primary screen.  The value counts rows before the active area, including any resident overlap carried before READY. It becomes available after READY validates.  Output type: uint64\\_t *                                                                                                                                                                                                                                                                                                                                                                                     |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_HISTORY\\_ROWS\\_ALTERNATE          | Advisory complete logical history extent for the alternate screen.  The value has the same semantics and lifetime as GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_HISTORY\\_ROWS\\_PRIMARY. Querying it returns GHOSTTY\\_NO\\_VALUE when the snapshot does not declare an alternate screen.  Output type: uint64\\_t *                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_SCREEN                   | Screen associated with the most recently decoded history page or image pixels.  This value is available only after [`ghostty_snapshot_decoder_next`](@ref)() returns GHOSTTY\\_SUCCESS. A later call to next replaces it or clears it when FINISH is reached or an error occurs.  Output type: [`GhosttyTerminalScreen`](@ref) *                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_ROWS                     | Rows prepended by the most recently decoded history page.  Zero means the page was consumed and validated but could not be applied to the live terminal. Returns GHOSTTY\\_NO\\_VALUE unless the progress kind is GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_PAGE.  Output type: size\\_t *                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_REMAINING                | Page records remaining in the same screen's HISTORY sequence.  This is not a count of all pages remaining in the snapshot. Returns GHOSTTY\\_NO\\_VALUE unless the progress kind is GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_PAGE.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                           |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_RETAIN\\_CONTINUATION               | Whether decoded continuation tracking is retained on returned terminals.  This value is available in every non-failed decoder state.  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_COMPRESS\\_HISTORY                  | Whether history is compressed while it is restored.  See GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_COMPRESS\\_HISTORY. This value is available in every non-failed decoder state.  Output type: bool *                                                                                                                                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_KITTY\\_IMAGE\\_STORAGE\\_LIMIT     | Kitty graphics image storage limit applied to each restored screen.  See GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_KITTY\\_IMAGE\\_STORAGE\\_LIMIT. This value is available in every non-failed decoder state.  Output type: uint64\\_t *                                                                                                                                                                                                                                                                                                                                                                                            |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_KIND                     | What the most recent successful [`ghostty_snapshot_decoder_next`](@ref)() call decoded: a history page or the pixels of a Kitty graphics image.  This value has the same lifetime as GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_SCREEN.  Output type: [`GhosttySnapshotDecoderProgressKind`](@ref) *                                                                                                                                                                                                                                                                                                                      |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_IMAGE\\_ID               | ID of the Kitty graphics image whose pixels the most recent [`ghostty_snapshot_decoder_next`](@ref)() call decoded.  Returns GHOSTTY\\_NO\\_VALUE unless the progress kind is GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_IMAGE.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_IMAGE\\_FRAME            | Which frame of the image those pixels are for, numbered as the Kitty graphics protocol numbers frames. 1 is the image itself, and 2 and up are its animation frames.  Returns GHOSTTY\\_NO\\_VALUE unless the progress kind is GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_IMAGE.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                               |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_IMAGE\\_BYTES            | Number of pixel bytes the most recent [`ghostty_snapshot_decoder_next`](@ref)() call attached to its image.  Zero means the pixels were consumed and validated but dropped. That happens when live input deleted the image or sent a new image with the same ID, when the image did not fit the storage limit, or when its screen was removed or replaced. Returns GHOSTTY\\_NO\\_VALUE unless the progress kind is GHOSTTY\\_SNAPSHOT\\_DECODER\\_PROGRESS\\_KIND\\_IMAGE.  Output type: size\\_t *                                                                                                                            |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_KITTY\\_IMAGES\\_PRIMARY            | Number of Kitty graphics images restored for the primary screen at READY.  These images can be placed and queried right away, but their pixels arrive later through [`ghostty_snapshot_decoder_next`](@ref)(). Until then, GHOSTTY\\_KITTY\\_GRAPHICS\\_IMAGE\\_DATA\\_PIXELS returns GHOSTTY\\_NO\\_VALUE for them. This value becomes available after READY validates, and is zero in a library built without Kitty graphics.  Output type: uint32\\_t *                                                                                                                                                                      |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_KITTY\\_IMAGES\\_ALTERNATE          | Number of Kitty graphics images restored for the alternate screen at READY.  Returns GHOSTTY\\_NO\\_VALUE when the snapshot does not declare an alternate screen. See GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_KITTY\\_IMAGES\\_PRIMARY.  Output type: uint32\\_t *                                                                                                                                                                                                                                                                                                                                                                |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_KITTY\\_PENDING\\_BYTES\\_PRIMARY   | Bytes of Kitty graphics pixels for the primary screen that were still to come at READY.  Use it to size a progress indicator while the pixels arrive, adding up GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_IMAGE\\_BYTES for the primary screen after each call to [`ghostty_snapshot_decoder_next`](@ref)(), which has an example. Pixels that are dropped report zero bytes, so the sum can end up below this total. Pixels may arrive between history pages, so they are only known to be done once next returns GHOSTTY\\_NO\\_VALUE. This value becomes available after READY validates.  Output type: uint64\\_t *  |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_KITTY\\_PENDING\\_BYTES\\_ALTERNATE | Bytes of Kitty graphics pixels for the alternate screen that were still to come at READY.  Returns GHOSTTY\\_NO\\_VALUE when the snapshot does not declare an alternate screen. See GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_KITTY\\_PENDING\\_BYTES\\_PRIMARY.  Output type: uint64\\_t *                                                                                                                                                                                                                                                                                                                                         |
| GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_MAX\\_VALUE                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
"""
@cenum GhosttySnapshotDecoderData::UInt32 begin
    GHOSTTY_SNAPSHOT_DECODER_DATA_INVALID = 0
    GHOSTTY_SNAPSHOT_DECODER_DATA_MAX_CONTINUATION_BYTES = 1
    GHOSTTY_SNAPSHOT_DECODER_DATA_SOURCE_OFFSET = 2
    GHOSTTY_SNAPSHOT_DECODER_DATA_HISTORY_ROWS_PRIMARY = 3
    GHOSTTY_SNAPSHOT_DECODER_DATA_HISTORY_ROWS_ALTERNATE = 4
    GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_SCREEN = 5
    GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_ROWS = 6
    GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_REMAINING = 7
    GHOSTTY_SNAPSHOT_DECODER_DATA_RETAIN_CONTINUATION = 8
    GHOSTTY_SNAPSHOT_DECODER_DATA_COMPRESS_HISTORY = 9
    GHOSTTY_SNAPSHOT_DECODER_DATA_KITTY_IMAGE_STORAGE_LIMIT = 10
    GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_KIND = 11
    GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_IMAGE_ID = 12
    GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_IMAGE_FRAME = 13
    GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_IMAGE_BYTES = 14
    GHOSTTY_SNAPSHOT_DECODER_DATA_KITTY_IMAGES_PRIMARY = 15
    GHOSTTY_SNAPSHOT_DECODER_DATA_KITTY_IMAGES_ALTERNATE = 16
    GHOSTTY_SNAPSHOT_DECODER_DATA_KITTY_PENDING_BYTES_PRIMARY = 17
    GHOSTTY_SNAPSHOT_DECODER_DATA_KITTY_PENDING_BYTES_ALTERNATE = 18
    GHOSTTY_SNAPSHOT_DECODER_DATA_MAX_VALUE = 2147483647
end

"""
    ghostty_snapshot_encode(terminal, writer)

Encode a complete terminal snapshot to a writer.

The terminal's persistent VT stream supplies the continuation bytes needed to reconstruct unfinished parser state. You must prevent concurrent writes or other terminal mutation for the duration of this call. The writer callback must not call terminal APIs with the same terminal handle. A terminal can be encoded with tracking disabled when its VT parser and UTF-8 decoder are both at ground. If either is unfinished, tracking must have been enabled before the input that produced that state was written; otherwise this returns GHOSTTY\\_INVALID\\_VALUE.

Encoding begins at the writer's current position. If an error occurs, the writer may contain a partial snapshot without a valid FINISH marker. Calls to the writer are synchronous; this function does not flush or make your destination durable.

` snapshot`

# Arguments
* `terminal`: Terminal to encode (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `writer`: Destination writer whose write callback must not be NULL
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_IO\\_ERROR if the writer rejects output, GHOSTTY\\_LIMIT\\_EXCEEDED if output accounting overflows, or another error code on failure
"""
function ghostty_snapshot_encode(terminal, writer)
    @ccall libghostty_vt.ghostty_snapshot_encode(terminal::GhosttyTerminal, writer::GhosttyWriter)::GhosttyResult
end

"""
    ghostty_snapshot_encode_buf(terminal, buf, buf_len, out_written)

Encode a complete terminal snapshot to a caller-provided buffer.

Pass NULL for buf with buf\\_len zero to query the required size. If the buffer is too small, this returns GHOSTTY\\_OUT\\_OF\\_SPACE and stores the required capacity in out\\_written. A non-NULL undersized buffer may contain a partial snapshot prefix. On success, out\\_written receives the number of bytes encoded.

A terminal can be encoded with tracking disabled when its VT parser and UTF-8 decoder are both at ground. If either is unfinished, tracking must have been enabled before the input that produced that state was written; otherwise this returns GHOSTTY\\_INVALID\\_VALUE.

` snapshot`

# Arguments
* `terminal`: Terminal to encode (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `buf`: Destination buffer, or NULL when buf\\_len is zero
* `buf_len`: Destination buffer capacity in bytes
* `out_written`:\\[out\\] Bytes written, or required capacity on GHOSTTY\\_OUT\\_OF\\_SPACE (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_snapshot_encode_buf(terminal, buf, buf_len, out_written)
    @ccall libghostty_vt.ghostty_snapshot_encode_buf(terminal::GhosttyTerminal, buf::Ptr{UInt8}, buf_len::Csize_t, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_snapshot_encode_alloc(terminal, allocator, out_ptr, out_len)

Encode a complete terminal snapshot to an allocated buffer.

The returned buffer is allocated with allocator, or the default allocator when allocator is NULL. You must release it with [`ghostty_free`](@ref)(), passing the same allocator used here.

A terminal can be encoded with tracking disabled when its VT parser and UTF-8 decoder are both at ground. If either is unfinished, tracking must have been enabled before the input that produced that state was written; otherwise this returns GHOSTTY\\_INVALID\\_VALUE.

` snapshot`

# Arguments
* `terminal`: Terminal to encode (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `allocator`: Allocator for the output, or NULL for the default allocator
* `out_ptr`:\\[out\\] Allocated snapshot bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `out_len`:\\[out\\] Number of allocated snapshot bytes (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_snapshot_encode_alloc(terminal, allocator, out_ptr, out_len)
    @ccall libghostty_vt.ghostty_snapshot_encode_alloc(terminal::GhosttyTerminal, allocator::Ptr{GhosttyAllocator}, out_ptr::Ptr{Ptr{UInt8}}, out_len::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_snapshot_decoder_new(allocator, decoder, reader)

Create a snapshot decoder that reads from a caller-provided reader.

The decoder stores a copy of reader. Its read callback must not be NULL, and both the callback and its caller-owned context must remain valid until FINISH is reached or the decoder is freed. Reads are synchronous and occur only during ready, next, or decode calls. A zero-byte successful read is permanent end-of-file, not temporary starvation; nonblocking sources must wait outside the decoder or block in their callback. The read callback must not call APIs, including [`ghostty_snapshot_decoder_free`](@ref)(), on the decoder that owns it. Returning false reports GHOSTTY\\_IO\\_ERROR; returning true with zero bytes before a required marker reports truncated snapshot data as GHOSTTY\\_INVALID\\_VALUE.

` snapshot`

# Arguments
* `allocator`: Allocator for decoder and decoded terminal state, or NULL for the default allocator
* `decoder`: Pointer to receive the decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `reader`: Snapshot source reader
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_snapshot_decoder_new(allocator, decoder, reader)
    @ccall libghostty_vt.ghostty_snapshot_decoder_new(allocator::Ptr{GhosttyAllocator}, decoder::Ptr{GhosttySnapshotDecoder}, reader::GhosttyReader)::GhosttyResult
end

"""
    ghostty_snapshot_decoder_new_buf(allocator, decoder, ptr, len)

Create a snapshot decoder over a borrowed byte buffer.

The bytes are not copied. ptr must remain valid and immutable until FINISH is reached or the decoder is freed. Bytes after FINISH are not consumed; query GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_SOURCE\\_OFFSET to locate them.

` snapshot`

# Arguments
* `allocator`: Allocator for decoder and decoded terminal state, or NULL for the default allocator
* `decoder`: Pointer to receive the decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `ptr`: Snapshot source bytes
* `len`: Number of source bytes
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_snapshot_decoder_new_buf(allocator, decoder, ptr, len)
    @ccall libghostty_vt.ghostty_snapshot_decoder_new_buf(allocator::Ptr{GhosttyAllocator}, decoder::Ptr{GhosttySnapshotDecoder}, ptr::Ptr{UInt8}, len::Csize_t)::GhosttyResult
end

"""
    ghostty_snapshot_decoder_free(decoder)

Free a snapshot decoder.

This does not release your ownership of a terminal returned by ready or decode. Abandoning an incremental decode leaves that terminal usable with whatever history had already been restored.

` snapshot`

# Arguments
* `decoder`: Decoder to free (may be NULL)
"""
function ghostty_snapshot_decoder_free(decoder)
    @ccall libghostty_vt.ghostty_snapshot_decoder_free(decoder::GhosttySnapshotDecoder)::Cvoid
end

"""
    ghostty_snapshot_decoder_set(decoder, option, value)

Set a snapshot decoder option.

The value pointer must have the type documented by option. Passing NULL for `value` restores the option's default, which each [`GhosttySnapshotDecoderOption`](@ref) value documents. Options can only be changed before decoding starts.

```c++
{.c}
 bool retain = true;
 ghostty_snapshot_decoder_set(
     decoder, GHOSTTY_SNAPSHOT_DECODER_OPT_RETAIN_CONTINUATION, &retain);

 // Changed our mind: go back to the default (false).
 ghostty_snapshot_decoder_set(
     decoder, GHOSTTY_SNAPSHOT_DECODER_OPT_RETAIN_CONTINUATION, NULL);
```

` snapshot`

# Arguments
* `decoder`: Decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `option`: Option to change
* `value`: Pointer to the option value, or NULL to restore the default
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_INVALID\\_VALUE if decoding has started or an argument is invalid, GHOSTTY\\_UNSUPPORTED if `option` is not known to this version of the library, or another error code on failure. An unknown `option` always returns GHOSTTY\\_UNSUPPORTED, even after decoding has started, so it is safe to use for checking whether the library knows an option.
"""
function ghostty_snapshot_decoder_set(decoder, option, value)
    @ccall libghostty_vt.ghostty_snapshot_decoder_set(decoder::GhosttySnapshotDecoder, option::GhosttySnapshotDecoderOption, value::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_snapshot_decoder_ready(decoder, terminal)

Decode and validate the renderable snapshot prefix through READY.

On success, terminal receives a caller-owned terminal with its persistent VT stream already restored from the snapshot continuation. The terminal is immediately usable for rendering and live input. Older scrollback remains to be restored with [`ghostty_snapshot_decoder_next`](@ref)().

The restored parser state may be unfinished. By default, terminal continuation tracking is disabled and GHOSTTY\\_TERMINAL\\_DATA\\_CONTINUATION\\_MAX\\_BYTES returns zero. When GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_RETAIN\\_CONTINUATION is true, the decoder's maximum continuation size is applied to the terminal, and the terminal continuation APIs export the exact current continuation when that limit is nonzero. Tracking remains enabled even if the exported continuation is empty. Callers that do not need ongoing tracking must set GHOSTTY\\_TERMINAL\\_OPT\\_CONTINUATION\\_MAX\\_BYTES to zero after export and before writing any post-snapshot bytes, because later input may change it.

You must keep the returned terminal alive until FINISH validates or the decoder is freed. The decoder borrows this terminal handle while it restores history; [`ghostty_snapshot_decoder_next`](@ref)() uses it automatically.

This operation may only be called once and only before decoding starts. terminal is set to NULL on every error. A decoding, I/O, or allocation error after input consumption begins poisons the decoder, after which it must be freed. An invalid argument or lifecycle error detected before the operation consumes input does not poison it.

` snapshot`

# Arguments
* `decoder`: Decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`:\\[out\\] Pointer to receive the terminal (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_snapshot_decoder_ready(decoder, terminal)
    @ccall libghostty_vt.ghostty_snapshot_decoder_ready(decoder::GhosttySnapshotDecoder, terminal::Ptr{GhosttyTerminal})::GhosttyResult
end

"""
    ghostty_snapshot_decoder_next(decoder)

Decode one history page, or the pixels of one Kitty graphics image, into the terminal returned by READY.

Each GHOSTTY\\_SUCCESS consumes and validates one record: a history page together with the Kitty graphics placements pinned to it, or the pixels of one image or animation frame. Pixels may arrive at any point, even between history pages. Query GHOSTTY\\_SNAPSHOT\\_DECODER\\_DATA\\_PROGRESS\\_KIND and the progress values for that kind before calling next again. GHOSTTY\\_NO\\_VALUE means FINISH was validated; repeated calls after FINISH also return GHOSTTY\\_NO\\_VALUE.

```c++
{.c}
 // How many image bytes the primary screen is waiting for, to show
 // progress while they arrive.
 uint64_t pending = 0;
 ghostty_snapshot_decoder_get(
     decoder, GHOSTTY_SNAPSHOT_DECODER_DATA_KITTY_PENDING_BYTES_PRIMARY,
     &pending);
 uint64_t received = 0;

 GhosttyResult result;
 while ((result = ghostty_snapshot_decoder_next(decoder)) == GHOSTTY_SUCCESS) {
   GhosttySnapshotDecoderProgressKind kind;
   ghostty_snapshot_decoder_get(
       decoder, GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_KIND, &kind);

   if (kind == GHOSTTY_SNAPSHOT_DECODER_PROGRESS_KIND_PAGE) {
     // Scrollback grew by this many rows.
     size_t rows = 0;
     ghostty_snapshot_decoder_get(
         decoder, GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_ROWS, &rows);
     continue;
   }

   // An image's pixels arrived.
   GhosttyTerminalScreen screen;
   size_t bytes = 0;
   ghostty_snapshot_decoder_get(
       decoder, GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_SCREEN, &screen);
   ghostty_snapshot_decoder_get(
       decoder, GHOSTTY_SNAPSHOT_DECODER_DATA_PROGRESS_IMAGE_BYTES, &bytes);
   if (screen == GHOSTTY_TERMINAL_SCREEN_PRIMARY) received += bytes;
 }

 // GHOSTTY_NO_VALUE means the snapshot is complete. Dropped pixels report
 // zero bytes, so received can end up below pending.
```

The terminal may be rendered, resized, and fed live PTY input between calls. If a history page can no longer be applied safely, it is still consumed and validated and progress reports zero rows. Image pixels work the same way: if live input deleted the image, or sent a new image with the same ID, the pixels are consumed and validated and progress reports zero bytes. The decoder applies history and pixels to your terminal produced by its READY operation.

If GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_COMPRESS\\_HISTORY is true, the page is compressed before this function returns, unless it is visible in the terminal's viewport.

A decoding error invalidates the decoder's source position. The terminal remains caller-owned and usable with its already-restored history, but only [`ghostty_snapshot_decoder_free`](@ref)() may subsequently be called on the decoder.

` snapshot`

# Arguments
* `decoder`: Decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS for one page or image, GHOSTTY\\_NO\\_VALUE after FINISH, or an error code on failure
"""
function ghostty_snapshot_decoder_next(decoder)
    @ccall libghostty_vt.ghostty_snapshot_decoder_next(decoder::GhosttySnapshotDecoder)::GhosttyResult
end

"""
    ghostty_snapshot_decoder_decode(decoder, terminal)

Decode and validate one complete snapshot.

This is the one-shot form of READY followed by all history pages through FINISH. It may only be called before decoding starts. Bytes following FINISH are left unread. On success terminal receives a caller-owned terminal with its persistent VT stream restored. Continuation tracking on the returned terminal is disabled by default. When GHOSTTY\\_SNAPSHOT\\_DECODER\\_OPT\\_RETAIN\\_CONTINUATION is true, the decoder's maximum continuation size is applied to the terminal, and the terminal continuation APIs export the exact current continuation when that limit is nonzero. Tracking remains enabled even if the exported continuation is empty. Callers that do not need ongoing tracking must set GHOSTTY\\_TERMINAL\\_OPT\\_CONTINUATION\\_MAX\\_BYTES to zero after export and before writing any post-snapshot bytes, because later input may change it. terminal is set to NULL on every error. A decoding, I/O, or allocation error after input consumption begins poisons the decoder, after which it must be freed. An invalid argument or lifecycle error detected before the operation consumes input does not poison it.

` snapshot`

# Arguments
* `decoder`: Decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `terminal`:\\[out\\] Pointer to receive the terminal (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, or an error code on failure
"""
function ghostty_snapshot_decoder_decode(decoder, terminal)
    @ccall libghostty_vt.ghostty_snapshot_decoder_decode(decoder::GhosttySnapshotDecoder, terminal::Ptr{GhosttyTerminal})::GhosttyResult
end

"""
    ghostty_snapshot_decoder_get(decoder, data, out)

Get typed data from a snapshot decoder.

The output pointer must have the type documented by data. A phase-dependent value that is not currently available returns GHOSTTY\\_NO\\_VALUE.

` snapshot`

# Arguments
* `decoder`: Decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `data`: Data kind to query
* `out`:\\[out\\] Pointer to receive the value (NULL returns GHOSTTY\\_INVALID\\_VALUE)
# Returns
GHOSTTY\\_SUCCESS on success, GHOSTTY\\_NO\\_VALUE if the requested data is unavailable, GHOSTTY\\_UNSUPPORTED if `data` is not known to this version of the library, or another error code on failure
"""
function ghostty_snapshot_decoder_get(decoder, data, out)
    @ccall libghostty_vt.ghostty_snapshot_decoder_get(decoder::GhosttySnapshotDecoder, data::GhosttySnapshotDecoderData, out::Ptr{Cvoid})::GhosttyResult
end

"""
    ghostty_snapshot_decoder_get_multi(decoder, count, keys, values, out_written)

Get multiple snapshot decoder data fields in a single call.

Use this when each call into the library is expensive, for example from WebAssembly or from another language through its foreign function interface. It reads every key in one call. From C in the same process it costs the same as calling [`ghostty_snapshot_decoder_get`](@ref)() once per key, so use whichever reads better.

Each keys element selects a data kind and the corresponding values element points to storage of the documented output type. Processing stops at the first error. On success out\\_written is set to count; on error it is set to the number of values written before the failing key. Invalid array arguments report zero values written.

` snapshot`

# Arguments
* `decoder`: Decoder handle (NULL returns GHOSTTY\\_INVALID\\_VALUE)
* `count`: Number of key/value pairs
* `keys`: Array of data kinds to query
* `values`: Array of output pointers corresponding to keys
* `out_written`:\\[out\\] Number of successfully written values (may be NULL)
# Returns
GHOSTTY\\_SUCCESS if every key succeeds. Otherwise the result of the first key that failed, for example GHOSTTY\\_UNSUPPORTED for a key that is not known to this version of the library.
"""
function ghostty_snapshot_decoder_get_multi(decoder, count, keys, values, out_written)
    @ccall libghostty_vt.ghostty_snapshot_decoder_get_multi(decoder::GhosttySnapshotDecoder, count::Csize_t, keys::Ptr{GhosttySnapshotDecoderData}, values::Ptr{Ptr{Cvoid}}, out_written::Ptr{Csize_t})::GhosttyResult
end

"""
    ghostty_unicode_codepoint_width(cp)

Returns the terminal display width of a Unicode codepoint in terminal grid cells: 0, 1, or 2.

This is the same width table the terminal itself uses when laying out printed text, so callers can predict column layout (e.g. IME preedit overlays) that exactly matches what the terminal will do when the text is actually written to it.

Semantics: - Returns 0 for zero-width codepoints: C0/C1 control characters, nonspacing and enclosing combining marks, default-ignorable codepoints (ZWJ, ZWNJ, variation selectors, etc.), and surrogate codepoints. - Returns 2 for wide codepoints: East Asian Wide/Fullwidth (including emoji with default emoji presentation) and regional indicators. Width is clamped to 2 (e.g. the three-em dash). - Returns 1 for everything else, including invalid codepoints beyond U+10FFFF (this function is total; it never fails).

This operates on a single codepoint only and therefore cannot account for grapheme-cluster-level width rules (VS16 emoji presentation, combining sequences, etc.). For cluster-accurate widths, use [`ghostty_unicode_grapheme_width`](@ref)(). Summing per-codepoint widths is only correct when mode 2027 (grapheme clustering) is disabled.

This function is pure, allocates nothing, and is thread-safe.

# Arguments
* `cp`: The Unicode codepoint to measure
# Returns
Display width in cells: 0, 1, or 2
"""
function ghostty_unicode_codepoint_width(cp)
    @ccall libghostty_vt.ghostty_unicode_codepoint_width(cp::UInt32)::UInt8
end

"""
    ghostty_unicode_grapheme_width(cps, len, width)

Measures the terminal display width of the first grapheme cluster in a sequence of Unicode codepoints.

This uses the exact same grapheme segmentation and cluster width rules the terminal itself uses when printing text with grapheme clustering enabled (mode 2027), so callers can predict column layout (e.g. IME preedit overlays) that exactly matches what the terminal will do when the text is actually written to it. Unlike [`ghostty_unicode_codepoint_width`](@ref)(), this accounts for cluster-level rules: emoji variation selectors, ZWJ sequences, combining marks, and skin tone modifiers.

Reads codepoints from cps until the terminal would consider the grapheme cluster complete, stores the cluster's total width in cells (0, 1, or 2) into width (which may be NULL if only segmentation is desired), and returns the number of codepoints consumed. Returns 0 if and only if len is 0; otherwise consumes at least one codepoint. Measure a whole string by calling in a loop:

```c++
 size_t total = 0;
 for (size_t i = 0; i < len;) {
   uint8_t width;
   i += ghostty_unicode_grapheme_width(cps + i, len - i, &width);
   total += width;
 }
```

This is not a streaming API. The provided sequence must contain a complete first grapheme cluster, or the logical end of the string. If input arrives in chunks, keep buffering while this function consumes all available codepoints (return value == len) and the stream may still continue; a later codepoint could still extend the cluster and change its width.

Width semantics, matching the terminal with mode 2027 enabled: - The cluster starts at the width of its first codepoint, as returned by [`ghostty_unicode_codepoint_width`](@ref)(). - VS16 (U+FE0F) forces the cluster wide (2) and VS15 (U+FE0E) forces it narrow (1), but only when the immediately preceding codepoint in the cluster is a valid emoji variation sequence base (per Unicode emoji-variation-sequences.txt). Invalid variation selectors are ignored entirely. - Any other continuation codepoint that contributes to grapheme width forces the cluster wide (2). Note this means cluster width is NOT the maximum of per-codepoint widths: some continuation marks have narrow codepoint width yet still widen the cluster.

Mode dependence: this models mode 2027 (grapheme clustering) enabled, which is Ghostty's recommended configuration. When mode 2027 is disabled, clusters never combine and variation selectors never change width; predict layout in that case by summing [`ghostty_unicode_codepoint_width`](@ref)() over each codepoint instead.

Edge cases: - Codepoints beyond U+10FFFF consume one codepoint, have width 1, and are always cluster boundaries. This function is total; it never fails. - Control characters (C0/C1, CR, LF) are never printed through the terminal's text path; passing them here returns an unspecified (but stable and bounded) result. - A cluster whose first codepoint is zero-width (e.g. a lone combining mark) is malformed at a cell start; the terminal may attach it to earlier screen content. This function reports the fold result for the sequence in isolation (typically 0).

This function is pure, allocates nothing, and is thread-safe.

# Arguments
* `cps`: Pointer to codepoints (may be NULL only when len is 0)
* `len`: Number of codepoints available
* `width`: Out: cluster display width in cells (0-2); may be NULL
# Returns
Number of codepoints in the first grapheme cluster
"""
function ghostty_unicode_grapheme_width(cps, len, width)
    @ccall libghostty_vt.ghostty_unicode_grapheme_width(cps::Ptr{UInt32}, len::Csize_t, width::Ptr{UInt8})::Csize_t
end

const GHOSTTY_VT_VERSION_MAJOR = 1

const GHOSTTY_VT_VERSION_MINOR = 0

const GHOSTTY_VT_VERSION_PATCH = 0

const GHOSTTY_VT_VERSION = "1.0.0"

const GHOSTTY_ENUM_MAX_VALUE = INT_MAX

const GHOSTTY_IMAGE_LAYER_MASK_BELOW_BACKGROUND = Cuint(1) << GHOSTTY_IMAGE_LAYER_BELOW_BACKGROUND

const GHOSTTY_IMAGE_LAYER_MASK_BELOW_TEXT = Cuint(1) << GHOSTTY_IMAGE_LAYER_BELOW_TEXT

const GHOSTTY_IMAGE_LAYER_MASK_ABOVE_TEXT = Cuint(1) << GHOSTTY_IMAGE_LAYER_ABOVE_TEXT

const GHOSTTY_COLOR_NAMED_BLACK = 0

const GHOSTTY_COLOR_NAMED_RED = 1

const GHOSTTY_COLOR_NAMED_GREEN = 2

const GHOSTTY_COLOR_NAMED_YELLOW = 3

const GHOSTTY_COLOR_NAMED_BLUE = 4

const GHOSTTY_COLOR_NAMED_MAGENTA = 5

const GHOSTTY_COLOR_NAMED_CYAN = 6

const GHOSTTY_COLOR_NAMED_WHITE = 7

const GHOSTTY_COLOR_NAMED_BRIGHT_BLACK = 8

const GHOSTTY_COLOR_NAMED_BRIGHT_RED = 9

const GHOSTTY_COLOR_NAMED_BRIGHT_GREEN = 10

const GHOSTTY_COLOR_NAMED_BRIGHT_YELLOW = 11

const GHOSTTY_COLOR_NAMED_BRIGHT_BLUE = 12

const GHOSTTY_COLOR_NAMED_BRIGHT_MAGENTA = 13

const GHOSTTY_COLOR_NAMED_BRIGHT_CYAN = 14

const GHOSTTY_COLOR_NAMED_BRIGHT_WHITE = 15

const GHOSTTY_DA_CONFORMANCE_VT100 = 1

const GHOSTTY_DA_CONFORMANCE_VT101 = 1

const GHOSTTY_DA_CONFORMANCE_VT102 = 6

const GHOSTTY_DA_CONFORMANCE_VT125 = 12

const GHOSTTY_DA_CONFORMANCE_VT131 = 7

const GHOSTTY_DA_CONFORMANCE_VT132 = 4

const GHOSTTY_DA_CONFORMANCE_VT220 = 62

const GHOSTTY_DA_CONFORMANCE_VT240 = 62

const GHOSTTY_DA_CONFORMANCE_VT320 = 63

const GHOSTTY_DA_CONFORMANCE_VT340 = 63

const GHOSTTY_DA_CONFORMANCE_VT420 = 64

const GHOSTTY_DA_CONFORMANCE_VT510 = 65

const GHOSTTY_DA_CONFORMANCE_VT520 = 65

const GHOSTTY_DA_CONFORMANCE_VT525 = 65

const GHOSTTY_DA_CONFORMANCE_LEVEL_2 = 62

const GHOSTTY_DA_CONFORMANCE_LEVEL_3 = 63

const GHOSTTY_DA_CONFORMANCE_LEVEL_4 = 64

const GHOSTTY_DA_CONFORMANCE_LEVEL_5 = 65

const GHOSTTY_DA_FEATURE_COLUMNS_132 = 1

const GHOSTTY_DA_FEATURE_PRINTER = 2

const GHOSTTY_DA_FEATURE_REGIS = 3

const GHOSTTY_DA_FEATURE_SIXEL = 4

const GHOSTTY_DA_FEATURE_SELECTIVE_ERASE = 6

const GHOSTTY_DA_FEATURE_USER_DEFINED_KEYS = 8

const GHOSTTY_DA_FEATURE_NATIONAL_REPLACEMENT = 9

const GHOSTTY_DA_FEATURE_TECHNICAL_CHARACTERS = 15

const GHOSTTY_DA_FEATURE_LOCATOR = 16

const GHOSTTY_DA_FEATURE_TERMINAL_STATE = 17

const GHOSTTY_DA_FEATURE_WINDOWING = 18

const GHOSTTY_DA_FEATURE_HORIZONTAL_SCROLLING = 21

const GHOSTTY_DA_FEATURE_ANSI_COLOR = 22

const GHOSTTY_DA_FEATURE_RECTANGULAR_EDITING = 28

const GHOSTTY_DA_FEATURE_ANSI_TEXT_LOCATOR = 29

const GHOSTTY_DA_FEATURE_CLIPBOARD = 52

const GHOSTTY_DA_DEVICE_TYPE_VT100 = 0

const GHOSTTY_DA_DEVICE_TYPE_VT220 = 1

const GHOSTTY_DA_DEVICE_TYPE_VT240 = 2

const GHOSTTY_DA_DEVICE_TYPE_VT330 = 18

const GHOSTTY_DA_DEVICE_TYPE_VT340 = 19

const GHOSTTY_DA_DEVICE_TYPE_VT320 = 24

const GHOSTTY_DA_DEVICE_TYPE_VT382 = 32

const GHOSTTY_DA_DEVICE_TYPE_VT420 = 41

const GHOSTTY_DA_DEVICE_TYPE_VT510 = 61

const GHOSTTY_DA_DEVICE_TYPE_VT520 = 64

const GHOSTTY_DA_DEVICE_TYPE_VT525 = 65

const GHOSTTY_STYLE_FLAG_BOLD = GhosttyStyleFlags(Cuint(1) << 0)

const GHOSTTY_STYLE_FLAG_ITALIC = GhosttyStyleFlags(Cuint(1) << 1)

const GHOSTTY_STYLE_FLAG_FAINT = GhosttyStyleFlags(Cuint(1) << 2)

const GHOSTTY_STYLE_FLAG_BLINK = GhosttyStyleFlags(Cuint(1) << 3)

const GHOSTTY_STYLE_FLAG_INVERSE = GhosttyStyleFlags(Cuint(1) << 4)

const GHOSTTY_STYLE_FLAG_INVISIBLE = GhosttyStyleFlags(Cuint(1) << 5)

const GHOSTTY_STYLE_FLAG_STRIKETHROUGH = GhosttyStyleFlags(Cuint(1) << 6)

const GHOSTTY_STYLE_FLAG_OVERLINE = GhosttyStyleFlags(Cuint(1) << 7)

const GHOSTTY_STYLE_UNDERLINE_SHIFT = 8

const GHOSTTY_STYLE_UNDERLINE_MASK = GhosttyStyleFlags(Cuint(0x07) << GHOSTTY_STYLE_UNDERLINE_SHIFT)

const GHOSTTY_MODE_DISABLE_KEYBOARD = ghostty_mode_new(2, true)

const GHOSTTY_MODE_INSERT = ghostty_mode_new(4, true)

const GHOSTTY_MODE_SEND_RECEIVE_MODE = ghostty_mode_new(12, true)

const GHOSTTY_MODE_LINEFEED = ghostty_mode_new(20, true)

const GHOSTTY_MODE_CURSOR_KEYS = ghostty_mode_new(1, false)

const GHOSTTY_MODE_132_COLUMN = ghostty_mode_new(3, false)

const GHOSTTY_MODE_SLOW_SCROLL = ghostty_mode_new(4, false)

const GHOSTTY_MODE_REVERSE_COLORS = ghostty_mode_new(5, false)

const GHOSTTY_MODE_ORIGIN = ghostty_mode_new(6, false)

const GHOSTTY_MODE_WRAPAROUND = ghostty_mode_new(7, false)

const GHOSTTY_MODE_AUTOREPEAT = ghostty_mode_new(8, false)

const GHOSTTY_MODE_MOUSE_EVENT_X10 = ghostty_mode_new(9, false)

const GHOSTTY_MODE_CURSOR_BLINKING = ghostty_mode_new(12, false)

const GHOSTTY_MODE_CURSOR_VISIBLE = ghostty_mode_new(25, false)

const GHOSTTY_MODE_ENABLE_MODE_3 = ghostty_mode_new(40, false)

const GHOSTTY_MODE_REVERSE_WRAP = ghostty_mode_new(45, false)

const GHOSTTY_MODE_ALT_SCREEN_LEGACY = ghostty_mode_new(47, false)

const GHOSTTY_MODE_KEYPAD_KEYS = ghostty_mode_new(66, false)

const GHOSTTY_MODE_BACKARROW_KEY_MODE = ghostty_mode_new(67, false)

const GHOSTTY_MODE_ENABLE_LEFT_AND_RIGHT_MARGIN = ghostty_mode_new(69, false)

const GHOSTTY_MODE_MOUSE_EVENT_NORMAL = ghostty_mode_new(1000, false)

const GHOSTTY_MODE_MOUSE_EVENT_BUTTON = ghostty_mode_new(1002, false)

const GHOSTTY_MODE_MOUSE_EVENT_ANY = ghostty_mode_new(1003, false)

const GHOSTTY_MODE_FOCUS_EVENT = ghostty_mode_new(1004, false)

const GHOSTTY_MODE_MOUSE_FORMAT_UTF8 = ghostty_mode_new(1005, false)

const GHOSTTY_MODE_MOUSE_FORMAT_SGR = ghostty_mode_new(1006, false)

const GHOSTTY_MODE_MOUSE_ALTERNATE_SCROLL = ghostty_mode_new(1007, false)

const GHOSTTY_MODE_MOUSE_FORMAT_URXVT = ghostty_mode_new(1015, false)

const GHOSTTY_MODE_MOUSE_FORMAT_SGR_PIXELS = ghostty_mode_new(1016, false)

const GHOSTTY_MODE_IGNORE_KEYPAD_WITH_NUMLOCK = ghostty_mode_new(1035, false)

const GHOSTTY_MODE_ALT_ESC_PREFIX = ghostty_mode_new(1036, false)

const GHOSTTY_MODE_ALT_SENDS_ESCAPE = ghostty_mode_new(1039, false)

const GHOSTTY_MODE_REVERSE_WRAP_EXTENDED = ghostty_mode_new(1045, false)

const GHOSTTY_MODE_ALT_SCREEN = ghostty_mode_new(1047, false)

const GHOSTTY_MODE_SAVE_CURSOR = ghostty_mode_new(1048, false)

const GHOSTTY_MODE_ALT_SCREEN_SAVE_CURSOR_CLEAR_ENTER = ghostty_mode_new(1049, false)

const GHOSTTY_MODE_BRACKETED_PASTE = ghostty_mode_new(2004, false)

const GHOSTTY_MODE_SYNCHRONIZED_OUTPUT = ghostty_mode_new(2026, false)

const GHOSTTY_MODE_GRAPHEME_CLUSTER = ghostty_mode_new(2027, false)

const GHOSTTY_MODE_REPORT_COLOR_SCHEME = ghostty_mode_new(2031, false)

const GHOSTTY_MODE_REPORT_VISIBILITY = ghostty_mode_new(2033, false)

const GHOSTTY_MODE_IN_BAND_SIZE_REPORTS = ghostty_mode_new(2048, false)

const GHOSTTY_MODE_KITTY_PASTE_EVENTS = ghostty_mode_new(5522, false)

const GHOSTTY_FORMATTER_EXTRA_PALETTE = Cuint(1) << 0

const GHOSTTY_FORMATTER_EXTRA_MODES = Cuint(1) << 1

const GHOSTTY_FORMATTER_EXTRA_SCROLLING_REGION = Cuint(1) << 2

const GHOSTTY_FORMATTER_EXTRA_TABSTOPS = Cuint(1) << 3

const GHOSTTY_FORMATTER_EXTRA_PWD = Cuint(1) << 4

const GHOSTTY_FORMATTER_EXTRA_KEYBOARD = Cuint(1) << 5

const GHOSTTY_FORMATTER_EXTRA_CURSOR = Cuint(1) << 6

const GHOSTTY_FORMATTER_EXTRA_STYLE = Cuint(1) << 7

const GHOSTTY_FORMATTER_EXTRA_HYPERLINK = Cuint(1) << 8

const GHOSTTY_FORMATTER_EXTRA_PROTECTION = Cuint(1) << 9

const GHOSTTY_FORMATTER_EXTRA_KITTY_KEYBOARD = Cuint(1) << 10

const GHOSTTY_FORMATTER_EXTRA_CHARSETS = Cuint(1) << 11

const GHOSTTY_FORMATTER_EXTRAS_NONE = Cuint(0)

const GHOSTTY_FORMATTER_EXTRAS_ALL = Cuint(0x0fff)

const GHOSTTY_FORMATTER_EXTRAS_DEFAULT = (GHOSTTY_FORMATTER_EXTRA_PALETTE | GHOSTTY_FORMATTER_EXTRA_STYLE) | GHOSTTY_FORMATTER_EXTRA_HYPERLINK

const GHOSTTY_MODS_SHIFT = 1 << 0

const GHOSTTY_MODS_CTRL = 1 << 1

const GHOSTTY_MODS_ALT = 1 << 2

const GHOSTTY_MODS_SUPER = 1 << 3

const GHOSTTY_MODS_CAPS_LOCK = 1 << 4

const GHOSTTY_MODS_NUM_LOCK = 1 << 5

const GHOSTTY_MODS_SHIFT_SIDE = 1 << 6

const GHOSTTY_MODS_CTRL_SIDE = 1 << 7

const GHOSTTY_MODS_ALT_SIDE = 1 << 8

const GHOSTTY_MODS_SUPER_SIDE = 1 << 9

const GHOSTTY_KITTY_KEY_DISABLED = 0

const GHOSTTY_KITTY_KEY_DISAMBIGUATE = 1 << 0

const GHOSTTY_KITTY_KEY_REPORT_EVENTS = 1 << 1

const GHOSTTY_KITTY_KEY_REPORT_ALTERNATES = 1 << 2

const GHOSTTY_KITTY_KEY_REPORT_ALL = 1 << 3

const GHOSTTY_KITTY_KEY_REPORT_ASSOCIATED = 1 << 4

const GHOSTTY_KITTY_KEY_ALL = (((GHOSTTY_KITTY_KEY_DISAMBIGUATE | GHOSTTY_KITTY_KEY_REPORT_EVENTS) | GHOSTTY_KITTY_KEY_REPORT_ALTERNATES) | GHOSTTY_KITTY_KEY_REPORT_ALL) | GHOSTTY_KITTY_KEY_REPORT_ASSOCIATED

# exports
const PREFIXES = ["Ghostty", "ghostty_", "GHOSTTY_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
