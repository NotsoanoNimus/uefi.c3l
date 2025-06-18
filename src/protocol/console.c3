module uefi::proto::console;
import uefi;


/*
 *
 */
bitstruct ConsoleColor : char @bigendian
{
    TextColor background: 0..3;
    TextColor foreground: 4..7;   /* NOTE: bit '7' is technically not used per spec */
}


/* 12.1.) Console I/O Protocol (Scan Codes - see Appendix B, Table B.1) */
enum ScanCode : ushort (inline ushort raw)
{
    NULL            = 0x0000,
    UP_ARROW        = 0x0001,
    DOWN_ARROW      = 0x0002,
    RIGHT_ARROW     = 0x0003,
    LEFT_ARROW      = 0x0004,
    HOME            = 0x0005,
    END             = 0x0006,
    INSERT          = 0x0007,
    DELETE          = 0x0008,
    PAGE_UP         = 0x0009,
    PAGE_DOWN       = 0x000A,
    F1              = 0x000B,
    F2              = 0x000C,
    F3              = 0x000D,
    F4              = 0x000E,
    F5              = 0x000F,
    F6              = 0x0010,
    F7              = 0x0011,
    F8              = 0x0012,
    F9              = 0x0013,
    F10             = 0x0014,
    F11             = 0x0015,
    F12             = 0x0016,
    ESCAPE          = 0x0017,
    PAUSE           = 0x0048,
    F13             = 0x0068,
    F14             = 0x0069,
    F15             = 0x006A,
    F16             = 0x006B,
    F17             = 0x006C,
    F18             = 0x006D,
    F19             = 0x006E,
    F20             = 0x006F,
    F21             = 0x0070,
    F22             = 0x0071,
    F23             = 0x0072,
    F24             = 0x0073,
    MUTE            = 0x007F,
    VOLUME_UP       = 0x0080,
    VOLUME_DOWN     = 0x0081,
    BRIGHTNESS_UP   = 0x0100,
    BRIGHTNESS_DOWN = 0x0101,
    SUSPEND         = 0x0102,
    HIBERNATE       = 0x0103,
    TOGGLE_DISPLAY  = 0x0104,
    RECOVERY        = 0x0105,
    EJECT           = 0x0106,
}


/* 12.3.) Simple Text Input Protocol */
module uefi::guid;
const EfiGuid SIMPLE_TEXT_INPUT_PROTOCOL =
    { 0x387477c1, 0x69c7, 0x11d2, {0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b} };
const EfiGuid SIMPLE_TEXT_INPUT_EX_PROTOCOL =
    { 0xdd9e7534, 0x7762, 0x4698, {0x8c,0x14,0xf5,0x85,0x17,0xa6,0x25,0xaa} };

module uefi::proto::console;
struct SimpleTextInputProtocol
{
    FnInputReset        reset;
    FnInputReadKey      read_key;
    EfiEvent            event_wait_for_key;
}

struct EfiInputKey
{
    ushort      scan_code;
    ushort      unicode_char;
}

alias FnInputReset = fn EfiStatus(SimpleTextInputProtocol*, bool);
alias FnInputReadKey = fn EfiStatus(SimpleTextInputProtocol*, EfiInputKey*);


/* 12.2.) Simple Text Input Ex Protocol */
struct SimpleTextInputExProtocol
{
    FnInputResetEx                      reset;
    FnInputReadKeyEx                    read_key;
    EfiEvent                            event_wait_for_key;
    FnInputSetState                     set_state;
    FnInputRegisterKeystrokeNotify      register_keystroke_notify;
    FnInputUnregisterKeystrokeNotify    unregister_keystroke_notify;
}

enum KeyShiftState : uint (inline uint raw)
{
    SHIFT_STATE_VALID       = 0x8000_0000,
    RIGHT_SHIFT_PRESSED     = 0x0000_0001,
    LEFT_SHIFT_PRESSED      = 0x0000_0002,
    RIGHT_CONTROL_PRESSED   = 0x0000_0004,
    LEFT_CONTROL_PRESSED    = 0x0000_0008,
    RIGHT_ALT_PRESSED       = 0x0000_0010,
    LEFT_ALT_PRESSED        = 0x0000_0020,
    RIGHT_LOGO_PRESSED      = 0x0000_0040,
    LEFT_LOGO_PRESSED       = 0x0000_0080,
    MENU_KEY_PRESSED        = 0x0000_0100,
    SYS_REQ_PRESSED         = 0x0000_0200,
}

