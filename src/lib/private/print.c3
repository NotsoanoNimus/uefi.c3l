module uefi::efilib @private;

import uefi;



macro EfiString? @expand_param($Type, any value, #assign_to)
{
    $switch $Type:
        $case EfiString: $nextcase; $weweoifj;
        $case ushort*:
            #assign_to = wstrdup((EfiStringRaw)value);
    $endswitch
}



fn EfiString? _expandf(EfiString input, args...)
{
    if (null == (void *)input.ptr) return efi_error::INVALID_PARAMETER?;
    if (0 == args.len) return wide_strdup(input);

    usz scroll = 0;
    usz pool_idx = 1;
    usz vararg_idx = 0;
    EfiString[32] strpool;
    strpool[0] = wstrdup(input)!;
    EfiString dup = strpool[0];

    while (scroll < dup.len && 0 != dup[scroll]) {
        if ((ushort)'<' != dup[scroll]) {
            ++scroll;
            continue;
        }

        // if (scroll == (dup.len - 1)) break;   // Do NOT read past the end.

        if ((ushort)'<' == dup[scroll + 1]) {
            dup[scroll + 1] = 0;

            // if ((scroll + 2) == (dup.len - 1)) break;

            if (pool_idx >= 64) return efi_error::OUT_OF_RESOURCES?;
            strpool[pool_idx] = dup[(scroll + 2) : wstrlen(&dup[scroll + 2])!];
            dup = strpool[pool_idx];
            ++pool_idx;

            scroll = 0;
            continue;
        } else if ((ushort)'>' == dup[scroll + 1]) {
            if (vararg_idx >= args.len) return efi_error::NO_MAPPING?;

            dup[scroll] = 0;

            if (pool_idx >= 64-1) return efi_error::OUT_OF_RESOURCES?;
            strpool[pool_idx] = _expand_arg(args[vararg_idx])!;
            ++vararg_idx;
            ++pool_idx;

            strpool[pool_idx] = dup[(scroll + 2) : wstrlen(&dup[scroll + 2])!];
            dup = strpool[pool_idx];
            ++pool_idx;

            scroll = 0;
            continue;
        } else {
            return efi_error::INVALID_LANGUAGE?;
        }
    }

    usz required_buffer_size = 0;
    EfiStringRaw buff = null;
    scroll = 0;

    foreach (item : strpool[:pool_idx]) {
        if (!item[0]) continue;
        io::wprintn(item)!;
        required_buffer_size += item.bytes();
    }

    buff = mem::malloc(required_buffer_size + ushort.sizeof)!;

    foreach (item : strpool[:pool_idx]) {
        if (!item[0]) continue;

        mem::memcpy(&buff[scroll], item.ptr, item.bytes());
        scroll += (item.len - 1);

        // mem::free(item.ptr);
    }

    buff[wstrlen(buff)!] = 0;
    io::memdump(buff, wstrlen(buff) + 2)!;

    return wslice_from_raw(buff, required_buffer_size / ushort.sizeof);
}


fn EfiString? _expand_arg(any value)
{
    EfiString expansion = {};

    switch (value.type) {
        case EfiString: nextcase;
        case EfiStringRaw:
io::wprintn($$wstr16("efi_string"))!;
            expansion = wide_strdup(wslice_from_raw(value, wstrlen((EfiStringRaw)value) + 1))!;
        case AsciiString:
io::wprintn($$wstr16("ascii_string"))!;
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
// io::print(a2w("EXPAND: '"))!;io::print(expansion)!;io::printn(a2w("'"))!;
// io::printn(a2w(memdump(&&expansion.len, usz.sizeof)))!;

    if (null == (void *)expansion.ptr || 0 == expansion.len) return efi_error::INVALID_PARAMETER?;

    return expansion;
}


fn EfiString? _bool_to_str(bool b) => b ? a2w("TRUE") : a2w("FALSE");

fn EfiString? _guid_to_str(EfiGuid *guid)
{
    return a2w("SOMEGUID");
}
