module uefi::efilib @private;

import uefi;



fn AsciiString! _ascii_printf(
    AsciiString format,
    args...
) => w2a(_printf(a2w(format)!, args))!;

fn AsciiString! _ascii_expandf(
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
fn EfiString! _printf(
    EfiString format,
    args...
) {
    if (null == (void *)format) return null;

    usz base_len = wide_strlen(format) + 1;

    return a2w("ok")!;
}




fn EfiString! _expandf(
    EfiString input,
    args...
) {
    if (null == (void *)input) return EfiError.INVALID_PARAMETER?;
    if (0 == args.len) return input;

    usz base_len = wide_strlen(input) + 1;
    usz vararg_idx = 0;
    EfiString scroll = input;
    usz scroll_idx = 0;

    EfiString ret = calloc(1, base_len)!;

    while (*scroll) {
        if ((ushort)'{' == *scroll) {
            if ((ushort)'{' == scroll[1]) {
                // '{{' Represents a literal '{'
                ret[scroll_idx] = (ushort)'{';
                ++scroll;   // skip second '{'
            }
            else if ((ushort)'}' == scroll[1]) {
                if (vararg_idx > args.len) return EfiError.NO_MAPPING?;

                _expand_arg(&ret, &base_len, &scroll_idx, args[vararg_idx])!;

                ++scroll;   // skip terminating '}'
                ++vararg_idx;   // next vararg
            }
            else {
                return EfiError.INVALID_LANGUAGE?;
            }
        }
        else {
            // Copy the character into the result since it's not part of an expansion.
            ret[scroll_idx] = *scroll;
        }
        ++scroll_idx;
        ++scroll;
    }

    return ret;
}


fn void! _expand_arg(
    EfiString *return_str_ptr,
    usz *base_strlen,
    usz *scroll_idx,
    any value
) {
    EfiString str = *return_str_ptr;
    EfiString expansion = (EfiString)null;
    defer efi_sys.free(expansion);

    switch (value.type) {
        case EfiString.typeid:  expansion = wide_strdup((EfiString)value)!;
        case String.typeid:     expansion = a2w((AsciiString)value.ptr)!;
        case bool.typeid:       expansion = _bool_to_str(*((bool *)(value.ptr)))!;
        case EfiGuid.typeid:    expansion = _guid_to_str((EfiGuid *)value.ptr)!;
        //case EfiDevicePath.typeid: expansion = _device_path_to_str((EfiDevicePath *)value);
        case float.typeid:
        case double.typeid:
            expansion = a2w("fract")!;//_fractional_to_str(value);
        case int128.typeid:
        case uint128.typeid:
        case long.typeid:
        case ulong.typeid:
        case int.typeid:
        case uint.typeid:
        case short.typeid:
        case ushort.typeid:
        case ichar.typeid:
        case char.typeid:
            expansion = a2w("number")!;//_number_to_str(value);
        case void.typeid:
            expansion = a2w("pointer")!;//_pointer_to_str(value);
        default:
            return EfiError.INVALID_PARAMETER?;
    }

    if (null == (void *)expansion) return;   // do nothing on empty expansions

    usz exp_len = wide_strlen(expansion);
    if (0 == exp_len) return;   // same here

    usz old_strlen = *base_strlen;   // used in 'realloc' but not really necessary since len always grows

    // Update string properties and positions.
    *scroll_idx = (*scroll_idx) + exp_len - 1;
    *base_strlen = (*base_strlen) + exp_len;
    *return_str_ptr = efi_sys.realloc(str, old_strlen, *base_strlen)!;
}


fn EfiString! _bool_to_str(bool b) => b ? a2w("TRUE") : a2w("FALSE");

fn EfiString! _guid_to_str(EfiGuid *guid)
{
    return a2w("SOMEGUID");
}
