; https://github.com/PunctualJustin/AutoHotkey-scripts/blob/master/alt_alttab.ahk
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
    SetTitleMatchMode, RegEx

#IfWinActive ahk_class TscShellContainerClass
    
    ;ALT+TAB
    
    <!Tab::
        SendInput, {LAlt Down}{PgUp}
    Return
    
    <!+Tab::
        SendInput, {LAlt Down}{PgDn}
    Return
    
    ;WinKey+D ;show desktop
	
    Fired:=0
    LWin & d::
		SendInput {RControl Down}D{RControl up}
		Sleep, 250
        Fired:=1
    Return
    
    ;WinKey+R ;open run
    #r::
        Fired = 1
        send {LAlt Down}{Home Down}run{Home Up}{LAlt up}
    Return
    
    #Numpad1::
		SendInput {RControl Down}{Numpad1}{RControl up}
        Fired:=1
		Return
    #Numpad2:: 
		SendInput {RControl Down}{Numpad2}{RControl up}
        Fired:=1
		Return
    #Numpad3:: 
		SendInput {RControl Down}{Numpad3}{RControl up}
        Fired:=1
		Return
    #Numpad4:: 
		SendInput {RControl Down}{Numpad4}{RControl up}
        Fired:=1
		Return
    #Numpad5:: 
		SendInput {RControl Down}{Numpad5}{RControl up}
        Fired:=1
		Return
    #Numpad6:: 
		SendInput {RControl Down}{Numpad6}{RControl up}
        Fired:=1
		Return
    #Numpad7:: 
		SendInput {RControl Down}{Numpad7}{RControl up}
        Fired:=1
		Return
    #Numpad8::
		SendInput {RControl Down}{Numpad8}{RControl up}
        Fired:=1
		Return
    #Numpad9::
		SendInput {RControl Down}{Numpad9}{RControl up}
        Fired:=1
		Return
    Return


	/*
	ahk on rdp machine:
	;; Mapping from the key right control to windows key 
		>^+D::
			send #d
		return
		>^Numpad9::
			send #{Numpad9}
		return
		>^Numpad8::
			send #{Numpad8}
		return
		>^Numpad7::
			send #{Numpad7}
		return
		>^Numpad6::
			send #{Numpad6}
		return
		>^Numpad5::
			send #{Numpad5}
		return
		>^Numpad3::
			send #{Numpad3}
		return
		>^Numpad2::
			send #{Numpad2}
		return
		>^Numpad1::
			send #{Numpad1}
		return
		>^Numpad0::
			send #{Numpad0}
		return
	*/
    
    ;Windows key
    LWin Up::
    RWin Up::
        if Fired = 0
        {
            sendInput, {LAlt Down}{Home}{LAlt up}
        }
        else
        {
            Fired:=0
        }
    Return
    
    ;when switching virtual desktops, don't trigger startmenu via WinKey
    ~#^Left::
    ~#^Right::
        Fired:=1
    Return
    
#IfWinActive