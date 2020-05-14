#Include %A_ScriptDir%\DesktopSwitcher.ahk
#Include %A_ScriptDir%\MouseBehaviour.ahk
#Include %A_ScriptDir%\WindowGrid.ahk
#Include %A_ScriptDir%\RemoteDesktopHelper.ahk
#Include %A_ScriptDir%\WindowBehaviour.ahk
#Include %A_ScriptDir%\ProgramLauncher.ahk

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

;;SetCapsLockState, alwaysoff
;; map capslock to shift
Capslock::Esc

;; vim movements alt j + alt k
; !h::Send,{Left}
!j::Send,{Down}
!k::Send,{Up}
; !l::Send,{Right}

;; turn off monitors
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
^!Home::Send   {Media_Play_Pause}
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