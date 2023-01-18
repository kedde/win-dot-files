Persistent
#SingleInstance Force
; global CurrentLogLevel := LogLevel.Debug()
; global CurrentLogLevel := LogLevel.Information()
; global Logger := new Logger

global toggle := "0"
border_thickness := "2"
; border_color = FF0000
border_color := "00BFFF"
myGui := ""

; ListVars ; debug variables

; -------------------------------------------------------------- ; notes
; --------------------------------------------------------------
; ! = alt
; ^ = ctrl
; + = shift
; # = lwin|rwin
;
; #Include A_ScriptDir "\DesktopSwitcher.ahk"
; #Include A_ScriptDir "\MouseBehaviour.ahk"
; #Include A_ScriptDir "\WindowGrid.ahk"
; #Include A_ScriptDir "\RemoteDesktopHelper.ahk"
; #Include A_ScriptDir "\WindowBehaviour.ahk"
; #Include A_ScriptDir "\ProgramLauncher.ahk"
; #Include A_ScriptDir "\Logger.ahk"
; #Include %A_ScriptDir%\DrawBorder.ahk does not work right now

win_is_desktop(HWND)
{
    win_class := WinGetClass("ahk_id " HWND)
    return (win_class ~= "WorkerW"                  ; desktop window class could be WorkerW or Progman
         or win_class ~= "Progman"
         or win_class ~= "SideBar_HTMLHostWindow")  ; sidebar widgets
}

