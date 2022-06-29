; -------------------------------------------------------------- ; notes
; --------------------------------------------------------------
; ! = alt
; ^ = ctrl
; + = shift
; # = lwin|rwin
;
#Include %A_ScriptDir%\DesktopSwitcher.ahk
#Include %A_ScriptDir%\MouseBehaviour.ahk
#Include %A_ScriptDir%\WindowGrid.ahk
#Include %A_ScriptDir%\RemoteDesktopHelper.ahk
#Include %A_ScriptDir%\WindowBehaviour.ahk
#Include %A_ScriptDir%\ProgramLauncher.ahk
; #Include %A_ScriptDir%\DrawBorder.ahk does not work right now

^#!r::
    ; Win Alt Ctrl + R reload autohotkey
    MsgBox Reloading autohotkey
    Reload
return



win_is_desktop(HWND)
{
    WinGetClass, win_class, ahk_id %HWND%
    return (win_class ~= "WorkerW"                  ; desktop window class could be WorkerW or Progman
         or win_class ~= "Progman"
         or win_class ~= "SideBar_HTMLHostWindow")  ; sidebar widgets
}

is_equal(a, b, delta = 10)
{
    return Abs(a - b) <= delta
}

;; ========================================================================================================
;; Bindings
;; ========================================================================================================

; *CapsLock::Esc
*CapsLock::
    KeyWait, CapsLock
    IF A_ThisHotkey = *CapsLock
	Send, {Blind}{Esc}
Return

#If GetKeyState("CapsLock", "P")
    ; vim movements if holding capslock
    h::Send,{blind}{Left}
    l::Send,{blind}{Right}
    j::Send,{blind}{Down}
    k::Send,{blind}{Up}
    0::Send, {Home}
    4::Send, {End}
    n::Send, #t
    p::Send, #+t
    d::Send, {PgDn}
    u::Send, {PgUp}

    ;u::Send, {Ctrl down}z{Ctrl up}

    ; windows switcher
    o::
       SendInput  {LControl Down}{LAlt Down}{Tab}{LControl Up}{LAlt Up} 
    return 
    ; !l::Send, {ALTDOWN}{TAB}{ALTUP}
    ; TODO holding down alt when switching - confuses windows and thinks some keys are still pushed
    ; !l::Send, {ALT}{TAB}
    ; !h::Send, {ALTDOWN}{ShiftDown}{TAB}{ALTUP}

    ; TODO navigate to window right and left
    +h::MsgBox "capslock shift h"
    +l::MsgBox "capslock shift l"

    ; TODO media keys

    ; toggle capslock
    c::
        GetKeyState, CapsLockState, CapsLock, T
        if CapsLockState = D
            SetCapsLockState, AlwaysOff
        else
            SetCapsLockState, AlwaysOn
    return
#If ; end of #If ; F13::MsgBox Hello World
; when on rdp push: ctrl+alt+home twice to get to desktop 1
^!Home::
  switchDesktopByNumber(1)
return

; use ctrl to send curly braces
^7:: Send {{}
^0:: Send {}}

; use ctrl to send square bracets
^8:: Send {[}
^9:: Send {]}

; switching tabs in nvim using ctrl+shift + j/k 
; #IfWinActive ahk_exe WindowsTerminal.exe 
; ^+j:: Send {AltDown}{ShiftDown}j{AltUp}{ShiftUp}}
; ^+k:: Send {AltDown}{ShiftDown}k{AltUp}{ShiftUp}}
; return
; hotkeys/hotstrings for notepad only

;; vim movements alt j + alt k
; !h::Send,{Left}
; !j::Send,{Down}
; !k::Send,{Up}
; !l::Send,{Right}

;; turn off monitors win + shift + f1
#^F1::
Sleep, 200
SendMessage,0x112,0xF170,2,,Program Manager
return

;; ==========================================================================================
;; Functions
;; ==========================================================================================

; ctrl + shift + "+" volumen up
^+NumpadAdd::
Send {Volume_Up}  ; Raise the master volume by 1 interval (typically 5%).
return

; ctrl + shift + "-" volumen down
^+NumpadSub::
Send {Volume_Down 3}  ; Lower the master volume by 3 intervals.
return

; ctrl + shift + "/" mute
^+NumpadDiv::
Send {Volume_Mute}  ; Mute/unmute the master volume.
return

^!PgDn::Send  {Media_Next}
^!PgUp::Send  {Media_Prev}
; ^!Home::Send   {Media_Play_Pause}
; ""CTRL + ALT + Home"  for pause

; "CTRL + ALT + UP"  for info
^!Up::
{
	DetectHiddenWindows, On
	SetTitleMatchMode 2
	; spotify
	WinGetTitle, now_playing, ahk_class SpotifyMainWindow
	;StringTrimLeft, playing, now_playing, 10; not needed anymore
	StringTrimLeft, playing, now_playing, 0
	; WinGrooves
	; WinGetTitle, now_playing, ahk_class WindowsForms10.Window.8.app.0.141b42a_r29_ad1
	; StringTrimRight, playing, now_playing, 12
	; show tray tip
	TrayTip, Now playing:, %playing%, 10 , 16
	DetectHiddenWindows, Off
	return
}


; Maximize
!F10::WinMaximize, A
; Restore
!F5::WinRestore, A
