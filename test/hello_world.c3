module uefi_test;

import uefi;


fn EfiStatus efi_main(
    EfiHandle image_handle,
    SystemTable *system_table
) @export("efi_main")
{
    /* Initialize uefi.c3l library constructs. */
    efilib::init(image_handle, system_table)!!;

    /* Clear the screen and print some messages. */
    efi_sys.console.clear({LIGHT_GREEN, BLACK})!!;
    efi_sys.console.cprintln(a2w("Hello, world!"), {LIGHT_GREEN, BLACK})!!;
    efi_sys.console.printe(a2w("A {} expression {}\r\n{}", true, "goes here!", a2w("FIN"))!!;

    /* Wait 8 seconds. */
    stall(uefi::@s2us(8));

    /* Exit success. */
    return SUCCESS;
}
