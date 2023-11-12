#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%/shared.ahk"

SendMode "Input"

^Esc::ExitApp

global pos1 := Point()
global pos2 := Point()

global looping := false
global delay := 1000

NumpadEnter::{
	global delay, looping

	if(looping)
	{
		looping := false
	}
	else
	{
		looping := true
		while looping {
			Click pos1.ToStringSpace() " Right" ; bucket
			Sleep 250 ; UI animation
			Click pos2.ToStringSpace() " Right" ; bucket 2
			
			Sleep delay ; player animation
		}
	}
}

Numpad0::{
	MouseGetPos &x, &y
	global pos1 := Point(x, y)
}

Numpad1::{
	MouseGetPos &x, &y
	global pos2 := Point(x, y)
}

Numpad2::global delay := 300
Numpad3::global delay := 600
Numpad4::global delay := 900
Numpad5::global delay := 1200
Numpad6::global delay := 1500
Numpad7::global delay := 1800
Numpad8::global delay := 2100
Numpad9::global delay := 2400