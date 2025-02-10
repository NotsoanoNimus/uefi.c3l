module uefi::adapter @private;


/* Create a memcpy symbol to use globally when building applications. */
fn void *memcpy(void *dst, void *src, usz len)
    @export("memcpy")
{
    if (null == dst || null == src || 0 == len) return null;

    if (((usz)dst | (usz)src | len) & (usz.sizeof - 1)) {
        char *d = dst;
        char *s = src;
        char *e = (char *)((usz)s + len);
        while (s != e) *(d++) = *(s++);
    } else {
        usz *d = dst;
        usz *s = src;
        usz *e = (usz *)(char *)((usz)s + len);
        while (s != e) *(d++) = *(s++);
    }

    return dst;
}


fn void *memset(void *at, char value, usz len)
    @export("memset")
{
    if (null == at || 0 == len) return null;

    char *p = (char *)at;

    while (len--) *p++ = value;

    return at;
}
