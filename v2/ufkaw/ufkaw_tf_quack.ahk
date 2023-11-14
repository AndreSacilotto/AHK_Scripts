#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

#Include "%A_ScriptDir%/shared.ahk"

global looping := false

; #region Entry Point

^Esc::ExitApp

F1::{
	ZoomWheel()
	QuackLoop()
}

F3::{
	global looping
	if(looping)
	{
		looping := false
		return
	}

	ZoomWheel()
	looping := true
	while looping {
		QuackLoop()
		Sleep 100
	}
	looping := false
}

; #region Coord Stuff

; you need to start north, at the ore near the wall/broken cart
; the side of the is the nearest to the next one

global quackTime := 2720

Quack(x, y){
	UIClick(x, y) ; fish
	Sleep quackTime
}

Walk(x, y, walkTime := 500){
	MyClick(x, y, "Left") ; walk
	Sleep walkTime ; walkTime
}

QuackLoop(){
	; start at the quack in the middle of the bridge
	Quack(1018, 599) ; middle bridge
	Walk(1016, 521, 360)
	
	Quack(1018, 600) ; south
	Walk(1133, 515,  1000)

	Quack(1018, 600) ; right
	Walk(979, 487, 420)

	Quack(1018, 535) ; north
	Walk(766, 574, 1000)

	Quack(891, 534) ; left
	Walk(891, 638, 1000)
}

