
;; ---------------------------------------------------
;; Move between monitors
;; ---------------------------------------------------
#Numpad0::Send #+{Left}     ; forward to the standard windows 7 shortcut

;; ---------------------------------------------------
;; Fixed positions
;; ---------------------------------------------------
#^Numpad4::win_align_to_grid(3, 3,   1, 1,   2, 3,  "A")
#^Numpad9::win_align_to_grid(3, 2,   3, 1,   1, 1,  "A")
#^Numpad3::win_align_to_grid(3, 2,   3, 2,   1, 1,  "A")

; win_align_to_grid(GridCols, GridRows, GridOffsetUnitsX, GridOffsetUnitsY, GridUnitsW, GridUnitsH, WinID)

;; ---------------------------------------------------
;; Compiz-like grid
;; ---------------------------------------------------
#Numpad1::win_resize_toggle_left(2, 1, 2)
#Numpad2::win_resize_toggle_center(2, 1, 2)
#Numpad3::win_resize_toggle_right(2, 1, 2)
#Numpad4::win_resize_toggle_left(1, 2, 2)
#Numpad5::win_resize_toggle_center(1, 2, 2)
#Numpad6::win_resize_toggle_right(1, 2, 2)
#Numpad7::win_resize_toggle_left(1, 1, 2)
#Numpad8::win_resize_toggle_center(1, 1, 2)
#Numpad9::win_resize_toggle_right(1, 1, 2)

#!Numpad1::win_resize_toggle_left(2, 2, 3)
#!Numpad2::win_resize_toggle_center(2, 2, 3)
#!Numpad3::win_resize_toggle_right(2, 2, 3)
#!Numpad4::win_align_to_grid(3, 3,   1, 1,   3, 1,  "A")
#!Numpad5::win_align_to_grid(3, 3,   1, 2,   3, 1,  "A")
#!Numpad6::win_align_to_grid(3, 3,   1, 3,   3, 1,  "A")
#!Numpad7::win_resize_toggle_left(1, 2, 3)
#!Numpad8::win_resize_toggle_center(1, 2, 3)
#!Numpad9::win_resize_toggle_right(1, 2, 3)

win_resize_toggle_params(ByRef mon_w_12, ByRef mon_w_13, ByRef win_w)
{
	HWND := "A"
	win_resolve(HWND)
	if win_is_desktop(HWND)
		return false
	WinGetPos,,, win_w, win_h, ahk_id %HWND%
	win_get_window_monitor_params(mon_x, mon_y, mon_w, mon_h, mon_cur, HWND)
	mon_w_12 := mon_w / 2
	mon_w_13 := mon_w / 3
	return true
}

win_resize_toggle_right(row, height, row_count)
{
	if !win_resize_toggle_params(mon_w_12, mon_w_13, win_w)
		return
	if is_equal(win_w, mon_w_12)
		win_align_to_grid( 3, row_count,   3, row,   1, height,   "A" )
	else if is_equal(win_w, mon_w_13)
		win_align_to_grid( 3, row_count,   2, row,   2, height,   "A" )
	else
		win_align_to_grid( 2, row_count,   2, row,   1, height,   "A" )
}

win_resize_toggle_left(row, height, row_count)
{
	if !win_resize_toggle_params(mon_w_12, mon_w_13, win_w)
		return
	if is_equal(win_w, mon_w_12)
		win_align_to_grid( 3, row_count,   1, row,   1, height,   "A" )
	else if is_equal(win_w, mon_w_13)
		win_align_to_grid( 3, row_count,   1, row,   2, height,   "A" )
	else
		win_align_to_grid( 2, row_count,   1, row,   1, height,   "A" )
}

win_resize_toggle_center(row, height, row_count)
{
	if !win_resize_toggle_params(mon_w_12, mon_w_13, win_w)
		return
	if is_equal(win_w, mon_w_13)
		win_align_to_grid( 3, row_count,   1, row,   3, height,   "A" )
	else
		win_align_to_grid( 3, row_count,   2, row,   1, height,   "A" )
}

;; -----------------------------------------------------------------------
;; Verifies that the given window exists. Along the way it also resolves
;; special values of the "WinID" function parameter:
;;		1) The letter "A" means to use the Active window
;;		2) The letter "M" means to use the window under the Mouse
;; The parameter value is checked to see that it corresponds to a valid
;; window, the function returning true or false accordingly.

