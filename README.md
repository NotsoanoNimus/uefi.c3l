# uefi.c3l - UEFI Definitions & Library for C3
A gnu-efi-like UEFI library enabling bootloader/firmware development with UEFI in C3.


## Example
The following example shows what a "Hello World" style EFI application might look like in C3.

Use of the `efilib` portion of the library is completely optional, including the global `System` object (`efi_sys`). This means those familiar with UEFI, `gnu-efi`, EDK2, etc. etc. might be more comfortable with `gBS` (Boot Services), `gRS` (Runtime Services) access, etc. Just keep in mind that, in order to use these global constants, one would only need to call `efilib::init` on startup.

```c3
module efi_hello_world;
import uefi;

fn EfiString! str_to_wide(char[] input) { /* ... */ }

fn EfiStatus efi_main(
    EfiHandle image_handle,
    SystemTable *system_table
) @export("efi_main")
{
    efilib::init(image_handle, system_table)!!;

    efi_sys.console.clear({YELLOW, RED})!!;

    /* NOTE: 'str_to_wide' is the current way to dynamically get a CHAR16 string.
        There is currently an open `c3c` issue to add native wide-string constants. */
    efi_sys.console.cprintln(str_to_wide("Enabling GOP mode..."), {GREEN, BLACK})!!;

    if (catch excuse = efilib::enable_gop()) {
        efi_sys.console.cprintln(str_to_wide("ERROR: Failed to initialize Graphics Output Protocol."),
{RED, BLACK})!!;
    } else {
        efi_sys.framebuffer.draw_rect({0,0,100,200},{0xff123456,0xff0000dd});
    }

    efi_sys.stall(uefi::@s2us(3));   /* s2us == sec-to-microsec; also could use gBS.stall(...) */
    efi_sys.reset(SHUTDOWN);
}

```


## Installation
The library is incredibly easy to pull and use right away.
1.) Change to your project's `lib` directory.
2.) Clone this repository: `git clone https://github.com/NotsoanoNimus/uefi.c3l.git`.
3.) Start developing with `import uefi;` where needed.

Most projects will automatically source modules from their `lib` folders. If this is not the case, you can use the following `c3c` parameters to source the library: `--lib uefi --libdir lib/`


## Compiling EFI Binaries
This will be improved as time goes on, but for now I have been compiling my EFI test binaries with:
```
. $ c3c compile-only src/** --use-stdlib=no --link-libc=no --no-entry \
    --target windows-x64 --lib uefi --libdir ./lib

. $ clang -target x86_64-unknown-windows -nostdlib -fno-stack-protector \
    -mno-red-zone -ffreestanding -Wl,-entry:efi_main -Wl,-subsystem:efi_application \
    -fuse-ld=lld-link -mno-stack-arg-probe -v -o test.efi ./*.obj
```

Notice that this requires `clang` and `lld-link` in order to generate the EFI application.
