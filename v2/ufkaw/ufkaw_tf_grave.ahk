#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%/shared.ahk"

global looping := false

; #region Entry Point

^Esc::ExitApp

F1::{
	WheelOut()
	GravediggerSetup()
	GravediggerClicks()
}

F2::{
	GravediggerClicks()
}

F3::{
	global looping := true
	WheelOut()
	while looping {
		GravediggerSetup()
		GravediggerClicks()
	}
}

F4::global looping := false

; #region Coord Stuff

Dig(x, y, clickDelay := 1700){
	MyClick(x, y, "Right") ; dig
	Sleep clickDelay
	MyClick(x, (y-27), "Right") ; dig ui
	Sleep 300
}

GravediggerSetup(){
	MyClick(720, 320, "Right") ; seller
	Sleep 300
	MyClick(720, 295, "Right") ; seller 2

	Sleep 3800 ; move & loading
	
	MyClick(1000, 525, "Right") ; gate
	Sleep 250
	MyClick(1000, 500, "Right") ; gate 2
	Sleep 1500 ; gate open
}

GravediggerClicks(){
	walkTime := 300

	; first dig
	Dig(1080, 480, walkTime)
	Sleep(walkTime * 2)

	Dig(978, 484)
	Dig(1021, 511)
	Dig(1029, 565)
	Dig(1081, 543)
	Dig(1085, 546)
	
	Dig(1081, 602)
	Sleep walkTime
	Dig(1078, 606)
	Dig(1080, 603)
	Dig(899, 573)
	Dig(1082, 543)
	Dig(901, 575)
	Dig(1024, 578)
	Dig(1083, 548)
	Dig(900, 578)
	Dig(1022, 575)
	Dig(1078, 606)
	Dig(1029, 513)
	Dig(902, 582)

	; Curva
	Dig(959, 603)
	Dig(841, 612)
	Dig(1014, 579)
	Dig(837, 608)
	Dig(898, 518)
	Dig(834, 611)
	Dig(900, 519)
	Dig(1020, 579)
	Dig(846, 608)
	Dig(902, 517)
	Dig(1021, 578)
}


