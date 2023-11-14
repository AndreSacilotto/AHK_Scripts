#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

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
		return
	}
	looping := true
	while looping {
		MyClick(pos1.x, pos1.y, "Right") ; bucket
		Sleep 300 ; UI animation
		MyClick(pos2.x, pos2.y, "Right") ; bucket UI
		
		Sleep delay ; player animation
	}
	looping := false
}

Numpad0::{
	global pos1 := GetClientMPos()
}

Numpad1::{
	global pos2 := GetClientMPos()
}

NumpadMult::MsgBox delay

NumpadSub::global delay -= 300
NumpadAdd::global delay += 300

Numpad2::global delay := 300
Numpad3::global delay := 600
Numpad4::global delay := 900
Numpad5::global delay := 1200
Numpad6::global delay := 1500
Numpad7::global delay := 1800
Numpad8::global delay := 2100
Numpad9::global delay := 2400