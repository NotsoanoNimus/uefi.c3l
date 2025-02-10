module uefi::efilib;
import uefi;


struct Console
{
    SimpleTextOutputProtocol *stdout;
    SimpleTextOutputProtocol *stderr;
    SimpleTextInputProtocol *stdin;
}


bitstruct ConsoleColor : char
{
    TextColor background: 0..3;
    TextColor foreground: 4..7;   /* NOTE: bit '7' is technically not used per spec */
}


// ---------------------------------------------------
module uefi::efilib::efi_console;
import uefi;

fn Console*! new()
{
    if (!efilib::initialized) return EfiError.EFILIB_UNINITIALIZED?;

    Console *new_console;
    efi_error(
        gBS.allocate_pool(LOADER_DATA, Console.sizeof, &new_console)
    )!;

    new_console.stdout = gST.conout;
    new_console.stderr = gST.conerr;
    new_console.stdin = gST.conin;

    return new_console;
}


// ---------------------------------------------------
module uefi::efilib;
import uefi;

fn EfiStatus! Console.print(
    Console *this,
    EfiString text,
    SimpleTextOutputProtocol *stream = null
) {
    if (null == (void *)stream) stream = this.stdout;
    efi_error(stream.output_string(stream, text))!;

    return SUCCESS;
}


fn void! Console.cprint(
    Console *this,
    EfiString text,
    ConsoleColor color,
    SimpleTextOutputProtocol *stream = null
) {
    if (null == (void *)stream) stream = this.stdout;

    usz previous_attr = stream.mode.current_attribute;

    stream.set_attribute(stream, (usz)(char)color);
    EfiStatus! status = this.print(text, stream);
    stream.set_attribute(stream, previous_attr);
}


fn void! Console.cprintln(
    Console *this,
    EfiString text,
    ConsoleColor color,
    SimpleTextOutputProtocol *stream = null
) {
    this.cprint(text, color, stream)!;

    ushort[3] nl = {'\r', '\n', 0x00};
    this.print((EfiString)&nl)!;
}


fn EfiStatus! Console.printf(
    Console *this,
    EfiString text,
    args...
) {
    // TODO.
    return this.print(text);
}


fn void! Console.clear(
    Console *this,
    ConsoleColor color,
    bool preserve_attr = false,
    bool reset_cursor = true
) {
    char previous_attr = (char)(this.stdout.mode.current_attribute & 0xFF);

    efi_error(this.stdout.set_attribute(this.stdout, (usz)(char)color))!;
    this.stdout.clear_screen(this.stdout);

    /* Reinstate the old attribute if specified. */
    if (preserve_attr) efi_error(this.stdout.set_attribute(this.stdout, (usz)previous_attr))!;

    /* Reset the cursor position if specified. */
    if (reset_cursor) efi_error(this.stdout.set_cursor_position(this.stdout, 0, 0))!;
}
