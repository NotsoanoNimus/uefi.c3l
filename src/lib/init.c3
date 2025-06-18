module uefi::efilib::pre_load;
import uefi;
import uefi::efi_system @public;


/* Global variables/structures to be optionally used with all EFI programs. */
bool initialized @private = false;

SystemTable *gST @export("gST") @builtin @deprecated("Legacy symbol. Use `sys::st()` instead.") = null;

BootServices *gBS @export("gBS") @builtin @deprecated("Legacy symbol. Use `sys::bs()` instead.") = null;
RuntimeServices *gRS @export("gRS") @builtin @deprecated("Legacy symbol. Use `sys::rs()` instead.") = null;

EfiHandle gImageHandle @export("gImageHandle") @builtin @deprecated("Legacy symbol. Use `sys::image()` instead.") = null;


<*
    Initialize the UEFI C3 library. This call should be made immediately upon EFI entry.
    @param [&in] image: "The input EFI_IMAGE handle to the EFI application"
    @param [&in] st: "A reference to the system table provided to the EFI application"
    @return "Whether the library was successfully initialized."
*>
fn bool? init(EfiHandle image, SystemTable *st) @public
{
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
