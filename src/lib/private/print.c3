module uefi::efilib @private;

import uefi;


<*
 * Traditional `printf` functionality which takes a format string
 *  and a variadic parameters list and returns a formatted string.
 *
 * Supports:
 *  %s - EfiString
 *  %a - ASCII String (String type)
 *  %d - Signed decimal value
 *  %u - Unsigned decimal value
 *  %f - Floating-point value
 *  %X - 8-byte hex value
 *  %x - hex value
 *  %c - Char16
 *  %C - ASCII char (char8)
 *  %p - Pointer
 *  %r - EFI Status code result
 *  %t - EFI time struct (from ref)
 *  %g - EFI GUID (from ref)
 *  %D - EFI Device Path
 *  %% - literal '%' sign
 *
 *>
fn EfiString? _printf(
    EfiString format,
    args...
) {
    if (null == (void *)format) return efi_error::INVALID_PARAMETER?;
    if (0 == args.len) return wide_strdup(format);

    EfiString tmp = wide_strdup(format)!;
    defer free(tmp);

    usz base_len = (tmp.len * ushort.sizeof) + 2;
    usz vararg_idx = 0;
    usz scroll_idx = 0;
    usz read_idx = 0;

    EfiString ret = ((ushort *)calloc(ushort.sizeof, base_len)!)[:base_len];

    while OUTER: (tmp[read_idx]) {
        ushort c = tmp[read_idx];

        if (0 == c) break;

        if ((ushort)'%' != c) {
            ret[scroll_idx] = c;
            ++read_idx;
            ++scroll_idx;
            continue;
        }

        if ('%' != tmp[read_idx + 1] && vararg_idx >= args.len) return efi_error::NO_MAPPING?;

        any arg = args[vararg_idx];
        void *value = (void *)(arg.ptr);

        switch (tmp[read_idx + 1]) {
            case '\0': return efi_error::END_OF_FILE?;
            case '%': ret[scroll_idx] = (ushort)'%';
            case 's': {
                EfiString s = *(EfiString *)value;
                usz len = s.len * ushort.sizeof;
                if (0 != len) {
                    EfiString new_pool = ((ushort *)realloc(ret, base_len, base_len + len)!)[:base_len + len];
                    wide_strcat(new_pool, s)!;
                    scroll_idx += (len >> 1);
                    base_len += len;
                    ret = new_pool;
                }
                ++vararg_idx;
            }
            default: read_idx += 2; continue OUTER;   // Leave token as-is
        }

        ++read_idx;
        ++scroll_idx;
    }

    return ret;
}


fn EfiString? _expandf(EfiString input, args...)
{
    if (null == (void *)input.ptr) return efi_error::INVALID_PARAMETER?;
    if (0 == args.len) return wide_strdup(input);

    EfiString dup = wstrdup(input)!;
    usz scroll = 0;
    usz pool_idx = 1;
    usz vararg_idx = 0;
    EfiString[32] strpool;
    strpool[0] = dup;

efi_sys.console.printn(strpool[0])!;
efi_sys.console.printn(a2w("start"))!;
    while (dup[scroll]) {
        if ((ushort)'<' != dup[scroll]) {
            ++scroll;
            continue;
        }

        if ((ushort)'<' == dup[scroll + 1]) {
            dup[scroll + 1] = 0;

efi_sys.console.printn(dup)!;
            strpool[pool_idx] = dup[(scroll + 2) : wstrlen(&dup[scroll + 2])!];
            dup = strpool[pool_idx];
            ++pool_idx;
            if (pool_idx >= 64) return efi_error::OUT_OF_RESOURCES?;
efi_sys.console.print(a2w("next1:"))!; efi_sys.console.printn(dup)!;

            scroll = 0;
            continue;
        } else if ((ushort)'>' == dup[scroll + 1]) {
            if (vararg_idx >= args.len) return efi_error::NO_MAPPING?;

            dup[scroll] = 0;

efi_sys.console.print(a2w("dup2:"))!; efi_sys.console.printn(dup)!;
            strpool[pool_idx] = _expand_arg(args[vararg_idx])!;
efi_sys.console.print(a2w("token:"))!; efi_sys.console.printn(strpool[pool_idx])!;
            ++vararg_idx;
            ++pool_idx;
            if (pool_idx >= 64) return efi_error::OUT_OF_RESOURCES?;

            strpool[pool_idx] = dup[(scroll + 2) : wstrlen(&dup[scroll + 2])!]; //(&dup[scroll + 2])[:wstrlen(&dup[scroll + 2])!];
            dup = strpool[pool_idx];
            ++pool_idx;
            if (pool_idx >= 64) return efi_error::OUT_OF_RESOURCES?;
efi_sys.console.print(a2w("next2:"))!; efi_sys.console.printn(dup)!;

            scroll = 0;
            continue;
        } else {
            return efi_error::INVALID_LANGUAGE?;
        }
    }

efi_sys.console.printn(a2w("======================"))!;
    for (usz i = 0; i < pool_idx; ++i) {
        efi_sys.console.printn(strpool[i])!;
    }

    return a2w("ok")!;
}


fn EfiString? _expand_arg(any value)
{
    EfiString expansion = {};

    switch (value.type) {
        case EfiString: nextcase;
        case EfiStringRaw:
efi_sys.console.printn($$wstr16("efi_string"))!;
            expansion = wide_strdup(wslice_from_raw(value, wstrlen((EfiStringRaw)value) + 1))!;
        case AsciiString:
efi_sys.console.printn($$wstr16("ascii_string"))!;
            expansion = a2w(slice_from_raw(value, strlen((AsciiStringRaw)value) + 1))!;
        case bool:
            expansion = _bool_to_str(((bool)(value.ptr)))!;
        case EfiGuid:
            expansion = _guid_to_str((EfiGuid *)value.ptr)!;
        //case EfiDevicePath: expansion = _device_path_to_str((EfiDevicePath *)value);
        case float: nextcase;
        case double:
            expansion = a2w("fract")!;//_fractional_to_str(value);
        case int128: nextcase;
        case uint128: nextcase;
        case long: nextcase;
        case ulong: nextcase;
        case int: nextcase;
        case uint: nextcase;
        case short: nextcase;
        case ushort: nextcase;
        case ichar: nextcase;
        case char:
            expansion = a2w("number")!;//_number_to_str(value);
        case void:
            expansion = a2w("pointer")!;//_pointer_to_str(value);
        default:
            expansion = a2w("umm")!; //efi_error::INVALID_PARAMETER?;
    }
// efi_sys.console.print(a2w("EXPAND: '"))!;efi_sys.console.print(expansion)!;efi_sys.console.printn(a2w("'"))!;
// efi_sys.console.printn(a2w(memdump(&&expansion.len, usz.sizeof)))!;

    if (null == (void *)expansion.ptr || 0 == expansion.len) return efi_error::INVALID_PARAMETER?;

    return expansion;
}


fn EfiString? _bool_to_str(bool b) => b ? a2w("TRUE") : a2w("FALSE");

fn EfiString? _guid_to_str(EfiGuid *guid)
{
    return a2w("SOMEGUID");
}
