; Press Ctrl+Shift+Space to set any currently active window to be always on top.
; Press Ctrl+Shift+Space again set the window to no longer be always on top.
; Source: https://www.howtogeek.com/196958/the-3-best-ways-to-make-a-window-always-on-top-on-windows


; win+O open window switcher 
#o::
    SendInput  {LControl Down}{LAlt Down}{Tab}{LControl Up}{LAlt Up}
return 

; vim movement in windows switcher (ctrl+alt+tab) 
#IfWinExist, ahk_class XamlExplorerHostIslandWindow ; Windows 11
    h::Left
    l::Right
    k::Up
    j::Down
#IF

