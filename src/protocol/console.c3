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

def FnInputReset = fn EfiStatus(SimpleTextInputProtocol*, bool);
def FnInputReadKey = fn EfiStatus(SimpleTextInputProtocol*, EfiKey*);

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

def FnOutputReset = fn EfiStatus(SimpleTextOutputProtocol*, bool);
def FnOutputString = fn EfiStatus(SimpleTextOutputProtocol*, EfiString);
def FnOutputTestString = fn EfiStatus(SimpleTextOutputProtocol*, EfiString);
def FnOutputQueryMode = fn EfiStatus(SimpleTextOutputProtocol*, usz, usz*, usz*);
def FnOutputSetMode = fn EfiStatus(SimpleTextOutputProtocol*, usz);
def FnOutputSetAttribute = fn EfiStatus(SimpleTextOutputProtocol*, usz);
def FnOutputClearScreen = fn EfiStatus(SimpleTextOutputProtocol*);
def FnOutputSetCursorPosition = fn EfiStatus(SimpleTextOutputProtocol*, usz, usz);
def FnOutputEnableCursor = fn EfiStatus(SimpleTextOutputProtocol*, bool);

/* Standard terminal color constants. */
enum TextColor : char (inline char raw)
{
    BLACK       = 0x00,
    BLUE        = 0x01,
    GREEN       = 0x02,
    CYAN        = 0x03,
    RED         = 0x04,
    MAGENTA     = 0x05,
    BROWN       = 0x06,
    GRAY        = 0x07,
    BRIGHT      = 0x08,
}

macro char @tcolor($fg, $bg) @public => ($fg | ((0x07 & $bg) << 4));
