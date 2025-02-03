module uefi_test;


/* ... */

import uefi;


fn EfiStatus efi_main(
    EfiHandle image_handle,
    SystemTable *system_table
) {
    return uefi::EFI_SUCCESS;
}
