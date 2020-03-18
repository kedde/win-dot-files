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
>^r::
    send #r
return
>^a::
    send #a
return

; win+O - outlook
>^o::
    send {LWin down}{O}{LWin up}
return

; program launcher
>^F9::
    send #F9
return
>^F10::
    send #F10
return
>^F11::
    send #F11
return
>^F12::
    send #F12
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