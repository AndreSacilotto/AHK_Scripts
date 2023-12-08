#Requires AutoHotkey v2.0
#SingleInstance Off ; Force
#MaxThreadsPerHotkey 2

#Include "%A_ScriptDir%/shared.ahk"

SendMode "Input"

^Esc::ExitApp

global pos1 := Point()
global pos2 := Point()

global looping := false
global delay := 1000
global clickCount := 9

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
		
		if(delay > 0)
			Sleep delay ; player animation
	}
	looping := false
}

NumpadDot::{
	MsgBox(ClickCount " | " delay)
}

Numpad0::{
	global pos1 := GetClientMPos()
}

Numpad1::{
	global pos2 := GetClientMPos()
}

global delayBase := 250

NumpadSub::global delay -= 100
NumpadAdd::global delay += 100

NumpadMult::{
	ib := InputBox("Delay in MS",, "w200 h150")
	if(ib.Result = "OK" and IsNumber(ib.Value) and Number(ib.Value) > 0){
		global delay := ib.Value
	}
}

Numpad2::global delay := 0
Numpad3::global delay := delayBase * 0.5
Numpad4::global delay := delayBase
Numpad5::global delay := delayBase * 2
Numpad6::global delay := delayBase * 4
Numpad7::global delay := delayBase * 6
Numpad8::global delay := delayBase * 8
Numpad9::global delay := delayBase * 10