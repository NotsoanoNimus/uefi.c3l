module uefi::proto::variable;
import uefi;


/* 8.2.) Variable services */
/* 8.2.1.) GetVariable() */
alias FnGetVariable = fn EfiStatus(EfiStringRaw, EfiGuid*, uint*, usz*, void*);

/* Variable Attributes */
enum EfiVarAttr : uint (uint raw)   // TODO: Add `inline` inside parens when supported
{
    NON_VOLATILE                = 0x0000_0001,
    BOOTSERVICE_ACCESS          = 0x0000_0002,
    RUNTIME_ACCESS              = 0x0000_0004,
    HARDWARE_ERROR_RECORD       = 0x0000_0008,
    HR                          = 0x0000_0008,   /* spec notes aliasing of this to above */
    RESERVED                    = 0x0000_0010,
    TIME_BASED_AUTHENTICATED_WRITE_ACCESS = 0x0000_0020,
    APPEND_WRITE                = 0x0000_0040,
    ENHANCED_AUTHENTICATED_ACCESS = 0x0000_0080,
}

struct VariableAuthentication3CertId
{
    char        type;
    uint        id_size;
    /* implied to follow:  char id[id_size]; */
}

/* 8.2.2.) GetNextVariableName() */
alias FnGetNextVariableName = fn EfiStatus(usz*, EfiStringRaw, EfiGuid*);

/* 8.2.3.) SetVariable() */
alias FnSetVariable = fn EfiStatus(EfiStringRaw, EfiGuid*, uint, usz, void*);

/* TODO: Too much extra complexity to use right now. Add later. */
/*
struct VariableAuthentication2
{
    EfiTime                     timestamp;
    WinCertificateUefiGuid      auth_info;
}
*/

const char EFI_VARIABLE_AUTHENTICATION_3_TIMESTAMP_TYPE = 1;
const char EFI_VARIABLE_AUTHENTICATION_3_NONCE_TYPE     = 2;
struct VariableAuthentication3
{
    char        version;
    char        type;
    uint        metadata_size;
    uint        flags;
}

struct VariableAuthentication3Nonce
{
    uint        nonce_size;
    /* implied to follow:  char nonce[nonce_size]; */
}

/* 8.2.4.) QueryVariableInfo() */
alias FnQueryVariableInfo = fn EfiStatus(uint, ulong*, ulong*, ulong*);

/* 8.2.7.2.) Hardware Error Record Variables */
const EfiGuid EFI_HARDWARE_ERROR_VARIABLE =
    { 0x414e6bdd, 0xe47b, 0x47cc, {0xb2,0x44,0xbb,0x61,0x02,0x0c,0xf5,0x16} };
