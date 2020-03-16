;; ---------------------------------------------------
;; Window scrolling
;; ---------------------------------------------------
!MButton::win_scroll()

;; ---------------------------------------------------
;; Window mouse controls
;; ---------------------------------------------------
#LButton::win_move()
#MButton::win_resize()
#RButton::win_close()
#WheelUp::win_max_toggle()
#WheelDown::win_minimize()

; These can cause problems with forward / back mouse buttons
; XButton1 & LButton::win_move()
; XButton1 & MButton::win_resize()
; XButton1 & RButton::win_close()
; XButton1 & WheelUp::win_max_toggle()
; XButton1 & WheelDown::win_minimize()

win_max_toggle()
{
    MouseGetPos,,, HWND
	if win_is_desktop(HWND)
		return

    if win_is_maximized(HWND)
        WinRestore, ahk_id %HWND%
    else
        WinMaximize, ahk_id %HWND%
}

win_minimize()
{
    MouseGetPos,,, HWND
	if win_is_desktop(HWND)
		return
    ; This message is mostly equivalent to WinMinimize, but it avoids a bug with PSPad.
    PostMessage, 0x112, 0xf020,,, ahk_id %HWND%
}

win_close()
{
    MouseGetPos,,, HWND
	if win_is_desktop(HWND)
		return
    ; WinClose, ahk_id %HWND%
	Send {LButton}  ; WinClose() terminates the program.
	Send !{F4}      ; ALT+F4 closes the window.
}
win_activate(HWND)
{
    WinGetTitle, window_title, ahk_id %HWND%
    WinActivate, %window_title%    ; this doesn't always work :/
}

win_is_maximized(HWND)
{
	WinGet, is_maximized, MinMax, ahk_id %HWND%
	return is_maximized
}

win_scroll()
{
	Loop
	{
		GetKeyState, mouse_button_state, MButton, P
		if mouse_button_state = U 
			break

        MouseGetPos,, y1
        Sleep 10
        MouseGetPos,, y2
        speed := y1 - y2
        
        if (speed < 0) 
            MouseClick, WheelDown,,, -speed / 2
        if (speed > 0)
            MouseClick, WheelUp,,, speed / 2
	}
}

win_move()
{
	MouseGetPos, mouse_start_x, mouse_start_y, HWND
	if (win_is_desktop(HWND))
		return

    win_activate(HWND)

	if (win_is_maximized(HWND))
	{
		; to disallow moving maximized windows, uncomment return
		; return
		
		; restore window's size and position it
		; so it's centered around the mouse cursor
		MouseGetPos, mouse_x, mouse_y
		WinRestore, ahk_id %HWND%
		WinGetPos,,, win_w, win_h, ahk_id %HWND%
		restored_win_x := mouse_x - (win_w / 2)
		restored_win_y := mouse_y - (win_h / 2)
		WinMove, ahk_id %HWND%,, %restored_win_x%, %restored_win_y%
	}

	WinGetPos, win_start_x, win_start_y,,, ahk_id %HWND%
	Loop
	{
		GetKeyState, mouse_button_state, LButton, P ; Break if button has been released.
		if mouse_button_state = U
			break
		MouseGetPos, mouse_cur_x, mouse_cur_y
		mouse_cur_x -= mouse_start_x
		mouse_cur_y -= mouse_start_y
		win_new_x := (win_start_x + mouse_cur_x)
		win_new_y := (win_start_y + mouse_cur_y)
		WinMove, ahk_id %HWND%,, %win_new_x%, %win_new_y%
	}
}

