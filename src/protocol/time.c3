module uefi::proto::time;
import uefi;


/* 8.3.) Time services */
/* 8.3.1.) GetTime() */
def FnGetTime = fn EfiStatus(EfiTime*, EfiTimeCapabilities*);

struct TimeCapabilities
{
    uint        resolution;
    uint        accuracy;
    bool        sets_to_zero;
}

/* 8.3.2.) SetTime() */
def FnSetTime = fn EfiStatus(EfiTime*);

/* 8.3.3.) GetWakeupTime() */
def FnGetWakeupTime = fn EfiStatus(bool*, bool*, EfiTime*);

/* 8.3.4.) SetWakeupTime() */
def FnSetWakeupTime = fn EfiStatus(bool, EfiTime*);
