module uefi::efilib;
import uefi;



fn usz? wide_strlen(ushort *rawptr)
    @export("wstrlen")
{
    if (null == rawptr) return efi_error::INVALID_PARAMETER?;

    usz len = 0;
    while (rawptr[len]) ++len;

    return len;
}


fn usz? ascii_strlen(char *rawptr)
    @export("strlen")
{
    if (null == rawptr) return efi_error::INVALID_PARAMETER?;

    usz len = 0;
    while (rawptr[len]) ++len;

    return len;
}


fn EfiString? ascii_to_wide(AsciiString str)
    @export("a2w")
{
    if (null == (void *)str.ptr || 0 == str[0]) return efi_error::INVALID_PARAMETER?;

    EfiString ret = ((ushort *)malloc(ushort.sizeof * (str.len + 1))!)[:(str.len + 1)];

    for (int i = 0; i < str.len; ++i) ret[i] = (ushort)str[i];
    ret[^1] = 0;

    return ret;
}


fn AsciiString? wide_to_ascii(EfiString str)
    @export("w2a")
{
    if (null == (void *)str.ptr || 0 == str[0]) return efi_error::INVALID_PARAMETER?;

    AsciiString ret = ((char *)malloc(str.len + 1)!)[:(str.len + 1)];

    for (int i = 0; i < str.len; ++i) ret[i] = (char)str[i];   /* lossy */
    ret[^1] = 0;

    return ret;
}


fn EfiString? wide_strdup(EfiString str)
    @export("wstrdup")
{
    if (null == (void *)str.ptr) return efi_error::INVALID_PARAMETER?;
    if (0 == str.len) return a2w({0});

    EfiString ret = ((ushort *)malloc(ushort.sizeof * (str.len + 1))!)[:(str.len + 1)];

    efi_sys.memcpy(ret, str, str.len * ushort.sizeof);
    ret[^1] = 0;

    return ret;
}


fn AsciiString? ascii_strdup(AsciiString str)
    @export("strdup")
{
    if (null == (void *)str.ptr) return efi_error::INVALID_PARAMETER?;
    if (0 == str.len) return calloc(char.sizeof, 1)![:1];

    AsciiString ret = ((char *)malloc(str.len + 1)!)[:(str.len + 1)];
    efi_sys.memcpy(ret, str, str.len);
    ret[^1] = 0;

    return ret;
}


fn EfiString? wide_strcat(EfiString str, EfiString addl)
    @export("wstrcat")
{
    if (null == (void *)str || null == (void *)addl) return efi_error::INVALID_PARAMETER?;

    efi_sys.memcpy((void *)((uptr)str.ptr + (str.len * ushort.sizeof)), addl, addl.len * ushort.sizeof);

    return str;
}


fn AsciiString? ascii_strcat(AsciiString str, AsciiString addl)
    @export("strcat")
{
    if (null == (void *)str || null == (void *)addl) return efi_error::INVALID_PARAMETER?;

    efi_sys.memcpy((void *)((uptr)str.ptr + str.len), addl, addl.len);

    return str;
}


macro usz? wstrlen(ushort *rawptr) @builtin => wide_strlen(rawptr);
macro usz? strlen(char *rawptr) @builtin => ascii_strlen(rawptr);
macro EfiString? a2w(AsciiString c) @builtin => ascii_to_wide(c);
macro AsciiString? w2a(EfiString c) @builtin => wide_to_ascii(c);

macro EfiString wslice_from_raw(void *rawptr, usz length) @builtin => ((ushort *)rawptr)[:length];
macro AsciiString slice_from_raw(void *rawptr, usz length) @builtin => ((char *)rawptr)[:length];
