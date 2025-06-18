module uefi::proto::misc_bs;
import uefi;


/* 7.5) Miscellaneous Boot Services */
/* EFI_SET_WATCHDOG_TIMER (7.5.1) */
alias FnSetWatchdogTimer = fn EfiStatus(usz, ulong, usz, EfiStringRaw);

/* EFI_STALL (7.5.2) */
alias FnStall = fn EfiStatus(usz);

/* EFI_COPY_MEM (7.5.3) */
alias FnCopyMem = fn void(void*, void*, usz);

/* EFI_SET_MEM (7.5.4) */
alias FnSetMem = fn void(void*, usz, char);

/* EFI_GET_NEXT_MONOTONIC_COUNT (7.5.5) */
alias FnGetNextMonotonicCount = fn EfiStatus(ulong*);

/* EFI_INSTALL_CONFIGURATION_TABLE (7.5.6) */
alias FnInstallConfigurationTable = fn EfiStatus(EfiGuid*, void*);

/* EFI_CALCULATE_CRC32 (7.5.7) */
alias FnCalculateCrc32 = fn EfiStatus(void*, usz, uint*);
