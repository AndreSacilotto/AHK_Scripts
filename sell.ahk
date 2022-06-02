#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CoordMode, Mouse, Relative

A::
	MouseGetPos, posX, posY
	vec := "x" . posX . " y" . posY
return

S::
	ControlClick, % vec, ahk_exe MEmu.exe,,,, Pos NA
return

~+Esc::ExitApp