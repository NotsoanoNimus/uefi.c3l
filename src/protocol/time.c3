module uefi::proto::time;
import uefi;


/* 8.3.) Time services */
/* 8.3.1.) GetTime() */
alias FnGetTime = fn EfiStatus(EfiTime*, EfiTimeCapabilities*);

struct TimeCapabilities
{
    uint        resolution;
    uint        accuracy;
    bool        sets_to_zero;
}

/* 8.3.2.) SetTime() */
alias FnSetTime = fn EfiStatus(EfiTime*);

/* 8.3.3.) GetWakeupTime() */
alias FnGetWakeupTime = fn EfiStatus(bool*, bool*, EfiTime*);

/* 8.3.4.) SetWakeupTime() */
alias FnSetWakeupTime = fn EfiStatus(bool, EfiTime*);
