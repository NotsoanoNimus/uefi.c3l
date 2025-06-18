module uefi::efilib;
import uefi;


struct System
{
    Console                     *console;
    EfiHandle                   image_handle;
    SystemTable                 *system_table;
    BootServices                *boot_services;
    RuntimeServices             *runtime_services;
    // TODO: What's going on here?
    //LoadedImageProtocol         image_info;
    MemoryType image_data_type;
}



// ---------------------------------------------------
module uefi::efi_system @private;
import uefi;
import uefi::efilib::efi_console @public;
import uefi::efilib::pre_load @public;


System *efi_sys @private = null;


fn System*? new(EfiHandle image, SystemTable *st)
{
    if (!pre_load::initialized) return efi_error::EFILIB_UNINITIALIZED?;

    System *new_system = null;
    efi_error(
        st.boot_services.allocate_pool(LOADER_CODE, System.sizeof, &new_system)
    )!;

    if (null == new_system) return efi_error::OUT_OF_RESOURCES?;

    new_system.system_table = st;

    new_system.boot_services = st.boot_services;
    new_system.runtime_services = st.runtime_services;

    new_system.image_handle = image;

    new_system.console = efi_console::new(image, st)!;

    return new_system;
}



// ---------------------------------------------------
module uefi::efilib;
import uefi;


fn void System.reset(&self, ResetType type, EfiStatus code = SUCCESS, char[] buffer = {})
    @export("reset") @noreturn
{
    self.runtime_services.reset_system(type, code, buffer.len, buffer.ptr);
}


fn void System.stall(&self, usz duration) => self.boot_services.stall(duration);


fn bool? System.set_watchdog_timer(&self, usz timer_seconds, ulong code = -1, usz data_size = 0, EfiStringRaw data = null)
    => efi_error(self.boot_services.set_watchdog_timer(timer_seconds, code, data_size, data));


fn ulong? System.get_next_monotonic_count(&self)
{
    ulong count_value = 0;

    efi_error(self.boot_services.get_next_monotonic_count(&count_value))!;

    return count_value;
}

fn uint? System.calculate_crc32(&self, void *data @noalias, usz data_size)
{
    uint result = 0;

    efi_error(self.boot_services.calculate_crc32(data, data_size, &result))!;

    return result;
}


fn void System.free(&self, void *pool)
    @export("free")
{
    if (null != pool) self.boot_services.free_pool(pool);
}


fn void? System.free_safe(&self, void *pool)
    @export("free_safe") 
{
    if (null != pool) efi_error(self.boot_services.free_pool(pool))!;
}


fn void*? System.malloc(&self, usz size, MemoryType type = LIMIT)
    @export("malloc")
{
    if (LIMIT == type) type = self.image_data_type;

    void *res;
    efi_error(self.boot_services.allocate_pool(type, size, &res))!;

    return res;
}


fn void*? System.calloc(&self, usz size, usz length, MemoryType type = LIMIT)
    @export("calloc")
{
    if (LIMIT == type) type = self.image_data_type;

    void *p = self.malloc(size * length, type)!;
    self.memset(p, 0x00, size * length);

    return p;
}


fn void*? System.realloc(&self, void *pool, usz prev_len, usz new_len)
    @export("realloc")
{
    if (0 == new_len) {
        self.free(pool);
        return null;
    }

    void *new_pool = self.calloc(1, new_len)!;

    if (null != pool) {
        self.memcpy(new_pool, pool, @min(prev_len, new_len));
        self.free(pool);
    }

    return new_pool;
}


fn void System.memset(&self, void *at, char value, usz length)
    @export("memset")
{
    if (null == at || 0 == length) return;

    self.boot_services.set_mem(at, length, value);
}


fn void System.memcpy(&self, void *to, void *from, usz length)
    @export("memcpy")
{
    if (null == to || null == from || 0 == length) return;

    self.boot_services.copy_mem(to, from, length);
}


fn AsciiString? System.create_memdump(&self, void *at, usz len, usz align = 16)
{
    if (null == at || 0 == len) return efi_error::INVALID_PARAMETER?;

    AsciiString ret = slice_from_raw(self.calloc(char.sizeof, (len * 3) + 1)!, (len * 3) + 1);

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
