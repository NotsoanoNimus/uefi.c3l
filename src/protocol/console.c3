module uefi::proto::console;
import uefi;


/* 12.1.) Console I/O Protocol (Scan Codes) */
// TODO

/* 12.3.) Simple Text Input Protocol */
module uefi::guid;
const EfiGuid SIMPLE_TEXT_INPUT_PROTOCOL =
    { 0x387477c1, 0x69c7, 0x11d2, {0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b} };

module uefi::proto::console;
struct SimpleTextInputProtocol
{
    FnInputReset        reset;
    FnInputReadKey      read_key;
    EfiEvent            event_wait_for_key;
}

struct EfiKey
{
    ushort      scan_code;
    ushort      unicode_char;
}

alias FnInputReset = fn EfiStatus(SimpleTextInputProtocol*, bool);
alias FnInputReadKey = fn EfiStatus(SimpleTextInputProtocol*, EfiKey*);

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
alias FnOutputString = fn EfiStatus(SimpleTextOutputProtocol*, EfiString);
alias FnOutputTestString = fn EfiStatus(SimpleTextOutputProtocol*, EfiString);
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
