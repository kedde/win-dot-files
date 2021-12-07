; Get the HWND of the Spotify main window.
getSpotifyHwnd() {
	WinGet, id, list, ahk_exe  Spotify.exe
        Loop, %id%
        {
            this_ID := id%A_Index%
            WinGetTitle, title, ahk_id %this_ID%
			
            If (title = "" )
                continue
				
			return this_ID
		}
}

getLinqPadHwnd(){
	WinGet, id, list, ahk_exe LINQPad.exe
        Loop, %id%
        {
            this_ID := id%A_Index%
            WinGetTitle, title, ahk_id %this_ID%
            If (title = "")
                continue

			;; MsgBox %title% %this_ID%
				
			return this_ID
		}
}

getVsCodeHwnd(){
	WinGet, id, list, ahk_exe Code.exe
        Loop, %id%
        {
            this_ID := id%A_Index%
            WinGetTitle, title, ahk_id %this_ID%
            If (title = "")
                continue
				
			return this_ID
		}
}

#n::
FormatTime, CurrentDateYear,, yyyy
FormatTime, CurrentDateMonth,, MM
FormatTime, CurrentDateTime,, yyyy-MM-dd
EnvGet, oneDrive, OneDriveConsumer
workDirectory := "c:\notes\"
MsgBox %workDirectory%
arguments="--title="Note-%CurrentDateTime%"" nvim %workDirectory%\%CurrentDateYear%\%CurrentDateMonth%\%CurrentDateTime%.md"
ShellRun("wt.exe", arguments, workDirectory)
return

;; 
;; Toggle linqpad
#F9:: 
DetectHiddenWindows, on
IfWinExist ahk_exe LINQPad.exe
{
	linqpadId := getLinqPadHwnd()

	IfWinActive ahk_exe LINQPad.exe
		{
			WinHide, ahk_id %linqpadId%
			WinActivate ahk_class Shell_TrayWnd
		}
	else
		{
			WinShow, ahk_id %linqpadId%
			WinActivate, ahk_id %linqpadId%
		}
}
else
	ShellRun("C:\Program Files (x86)\LINQPad5\LINQPad.exe")

DetectHiddenWindows, off
return

;; Toggle Spotify
#F11::
DetectHiddenWindows, on
IfWinExist ahk_exe Spotify.exe
{
	spotifyHwnd := getSpotifyHwnd()
	IfWinActive ahk_exe Spotify.exe
	{
		WinHide, ahk_id %spotifyHwnd%
		WinActivate ahk_class Shell_TrayWnd
	}
	else
	{
		WinShow, ahk_id %spotifyHwnd%
		WinActivate, ahk_id %spotifyHwnd%
	}
}
else{
	ShellRun("Spotify.exe")
}
DetectHiddenWindows, off
return	


;; Toggle WindowsTerminal
#F12:: 
DetectHiddenWindows, on
IfWinExist ahk_class CASCADIA_HOSTING_WINDOW_CLASS
{
	IfWinActive ahk_class CASCADIA_HOSTING_WINDOW_CLASS
		{
			WinHide ahk_class CASCADIA_HOSTING_WINDOW_CLASS
			WinActivate ahk_class Shell_TrayWnd
		}
	else
		{
			WinShow ahk_class CASCADIA_HOSTING_WINDOW_CLASS
			WinActivate ahk_class CASCADIA_HOSTING_WINDOW_CLASS
		}
}
else
	ShellRun("wt.exe")

DetectHiddenWindows, off
return

;; 
;; Toggle code
#F10:: 
DetectHiddenWindows, on

IfWinExist ahk_exe Code.exe
{
	codeHandle := getVsCodeHwnd()
	IfWinActive ahk_exe Code.exe
		{
			WinHide, ahk_id %codeHandle%
			WinActivate ahk_class Shell_TrayWnd
		}
	else
		{
			WinShow, ahk_id %codeHandle%
			WinActivate, ahk_id %codeHandle%
		}
}
else{
	vsCodePath="C:\Users\%A_UserName%\AppData\Local\Programs\Microsoft VS Code\Code.exe"
	ShellRun(vsCodePath)
}

DetectHiddenWindows, off
return
;Parameters for ShellRun
;1 application to launch
;2 command line parameters
;3 working directory for the new process
;4 "Verb" (For example, pass "RunAs" to run as administrator)
;5 Suggestion to the application about how to show its window - see the msdn link for possible values


/*
  ShellRun("Taskmgr.exe")  ;Task manager
  ShellRun("Notepad", A_ScriptFullPath)  ;Open a file with notepad
  ShellRun("Notepad",,,"RunAs")  ;Open untitled notepad as administrator


  ShellRun by Lexikos
    requires: AutoHotkey_L
    license: http://creativecommons.org/publicdomain/zero/1.0/

  Credit for explaining this method goes to BrandonLive:
  http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/
 
  Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
  http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
ShellRun(prms*)
{
    shellWindows := ComObjCreate("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")
    
    desktop := shellWindows.Item(ComObj(19, 8)) ; VT_UI4, SCW_DESKTOP                
   
    ; Retrieve top-level browser object.
    if ptlb := ComObjQuery(desktop
        , "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
        , "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
    {
        ; IShellBrowser.QueryActiveShellView -> IShellView
        if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv:=0) = 0
        {
            ; Define IID_IDispatch.
            VarSetCapacity(IID_IDispatch, 16)
            NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")
           
            ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
            DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
                , "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp:=0)
           
            ; Get Shell object.
            shell := ComObj(9,pdisp,1).Application
           
            ; IShellDispatch2.ShellExecute
            shell.ShellExecute(prms*)
           
            ObjRelease(psv)
        }
        ObjRelease(ptlb)
    }
}
