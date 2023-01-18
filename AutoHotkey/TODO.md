# TODO

* [x] change capslock:esc mapping to send on capslock keyup event
* [x] Change focus of active window to the one to the right 
  - [x] capslock+shift+l change focus to window to the right
  - [x] capslock+shift+h change focus to window to the left
* [x] Add border around active window
* [ ] Grid-issue e.g. when screen in portrait mode e.g. chrome resizes wrongly
* [ ] Media keys (controls)

# DEV

* [x] refresh autohotkey from nvim - maybe just use autohotkey-reload method to restart it: https://stackoverflow.com/questions/15706534/hotkey-to-restart-autohotkey-script
* [ ] caps-lock+alt+l does not working correctly when holding down alt when switching - confuses windows and thinks some keys are still pushed
* [x] Logs - possible create a log - view it with get-content --wait

BUG: caps lock + shift + l... when wezterm is in fullscreen is not selected