win_resize()
{
	MouseGetPos, mouse_x1, mouse_y1, HWND
	if win_is_desktop(HWND)
		return

    if win_is_maximized(HWND)
		return
        
    win_activate(HWND)
		
	WinGetPos, win_x, win_y, win_w, win_h, ahk_id %HWND%
	
	; Define the window region the mouse is currently in.
	; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
	if (mouse_x1 < win_x + win_w / 2)
	   win_left := 1
	else
	   win_left := -1
	if (mouse_y1 < win_y + win_h / 2)
	   win_up := 1
	else
	   win_up := -1
	Loop
	{
		GetKeyState, button_state, MButton, P                           ; Break if button has been released.
		if button_state = U
			break
		MouseGetPos, mouse_x2, mouse_y2                                 ; Get the current mouse position.
		WinGetPos, win_x, win_y, win_w, win_h, ahk_id %HWND%            ; Get the current window position and size.
		mouse_x2 -= mouse_x1                                            ; Obtain an offset from the initial mouse position.
		mouse_y2 -= mouse_y1
		WinMove, ahk_id %HWND%,,  win_x + (win_left + 1) / 2 * mouse_x2 ; X of resized window
								, win_y +   (win_up + 1) / 2 * mouse_y2 ; Y of resized window
								, win_w  -     win_left      * mouse_x2 ; W of resized window
								, win_h  -       win_up      * mouse_y2 ; H of resized window
		mouse_x1 := mouse_x2 + mouse_x1                                 ; Reset the initial position for the next iteration.
		mouse_y1 := mouse_y2 + mouse_y1
	}
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                      ;;
;; KDE-Style Alt-Grab Window Move Convenience Script    ;;
;;                                                      ;;
;; version 0.1 - 07/24/04                               ;;
;; ck <use www.autohotkey.com forum to contact me>      ;;
;;                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Usage Instructions:
;; -------------------
;; Load Script into AutoHotKey (only verified to work properly with 1.0.16 and Windows XP)
;; - Hold down the Alt key and lef-click anywhere in a window to move the window

LAlt & LButton::
; If this command isn't used, all commands except those documented otherwise (e.g. WinMove and InputBox)
; use coordinates that are relative to the active window
CoordMode, Mouse, Screen

; speed things up
SetWinDelay, 0

; get current mouse position
MouseGetPos, OLDmouseX, OLDmouseY, WindowID

; get the postition and ID of the window under the mouse cursor
WinGetPos, winX, winY, winW, winH ,ahk_id %WindowID%

; Turn off Window Animation
;RegRead, BoolMinAni, HKEY_CURRENT_USER,Control Panel\Desktop\WindowMetrics, MinAnimate
;if BoolMinAni = 1
;{
;   ; this has no effect until it's reloaded / re-logon... (-> disabled code)
;   RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, MinAnimate, 0
;}

; this restore (= undo max or min) call tells the OS that originally
; maximized windows are now restored/normal and can be moved even after this script takes off
; this is absolutely mandatory for windows which remember their last location like IE windows
; otherwise you cannot properly maximize them anymore

;WinHide, ahk_id %WindowID%
WinRestore, ahk_id %WindowID%
WinMove, ahk_id %WindowID%,,%winX%,%winY%,%winW%,%winH%
;WinShow, ahk_id %WindowID%

Loop
{
   ; is the User still keeping that Alt key down?
   GetKeyState, AltKeyState, Alt, P
   if AltKeyState = U ; key has been released
   {
      break
   }
      
   ; get new mouse position
   MouseGetPos, newMouseX, newMouseY

   ; get relative mouse X movement
   if newMouseX < %OLDmouseX%
   {
      ; mouse was moved to the left
      Xdistance = %OLDmouseX%
      EnvSub, Xdistance, %newMouseX%   
      EnvSub, winX, %Xdistance%
   }
   else if newMouseX > %OLDmouseX%
   {
      ; mouse was moved to the right
      Xdistance = %newMouseX%
      EnvSub, Xdistance, %OLDmouseX%   
      EnvAdd, winX, %Xdistance%
   }
   else
   {
      ; mouse X coordinate wasn't changed
   }
   
   ; set OLDmouseX
   OLDmouseX = %newMouseX%

   ; repeat the same stuff for the Y-axis
   if newMouseY < %OLDmouseY%
   {
      Ydistance = %OLDmouseY%
      EnvSub, Ydistance, %newMouseY%   
      EnvSub, winY, %Ydistance%
   }
   else if newMouseY > %OLDmouseY%
   {
      Ydistance = %newMouseY%
      EnvSub, Ydistance, %OLDmouseY%   
      EnvAdd, winY, %Ydistance%
   }
   else
   {
   }
   OLDmouseY = %newMouseY%

   ; move Window accordingly
   WinMove, ahk_id %WindowID%,,%winX%,%winY%
}
return

;
; RESIZE WINDOW
;
!RButton::
    CoordMode, Mouse, Relative
    MouseGetPos, inWinX, inWinY, WinId
    if WinId =
        return
    WinGetPos, winX, winY, winW, winH, ahk_id %WinId%
    halfWinW = %winW%
    EnvDiv, halfWinW, 2
    halfWinH = %winH%
    EnvDiv, halfWinH, 2
    if inWinX < %halfWinW%
        MousePosX = left
    else
        MousePosX = right
    if inWinY < %halfWinH%
        MousePosY = up
    else
        MousePosY = down
    CoordMode, Mouse, Screen
    MouseGetPos, OLDmouseX, OLDmouseY, WinId
    SetWinDelay, 0
    Loop
    {
        GetKeyState, state, ALT, P
        if state = U
            break
        GetKeyState, state, RButton, P
        if state = U
            break
        MouseGetPos, newMouseX, newMouseY
        if newMouseX < %OLDmouseX%
        {
            Xdistance = %OLDmouseX%
            EnvSub, Xdistance, %newMouseX%
            if MousePosX = left ; mouse is on left side of window
            {
                EnvSub, winX, %Xdistance%
                EnvAdd, winW, %Xdistance%
            }
            else
            {
                EnvSub, winW, %Xdistance%
            }
        }
        else if newMouseX > %OLDmouseX%
        {
            ; mouse was moved to the right
            Xdistance = %newMouseX%
            EnvSub, Xdistance, %OLDmouseX%   
            if MousePosX = left ; mouse is on left side of window
            {
                EnvSub, winW, %Xdistance%
                EnvAdd, winX, %Xdistance%
            }
            else
            {
                EnvAdd, winW, %Xdistance%
            }
        }
        OLDmouseX = %newMouseX%
        if newMouseY < %OLDmouseY%
        {
            Ydistance = %OLDmouseY%
            EnvSub, Ydistance, %newMouseY%   
            if MousePosY = up ; mouse is on upper side of windows
            {
                EnvSub, winY, %Ydistance%
                EnvAdd, winH, %Ydistance%
            }
            else
            {
                EnvSub, winH, %Ydistance%
            }
        }
        else if newMouseY > %OLDmouseY%
        {
            Ydistance = %newMouseY%
            EnvSub, Ydistance, %OLDmouseY%   
            if MousePosY = up ; mouse is on upper side of windows
            {
                EnvAdd, winY, %Ydistance%
                EnvSub, winH, %Ydistance%
            }
            else
            {
                EnvAdd, winH, %Ydistance%
            }
        }
        OLDmouseY = %newMouseY%
        WinMove, ahk_id %WinID%,,%winX%,%winY%,%winW%,%winH%
    }
return