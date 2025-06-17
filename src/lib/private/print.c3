module uefi::efilib @private;

import uefi;



fn AsciiString? _ascii_printf(
    AsciiString format,
    args...
) => w2a(_printf(a2w(format)!, args))!;

fn AsciiString? _ascii_expandf(
    AsciiString input,
    args...
) => w2a(_expandf(a2w(input)!, args))!;


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


fn EfiString? _expandf(
    EfiString input,
    args...
) {
    if (null == (void *)input) return efi_error::INVALID_PARAMETER?;
    if (0 == args.len) return wide_strdup(input);

    usz base_len = (input.len + 1) * ushort.sizeof;
    usz vararg_idx = 0;
    usz scroll_idx = 0;
    usz read_idx = 0;

    EfiString ret = ((ushort *)calloc(1, base_len)!)[:base_len];

    while (input[read_idx]) {
        if ((ushort)'<' == input[read_idx]) {
            if ((ushort)'<' == input[read_idx + 1]) {
                // '{{' Represents a literal '<'
                ret[scroll_idx] = (ushort)'<';
                ++read_idx;   // skip second '<'
            }
            else if ((ushort)'>' == input[read_idx + 1]) {
                if (vararg_idx >= args.len) return efi_error::NO_MAPPING?;

                _expand_arg(&ret, &base_len, &scroll_idx, args[vararg_idx])!;

                ++read_idx;   // skip terminating '>'
                ++vararg_idx;   // next vararg
            }
            else {
                return efi_error::INVALID_LANGUAGE?;
            }
        }
        else {
            // Copy the character into the result since it's not part of an expansion.
            ret[scroll_idx] = input[read_idx];
efi_sys.console.printn(ret)!;
        }
        ++scroll_idx;
        ++read_idx;
    }

    return ret;
}


fn void? _expand_arg(
    EfiString *return_str_ptr,
    usz *base_strlen,
    usz *scroll_idx,
    any value
) {
    EfiString str = *return_str_ptr;
    EfiString expansion = {};
    defer
    {
        if (null != expansion.ptr) efi_sys.free(expansion.ptr);
    }

    switch (value.type) {
        case EfiString:  expansion = wide_strdup(((ushort *)value)[:wstrlen((ushort *)value)!])!;
        case String:     expansion = a2w(((char *)value)[:strlen((char *)value)!])!;
        case bool:       expansion = _bool_to_str(*((bool *)(value.ptr)))!;
        case EfiGuid:    expansion = _guid_to_str((EfiGuid *)value.ptr)!;
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
        default: return;
            //return efi_error::INVALID_PARAMETER?;
    }

    if (null == (void *)expansion) return;   // do nothing on empty expansions

    usz exp_len = expansion.len;
    if (0 == exp_len) return;   // same here

    usz old_strlen = *base_strlen;   // used in 'realloc' but not really necessary since len always grows

    // Update string properties and positions.
    *scroll_idx = (*scroll_idx) + exp_len - 1;
    *base_strlen = (*base_strlen) + (exp_len * ushort.sizeof);
    *return_str_ptr = ((ushort *)realloc(str, old_strlen, *base_strlen)!)[:*base_strlen];
}


fn EfiString? _bool_to_str(bool b) => b ? a2w("TRUE") : a2w("FALSE");

fn EfiString? _guid_to_str(EfiGuid *guid)
{
    return a2w("SOMEGUID");
}
