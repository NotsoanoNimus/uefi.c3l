module uefi::efilib;

import uefi;


<*
    @param [&in] image_handle "The input EFI_IMAGE handle to the EFI application"
    @param [&in] system_table "A reference to the system table provided to the EFI application"
*>
fn void initialize_lib(
    EfiHandle image_handle,
    SystemTable *system_table
) {
}
