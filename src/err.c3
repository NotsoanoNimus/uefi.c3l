module uefi;


/*
 * EFI_STATUS enum (apx D of the UEFI 2.11 specification).
 */
macro @efi_err($x) @private => (usz)((1l << ((usz.sizeof * 8) - 1)) | $x);
macro @efi_warn($x) @private => (usz)$x;

enum EfiStatus : usz (inline usz raw)
{
    SUCCESS                     = 0,

    LOAD_ERROR                  = @efi_err(1),
    INVALID_PARAMETER           = @efi_err(2),
    UNSUPPORTED                 = @efi_err(3),
    BAD_BUFFER_SIZE             = @efi_err(4),
    BUFFER_TOO_SMALL            = @efi_err(5),
    NOT_READY                   = @efi_err(6),
    DEVICE_ERROR                = @efi_err(7),
    WRITE_PROTECTED             = @efi_err(8),
    OUT_OF_RESOURCES            = @efi_err(9),
    VOLUME_CORRUPTED            = @efi_err(10),
    VOLUME_FULL                 = @efi_err(11),
    NO_MEDIA                    = @efi_err(12),
    MEDIA_CHANGED               = @efi_err(13),
    NOT_FOUND                   = @efi_err(14),
    ACCESS_DENIED               = @efi_err(15),
    NO_RESPONSE                 = @efi_err(16),
    NO_MAPPING                  = @efi_err(17),
    TIMEOUT                     = @efi_err(18),
    NOT_STARTED                 = @efi_err(19),
    ALREADY_STARTED             = @efi_err(20),
    ABORTED                     = @efi_err(21),
    ICMP_ERROR                  = @efi_err(22),
    TFTP_ERROR                  = @efi_err(23),
    PROTOCOL_ERROR              = @efi_err(24),
    INCOMPATIBLE_VERSION        = @efi_err(25),
    SECURITY_VIOLATION          = @efi_err(26),
    CRC_ERROR                   = @efi_err(27),
    END_OF_MEDIA                = @efi_err(28),
    UNKNOWN_29                  = @efi_err(29),   /* NOTE: UEFI spec is missing this definition. */
    UNKNOWN_30                  = @efi_err(30),   /* NOTE: UEFI spec is missing this definition. */
    END_OF_FILE                 = @efi_err(31),
    INVALID_LANGUAGE            = @efi_err(32),
    COMPROMISED_DATA            = @efi_err(33),
    IP_ADDRESS_CONFLICT         = @efi_err(34),
    HTTP_ERROR                  = @efi_err(35),

    WARN_UNKNOWN_GLYPH          = @efi_warn(1),
    WARN_DELETE_FAILURE         = @efi_warn(2),
    WARN_WRITE_FAILURE          = @efi_warn(3),
    WARN_BUFFER_TOO_SMALL       = @efi_warn(4),
    WARN_STALE_DATA             = @efi_warn(5),
    WARN_FILE_SYSTEM            = @efi_warn(6),
    WARN_RESET_REQUIRED         = @efi_warn(7),
}


/* EFI errors can actually be faults: they should raise exceptions
    in the handling of a program, if the user so chooses to. */
fault EfiError
{
    LOAD_ERROR          ,
    INVALID_PARAMETER   ,
    UNSUPPORTED         ,
    BAD_BUFFER_SIZE     ,
    BUFFER_TOO_SMALL    ,
    NOT_READY           ,
    DEVICE_ERROR        ,
    WRITE_PROTECTED     ,
    OUT_OF_RESOURCES    ,
    VOLUME_CORRUPTED    ,
    VOLUME_FULL         ,
    NO_MEDIA            ,
    MEDIA_CHANGED       ,
    NOT_FOUND           ,
    ACCESS_DENIED       ,
    NO_RESPONSE         ,
    NO_MAPPING          ,
    TIMEOUT             ,
    NOT_STARTED         ,
    ALREADY_STARTED     ,
    ABORTED             ,
    ICMP_ERROR          ,
    TFTP_ERROR          ,
    PROTOCOL_ERROR      ,
    INCOMPATIBLE_VERSION,
    SECURITY_VIOLATION  ,
    CRC_ERROR           ,
    END_OF_MEDIA        ,
    UNKNOWN_29          ,   /* NOTE: UEFI spec is missing this definition. */
    UNKNOWN_30          ,   /* NOTE: UEFI spec is missing this definition. */
    END_OF_FILE         ,
    INVALID_LANGUAGE    ,
    COMPROMISED_DATA    ,
    IP_ADDRESS_CONFLICT ,
    HTTP_ERROR          ,

    EFILIB_UNINITIALIZED,   /* Used for efilib calls when init() hasn't been called. */
    UNKNOWN_STATUS      ,   /* Fallback for an unknown status code. */
}

fault EfiWarning
{
    UNKNOWN_GLYPH   ,
    DELETE_FAILURE  ,
    WRITE_FAILURE   ,
    BUFFER_TOO_SMALL,
    STALE_DATA      ,
    FILE_SYSTEM     ,
    RESET_REQUIRED  ,
}


////////////////////////////////////////////////////////////////////////
<*
    @param status "The EfiStatus code to check"
    @param throw_on_warnings "Return a `true` value on EFI_WARN_... codes"
*>
fn bool! efi_error(
    EfiStatus status,
    bool throw_on_warnings = true
) @export("efi_error") @builtin
{
    switch {
        case status == SUCCESS: return false;

        case status >= WARN_UNKNOWN_GLYPH && status <= WARN_RESET_REQUIRED:
            return throw_on_warnings ? EfiWarning.values[(usz)status]? : true;

        case status >= LOAD_ERROR && status <= HTTP_ERROR:
            return EfiError.values[(usz)status & ~(1l << ((usz.sizeof * 8) - 1))]?;
    }

    return EfiError.UNKNOWN_STATUS?;
}
