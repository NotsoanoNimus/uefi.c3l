module uefi::efilib;
import uefi;


/* Global variables/structures to be optionally used with all EFI programs. */
bool initialized = false;

SystemTable *gST @export("gST") @builtin = null;
BootServices *gBS @export("gBS") @builtin = null;
RuntimeServices *gRS @export("gRS") @builtin = null;

EfiHandle gImageHandle @export("gImageHandle") @builtin = null;
System *efi_sys @export("efi_sys") @builtin = null;


<*
    Initialize the UEFI C3 library. This call should be made immediately upon EFI entry.

    @param [&in] image "The input EFI_IMAGE handle to the EFI application"
    @param [&in] st "A reference to the system table provided to the EFI application"
    @return "Whether the library was successfully initialized."
*>
fn bool! init(
    EfiHandle image,
    SystemTable *st
) {
    EfiStatus result = SUCCESS;

    if (null == (void *)image || null == (void *)st) return EfiError.LOAD_ERROR?;

    gST = st;
    gBS = st.boot_services;
    gRS = st.runtime_services;
    gImageHandle = image;

    /* The library is _technically_ initialized once the above pointers are populated. */
    initialized = true;

    efi_sys = efi_system::new()!;
    initialized = initialized && (null != (void *)efi_sys);

    return initialized;
}
