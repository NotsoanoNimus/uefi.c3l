module uefi;


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
