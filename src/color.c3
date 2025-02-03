module uefi::color;
import uefi;


/* Standard terminal color constants. */
const char BLACK        = 0x00;
const char BLUE         = 0x01;

macro char @text_attr($fg, $bg) @public => ($fg | ($bg << 4));
