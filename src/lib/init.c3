module uefi::efilib;
import uefi;


/* Global structures to be optionally used with all EFI programs. */
SystemTable *gST @export("gST") = null;
BootServices *gBS @export("gBS") = null;
RuntimeServices *gRS @export("gRS") = null;


fn bool! init(
    EfiHandle image,
    SystemTable *st
) {
    EfiStatus result = uefi::EFI_SUCCESS;

    return !(uefi::is_error(result));   /* ! because we want this to return 'true' on success */
}
