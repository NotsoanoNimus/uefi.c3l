/* EFI errors can actually be faults: they should raise exceptions
    in the handling of a program, if the user so chooses to. */
module uefi::efi_error;
faultdef
    NO_FAULT            ,
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
    UNKNOWN_STATUS      ;   /* Fallback for an unknown status code. */

module uefi::efi_warning;
faultdef
    UNKNOWN_GLYPH   ,
    DELETE_FAILURE  ,
    WRITE_FAILURE   ,
    BUFFER_TOO_SMALL,
    STALE_DATA      ,
    FILE_SYSTEM     ,
    RESET_REQUIRED  ;



module uefi;

import uefi::efi_error;
import uefi::efi_warning;

/*
 * EFI_STATUS enum (apx D of the UEFI 2.11 specification).
 */
macro @efi_err($x) @private => (usz)((1l << ((usz.sizeof * 8) - 1)) | $x);
macro @efi_warn($x) @private => (usz)$x;

enum EfiStatus : usz (usz raw, fault fault_type)
{
    SUCCESS                     = { 0, efi_error::NO_FAULT },

    LOAD_ERROR                  = { @efi_err(1), efi_error::LOAD_ERROR },
    INVALID_PARAMETER           = { @efi_err(2), efi_error::INVALID_PARAMETER },
    UNSUPPORTED                 = { @efi_err(3), efi_error::UNSUPPORTED },
    BAD_BUFFER_SIZE             = { @efi_err(4), efi_error::BAD_BUFFER_SIZE },
    BUFFER_TOO_SMALL            = { @efi_err(5), efi_error::BUFFER_TOO_SMALL },
    NOT_READY                   = { @efi_err(6), efi_error::NOT_READY },
    DEVICE_ERROR                = { @efi_err(7), efi_error::DEVICE_ERROR },
    WRITE_PROTECTED             = { @efi_err(8), efi_error::WRITE_PROTECTED },
    OUT_OF_RESOURCES            = { @efi_err(9), efi_error::OUT_OF_RESOURCES },
    VOLUME_CORRUPTED            = { @efi_err(10), efi_error::VOLUME_CORRUPTED },
    VOLUME_FULL                 = { @efi_err(11), efi_error::VOLUME_FULL },
    NO_MEDIA                    = { @efi_err(12), efi_error::NO_MEDIA },
    MEDIA_CHANGED               = { @efi_err(13), efi_error::MEDIA_CHANGED },
    NOT_FOUND                   = { @efi_err(14), efi_error::NOT_FOUND },
    ACCESS_DENIED               = { @efi_err(15), efi_error::ACCESS_DENIED },
    NO_RESPONSE                 = { @efi_err(16), efi_error::NO_RESPONSE },
    NO_MAPPING                  = { @efi_err(17), efi_error::NO_MAPPING },
    TIMEOUT                     = { @efi_err(18), efi_error::TIMEOUT },
    NOT_STARTED                 = { @efi_err(19), efi_error::NOT_STARTED },
    ALREADY_STARTED             = { @efi_err(20), efi_error::ALREADY_STARTED },
    ABORTED                     = { @efi_err(21), efi_error::ABORTED },
    ICMP_ERROR                  = { @efi_err(22), efi_error::ICMP_ERROR },
    TFTP_ERROR                  = { @efi_err(23), efi_error::TFTP_ERROR },
    PROTOCOL_ERROR              = { @efi_err(24), efi_error::PROTOCOL_ERROR },
    INCOMPATIBLE_VERSION        = { @efi_err(25), efi_error::INCOMPATIBLE_VERSION },
    SECURITY_VIOLATION          = { @efi_err(26), efi_error::SECURITY_VIOLATION },
    CRC_ERROR                   = { @efi_err(27), efi_error::CRC_ERROR },
    END_OF_MEDIA                = { @efi_err(28), efi_error::END_OF_MEDIA },
    UNKNOWN_29                  = { @efi_err(29), efi_error::UNKNOWN_29 },   /* NOTE: UEFI spec is missing this definition. */
    UNKNOWN_30                  = { @efi_err(30), efi_error::UNKNOWN_30 },   /* NOTE: UEFI spec is missing this definition. */
    END_OF_FILE                 = { @efi_err(31), efi_error::END_OF_FILE },
    INVALID_LANGUAGE            = { @efi_err(32), efi_error::INVALID_LANGUAGE },
    COMPROMISED_DATA            = { @efi_err(33), efi_error::COMPROMISED_DATA },
    IP_ADDRESS_CONFLICT         = { @efi_err(34), efi_error::IP_ADDRESS_CONFLICT },
    HTTP_ERROR                  = { @efi_err(35), efi_error::HTTP_ERROR },

    WARN_UNKNOWN_GLYPH          = { @efi_warn(1), efi_warning::UNKNOWN_GLYPH },
    WARN_DELETE_FAILURE         = { @efi_warn(2), efi_warning::DELETE_FAILURE },
    WARN_WRITE_FAILURE          = { @efi_warn(3), efi_warning::WRITE_FAILURE },
    WARN_BUFFER_TOO_SMALL       = { @efi_warn(4), efi_warning::BUFFER_TOO_SMALL },
    WARN_STALE_DATA             = { @efi_warn(5), efi_warning::STALE_DATA },
    WARN_FILE_SYSTEM            = { @efi_warn(6), efi_warning::FILE_SYSTEM },
    WARN_RESET_REQUIRED         = { @efi_warn(7), efi_warning::RESET_REQUIRED },
}




////////////////////////////////////////////////////////////////////////
<*
    Handle EFI errors when they occur.
    @param status: `The EfiStatus code to check`
    @param throw_on_warnings: `Return a ``true`` value on EFI_WARN_... codes`
    @return ```false`` on success. ``true`` when ``throw_on_warnings`` is false and ``status`` is a warning. Returns a fault otherwise.`
*>
fn bool? efi_error(
    EfiStatus status,
    bool throw_on_warnings = true
) @export("efi_error") @builtin
{
    switch {
        case status == SUCCESS: return false;

        case status >= EfiStatus.WARN_UNKNOWN_GLYPH && status <= EfiStatus.WARN_RESET_REQUIRED:
            return throw_on_warnings ? status.fault_type? : true;

        case status >= EfiStatus.LOAD_ERROR && status <= EfiStatus.HTTP_ERROR:
            return status.fault_type?;
    }

    return efi_error::UNKNOWN_STATUS?;
}
