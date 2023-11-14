#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

#Include "%A_ScriptDir%/shared.ahk"

global looping := false

; #region Entry Point

^Esc::ExitApp

F1::{
	ZoomWheel()
	MineLoop()
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
		MineLoop()
		Sleep 100
	}
	looping := false
}

; #region Coord Stuff

; you need to start north, at the ore near the wall/broken cart
; the side of the is the nearest to the next one

global mineTime := 3000

Mine(x, y){
	UIClick(x, y) ; dig
	Sleep(mineTime)
}

Walk(x, y, walkTime := 300){
	MyClick(x, y, "Left") ; dig
	Sleep walkTime
}

Mount(){
	Shortcut(2)
	Sleep 300
}

MineLoop(){
	Mine(900, 482)

	Walk(1081, 611, 1000)
	Mine(1017, 478)

	Walk(948, 610, 800)
	Mine(1016, 536)

	Walk(857, 604, 1000)
	Mine(897, 537)

	Mount()
	Walk(421, 315, 4050) ; go to plataform
	Mine(1015, 508)
	Mine(899, 559)
	Walk(1080 615, 1100)
	Mine(1139, 560)
	Mine(899, 559)

	Mount()
	Walk(1374, 553, 4700) ; go back to start
}

