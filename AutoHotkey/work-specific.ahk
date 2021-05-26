;; outlook
#o::
    DetectHiddenWindows, On 
    IfWinNotExist, ahk_class rctrl_renwnd32
        ShellRun("C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE")
    Else 
        DetectHiddenWindows, Off
    IfWinNotExist ahk_class rctrl_renwnd32
    { 
        WinShow, ahk_class rctrl_renwnd32
        WinActivate, ahk_class rctrl_renwnd32
    } 
    Else IfWinExist, ahk_class rctrl_renwnd32
    { 
        WinMinimize, ahk_class rctrl_renwnd32
        WinHide, ahk_class rctrl_renwnd32
    } 
Return