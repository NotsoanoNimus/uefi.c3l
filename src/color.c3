module uefi::color;
import uefi;


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

macro char @tcolor($fg, $bg) @public => ($fg | ($bg << 4));
