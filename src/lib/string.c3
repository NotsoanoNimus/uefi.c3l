module uefi::efilib;
import uefi;

// TODO: Before this is too entrenched, create a string interface and separate implementations for String vs EfiString.


fn usz wide_strlen(EfiString str)
    @export("wstrlen")
{
    if (null == (void *)str || 0 == *str) return 0;

    usz len = 0;
    EfiString c = str;
    while (*(c++)) ++len;

    return len;
}


fn usz ascii_strlen(String str)
    @export("strlen")
{
    if (null == (void *)str || 0 == *str) return 0;

    usz len = 0;
    String c = str;
    while (*(c++)) ++len;

    return len;
}


fn EfiString! ascii_to_wide(String str)
    @export("a2w")
{
    if (null == (void *)str) return null;
    if (0 == *str) return (EfiString)(calloc(2)!);

    EfiString ret = calloc((ascii_strlen(str) * ushort.sizeof) + ushort.sizeof)!;

    foreach (int idx, char &c : str) ret[idx] = (ushort)c;

    return ret;
}


fn String! wide_to_ascii(EfiString str)
    @export("w2a")
{
    if (null == (void *)str) return null;
    if (0 == *str) return (String)(calloc(1)!);

    String ret = calloc(wide_strlen(str) + 1);

    foreach (int idx, ushort &s : str) ret[idx] = (char)c;

    return ret;
}


macro EfiString! a2w(String c) @builtin => ascii_to_wide(c);
macro String! w2a(EfiString c) @builtin => wide_to_ascii(c);


fn EfiString! wide_strdup(EfiString str)
    @export("wstrdup")
{
    if (null == (void *)str) return null;

    usz len = wide_strlen(str);
    if (0 == len) return (EfiString)calloc(ushort.sizeof)!;

    EfiString ret = calloc(len + ushort.sizeof)!;
    memcpy(ret, str, len);

    return ret;
}


fn String! ascii_strdup(String str)
    @export("strdup")
{
    if (null == (void *)str) return null;

    usz len = ascii_strlen(str);
    if (0 == len) return (String)calloc(1)!;

    String ret = calloc(len + 1)!;
    memcpy(ret, str, len);

    return ret;
}


fn EfiString! wide_strcat(EfiString str, EfiString addl)
    @export("wstrcat")
{
    if (null == (void *)str || null == (void *)addl) return EfiError.INVALID_PARAMETER?;

    memcpy(str + wide_strlen(str), addl, wide_strlen(addl));

    return str;
}


fn String! ascii_strcat(String str, String addl)
    @export("strcat")
{
    if (null == (void *)str || null == (void *)addl) return EfiError.INVALID_PARAMETER?;

    memcpy(str + ascii_strlen(str), addl, ascii_strlen(addl));

    return str;
}
