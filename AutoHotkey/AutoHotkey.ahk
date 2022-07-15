#persistent
#SingleInstance Force
; global CurrentLogLevel := LogLevel.Debug()
global CurrentLogLevel := LogLevel.Information()
global Logger := new Logger

toggle = 0
border_thickness = 2
border_color = FF0000

; ListVars ; debug variables

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
#Include %A_ScriptDir%\Logger.ahk
; #Include %A_ScriptDir%\DrawBorder.ahk does not work right now

win_is_desktop(HWND)
{
    WinGetClass, win_class, ahk_id %HWND%
    return (win_class ~= "WorkerW"                  ; desktop window class could be WorkerW or Progman
         or win_class ~= "Progman"
         or win_class ~= "SideBar_HTMLHostWindow")  ; sidebar widgets
}

get_visible_windows()
{
    visibleWindowAhkIds := []
    WinGet windows, List
    Loop %windows%
    {
        id := windows%A_Index%
        WinGetTitle title, ahk_id %id%
        WinGet, style, style, ahk_id %id%
        WinGetClass, wClass, % "ahk_id " id
        if !(style & 0xC00000) ; if the window doesn't have a title bar
        {	
            continue
        }
        if (title = "")
        {
            continue
        }
        visibleWindowAhkIds.Push(id)
        ; r .= wClass . " " . title . "`n" ; TODO log?
    }
    return visibleWindowAhkIds
}

win_focus(direction){
    visibleWindowAhkIds := get_visible_windows()

    WinGet, winid ,, A ; <-- need to identify window A = acitive
    WinGetPos, X, Y,Width,Height, ahk_id %winid%

    activateWindowId := ""
    deltaX :=  10000000
    deltaY :=  10000000
    for index, ahkId in visibleWindowAhkIds ; Enumeration is the recommended approach in most cases.
    {
        if (ahkId = winid)
        {
            ; dont consider active window
            WinGetTitle winTitle, ahk_id %winId%
            logText = active: (%X%,%Y%,%Width%,%Height%) %winTitle%
            Logger.WriteLog(logText, LogLevel.Debug())
            continue
        }
        WinGetPos, winX, winY,winWidth,winHeight, ahk_id %ahkId%
        WinGetTitle winTitle, ahk_id %ahkId%
        
        isAllowed := false

        ; TODO verify
        ; When window is full screen X of the active window can be -8 this makes
        ; moving to the right window wrong
        ; offset when in fullscreen mode? 10px
        offset = 10
        switch direction
        {
            case "left":
                currentDeltaX := abs(X - winX)
                currentDeltaY := abs(Y - winY)
                isAllowed := winX < X
            case "right":
                currentDeltaX := abs(winX - X)
                currentDeltaY := abs(Y - winY)
                isAllowed := winX > X
            case "up":
                currentDeltaY := abs(Y - winY)
                currentDeltaX := abs(X - winX)
                activeWindowRight := X + Width - offset
                activeWindowLeft := X
                isAllowed := winY < Y AND winX < activeWindowRight AND winX >= activeWindowLeft
            case "down":
                currentDeltaY := abs(winY - Y)
                currentDeltaX := abs(X - winX)
                activeWindowRight := X + Width - offset
                activeWindowLeft := X
                isAllowed := winY >= Y AND winX <= activeWindowRight AND winX >= activeWindowLeft
        }

        WinGetTitle winTitle, ahk_id %ahkId%
        logText = (%winX%,%winY%, %winWidth%, %winHeight%) currentDeltaX: %currentDeltaX% currentDeltaY %currentDeltaY% %winTitle%
        Logger.WriteLog(logText, LogLevel.Debug())
        if (isAllowed AND (currentDeltaX < deltaX OR currentDeltaY < deltaY) )
        {
            deltaX := currentDeltaX
            deltaY := currentDeltaY
            activateWindowId := ahkId
            
            WinGetTitle title, ahk_id %winId%
            logText =  %winTitle%  "(" %winX% "," %winY% ") " %title%  "(" %X% "," %Y%") deltaX: " %deltaX%
            ; logText =  "(" %winX% "," %winY% ") and (" %X% "," %Y%") delta: " %delta%
            ; Logger.WriteLog(logText, LogLevel.Debug())
        }
    }

    if  (activateWindowId != "")
    {
        WinGetTitle switchToTitle, ahk_id %activateWindowId%
        switchToLogText = "switching to window with title: " %switchToTitle%
        Logger.WriteLog(switchToLogText, LogLevel.Debug())
        Logger.WriteLog("============================================", LogLevel.Debug())
        WinActivate, ahk_id %activateWindowId%
    }

}