win_resolve(ByRef HWND)
{
	if (HWND = "A")
		HWND := WinExist("A")
	else if (HWND = "M")
		MouseGetPos,,, HWND

	IfWinExist, ahk_id %HWND%
        return true

    SoundPlay, *64 ; Make a short noise so the user knows to stop expecting something fun to happen.
    ;MsgBox, 16, Error, Specified window does not exist.`nWindow ID = %HWND%
    return false
}

;; -----------------------------------------------------------------------
;; This function returns the position and dimensions of the monitor which
;; contains (the most screen area of) a specified window.

win_get_window_monitor_params(ByRef MonX, ByRef MonY, ByRef MonW, ByRef MonH, ByRef MonN, WinID)
{
	; Compute the dimensions of the subject window
	WinGetPos, WinLeft, WinTop, WinWidth, WinHeight, ahk_id %WinID%
	WinRight  := WinLeft + WinWidth
	WinBottom := WinTop  + WinHeight

	; How many monitors are we dealing with?
	SysGet, MonitorCount, MonitorCount

	; For each active monitor, we get Top, Bottom, Left, Right of the monitor's
	;  'Work Area' (i.e., excluding taskbar, etc.). From these values we compute Width and Height.
	;  As we loop, we track which monitor has the largest overlap (in the sense of screen area)
	;  with the subject window. We call that monitor the window's 'Source Monitor'.

	SourceMonitorNum = 0
	MaxOverlapArea   = 0

	Loop, %MonitorCount%
	{
		MonitorNum    := A_Index		; Give the loop variable a sensible name

		; Retrieve position / dimensions of the monitor's work area
		SysGet, Monitor, MonitorWorkArea, %MonitorNum%
		MonitorWidth  := MonitorRight  - MonitorLeft
		MonitorHeight := MonitorBottom - MonitorTop

		; Check for any overlap with the subject window
		; The following ternary expressions simulate "max(a,b)" and "min(a,b)" type function calls:
		;	max(a,b) <==> (a>b ? a : b)
		;	min(a,b) <==> (a<b ? a : b)
		; The intersection between two windows is characterized as that part below both
		; windows' "Top" values and above both "Bottoms"; similarly to the right of both "Lefts"
		; and to the left of both "Rights". Hence the need for all these min/max operations.

		MaxTop    := (WinTop    > MonitorTop   ) ? WinTop    : MonitorTop
		MinBottom := (WinBottom < MonitorBottom) ? WinBottom : MonitorBottom

		MaxLeft   := (WinLeft   > MonitorLeft  ) ? WinLeft   : MonitorLeft
		MinRight  := (WinRight  < MonitorRight ) ? WinRight  : MonitorRight

		HorizontalOverlap := MinRight  - MaxLeft
		VerticalOverlap   := MinBottom - MaxTop

		if (HorizontalOverlap > 0 and VerticalOverlap > 0)
		{
			OverlapArea := HorizontalOverlap * VerticalOverlap
			if (OverlapArea > MaxOverlapArea)
			{
				SourceMonitorLeft		:= MonitorLeft
				SourceMonitorRight		:= MonitorRight		; not used
				SourceMonitorTop		:= MonitorTop
				SourceMonitorBottom		:= MonitorBottom	; not used
				SourceMonitorWidth		:= MonitorWidth
				SourceMonitorHeight		:= MonitorHeight
				SourceMonitorNum		:= MonitorNum

				MaxOverlapArea      	:= OverlapArea
			}
		}
	}

	if MaxOverlapArea = 0
	{
		; if the subject window wasn't visible in *ANY* monitor, default to the 'Primary'
		SysGet, SourceMonitorNum, MonitorPrimary

		SysGet, SourceMonitor, MonitorWorkArea, %SourceMonitorNum%
		SourceMonitorWidth  := SourceMonitorRight  - SourceMonitorLeft
		SourceMonitorHeight := SourceMonitorBottom - SourceMonitorTop
	}

	MonX := SourceMonitorLeft
	MonY := SourceMonitorTop
	MonW := SourceMonitorWidth
	MonH := SourceMonitorHeight
	MonN := SourceMonitorNum
}

;; -----------------------------------------------------------------------
;; Prepare a window for any sort of scripted 'move' operation.
;;
;; The first thing to do is to restore the window if it was min/maximized.
;; The reason for this is that the standard min/max window controls don't
;; seem to like it if you script a move / resize while a window is
;; minimized or maximized.
;;
;; After that, we look to see which monitor holds the "most" of the window
;; (in the sense of screen real estate) and we return a bunch of information
;; about that monitor so the caller can figure out the best way to do the move.
;;
;; The original min/max state is also returned in case the window needs to
;; be restored to that state at some future time.
;;
;; The window ID is also resolved, as per the function win_resolve().

win_prepare_to_move(ByRef MonX, ByRef MonY, ByRef MonW, ByRef MonH, ByRef MonN, ByRef WinMinMax, ByRef HWND)
{
	if !win_resolve(HWND)
		return false

	if win_is_maximized(HWND)
		WinRestore, ahk_id %HWND%

	win_get_window_monitor_params(MonX, MonY, MonW, MonH, MonN, HWND)
	return true
}

;; -----------------------------------------------------------------------
;; Move and resize a window to align it to a specified screen grid.
;;
;; The first two parameters, GridRows and GridCols, determine the granularity
;; of the grid. The other four grid parameters determine which grid cell
;; the window is to fit into and how big it should be in each direction:
;;
;;		GridOffsetUnitsX:	The X coordinate of the top left grid cell, in the range 1..GridCols
;;		GridOffsetUnitsY:	The Y coordinate of the top left grid cell, in the range 1..GridRows
;;		GridUnitsW:			The width  of the window, in units of cells
;;		GridUnitsH:			The height of the window, in units of cells
;;
;; For example, to grid six windows on the screen, three across and two
;; down, each occupying a single grid cell, you might issue the following
;; six commands to six different windows (WinID1 .. WinID6):
;;
;;	 	win_align_to_grid( 3, 2,   1, 1,   1, 1,   WinID1 )
;;	 	win_align_to_grid( 3, 2,   2, 1,   1, 1,   WinID2 )
;;	 	win_align_to_grid( 3, 2,   3, 1,   1, 1,   WinID3 )
;;	 	win_align_to_grid( 3, 2,   1, 2,   1, 1,   WinID4 )
;;	 	win_align_to_grid( 3, 2,   2, 2,   1, 1,   WinID5 )
;;	 	win_align_to_grid( 3, 2,   3, 2,   1, 1,   WinID6 )
;;
;; I've added extra spaces between pairs of related parameters to act as visual
;; clues for the reader. The spaces are, of course, not required.
;;
;; These commands would result in the following gridded window arrangement:
;;
;;		+---------+---------+---------+
;;		|         |         |         |
;;		|    1    |    2    |    3    |
;;		|         |         |         |
;;		+---------+---------+---------+
;;		|         |         |         |
;;		|    4    |    5    |    6    |
;;		|         |         |         |
;;		+---------+---------+---------+
;;
;; As another example, consider the following two commands:
;;
;;	 	win_align_to_grid( 3, 2,   1, 1,   2, 2,   WinID7 )
;;	 	win_align_to_grid( 3, 2,   3, 1,   1, 2,   WinID8 )
;;
;; Here the windows are larger than a single grid cell, as they were in the first example.
;; The first command asks for a 2x2 window and the second one asks for a 1x2 (1 col, 2 rows)
;; window. This ought to result in the following window arrangement:
;;
;;		+-------------------+---------+
;;		|                   |         |
;;		|                   |         |
;;		|                   |         |
;;		|        7          |    8    |
;;		|                   |         |
;;		|                   |         |
;;		|                   |         |
;;		+-------------------+---------+

win_align_to_grid(GridCols, GridRows, GridOffsetUnitsX, GridOffsetUnitsY, GridUnitsW, GridUnitsH, WinID)
{
	if !win_prepare_to_move(MonX, MonY, MonW, MonH, MonN, WinMinMax, WinID)
		return false

	X := Round(MonW * (GridOffsetUnitsX - 1) / GridCols) + MonX
	Y := Round(MonH * (GridOffsetUnitsY - 1) / GridRows) + MonY
	W := Round(MonW *  GridUnitsW            / GridCols)
	H := Round(MonH *  GridUnitsH            / GridRows)

	WinMove, ahk_id %WinID%,, X, Y, W, H
	return true
}