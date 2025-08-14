module uefi::proto::memory;
import uefi;


/* 7.2.) Memory Allocation Services */

/* EFI_ALLOCATE_PAGES (7.2.1) and Allocation definitions */
alias FnAllocatePages = fn EfiStatus(AllocateType, MemoryType, usz, PhysicalAddress*);

alias PhysicalAddress = ulong;
alias VirtualAddress = ulong;
enum AllocateType
{
    ANY_PAGES,
    MAX_ADDRESS,
    ADDRESS,
    LIMIT
}
enum MemoryType : uint
{
    RESERVED,
    LOADER_CODE,
    LOADER_DATA,
    BOOT_SERVICES_CODE,
    BOOT_SERVICES_DATA,
    RUNTIME_SERVICES_CODE,
    RUNTIME_SERVICES_DATA,
    CONVENTIONAL,
    UNUSABLE,
    ACPI_RECLAIM,
    ACPI_NVS,
    MMIO,
    MMIO_PORT_SPACE,
    PAL_CODE,
    PERSISTENT,
    UNACCEPTED,
    LIMIT
}

/* EFI_FREE_PAGES (7.2.2) */
alias FnFreePages = fn EfiStatus(PhysicalAddress, usz);

/* EFI_GET_MEMORY_MAP (7.2.3) and related definitions */
alias FnGetMemoryMap = fn EfiStatus(usz*, void*, usz*, usz*, uint*);

const uint MEMORY_DESCRIPTOR_VERSION    = 1;
struct MemoryDescriptor
{
    MemoryType          type;
    PhysicalAddress     physical_start;
    VirtualAddress      virtual_start;
    ulong               num_pages;
    MemoryAttribute     attribute;
}

struct SystemMemoryMap
{
    usz map_key;
    usz buffer_size;
    usz descriptor_size;
    uint descriptor_version;
    void *descriptors;
    usz descriptors_count;
}

typedef MemoryAttribute = ulong;
const MemoryAttribute MEMORY_UC                 = 0x0000_0000_0000_0001;
const MemoryAttribute MEMORY_WC                 = 0x0000_0000_0000_0002;
const MemoryAttribute MEMORY_WT                 = 0x0000_0000_0000_0004;
const MemoryAttribute MEMORY_WB                 = 0x0000_0000_0000_0008;
const MemoryAttribute MEMORY_UCE                = 0x0000_0000_0000_0010;
const MemoryAttribute MEMORY_WP                 = 0x0000_0000_0000_1000;
const MemoryAttribute MEMORY_RP                 = 0x0000_0000_0000_2000;
const MemoryAttribute MEMORY_XP                 = 0x0000_0000_0000_4000;
const MemoryAttribute MEMORY_NV                 = 0x0000_0000_0000_8000;
const MemoryAttribute MEMORY_MORE_RELIABLE      = 0x0000_0000_0001_0000;
const MemoryAttribute MEMORY_RO                 = 0x0000_0000_0002_0000;
const MemoryAttribute MEMORY_SP                 = 0x0000_0000_0004_0000;
const MemoryAttribute MEMORY_CPU_CRYPTO         = 0x0000_0000_0008_0000;
const MemoryAttribute MEMORY_HOT_PLUGGABLE      = 0x0000_0000_0010_0000;
const MemoryAttribute MEMORY_RUNTIME            = 0x8000_0000_0000_0000;
const MemoryAttribute MEMORY_ISA_VALID          = 0x4000_0000_0000_0000;
const MemoryAttribute MEMORY_ISA_MASK           = 0x0FFF_F000_0000_0000;

/* EFI_ALLOCATE_POOL (7.2.4) */
alias FnAllocatePool = fn EfiStatus(MemoryType, usz, void**);

/* EFI_FREE_POOL (7.2.5) */
alias FnFreePool = fn EfiStatus(void*);


/* 8.4.) Virtual Memory services */
/* 8.4.1.) SetVirtualAddressMap() */
alias FnSetVirtualAddressMap = fn EfiStatus(usz, usz, uint, MemoryDescriptor*);

/* 8.4.2.) ConvertPointer() */
alias FnConvertPointer = fn EfiStatus(usz, void**);
const usz EFI_OPTIONAL_PTR = 0x1;

/* 8.5.3.3.) Items related to capsules */
struct MemoryRange
{
    PhysicalAddress     address;
    ulong               length;
}
