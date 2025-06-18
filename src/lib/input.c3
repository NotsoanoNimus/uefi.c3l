module uefi::efilib;
import uefi;


fn EfiKeyData? read_key(usz timeout_ms)
{
    EfiEvent[2] events;
    usz fired_event_index = 0;

    // if (timeout_ms) {
    //     //
    // }

    while OUTER: (true) {
        // events[0] = sys::bs().wait_for_event(timeout_ms ? 2 : 1, &events, &fired_event_index);

        // any _stdin = sys::stdin();

        // switch (_stdin.type) {
        //     case SimpleTextInputProtocol.typeid:
        //         SimpleTextInputProtocol* stdin = _stdin;
        //         stdin.reset(stdin, false);


        //     case SimpleTextInputExProtocol.typeId:
        //         SimpleTextInputExProtocol* stdin = _stdin;
        //         stdin.reset(stdin, false);

        //     default: return efi_error::NO_MAPPING?;
        // }
    }
}


// macro bool? @confirm(EfiString prompt, $yes_by_default = true)
// {
//     confirm
// }

fn bool? confirm(EfiString prompt) => {}