get_visible_windows()
{
    visibleWindowAhkIds := []
    owindows := WinGetList(,,,)
    awindows := Array()
    windows := owindows.Length
    For v in owindows
    {   awindows.Push(v)
    }
    Loop awindows.Length
    {
        id := awindows[A_Index]
        title := WinGetTitle("ahk_id " id)
        style := WinGetstyle("ahk_id " id)
        wClass := WinGetClass("ahk_id " id)
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

    winid := WinGetID("A") ; WinGet("A") ; <-- need to identify window A = acitive
    WinGetPos(&X, &Y, &Width, &Height, "ahk_id " winid)

    activateWindowId := ""
    deltaX :=  10000000
    deltaY :=  10000000
    for index, ahkId in visibleWindowAhkIds ; Enumeration is the recommended approach in most cases.
    {
        if (ahkId = winid)
        {
            ; dont consider active window
            winTitle := WinGetTitle("ahk_id " winId)
            logText := "active: (" . X . "," . Y . "," . Width . "," . Height . ") " . winTitle
            ; Logger.WriteLog(logText, LogLevel.Debug())
            continue
        }
        WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " ahkId)
        winTitle := WinGetTitle("ahk_id " ahkId)
        
        isAllowed := false

        ; TODO verify
        ; When window is full screen X of the active window can be -8 this makes
        ; moving to the right window wrong
        ; offset when in fullscreen mode? 10px
        offset := "10"
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

        winTitle := WinGetTitle("ahk_id " ahkId)
        logText := "(" . winX . "," . winY . ", " . winWidth . ", " . winHeight . ") currentDeltaX: " . currentDeltaX . " currentDeltaY " . currentDeltaY . " " . winTitle
;       Logger.WriteLog(logText, LogLevel.Debug())
        if (isAllowed AND (currentDeltaX < deltaX OR currentDeltaY < deltaY) )
        {
            deltaX := currentDeltaX
            deltaY := currentDeltaY
            activateWindowId := ahkId
            
            title := WinGetTitle("ahk_id " winId)
            logText := winTitle . "  `"(`" " . winX . " `",`" " . winY . " `") `" " . title . "  `"(`" " . X . " `",`" " . Y . "`") deltaX: `" " . deltaX
            ; logText =  "(" %winX% "," %winY% ") and (" %X% "," %Y%") delta: " %delta%
            ; Logger.WriteLog(logText, LogLevel.Debug())
        }
    }

    if (activateWindowId != "")
    {
        switchToTitle := WinGetTitle("ahk_id " activateWindowId)
        switchToLogText := "`"switching to window with title: `" " . switchToTitle
;        Logger.WriteLog(switchToLogText, LogLevel.Debug())
;        Logger.WriteLog("============================================", LogLevel.Debug())
        WinActivate("ahk_id " activateWindowId)
    }

}


EnsureInitializedGui() {
   global ; Assume-global mode https://www.autohotkey.com/docs/v2/Functions.htm#Global
   if (!myGui){
        myGui := Gui()
    }
}

DrawRect()
{ 
    EnsureInitializedGui()
    if (!WinExist("A")){
        return
    }

    WinGetPos(&x, &y, &w, &h, "A")
    if (x="")
        return
    myGui.Opt("+Lastfound +AlwaysOnTop +Toolwindow")

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
        myState := WinGetMinMax("A")
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

    myGui.BackColor := border_color
    myGui.Opt("-Caption")

    ;WinSet, Region, 0-0 %w%-0 %w%-%h% 0-%h% 0-0 %border_thickness%-%border_thickness% %iw%-%border_thickness% %iw%-%ih% %border_thickness%-%ih% %border_thickness%-%border_thickness%
    WinSetRegion(outerX "-" outerY " " outerX2 "-" outerY " " outerX2 "-" outerY2 " " outerX "-" outerY2 " " outerX "-" outerY "    " innerX "-" innerY " " innerX2 "-" innerY " " innerX2 "-" innerY2 " " innerX "-" innerY2 " " innerX "-" innerY)

    ;Gui, Show, w%w% h%h% x%x% y%y% NoActivate, Table awaiting Action
    myGui.Title := "Table awaiting Action - border"
    myGui.Show("w" . newW . " h" . newH . " x" . newX . " y" . newY . " NoActivate")
}


; border
^#!b::
{ 
    global
    toggle := !toggle
    if (toggle)
        SetTimer(DrawRect,100)
    else
    {
        EnsureInitializedGui()
        SetTimer(DrawRect,0)
        myGui.Hide()
    }
} 

^#!h::
{ 
    win_focus("left")
} 

^#!l::
{ 
  win_focus("right")
} 

^#!j::
{ 
  win_focus("down")
} 

^#!k::
{ 
  win_focus("up")
} 

IsInitialized(&var) {
	return &var != &UninitializedVar
}


is_equal(a, b, delta := 10)
{
    return Abs(a - b) <= delta
}

;; ========================================================================================================
;; Bindings
;; ========================================================================================================

; *CapsLock::Esc
*CapsLock::
{ 
    KeyWait("CapsLock")
    if (A_ThisHotkey = "*CapsLock")
	Send("{Blind}{Esc}")
}

#HotIf GetKeyState("CapsLock", "P")
{
    ; vim movements if holding capslock
    h::    Send("{blind}{Left}")
    l::    Send("{blind}{Right}")
    j::    Send("{blind}{Down}")
    k::    Send("{blind}{Up}")

    m::    WinMaximize("A")
    n::    WinRestore("A")
    ,::    send("#{left}")
    .::    send("#{right}")
    0::    Send("{Home}")
    4::    Send("{End}")

    enter::    Send("#+{Left}") ; move current window to next monitor
    ; n::Send, #t
    ; p::Send, #+t
    w::    Send("^{Right}")
    d::    Send("{PgDn}")
    u::    Send("{PgUp}")
    F9::    Send("{Media_Play_Pause}")
    F10::    Send("{Volume_Mute}")  ; Mute/unmute the master volume.}
    F11::    Send("{Volume_Down}")
    F12::    Send("{Volume_Up}")

    t:: {
        activeWindow := WinGetTitle("A")
        if IsWindowAlwaysOnTop(activeWindow) {
            notificationMessage := "The window '" . activeWindow . "' is now always on top."
            notificationIcon := 16 + 1 ; No notification sound (16) + Info icon (1)
        }
        else {
            notificationMessage := "The window  '" . activeWindow . "' is no longer always on top."
            notificationIcon := 16 + 2 ; No notification sound (16) + Warning icon (2)
        }
        WinSetAlwaysontop(, "A")
        TrayTip("Always-on-top", notificationMessage, notificationIcon)
        Sleep(3000) ; Let it display for 3 seconds.
        HideTrayTip()
    } 

    IsWindowAlwaysOnTop(windowTitle) {
        windowStyle := WinGetExStyle(windowTitle)
        isWindowAlwaysOnTop := windowStyle & 0x8 ? false : true ; 0x8 is WS_EX_TOPMOST.
        return isWindowAlwaysOnTop
    }

    HideTrayTip() {
        TrayTip()  ; Attempt to hide it the normal way.
        if SubStr(A_OSVersion, 1, 3) = "10." {
            Tray:= A_TrayMenu
            Tray.NoIcon()
            Sleep(200)  ; It may be necessary to adjust this sleep.
            Tray.Icon()
        }
    }

    ; windows switcher
    o::{ 
        SendInput("{LControl Down}{LAlt Down}{Tab}{LControl Up}{LAlt Up}")
        ; !l::Send, {ALTDOWN}{TAB}{ALTUP}
        ; TODO holding down alt when switching - confuses windows and thinks some keys are still pushed
        ; !l::Send, {ALT}{TAB}
        ; !h::Send, {ALTDOWN}{ShiftDown}{TAB}{ALTUP}
    } ; V1toV2: Added Bracket before hotkey or Hotstring

    +h::win_focus("left")
    +l::win_focus("right")
    +j::win_focus("down")
    +k::win_focus("up")

    ; capslock + alt + h/l switch desktop left and right
    !h::    Send("^#{left}")
    !l::    Send("^#{right}")

    ; toggle capslock
    c::{ 
        CapsLockState := GetKeyState("CapsLock", "T") ? "D" : "U"
        if (CapsLockState = "D")
            SetCapsLockState("AlwaysOff")
        else
            SetCapsLockState("AlwaysOn")
    }
}
#HotIf ; <== no expression after hotif turns of hotif

; when on rdp push: ctrl+alt+home twice to get to desktop 1
^!Home::
{ 
  ;switchDesktopByNumber(1)
  MsgBox "test"
}
; use ctrl to send curly braces
^7::{
  Send("{{}")
}
; ^7::Send("{") 
^0::Send("{}}")


; use ctrl to send square bracets
^8::Send("{[}")
^9::Send("{}]}")

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
{ ; V1toV2: Added bracket
    Sleep(200)
    ErrorLevel := SendMessage(0x112, 0xF170, 2, , "Program Manager")
}

;; ==========================================================================================
;; Functions
;; ==========================================================================================

; ctrl + shift + "+" volumen up
^+NumpadAdd::
{ 
    Send("{Volume_Up}")  ; Raise the master volume by 1 interval (typically 5%).
}

; ctrl + shift + "-" volumen down
^+NumpadSub::
{ 
    Send("{Volume_Down 3}")  ; Lower the master volume by 3 intervals.
}

; ctrl + shift + "/" mute

^+NumpadDiv::
{ ; V1toV2: Added bracket
    Send("{Volume_Mute}")  ; Mute/unmute the master volume.
} 

^!PgDn::Send("{Media_Next}")
^!PgUp::Send("{Media_Prev}")
; ^!Home::Send   {Media_Play_Pause}
; ""CTRL + ALT + Home"  for pause

; "CTRL + ALT + UP"  for info
^!Up::
{
	DetectHiddenWindows(true)
	SetTitleMatchMode(2)
	; spotify
	now_playing := WinGetTitle("ahk_class SpotifyMainWindow")
	;StringTrimLeft, playing, now_playing, 10; not needed anymore
	playing := SubStr(now_playing, (0)+1)
	; WinGrooves
	; WinGetTitle, now_playing, ahk_class WindowsForms10.Window.8.app.0.141b42a_r29_ad1
	; StringTrimRight, playing, now_playing, 12
	; show tray tip
	TrayTip("Now playing:", playing, 16)
	DetectHiddenWindows(false)
}


; Maximize
!F10::WinMaximize("A")
; Restore
!F5::WinRestore("A")


; Win Alt Ctrl + R reload autohotkey
^#!r::
{ 
    MsgBox("Reloading autohotkey")
    Reload()
} 
