module uefi::proto::handle;
import uefi;


/* 7.3) Protocol Handler Services */
/* EFI_INSTALL_PROTOCOL_INTERFACE (7.3.2) and related definitions */
def FnInstallProtocolInterface = fn EfiStatus(EfiHandle*, EfiGuid*, InterfaceType, void*);

/* NOTE: EFI_HANDLE and EFI_GUID are defined in the def.c3 globals file. */
enum InterfaceType
{
    NATIVE_INTERFACE,
}

/* EFI_UNINSTALL_PROTOCOL_INTERFACE (7.3.3) */
def FnUninstallProtocolInterface = fn EfiStatus(EfiHandle*, EfiGuid*, void*);

/* EFI_REINSTALL_PROTOCOL_INTERFACE (7.3.4) */
def FnReinstallProtocolInterface = fn EfiStatus(EfiHandle*, EfiGuid*, void*, void*);

/* EFI_REGISTER_PROTOCOL_NOTIFY (7.3.5) */
def FnRegisterProtocolNotify = fn EfiStatus(EfiGuid*, evt::EfiEvent, void**);

/* EFI_LOCATE_HANDLE (7.3.6) and related */
def FnLocateHandle = fn EfiStatus(HandleSearchType, EfiGuid*, void*, usz*, EfiHandle*);

enum HandleSearchType
{
    ALL_HANDLES,
    BY_REGISTER_NOTIFY,
    BY_PROTOCOL,
}

/* EFI_HANDLE_PROTOCOL (7.3.7) */
def FnHandleProtocol = fn EfiStatus(EfiHandle, EfiGuid*, void**);

/* EFI_LOCATE_DEVICE_PATH (7.3.8) */
//def FnLocateDevicePath = fn EfiStatus(EfiGuid*, device::DevicePathProtocol**, EfiHandle*);
def FnLocateDevicePath = fn EfiStatus(EfiGuid*, void**, EfiHandle*);

/* EFI_OPEN_PROTOCOL (7.3.9) and related */
def FnOpenProtocol = fn EfiStatus(EfiHandle, EfiGuid*, void**, EfiHandle, EfiHandle, OpenProtocolAttribute);

def OpenProtocolAttribute = uint;
const OpenProtocolAttribute BY_HANDLE_PROTOCOL  = 0x0000_0001;
const OpenProtocolAttribute GET_PROTOCOL        = 0x0000_0002;
const OpenProtocolAttribute TEST_PROTOCOL       = 0x0000_0004;
const OpenProtocolAttribute BY_CHILD_CONTROLLER = 0x0000_0008;
const OpenProtocolAttribute BY_DRIVER           = 0x0000_0010;
const OpenProtocolAttribute EXCLUSIVE           = 0x0000_0020;

/* EFI_CLOSE_PROTOCOL (7.3.10) */
def FnCloseProtocol = fn EfiStatus(EfiHandle, EfiGuid*, EfiHandle, EfiHandle);

/* EFI_OPEN_PROTOCOL_INFORMATION (7.3.11) and related */
def FnOpenProtocolInformation = fn EfiStatus(EfiHandle, EfiGuid*, OpenProtocolInformationEntry**, usz*);

struct OpenProtocolInformationEntry
{
    EfiHandle                   agent_handle;
    EfiHandle                   controller_handle;
    OpenProtocolAttribute       attributes;
    uint                        open_count;
}

/* EFI_CONNECT_CONTROLLER (7.3.12) */
//def FnConnectController = fn EfiStatus(EfiHandle, EfiHandle*, device::DevicePathProtocol*, bool);
def FnConnectController = fn EfiStatus(EfiHandle, EfiHandle*, void*, bool);

/* EFI_DISCONNECT_CONTROLLER (7.3.13) */
def FnDisconnectController = fn EfiStatus(EfiHandle, EfiHandle, EfiHandle);

/* EFI_PROTOCOLS_PER_HANDLE (7.3.14) */
def FnProtocolsPerHandle = fn EfiStatus(EfiHandle, EfiGuid***, usz*);

/* EFI_LOCATE_HANDLE_BUFFER (7.3.15) */
def FnLocateHandleBuffer = fn EfiStatus(HandleSearchType, EfiGuid*, void*, usz*, EfiHandle**);

/* EFI_LOCATE_PROTOCOL (7.3.16) */
def FnLocateProtocol = fn EfiStatus(EfiGuid*, void*, void**);

/* EFI_INSTALL_MULTIPLE_PROTOCOL_INTERFACES (7.3.17) */
def FnInstallMultipleProtocolInterfaces = fn EfiStatus(EfiHandle*, ...);

/* EFI_UNINSTALL_MULTIPLE_PROTOCOL_INTERFACES (7.3.18) */
def FnUninstallMultipleProtocolInterfaces = fn EfiStatus(EfiHandle, ...);