enum KeyToggleState : char (inline char raw)
{
    TOGGLE_STATE_VALID      = 0x80,
    KEY_STATE_EXPOSED       = 0x40,
    SCROLL_LOCK_ACTIVE      = 0x01,
    NUM_LOCK_ACTIVE         = 0x02,
    CAPS_LOCK_ACTIVE        = 0x04,
}

struct EfiKeyState
{
    KeyShiftState   key_shift_state;
    KeyToggleState  key_toggle_state;
}

struct EfiKeyData
{
    EfiInputKey         key;
    EfiKeyState         key_state;
}

alias FnInputResetEx = fn EfiStatus(SimpleTextInputExProtocol*, bool);
alias FnInputReadKeyEx = fn EfiStatus(SimpleTextInputExProtocol*, EfiKeyData*);
alias FnInputSetState = fn EfiStatus(SimpleTextInputExProtocol*, KeyToggleState*);
alias FnInputRegisterKeystrokeNotify = fn EfiStatus(SimpleTextInputExProtocol*, EfiKeyData*, FnKeyNotificationFunction, void**);
alias FnInputUnregisterKeystrokeNotify = fn EfiStatus(EfiKeyData*);

alias FnKeyNotificationFunction = fn EfiStatus(EfiKeyData*);


/* 12.4.) Simple Text Output Protocol */
module uefi::guid;
const EfiGuid SIMPLE_TEXT_OUTPUT_PROTOCOL =
    { 0x387477c2, 0x69c7, 0x11d2, {0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b} };

module uefi::proto::console;
struct SimpleTextOutputProtocol
{
    FnOutputReset               reset;
    FnOutputString              output_string;
    FnOutputTestString          test_string;
    FnOutputQueryMode           query_mode;
    FnOutputSetMode             set_mode;
    FnOutputSetAttribute        set_attribute;
    FnOutputClearScreen         clear_screen;
    FnOutputSetCursorPosition   set_cursor_position;
    FnOutputEnableCursor        enable_cursor;
    TextMode                    *mode;
}

struct TextMode
{
    int         max_mode;
    int         current_mode;
    int         current_attribute;
    int         current_cursor_column;
    int         current_cursor_row;
    bool        is_cursor_visible;
}

alias FnOutputReset = fn EfiStatus(SimpleTextOutputProtocol*, bool);
alias FnOutputString = fn EfiStatus(SimpleTextOutputProtocol*, EfiStringRaw);
alias FnOutputTestString = fn EfiStatus(SimpleTextOutputProtocol*, EfiStringRaw);
alias FnOutputQueryMode = fn EfiStatus(SimpleTextOutputProtocol*, usz, usz*, usz*);
alias FnOutputSetMode = fn EfiStatus(SimpleTextOutputProtocol*, usz);
alias FnOutputSetAttribute = fn EfiStatus(SimpleTextOutputProtocol*, usz);
alias FnOutputClearScreen = fn EfiStatus(SimpleTextOutputProtocol*);
alias FnOutputSetCursorPosition = fn EfiStatus(SimpleTextOutputProtocol*, usz, usz);
alias FnOutputEnableCursor = fn EfiStatus(SimpleTextOutputProtocol*, bool);

/* Standard terminal color constants. */
enum TextColor : char (inline char raw)
{
    BLACK               = 0x00,
    BLUE                = 0x01,
    GREEN               = 0x02,
    CYAN                = 0x03,
    RED                 = 0x04,
    MAGENTA             = 0x05,
    BROWN               = 0x06,
    LIGHT_GRAY          = 0x07,
    DARK_GRAY           = 0x08,   /* BRIGHT, or (BLACK|BRIGHT) */
    LIGHT_BLUE          = 0x09,
    LIGHT_GREEN         = 0x0A,
    LIGHT_CYAN          = 0x0B,
    LIGHT_RED           = 0x0C,
    LIGHT_MAGENTA       = 0x0D,
    YELLOW              = 0x0E,
    WHITE               = 0x0F,

}

macro char @efi_color($fg, $bg) @builtin @public => ($fg | ((0x07 & $bg) << 4));
