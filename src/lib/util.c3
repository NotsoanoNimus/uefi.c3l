module uefi::core_util;


/* Conversion macros: s2ms, s2us, ms2us (sec to millisec, sec to microsec, millisec to microsec) */
macro usz @s2ms(usz $x) @public @builtin => $x * 1_000;
macro usz @s2us(usz $x) @public @builtin => $x * 1_000_000;
macro usz @ms2us(usz $x) @public @builtin => $x * 1_000;

/* min/max macros for le global use */
macro @min(#x, #y) @public @builtin => ((#x) < (#y) ? (#x) : (#y));
macro @max(#x, #y) @public @builtin => ((#x) > (#y) ? (#x) : (#y));

macro @foreach(rawptr, len; @body(index, value)) @builtin
{
    for (usz i = 0; i < len; ++i) {
        @body(i, rawptr[i]);
    }
}
