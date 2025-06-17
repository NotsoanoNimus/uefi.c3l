module uefi::proto::evt;
import uefi;


/* 7.1.) Event, Timer, and Task Priority Services */
/* NOTE: EfiEvent is defined in ../def.c3, as it's more globally used. */
typedef EventType = uint;
const EventType EVT_TIMER               = 0x8000_0000;
const EventType EVT_RUNTIME             = 0x4000_0000;
const EventType EVT_NOTIFY_WAIT         = 0x0000_0100;
const EventType EVT_NOTIFY_SIGNAL       = 0x0000_0200;
const EventType EVT_SIGNAL_EXIT_BOOT_SERVICES        = 0x0000_0201;
const EventType EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE    = 0x6000_0202;


/* EFI_EVENT_NOTIFY (7.1.1) */
alias FnEventNotify = fn void(EfiEvent, void*);

/* EFI_CREATE_EVENT (7.1.1) */
alias FnCreateEvent = fn EfiStatus(EventType, EventTpl, FnEventNotify, void*, EfiEvent*);

/* EFI_CREATE_EVENT_EX (7.1.2) */
alias FnCreateEventEx = fn EfiStatus(EventType, EventTpl, FnEventNotify, void*, EfiGuid*, EfiEvent*);

/* EFI event group GUIDs (7.1.2) */
const EfiGuid EVENT_GROUP_EXIT_BOOT_SERVICES =
    { 0x27abf055, 0xb1b8, 0x4c26, {0x80,0x48,0x74,0x8f,0x37,0xba,0xa2,0xdf} };
const EfiGuid EVENT_GROUP_BEFORE_EXIT_BOOT_SERVICES =
    { 0x8be0e274, 0x3970, 0x4b44, {0x80,0xc5,0x1a,0xb9,0x50,0x2f,0x3b,0xfc} };
const EfiGuid EVENT_GROUP_VIRTUAL_ADDRESS_CHANGE =
    { 0x13fa7698, 0xc831, 0x49c7, {0x87,0xea,0x8f,0x43,0xfc,0xc2,0x51,0x96} };
const EfiGuid EVENT_GROUP_MEMORY_MAP_CHANGE =
    { 0x78bee926, 0x692f, 0x48fd, {0x9e,0xdb,0x01,0x42,0x2e,0xf0,0xd7,0xab} };
const EfiGuid EVENT_GROUP_READY_TO_BOOT =
    { 0x7ce88fb3, 0x4bd7, 0x4679, {0x87,0xa8,0xa8,0xd8,0xde,0xe5,0x0d,0x2b} };
const EfiGuid EVENT_GROUP_AFTER_READY_TO_BOOT =
    { 0x3a2a00ad, 0x98b9, 0x4cdf, {0xa4,0x78,0x70,0x27,0x77,0xf1,0xc1,0x0b} };
const EfiGuid EVENT_GROUP_RESET_SYSTEM =
    { 0x62da6a56, 0x13fb, 0x485a, {0xa8,0xda,0xa3,0xdd,0x79,0x12,0xcb,0x6b} };

/* EFI_CLOSE_EVENT (7.1.3) */
alias FnCloseEvent = fn EfiStatus(EfiEvent);

/* EFI_SIGNAL_EVENT (7.1.4) */
alias FnSignalEvent = fn EfiStatus(EfiEvent);

/* EFI_WAIT_FOR_EVENT (7.1.5) */
alias FnWaitForEvent = fn EfiStatus(usz, EfiEvent*, usz*);

/* EFI_CHECK_EVENT (7.1.6) */
alias FnCheckEvent = fn EfiStatus(EfiEvent);

/* EFI_SET_TIMER (7.1.7) and EFI_TIMER_DELAY */
alias FnSetTimer = fn EfiStatus(EfiEvent, TimerDelay, ulong);

enum TimerDelay
{
    TIMER_CANCEL,
    TIMER_PERIODIC,
    TIMER_RELATIVE,
}

/* EFI_RAISE_TPL (7.1.8) and TPL */
alias FnRaiseTpl = fn EventTpl(EventTpl);

typedef EventTpl  = usz;
const EventTpl TPL_APPLICATION  = 4;
const EventTpl TPL_CALLBACK     = 8;
const EventTpl TPL_NOTIFY       = 16;
const EventTpl TPL_HIGH_LEVEL   = 31;

/* EFI_RESTORE_TPL (7.1.9) */
alias FnRestoreTpl = fn void(EventTpl);
