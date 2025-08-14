module uefi::efilib::pre_load;
import uefi;
import uefi::efi_system @public;


/* Global variables/structures to be optionally used with all EFI programs. */
bool initialized @private = false;

SystemTable *gST @export("gST") @builtin @deprecated("Legacy symbol. Use `sys::st()` instead.") = null;

BootServices *gBS @export("gBS") @builtin @deprecated("Legacy symbol. Use `sys::bs()` instead.") = null;
RuntimeServices *gRS @export("gRS") @builtin @deprecated("Legacy symbol. Use `sys::rs()` instead.") = null;

EfiHandle gImageHandle @export("gImageHandle") @builtin @deprecated("Legacy symbol. Use `sys::image()` instead.") = null;

bool in_panic @local = false;
bool panic_in_panic @local = false;

fn void default_panic(String message, String file, String function, uint line) @public @allow_deprecated @export("panic") @noreturn
{
    if (!initialized) sys::lock();   // spin forever, can't do anything...

    if (in_panic)
    {
        if (panic_in_panic) sys::lock();   // prevent infinite panic recursion
        panic_in_panic = true;

        gST.conout.output_string(gST.conout, @wstring("PANIC raised within panicfn! Locking system..."));
        sys::lock();
    }

    in_panic = true;

    // Create a wide string on the stack from the passed information.
    ushort[1024] _w_msg;
    usz _w_msg_start, x;

    foreach (i, c : file) _w_msg[i % _w_msg.len] = (ushort)c; _w_msg_start = file.len;

    _w_msg[_w_msg_start++] = (ushort)':';
    foreach (i, c : function) _w_msg[(i + _w_msg_start) % _w_msg.len] = (ushort)c; _w_msg_start += function.len;

    _w_msg[_w_msg_start++] = (ushort)':';
    ushort[7] _i_to_str;
    for (x = 0; line && x < _i_to_str.len; line /= 10, ++x) _i_to_str[x] = (ushort)(0x30 + (line % 10));
    for (usz w = 1; w <= x; ++w) _w_msg[_w_msg_start++] = _i_to_str[x - w];

    _w_msg[_w_msg_start++] = (ushort)':';
    foreach (i, c : message) _w_msg[(i + _w_msg_start) % _w_msg.len] = (ushort)c;

    _w_msg[1023] = 0;   // explicit null-terminator

    gST.conout.output_string(gST.conout, @wstring("PANIC!  "));
    gST.conout.output_string(gST.conout, &_w_msg);

    sys::lock();
}


<*
    Initialize the UEFI C3 library. This call should be made immediately upon EFI entry.
    @param [&in] image: "The input EFI_IMAGE handle to the EFI application"
    @param [&in] st: "A reference to the system table provided to the EFI application"
    @return "Whether the library was successfully initialized."
*>
fn bool? init(EfiHandle image, SystemTable *st) @public @allow_deprecated
{
    builtin::panic = &default_panic;   // in case the user did not compile with '--panicfn'

    if (null == (void *)image || null == (void *)st) return efi_error::LOAD_ERROR?;

    // Though these are deprecated, they should hang around for the purpose of interfacing with old code.
    gST = st;
    gBS = st.boot_services;
    gRS = st.runtime_services;
    gImageHandle = image;

    /* The library is _technically_ initialized once the above pointers are populated. */
    initialized = true;

    efi_system::efi_sys = efi_system::new(image, st)!;
    initialized = initialized && (null != (void *)efi_system::efi_sys);

    return initialized;
}
