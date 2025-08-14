module uefi::proto::misc_rt;
import uefi;


/* 8.5.) Miscellaneous Runtime services */
/* 8.5.1.1.) ResetSystem() */
alias FnResetSystem = fn void(ResetType, EfiStatus, usz, void*);

enum ResetType : uint
{
    COLD,
    WARM,
    SHUTDOWN,
    PLATFORM_SPECIFIC,
}

/* 8.5.2.1.) GetNextHighMonotonicCount() */
alias FnGetNextHighMonotonicCount = fn EfiStatus(uint*);

/* 8.5.3.1.) UpdateCapsule() and related */
alias FnUpdateCapsule = fn EfiStatus(CapsuleHeader**, usz, PhysicalAddress);

struct CapsuleHeader
{
    EfiGuid     capsule_guid;
    uint        header_size;
    uint        flags;
    uint        capsule_image_size;
}

enum CapsuleFlags : uint (uint raw)
{
    PERSIST_ACROSS_RESET        = 0x0001_0000,
    POPULATE_SYSTEM_TABLE       = 0x0002_0000,
    INITIATE_RESET              = 0x0004_0000,
}

struct CapsuleBlockDescriptor
{
    ulong       length;
    union
    {
        PhysicalAddress data_block;
        PhysicalAddress continuation_pointer;
    }
}

struct CapsuleTable
{
    uint        capsule_array_number;
    void        *capsule_ptr;
}

const EfiGuid EFI_MEMORY_RANGE_CAPSULE_GUID =
    { 0xde9f0ec, 0x88b6, 0x428f, {0x97,0x7a,0x25,0x8f,0x1d,0xe,0x5e,0x72} };

struct MemoryRangeCapsule
{
    CapsuleHeader       header;
    uint                requested_memory_type;
    ulong               num_memory_ranges;
    MemoryRange         *memory_ranges;
}

struct MemoryRangeCapsuleResult
{
    ulong       firmware_memory_requirement;
    ulong       num_memory_ranges;
}

/* 8.5.3.4.) QueryCapsuleCapabilities() */
alias FnQueryCapsuleCapabilities = fn EfiStatus(CapsuleHeader**, usz, ulong*, ResetType*);

/* OS Indications from a nearby section */
enum OsIndications : ulong (ulong raw)   // TODO: Change to inline ulong once supported
{
    BOOT_TO_FW_UI                       = 0x1,
    TIMESTAMP_REVOCATION                = 0x2,
    FILE_CAPSULE_DELIVERY_SUPPORTED     = 0x4,
    FMP_CAPSULE_SUPPORTED               = 0x8,
    CAPSULE_RESULT_VAR_SUPPORTED        = 0x10,
    START_OS_RECOVERY                   = 0x20,
    START_PLATFORM_RECOVERY             = 0x40,
    JSON_CONFIG_DATA_REFRESH            = 0x80,
}

/* 8.5.6.1.) -- */
const EfiGuid EFI_CAPSULE_REPORT_GUID =
    { 0x39b68c46, 0xf7fb, 0x441b, {0xb6,0xec,0x16,0xb0,0xf6,0x98,0x21,0xf3} };

struct CapsuleResultVariableHeader
{
    uint        variable_total_size;
    uint        reserved;   /* spec says 'alignment' */
    EfiGuid     capsule_guid;
    EfiTime     capsule_processed_at;
    EfiStatus   capsule_status;
}

struct CapsuleResultVariableFMP
{
    ushort      version;
    char        payload_index;
    char        update_image_index;
    EfiGuid     update_image_type_id;
    /* implied:  EfiStringRaw capsule_file_name */
    /* implied:  EfiStringRaw capsule_target */
}

struct CapsuleResultVariableJson
{
    uint        version;
    uint        capsule_id;
    uint        response_length;
    char        *response_data;
}
