;; ahk on rdp machine:
;; Mapping from the key "right contro"l to windows key 

; rightControl+insert map to alt insert 
>^Insert::
	Send <!{Insert}
return

; ShowDesktop
>^+D::
    send #d
return
; run dialog
>^r::
    send #r
return

; windows notification
>^a::
    send #a
return

; explorer
>^e::
    send {LWin down}{e}{LWin up}
return

; win+O - outlook
>^o::
    send {LWin down}{O}{LWin up}
return

; program launchers
; ===================
; linqpad
>^F9::
    send {LWin down}{F9}{LWin up}
return
; vs code
>^F10::
    send {LWin down}{F10}{LWin up}
return
; spotify
>^F11::
    send {LWin down}{F11}{LWin up}
return
; windows terminal 
>^F12::
    send {LWin down}{F12}{LWin up}
return

; map the grid layout
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
>^Numpad4::
    send #{Numpad4}
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