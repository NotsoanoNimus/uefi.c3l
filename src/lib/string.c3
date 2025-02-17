module uefi::efilib;
import uefi;

// TODO: Before this is too entrenched, create a string interface and separate implementations for AsciiString vs EfiString.


fn usz wide_strlen(EfiString str)
    @export("wstrlen")
{
    if (null == (void *)str || 0 == *((ushort *)str)) return 0;

    usz len = 0;
    ushort *c = str;
    while (*(c++)) ++len;

    efi_sys.console.println(&&u"length returns")!!;
    return len;
}


fn usz ascii_strlen(AsciiString str)
    @export("strlen")
{
    if (null == (void *)str || 0 == *((char *)str)) return 0;

    usz len = 0;
    char *c = str;
    while (*(c++)) ++len;

    return len;
}


fn EfiString! ascii_to_wide(AsciiString str)
    @export("a2w")
{
    if (null == (void *)str) return null;
    if (0 == *((char *)str)) return (EfiString)calloc(1, 2)!;

    EfiString ret = calloc(ushort.sizeof, ascii_strlen(str) + 1)!;

    for (int i = 0; i < ascii_strlen(str); ++i) ret[i] = (ushort)str[i];

    return ret;
}


fn AsciiString! wide_to_ascii(EfiString str)
    @export("w2a")
{
    if (null == (void *)str) return null;
    if (0 == *((ushort *)str)) return (AsciiString)calloc(1, 1)!;

    usz strlen = wide_strlen(str);
    AsciiString ret = (AsciiString)calloc(char.sizeof, strlen + 1)!;

    for (int i = 0; i < strlen; ++i) ret[i] = (char)str[i];

    return ret;
}


macro EfiString! a2w(AsciiString c) @builtin => ascii_to_wide(c);
macro AsciiString! w2a(EfiString c) @builtin => wide_to_ascii(c);


fn EfiString! wide_strdup(EfiString str)
    @export("wstrdup")
{
    if (null == (void *)str) return null;

    usz len = wide_strlen(str);
    if (0 == len) return (EfiString)calloc(ushort.sizeof, 1)!;

    EfiString ret = (EfiString)calloc(ushort.sizeof, len + 1)!;
    efi_sys.memcpy(ret, str, len);

    return ret;
}


fn AsciiString! ascii_strdup(AsciiString str)
    @export("strdup")
{
    if (null == (void *)str) return null;

    usz len = ascii_strlen(str);
    if (0 == len) return (AsciiString)calloc(char.sizeof, 1)!;

    AsciiString ret = (AsciiString)calloc(char.sizeof, len + 1)!;
    efi_sys.memcpy(ret, str, len);

    return ret;
}


fn EfiString! wide_strcat(EfiString str, EfiString addl)
    @export("wstrcat")
{
    if (null == (void *)str || null == (void *)addl) return EfiError.INVALID_PARAMETER?;

    efi_sys.memcpy((void *)((uptr)str + wide_strlen(str)), addl, wide_strlen(addl));

    return str;
}


fn AsciiString! ascii_strcat(AsciiString str, AsciiString addl)
    @export("strcat")
{
    if (null == (void *)str || null == (void *)addl) return EfiError.INVALID_PARAMETER?;

    efi_sys.memcpy((void *)((uptr)str + ascii_strlen(str)), addl, ascii_strlen(addl));

    return str;
}
