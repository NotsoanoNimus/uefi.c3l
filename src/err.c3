module uefi;


/*
 * EFI_STATUS enum (apx D of the UEFI 2.11 specification).
 */
/* EfiStatus is a distinct type that shouldn't be implicitly converted. */
distinct EfiStatus = usz;

macro @efi_err($x) @private => (EfiStatus)((1 << (usz.sizeof - 1)) | $x);
macro @efi_warn($x) @private => (EfiStatus)$x;

const EfiStatus EFI_SUCCESS             = 0;

const EfiStatus EFI_LOAD_ERROR          = @efi_err(1);
const EfiStatus EFI_INVALID_PARAMETER   = @efi_err(2);
const EfiStatus EFI_UNSUPPORTED         = @efi_err(3);
const EfiStatus EFI_BAD_BUFFER_SIZE     = @efi_err(4);
const EfiStatus EFI_BUFFER_TOO_SMALL    = @efi_err(5);
const EfiStatus EFI_NOT_READY           = @efi_err(6);
const EfiStatus EFI_DEVICE_ERROR        = @efi_err(7);
const EfiStatus EFI_WRITE_PROTECTED     = @efi_err(8);
const EfiStatus EFI_OUT_OF_RESOURCES    = @efi_err(9);
const EfiStatus EFI_VOLUME_CORRUPTED    = @efi_err(10);
const EfiStatus EFI_VOLUME_FULL         = @efi_err(11);
const EfiStatus EFI_NO_MEDIA            = @efi_err(12);
const EfiStatus EFI_MEDIA_CHANGED       = @efi_err(13);
const EfiStatus EFI_NOT_FOUND           = @efi_err(14);
const EfiStatus EFI_ACCESS_DENIED       = @efi_err(15);
const EfiStatus EFI_NO_RESPONSE         = @efi_err(16);
const EfiStatus EFI_NO_MAPPING          = @efi_err(17);
const EfiStatus EFI_TIMEOUT             = @efi_err(18);
const EfiStatus EFI_NOT_STARTED         = @efi_err(19);
const EfiStatus EFI_ALREADY_STARTED     = @efi_err(20);
const EfiStatus EFI_ABORTED             = @efi_err(21);
const EfiStatus EFI_ICMP_ERROR          = @efi_err(22);
const EfiStatus EFI_TFTP_ERROR          = @efi_err(23);
const EfiStatus EFI_PROTOCOL_ERROR      = @efi_err(24);
const EfiStatus EFI_INCOMPATIBLE_VERSION= @efi_err(25);
const EfiStatus EFI_SECURITY_VIOLATION  = @efi_err(26);
const EfiStatus EFI_CRC_ERROR           = @efi_err(27);
const EfiStatus EFI_END_OF_MEDIA        = @efi_err(28);
const EfiStatus EFI_UNKNOWN_29          = @efi_err(29);   /* NOTE: UEFI spec is missing this definition. */
const EfiStatus EFI_UNKNOWN_30          = @efi_err(30);   /* NOTE: UEFI spec is missing this definition. */
const EfiStatus EFI_END_OF_FILE         = @efi_err(31);
const EfiStatus EFI_INVALID_LANGUAGE    = @efi_err(32);
const EfiStatus EFI_COMPROMISED_DATA    = @efi_err(33);
const EfiStatus EFI_IP_ADDRESS_CONFLICT = @efi_err(34);
const EfiStatus EFI_HTTP_ERROR          = @efi_err(35);

const EfiStatus EFI_WARN_UNKNOWN_GLYPH  = @efi_warn(1);
const EfiStatus EFI_WARN_DELETE_FAILURE = @efi_warn(2);
const EfiStatus EFI_WARN_WRITE_FAILURE  = @efi_warn(3);
const EfiStatus EFI_WARN_BUFFER_TOO_SMALL = @efi_warn(4);
const EfiStatus EFI_WARN_STALE_DATA     = @efi_warn(5);
const EfiStatus EFI_WARN_FILE_SYSTEM    = @efi_warn(6);
const EfiStatus EFI_WARN_RESET_REQUIRED = @efi_warn(7);


/* EFI errors can actually be faults: they should raise exceptions
    in the handling of a program, if the user so chooses to. */
fault EfiError
{
    EFI_LOAD_ERROR          ,
    EFI_INVALID_PARAMETER   ,
    EFI_UNSUPPORTED         ,
    EFI_BAD_BUFFER_SIZE     ,
    EFI_BUFFER_TOO_SMALL    ,
    EFI_NOT_READY           ,
    EFI_DEVICE_ERROR        ,
    EFI_WRITE_PROTECTED     ,
    EFI_OUT_OF_RESOURCES    ,
    EFI_VOLUME_CORRUPTED    ,
    EFI_VOLUME_FULL         ,
    EFI_NO_MEDIA            ,
    EFI_MEDIA_CHANGED       ,
    EFI_NOT_FOUND           ,
    EFI_ACCESS_DENIED       ,
    EFI_NO_RESPONSE         ,
    EFI_NO_MAPPING          ,
    EFI_TIMEOUT             ,
    EFI_NOT_STARTED         ,
    EFI_ALREADY_STARTED     ,
    EFI_ABORTED             ,
    EFI_ICMP_ERROR          ,
    EFI_TFTP_ERROR          ,
    EFI_PROTOCOL_ERROR      ,
    EFI_INCOMPATIBLE_VERSION,
    EFI_SECURITY_VIOLATION  ,
    EFI_CRC_ERROR           ,
    EFI_END_OF_MEDIA        ,
    EFI_UNKNOWN_29          ,   /* NOTE: UEFI spec is missing this definition. */
    EFI_UNKNOWN_30          ,   /* NOTE: UEFI spec is missing this definition. */
    EFI_END_OF_FILE         ,
    EFI_INVALID_LANGUAGE    ,
    EFI_COMPROMISED_DATA    ,
    EFI_IP_ADDRESS_CONFLICT ,
    EFI_HTTP_ERROR          ,

    EFI_UNKNOWN_STATUS      ,   /* Fallback for an unknown status code. */
}

fault EfiWarning
{
    EFI_WARN_UNKNOWN_GLYPH   ,
    EFI_WARN_DELETE_FAILURE  ,
    EFI_WARN_WRITE_FAILURE   ,
    EFI_WARN_BUFFER_TOO_SMALL,
    EFI_WARN_STALE_DATA      ,
    EFI_WARN_FILE_SYSTEM     ,
    EFI_WARN_RESET_REQUIRED  ,
}


////////////////////////////////////////////////////////////////////////
module uefi::efi;
import uefi;

<*
    @param status "The EfiStatus code to check."
*>
// TODO: There's probably a better way to do this.
fn bool! is_error(EfiStatus status, bool throw_on_warnings)
{
    switch {
        case status == uefi::EFI_SUCCESS: return false;

        case status >= uefi::EFI_WARN_UNKNOWN_GLYPH && status <= uefi::EFI_WARN_RESET_REQUIRED:
            return throw_on_warnings ? EfiWarning.values[(usz)status]? : true;

        case status >= uefi::EFI_LOAD_ERROR && status <= uefi::EFI_HTTP_ERROR:
            return EfiError.values[(usz)(status & ~(1 << (usz.sizeof - 1)))]?;
    }

    return EfiError.EFI_UNKNOWN_STATUS?;
}
