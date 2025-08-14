// ------------------------------------------------------------------
module uefi;
import uefi::efi_system @public;


extern fn void initialize_lib(EfiHandle, SystemTable*);

PanicFn panic_func = &uefi::efilib::pre_load::default_panic;



// ------------------------------------------------------------------
module uefi::io;
import uefi;
import uefi::efi_system @public;


// interface LibcFile
// {
//     //
// }
// typedef OutStream (LibcFile) = uptr;
// const OutStream STDERR @export("stderr") = (OutStream)efi_system::efi_sys.console.stderr;

macro EfiStatus? memdump(void *ptr, usz len, usz $align = 16) @maydiscard => efi_system::efi_sys.console.printn(a2w(efi_system::efi_sys.create_memdump(ptr, len, $align)));
macro EfiStatus? cmemdump(ConsoleColor color, void *ptr, usz len, usz $align = 16) @maydiscard => efi_system::efi_sys.console.cprintn(color, a2w(efi_system::efi_sys.create_memdump(ptr, len, $align)));

macro EfiStatus? wprint(EfiString str) @maydiscard => efi_system::efi_sys.console.print(str);
macro EfiStatus? wprintn(EfiString str) @maydiscard => efi_system::efi_sys.console.printn(str);
macro EfiStatus? wfprint(SimpleTextOutputProtocol *stream, EfiString str) @maydiscard => efi_system::efi_sys.console.print(str, stream);
macro EfiStatus? wfprintn(SimpleTextOutputProtocol *stream, EfiString str) @maydiscard => efi_system::efi_sys.console.printn(str, stream);
macro EfiStatus? wprinte(EfiString str, args...) @maydiscard => efi_system::efi_sys.console.printe(str, ...args);
macro EfiStatus? wfprinte(SimpleTextOutputProtocol *stream, EfiString str, args...) @maydiscard => efi_system::efi_sys.console.fprinte(stream, str, ...args);

macro EfiStatus? print(AsciiString str) @maydiscard => efi_system::efi_sys.console.print(a2w(str));
macro EfiStatus? printn(AsciiString str) @maydiscard => efi_system::efi_sys.console.printn(a2w(str));
macro EfiStatus? fprint(SimpleTextOutputProtocol *stream, AsciiString str) @maydiscard => efi_system::efi_sys.console.print(a2w(str), stream);
macro EfiStatus? fprintn(SimpleTextOutputProtocol *stream, AsciiString str) @maydiscard => efi_system::efi_sys.console.printn(a2w(str), stream);
macro EfiStatus? printe(AsciiString str, args...) @maydiscard => efi_system::efi_sys.console.printn(a2w(str), ...args);
macro EfiStatus? fprinte(SimpleTextOutputProtocol *stream, AsciiString str, args...) @maydiscard => efi_system::efi_sys.console.printn(stream, a2w(str), ...args);

macro EfiStatus? wcprint(ConsoleColor color, EfiString str) @maydiscard => efi_system::efi_sys.console.cprint(color, str);
macro EfiStatus? wcprintn(ConsoleColor color, EfiString str) @maydiscard => efi_system::efi_sys.console.cprintn(color, str);
macro EfiStatus? wcprinte(ConsoleColor color, EfiString str, args...) @maydiscard => efi_system::efi_sys.console.cprinte(color, str, ...args);
macro EfiStatus? cprint(ConsoleColor color, AsciiString str) @maydiscard => efi_system::efi_sys.console.cprint(color, a2w(str));
macro EfiStatus? cprintn(ConsoleColor color, AsciiString str) @maydiscard => efi_system::efi_sys.console.cprintn(color, a2w(str));
macro EfiStatus? cprinte(ConsoleColor color, AsciiString str, args...) @maydiscard => efi_system::efi_sys.console.cprinte(color, a2w(str), ...args);



// ------------------------------------------------------------------
module uefi::str;
import uefi;
import uefi::efi_system @public;


