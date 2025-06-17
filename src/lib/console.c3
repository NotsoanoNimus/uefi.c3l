module uefi::efilib;
import uefi;


struct Console
{
    SimpleTextOutputProtocol *stdout;
    SimpleTextOutputProtocol *stderr;
    SimpleTextInputProtocol *stdin;
}


bitstruct ConsoleColor : char @bigendian
{
    TextColor background: 0..3;
    TextColor foreground: 4..7;   /* NOTE: bit '7' is technically not used per spec */
}


// ---------------------------------------------------
module uefi::efilib::efi_console;
import uefi;

fn Console*? new()
{
    if (!efilib::initialized) return efi_error::EFILIB_UNINITIALIZED?;

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

fn EfiStatus? Console.print(
    Console *this,
    EfiString text,
    SimpleTextOutputProtocol *stream = null
) {
    if (null == (void *)stream) stream = this.stdout;
    efi_error(stream.output_string(stream, text))!;

    return SUCCESS;
}


fn EfiStatus? Console.printn(
    Console *this,
    EfiString text,
    SimpleTextOutputProtocol *stream = null
) {
    this.print(text, stream)!;

    ushort[3] nl = { '\r', '\n', 0 };
    return this.print((EfiString)&nl, stream)!;
}


fn EfiStatus? Console.cprint(
    Console *this,
    EfiString text,
    ConsoleColor color,
    SimpleTextOutputProtocol *stream = null
) {
    if (null == (void *)stream) stream = this.stdout;

    usz previous_attr = stream.mode.current_attribute;

    stream.set_attribute(stream, (usz)(char)color);
    EfiStatus? status = this.print(text, stream);
    stream.set_attribute(stream, previous_attr);

    return status;
}


fn EfiStatus? Console.cprintn(
    Console *this,
    EfiString text,
    ConsoleColor color,
    SimpleTextOutputProtocol *stream = null
) {
    this.cprint(text, color, stream)!;

    ushort[3] nl = { '\r', '\n', 0x00 };
    return this.print((EfiString)&nl);
}


fn EfiStatus? Console.printf(
    Console *this,
    EfiString text,
    args...
) {
    EfiString formatted_text = _printf(text, args)!;
    defer free(formatted_text);

    return this.print(formatted_text);
}


fn EfiStatus? Console.fprintf(
    Console *this,
    SimpleTextOutputProtocol *stream,
    EfiString text,
    args...
) {
    EfiString formatted_text = _printf(text, args)!;
    defer free(formatted_text);

    return this.print(formatted_text, stream);
}


fn EfiStatus? Console.cprintf(
    Console *this,
    ConsoleColor color,
    EfiString text,
    args...
) {
    EfiString formatted_text = _printf(text, args)!;
    defer free(formatted_text);

    return this.cprint(formatted_text, color);
}


fn EfiStatus? Console.cfprintf(
    Console *this,
    ConsoleColor color,
    SimpleTextOutputProtocol *stream,
    EfiString text,
    args...
) {
    EfiString formatted_text = _printf(text, args)!;
    defer free(formatted_text);

    return this.cprint(formatted_text, color, stream);
}


fn EfiStatus? Console.printe(
    Console *this,
    EfiString text,
    args...
) {
    EfiString formatted_text = _expandf(text, args)!;
    defer free(formatted_text);

    return this.print(formatted_text);
}


fn EfiStatus? Console.fprinte(
    Console *this,
    SimpleTextOutputProtocol *stream,
    EfiString text,
    args...
) {
    EfiString formatted_text = _expandf(text, args)!;
    defer free(formatted_text);

    return this.print(formatted_text, stream);
}


fn EfiStatus? Console.cprinte(
    Console *this,
    ConsoleColor color,
    EfiString text,
    args...
) {
    EfiString formatted_text = _expandf(text, args)!;
    defer free(formatted_text);

    return this.cprint(formatted_text, color);
}


fn EfiStatus? Console.cfprinte(
    Console *this,
    ConsoleColor color,
    SimpleTextOutputProtocol *stream,
    EfiString text,
    args...
) {
    EfiString formatted_text = _expandf(text, args)!;
    defer free(formatted_text);

    return this.cprint(formatted_text, color, stream);
}


fn void? Console.clear(
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
