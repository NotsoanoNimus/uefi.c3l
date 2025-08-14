# uefi.c3l - UEFI Definitions & Library for C3
A gnu-efi-like library enabling UEFI bootloader development in C3.


## Installation
The library is incredibly easy to pull and use right away.

1. Change to your project's `lib` directory.
2. Clone this repository: `git clone https://github.com/NotsoanoNimus/uefi.c3l.git`.
3. Start developing with `import uefi;` where needed.

Most c3c projects will automatically source modules from their `lib` folders. If this is not the case, you can use the following `c3c` parameters to source the library: `--lib uefi --libdir lib/`

This will certainly be improved as the project becomes more mature.


## Compiling EFI Binaries
I need to revisit this, but I have been successfully compiling my EFI test binaries with the following:
```
~$  c3c compile-only src/*.c3 --link-libc=no --no-entry \
        --target windows-x64 --lib uefi --libdir ./lib

~$  clang -target x86_64-unknown-windows -nostdlib -fno-stack-protector -mno-red-zone \
        -ffreestanding -fPIC -Wl,-entry:efi_main -Wl,-subsystem:efi_application \
        -fuse-ld=lld-link -mno-stack-arg-probe -v -o test.efi ./obj/windows-x64/*.obj
```

I'm pretty sure I'm switching up my compilation and linker arguments for this right now. :shrug: Again, to be improved as the project matures.

This snippet explicitly uses `clang` and `lld-link` in order to generate the EFI application. For me, it's a must; however, others may be more comfortable linking with another tool like `gcc`. It's all the same after `c3c` generates its objects.


## Example Usage
The following example shows what a "Hello World" style EFI application might look like in C3. When it starts, it sets a baseline console color, clears the window, and attempts to enable the Graphics Output Protocol and draw a simple rectangle.

Some of these methods currently don't exist; this is more of a "finished product" presentation.


```cpp
module hello_uefi;

import uefi;


fn EfiStatus efi_main(EfiHandle image_handle, SystemTable* system_table) @export("efi_main")
{
    pre_load::init(image_handle, system_table)!!;

    console::clear_to({YELLOW, RED});

    io::cprintn(@wstring("Enabling GOP mode..."), {GREEN, BLACK})!!;

    if (catch excuse = sys::enable_gop()) {
        io::cprintn(@wstring("ERROR: Failed to initialize Graphics Output Protocol."), {RED, BLACK})!!;
    } else {
        gop::draw_rect(
            {0, 0, 100, 200},
            {{0xff, 0x12, 0x34, 0x56}, {.a = 0xff, .r = 0xdd}} /* {r,g,b,a} */
        );
    }

    sys::@stall(s2us(3));   /* s2us == sec-to-microsec */
    sys::@reset(SHUTDOWN);
}

```


## TODOs
In no particular order...
- [ ] Finish C3 standard library integration, to provide helpful constructs like String formatting and such.
- [ ] Implement all macro exports for System, Console, etc.
- [ ] Organize library imports such that `uefi` isn't just bulk-imported everywhere.
- [ ] Unit/Integration testing.
    - Not sure if this will require a mock UEFI environment, or if it will need to be on a function-by-function basis. We'll see.
- [ ] Graphics library support and support functions .
    - [ ] e.g. an optional BLT-based framebuffer lib.