DrawRect:
    WinGetPos, x, y, w, h, A
    if (x="")
        return
    Gui, +Lastfound +AlwaysOnTop +Toolwindow

    borderType:="inside"                ; set to inside, outside, or both

    if (borderType="outside") { 
        outerX:=0
        outerY:=0
        outerX2:=w+2*border_thickness
        outerY2:=h+2*border_thickness

        innerX:=border_thickness
        innerY:=border_thickness
        innerX2:=border_thickness+w
        innerY2:=border_thickness+h

        newX:=x-border_thickness
        newY:=y-border_thickness
        newW:=w+2*border_thickness
        newH:=h+2*border_thickness

    } else if (borderType="inside") {   
        WinGet, myState, MinMax, A
        if (myState=1)
            offset:=8
        else 
            offset:=8

        outerX:=offset
        outerY:=offset
        outerX2:=w-offset
        outerY2:=h-offset

        innerX:=border_thickness+offset
        innerY:=border_thickness+offset
        innerX2:=w-border_thickness-offset
        innerY2:=h-border_thickness-offset

        newX:=x
        newY:=y
        newW:=w
        newH:=h
    } else if (borderType="both") { 
        outerX:=0
        outerY:=0
        outerX2:=w+2*border_thickness
        outerY2:=h+2*border_thickness

        innerX:=border_thickness*2
        innerY:=border_thickness*2
        innerX2:=w
        innerY2:=h

        newX:=x-border_thickness
        newY:=y-border_thickness
        newW:=w+4*border_thickness
        newH:=h+4*border_thickness
    }

    Gui, Color, %border_color%
    Gui, -Caption

    ;WinSet, Region, 0-0 %w%-0 %w%-%h% 0-%h% 0-0 %border_thickness%-%border_thickness% %iw%-%border_thickness% %iw%-%ih% %border_thickness%-%ih% %border_thickness%-%border_thickness%
    WinSet, Region, %outerX%-%outerY% %outerX2%-%outerY% %outerX2%-%outerY2% %outerX%-%outerY2% %outerX%-%outerY%    %innerX%-%innerY% %innerX2%-%innerY% %innerX2%-%innerY2% %innerX%-%innerY2% %innerX%-%innerY% 

    ;Gui, Show, w%w% h%h% x%x% y%y% NoActivate, Table awaiting Action
    Gui, Show, w%newW% h%newH% x%newX% y%newY% NoActivate, Table awaiting Action
return


^#!b::
    if toggle := !toggle
        SetTimer, DrawRect, 100
    else
    {
        SetTimer, DrawRect, off
        Gui, Cancel
        Gui, Hide
    }
    return

^#!h::
    win_focus("left")
    return

^#!l::
  win_focus("right")
  return

^#!j::
  win_focus("down")
  return

^#!k::
  win_focus("up")
  return

IsInitialized(ByRef var) {
	return &var != &UninitializedVar
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

    +h::win_focus("left")
    +l::win_focus("right")
    +j::win_focus("down")
    +k::win_focus("up")

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


^#!r::
    ; Win Alt Ctrl + R reload autohotkey
    MsgBox Reloading autohotkey
    Reload
