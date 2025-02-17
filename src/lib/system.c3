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

fn System*! new()
{
    if (!efilib::initialized) return EfiError.EFILIB_UNINITIALIZED?;

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


fn void! System.free_safe(
    System *this,
    void *pool
) {
    if (null != pool) efi_error(gBS.free_pool(pool))!;
}

fn void! free_safe(void *pool) @export("free_safe") @builtin => efi_sys.free_safe(pool);


fn void*! System.malloc(
    System *this,
    usz size,
    MemoryType type = LIMIT
) {
    if (LIMIT == type) type = this.image_data_type;

    void *res;
    efi_error(gBS.allocate_pool(type, size, &res))!;

    return res;
}

fn void*! malloc(usz size) @export("malloc") @builtin => efi_sys.malloc(size);


fn void*! System.calloc(
    System *this,
    usz size,
    MemoryType type = LIMIT
) {
    if (LIMIT == type) type = this.image_data_type;

    void *p = this.malloc(size, type)!;
    this.memset(p, 0x00, size);

    return p;
}

fn void*! calloc(usz num, usz size) @export("calloc") @builtin => efi_sys.calloc(num * size);


fn void*! System.realloc(
    System *this,
    void *pool,
    usz prev_len,
    usz new_len
) {
    if (0 == new_len) {
        this.free(pool);
        return null;
    }

    void *new_pool = this.calloc(new_len)!;

    this.memcpy(new_pool, pool, @min(prev_len, new_len));
    this.free(pool);

    return new_pool;
}

fn void*! realloc(void *pool, usz prev_len, usz new_len) @export("realloc") => efi_sys.realloc(pool, prev_len, new_len);


fn AsciiString! System.create_memdump(
    System *this,
    void *at,
    usz len,
    usz align = 16
) {
    if (null == at || 0 == len) return EfiError.INVALID_PARAMETER?;

    AsciiString ret = (AsciiString)calloc(char.sizeof, (len * 3) + 1)!;

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

fn AsciiString! memdump(void *at, usz len) @export("memdump") @builtin => efi_sys.create_memdump(at, len);


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


fn void System.memcpy(
    System *this,
    void *to,
    void *from,
    usz length
) {
    if (null == to || null == from || 0 == length) return;

    gBS.copy_mem(to, from, length);
}
