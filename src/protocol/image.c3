module uefi::proto::image;
import uefi;


/* 7.4) Image Services */
/* EFI_IMAGE_LOAD (7.4.1) */
//def FnLoadImage = fn EfiStatus(bool, EfiHandle, device::DevicePathProtocol*, void*, usz, EfiHandle*);
def FnLoadImage = fn EfiStatus(bool, EfiHandle, void*, void*, usz, EfiHandle*);

/*const EfiGuid HII_PACKAGE_LIST_PROTOCOL =
    { 0x6a1ee763, 0xd47a, 0x43b4, {0xaa,0xbe,0xef,0x1d,0xe2,0xab,0x56,0xfc} };
def HiiPackageListHeader = hii::PackageListProtocol;*/

/* EFI_IMAGE_START (7.4.2) */
def FnStartImage = fn EfiStatus(EfiHandle, usz*, EfiString*);

/* EFI_IMAGE_UNLOAD (7.4.3) */
def FnUnloadImage = fn EfiStatus(EfiHandle);

/* EFI_IMAGE_ENTRY_POINT (7.4.4) */
def FnImageEntryPoint = fn EfiStatus(EfiHandle, SystemTable*);

/* EFI_EXIT (7.4.5) */
def FnExitImage = fn EfiStatus(EfiHandle, EfiStatus, usz, EfiString);

/* EFI_EXIT_BOOT_SERVICES (7.4.6) */
def FnExitBootServices = fn EfiStatus(EfiHandle, usz);
