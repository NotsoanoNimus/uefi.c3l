module uefi::proto::misc_bs;
import uefi;


/* 7.5) Miscellaneous Boot Services */
/* EFI_SET_WATCHDOG_TIMER (7.5.1) */
def FnSetWatchdogTimer = fn EfiStatus(usz, ulong, usz, EfiString);

/* EFI_STALL (7.5.2) */
def FnStall = fn EfiStatus(usz);

/* EFI_COPY_MEM (7.5.3) */
def FnCopyMem = fn void(void*, void*, usz);

/* EFI_SET_MEM (7.5.4) */
def FnSetMem = fn void(void*, usz, char);

/* EFI_GET_NEXT_MONOTONIC_COUNT (7.5.5) */
def FnGetNextMonotonicCount = fn EfiStatus(ulong*);

/* EFI_INSTALL_CONFIGURATION_TABLE (7.5.6) */
def FnInstallConfigurationTable = fn EfiStatus(EfiGuid*, void*);

/* EFI_CALCULATE_CRC32 (7.5.7) */
def FnCalculateCrc32 = fn EfiStatus(void*, usz, uint*);
