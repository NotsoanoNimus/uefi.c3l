module uefi::efilib;
import uefi;


struct Console
{
    SimpleTextOutputProtocol *stdout;
    SimpleTextOutputProtocol *stderr;
    SimpleTextInputProtocol *stdin;
    SimpleTextInputExProtocol *stdin_ex;
}



// ---------------------------------------------------
module uefi::efilib::efi_console @private;
import uefi;
import uefi::efilib::pre_load @public;


fn Console*? new(EfiHandle image, SystemTable *st)
{
    if (!pre_load::initialized) return efi_error::EFILIB_UNINITIALIZED?;

    Console *new_console;
    efi_error(
        st.boot_services.allocate_pool(LOADER_DATA, Console.sizeof, &new_console)
    )!;

    new_console.stdout = st.conout;
    new_console.stderr = st.conerr;
    new_console.stdin = st.conin;

    // Attempt to initialize the extended input protocol. To do this, its handle must be pulled off of
    //   instances pre-loaded by the system's UEFI firmware.
    if (catch
        efi_error(st.boot_services.locate_protocol(&&guid::SIMPLE_TEXT_INPUT_EX_PROTOCOL, null, &new_console.stdin_ex))
    ) new_console.stdin_ex = null;

    return new_console;
}



// ---------------------------------------------------
module uefi::efilib;
import uefi;

fn EfiStatus? Console.print(&self, EfiString text, SimpleTextOutputProtocol *stream = null)
{
    if (null == (void *)stream) stream = self.stdout;
    efi_error(stream.output_string(stream, text))!;

    return SUCCESS;
}


fn EfiStatus? Console.printn(&self, EfiString text, SimpleTextOutputProtocol *stream = null)
{
    self.print(text, stream)!;

    ushort[3] nl = { '\r', '\n', 0 };
    return self.print((EfiString)&nl, stream)!;
}


fn EfiStatus? Console.cprint(&self, EfiString text, ConsoleColor color, SimpleTextOutputProtocol *stream = null)
{
    if (null == (void *)stream) stream = self.stdout;

    usz previous_attr = stream.mode.current_attribute;
    defer stream.set_attribute(stream, previous_attr);

    stream.set_attribute(stream, (usz)(char)color);
    return self.print(text, stream);
}


fn EfiStatus? Console.cprintn(&self, ConsoleColor color, EfiString text, SimpleTextOutputProtocol *stream = null)
{
    self.cprint(text, color, stream)!;

    ushort[3] nl = { '\r', '\n', 0x00 };
    return self.print((EfiString)&nl);
}


fn EfiStatus? Console.printe(&self, EfiString text, args... )
{
    EfiString formatted_text = _expandf(text, ...args)!;
    defer mem::free(formatted_text);

    return self.print(formatted_text);
}


fn EfiStatus? Console.fprinte(&self, SimpleTextOutputProtocol *stream, EfiString text, args...)
{
    EfiString formatted_text = _expandf(text, ...args)!;
    defer mem::free(formatted_text);

    return self.print(formatted_text, stream);
}


fn EfiStatus? Console.cprinte(&self, ConsoleColor color, EfiString text, args...)
{
    EfiString formatted_text = _expandf(text, ...args)!;
    defer mem::free(formatted_text);

    return self.cprint(formatted_text, color);
}


fn EfiStatus? Console.cfprinte(&self, ConsoleColor color, SimpleTextOutputProtocol *stream, EfiString text, args...)
{
    EfiString formatted_text = _expandf(text, ...args)!;
    defer mem::free(formatted_text);

    return self.cprint(formatted_text, color, stream);
}


fn void? Console.clear(&self, ConsoleColor color, bool preserve_attr = false, bool reset_cursor = true)
{
    char previous_attr = (char)(self.stdout.mode.current_attribute & 0xFF);

    efi_error(self.stdout.set_attribute(self.stdout, (usz)(char)color))!;
    self.stdout.clear_screen(self.stdout);

    /* Reinstate the old attribute if specified. */
    if (preserve_attr) efi_error(self.stdout.set_attribute(self.stdout, (usz)previous_attr))!;

    /* Reset the cursor position if specified. */
    if (reset_cursor) efi_error(self.stdout.set_cursor_position(self.stdout, 0, 0))!;
}

