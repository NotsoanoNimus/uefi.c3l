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
    MemoryType type = this.image_data_type
) {
    void *res;
    efi_error(gBS.allocate_pool(type, size, &res))!;

    return res;
}

fn void*! malloc(usz size) @export("malloc") @builtin => efi_sys.malloc(size);


fn void*! System.calloc(
    System *this,
    usz size,
    MemoryType type = this.image_data_type
) {
    void *p = this.malloc(size, type)!;

    this.memset(p, 0x00, size)!;

    return p;
}

fn void*! calloc(usz num, usz size) @export("calloc") @builtin => efi_sys.calloc(num * size);


fn void! System.memset(
    System *this,
    void *at,
    char value,
    usz length
) {
    if (null == at) return EfiError.INVALID_PARAMETER?;

    gBS.set_mem(at, length, value);
}

fn void! memset(void *at, char c, usz len) @export("memset") @builtin => efi_sys.memset(at, c, len);


fn void System.memcpy(
    System *this,
    void *to,
    void *from,
    usz length
) {
    if (null == to || null == from || 0 == length) return;

    gBS.copy_mem(to, from, length);
}

fn void memcpy(void *d, void *s, usz len) @export("memcpy") @builtin => efi_sys.memcpy(d, s, len);


fn void*! System.realloc(
    System *this,
    void *pool,
    usz prev_len,
    usz new_len
) {
    if (0 == new_len) {
        this.free(pool)!;
        return null;
    }

    void *new_pool = this.calloc(new_len)!;

    this.memcpy(new_pool, pool, @min(prev_len, new_len));
    this.free(pool)!;

    return new_pool;
}

fn void*! realloc(void *p, usz plen, usz nlen) @export("realloc") @builtin => efi_sys.realloc(p, plen, nlen);
