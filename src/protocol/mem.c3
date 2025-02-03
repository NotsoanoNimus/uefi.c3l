module uefi::proto::mem;
import uefi;


/* 7.2.) Memory Allocation Services */

/* EFI_ALLOCATE_PAGES (7.2.1) and Allocation definitions */
def FnAllocatePages = fn EfiStatus(AllocateType, MemoryType, usz, PhysicalAddress*);

def PhysicalAddress = ulong;
def VirtualAddress = ulong;
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
def FnFreePages = fn EfiStatus(PhysicalAddress, usz);

/* EFI_GET_MEMORY_MAP (7.2.3) and related definitions */
def FnGetMemoryMap = fn EfiStatus(usz*, MemoryDescriptor*, usz*, usz*, uint*);

const uint MEMORY_DESCRIPTOR_VERSION    = 1;
struct MemoryDescriptor
{
    MemoryType          type;
    PhysicalAddress     physical_start;
    VirtualAddress      virtual_start;
    ulong               num_pages;
    MemoryAttribute     attribute;
}

distinct MemoryAttribute = ulong;

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
def FnAllocatePool = fn EfiStatus(MemoryType, usz, void**);

/* EFI_FREE_POOL (7.2.5) */
def FnFreePool = fn EfiStatus(void*);
