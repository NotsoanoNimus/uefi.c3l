module uefi::efilib;
import uefi;


struct System
{
    Console                     *console;
    //LoadedImageProtocol         image_info;
MemoryType image_data_type;
}


// ---------------------------------------------------
module uefi::efi_system;
import uefi;

fn System*? new()
{
    if (!efilib::initialized) return efi_error::EFILIB_UNINITIALIZED?;

    System *new_system;
    efi_error(
        gBS.allocate_pool(LOADER_CODE, System.sizeof, &new_system)
    )!;

    new_system.console = efi_console::new()!;

    return new_system;
}


// ---------------------------------------------------
module uefi::efilib;
import uefi;

fn void System.reset(
    System *this,
    ResetType type,
    EfiStatus code = SUCCESS,
    char[] buffer = {}
) @noreturn {
    gRS.reset_system(type, code, buffer.len, buffer.ptr);
}

fn void reset(ResetType type, EfiStatus code = SUCCESS, char[] buffer = {})
    @export("reset") @builtin @noreturn
    => efi_sys.reset(type, code, buffer);


fn void System.stall(
    System *this,
    usz duration
) {
    gBS.stall(duration);
}

fn void stall(usz duration) @export("stall") @builtin => efi_sys.stall(duration);


fn void System.free(
    System *this,
    void *pool
) {
    if (null != pool) gBS.free_pool(pool);
}

fn void free(void *pool) @export("free") @builtin => efi_sys.free(pool);


fn void? System.free_safe(&self, void *pool)
{
    if (null != pool) efi_error(gBS.free_pool(pool))!;
}

fn void? free_safe(void *pool) @export("free_safe") @builtin => efi_sys.free_safe(pool);


fn void*? System.malloc(&self, usz size, MemoryType type = LIMIT)
{
    if (LIMIT == type) type = self.image_data_type;

    void *res;
    efi_error(gBS.allocate_pool(type, size, &res))!;

    return res;
}

fn void*? malloc(usz size) @export("malloc") @builtin => efi_sys.malloc(size);


fn void*? System.calloc(
    System *this,
    usz size,
    usz length,
    MemoryType type = LIMIT
) {
    if (LIMIT == type) type = this.image_data_type;

    void *p = this.malloc(size * length, type)!;
    this.memset(p, 0x00, size * length);

    return p;
}

fn void*? calloc(usz num, usz size) @export("calloc") @builtin => efi_sys.calloc(size, num);


fn void*? System.realloc(
    System *this,
    void *pool,
    usz prev_len,
    usz new_len
) {
    if (0 == new_len) {
        this.free(pool);
        return null;
    }

    void *new_pool = this.calloc(1, new_len)!;

    if (null != pool) {
        this.memcpy(new_pool, pool, @min(prev_len, new_len));
        this.free(pool);
    }

    return new_pool;
}

fn void*? realloc(void *pool, usz prev_len, usz new_len) @export("realloc") @builtin => efi_sys.realloc(pool, prev_len, new_len);


fn AsciiString? System.create_memdump(
    System *this,
    void *at,
    usz len,
    usz align = 16
) {
    if (null == at || 0 == len) return efi_error::INVALID_PARAMETER?;

    AsciiString ret = slice_from_raw(calloc(char.sizeof, (len * 3) + 1)!, (len * 3) + 1);

    for (usz i = 0; i < len; ++i) {
        char c = *((char *)((usz)at + i));
        char high_nibble = (c & 0xF0) >> 4;
        char low_nibble = c & 0x0F;

        ret[(i * 3) + 0] = high_nibble + (high_nibble >= 10 ? ('A' - 10) : '0');
        ret[(i * 3) + 1] = low_nibble + (low_nibble >= 10 ? ('A' - 10) : '0');
        ret[(i * 3) + 2] = ((i+1) % align) ? ' ' : '\n';
    }

    ret[len * 3] = '\0';   // paranoia
    return ret;
}

fn AsciiString? memdump(void *at, usz len) @export("memdump") @builtin => efi_sys.create_memdump(at, len);


// NOTE: Do not export these functions, since the 'adapter' covers them.
fn void System.memset(
    System *this,
    void *at,
    char value,
    usz length
) {
    if (null == at) return;

    gBS.set_mem(at, length, value);
}

fn void memset(void *at, char value, usz length) @export("memset") @builtin => efi_sys.memset(at, value, length);


fn void System.memcpy(
    System *this,
    void *to,
    void *from,
    usz length
) {
    if (null == to || null == from || 0 == length) return;

    gBS.copy_mem(to, from, length);
}

fn void *memcpy(void *into, void *from, usz length) @export("memcpy") @builtin
{
    efi_sys.memcpy(into, from, length);
    return into;
}