//



// ------------------------------------------------------------------
module uefi::console;
import uefi;
import uefi::efi_system @public;


macro void? clear_to(ConsoleColor color, bool preserve = false, bool reset_cursor = true) @maydiscard =>
    efi_system::efi_sys.console.clear(color, preserve, reset_cursor);
macro void? clear() @maydiscard => (void)(efi_error(efi_system::efi_sys.console.stdout.clear_screen(efi_system::efi_sys.console.stdout))!);



// ------------------------------------------------------------------
module uefi::sys;
import uefi;
import uefi::efi_system @public;


macro BootServices* bs() => efi_system::efi_sys.boot_services;
macro RuntimeServices* rs() => efi_system::efi_sys.runtime_services;
macro SystemTable* st() => efi_system::efi_sys.system_table;
macro EfiHandle image() => efi_system::efi_sys.image_handle;

macro SimpleTextOutputProtocol* stdout() => efi_system::efi_sys.console.stdout;
macro SimpleTextOutputProtocol* stderr() => efi_system::efi_sys.console.stderr;
macro any stdin() => !sys::stdin_extended() ? efi_system::efi_sys.console.stdin : efi_system::efi_sys.console.stdin_ex;
macro bool stdin_extended() => null != efi_system::efi_sys.console.stdin_ex;

macro void @stall(usz $duration) @builtin => efi_system::efi_sys.stall($duration);

macro void @reset(ResetType $type, EfiStatus code = SUCCESS, char[] buffer = {}) @noreturn @builtin
    => efi_system::efi_sys.reset($type, code, buffer);

macro void hang() @noreturn
{
    sys::@disable_watchdog();
    while (true) sys::@stall(500_000);
}
macro void halt() @noreturn => sys::hang();
fn void lock() @noreturn { while (true); }

macro void @panic($message) @builtin => efi_system::efi_sys.panic("[" +++ $$FILE +++ ":" +++ $$FUNC +++ ":" +++ $$LINE +++  "] PANIC!  " +++ $message);

macro bool? @set_watchdog(usz $seconds) @maydiscard => efi_system::efi_sys.set_watchdog_timer($seconds);
macro bool? @disable_watchdog() @maydiscard => efi_system::efi_sys.set_watchdog_timer(0);
macro bool? set_watchdog_full(usz seconds, ulong code = -1, usz data_size = 0, EfiStringRaw data = null) @maydiscard
    => efi_system::efi_sys.set_watchdog_timer(seconds, code, data_size, data);

macro ulong? get_next_monotonic_count() @maydiscard => efi_system::efi_sys.get_next_monotonic_count();

macro uint? get_crc32(void *data @noalias, usz data_size) => efi_system::efi_sys.calculate_crc32(data, data_size);

macro SystemMemoryMap*? get_memory_map() => efi_system::efi_sys.get_memory_map();


// ------------------------------------------------------------------
module uefi::mem;
import uefi;
import uefi::efi_system @public;


fn void* memcpy(void *into, void *from, usz length) @export("memcpy") @nostrip
{
    efi_system::efi_sys.memcpy(into, from, length);
    return into;
}

fn void memset(void *at, char value, usz length) @export("memset") @nostrip
    => efi_system::efi_sys.memset(at, value, length);

fn void* malloc(usz size) @export("malloc") @nostrip => efi_system::efi_sys.malloc(size)!!;
fn void* calloc(usz num, usz size) @export("calloc") @nostrip => efi_system::efi_sys.calloc(num, size)!!;

fn void* realloc(void *pool, usz prev_len, usz new_len) @export("realloc") @nostrip
    => efi_system::efi_sys.realloc(pool, prev_len, new_len)!!;

fn void free(void *pool) @export("free") @nostrip => efi_system::efi_sys.free(pool);
fn void? free_safe(void *pool) @export("free_safe") @nostrip => efi_system::efi_sys.free_safe(pool);


