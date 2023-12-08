#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../libs/ShinsImageScanClass.ahk"

global looping := false
global shin := ShinsImageScanClass(windowTitle)

; #region Entry Point

^Esc::ExitApp

F1::{
	ZoomWheel()
	GravediggerSeller()
	if(GravediggerGate())
		GravediggerClicks()
}
+F1::{
	if(GravediggerGate())
		GravediggerClicks()
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
		GravediggerSeller()
		if(GravediggerGate())
			GravediggerClicks()
	}
	looping := false
}

; #region Coord Stuff

GravediggerSeller()
{
	Sleep 1000

	x := 700, y := 246, y2 := y-22
	ZoomWheel()

	loop(15) ; see if UI appear
	{
		Sleep 500
		MyClick(x, y, "Right")
		Sleep 450
		if(SearchForUIShin(shin, x, y2)){
			MyClick(x, y2, "Right") ; seller
			Sleep 3200

			; quick fix for for bug that click moves but does nothing
			x := 876, y := 337, y2 := y-22
			MyClick(x, y, "Right")
			Sleep 400
			if(SearchForUIShin(shin, x, y2))
				MyClick(x, y2, "Right")

			Sleep 1000 ; loading
			
			return 1
		}
	}

	return 0
}

GravediggerGate(){
	global dontHaveTimer

	Sleep 1000

	x := 1000, y := 525, y2 := y-22
	loop(5){
		MyClick(x, y, "Right") ; gate
		Sleep 400
		if(SearchForUIShin(shin, x, y2)){
			MyClick(x, y2, "Right")
			Sleep 400
		}

		if(SearchForTimerShin(shin)){
			dontHaveTimer := false
			return 1
		}

		Sleep 300
	}

	dontHaveTimer := true
	MsgBox("Gate didnt open",, "T1 Icon!")
	return 0
}

; #region Dig

global dontHaveTimer := true

CheckForTimer(){
	global dontHaveTimer := !SearchForTimerShin(shin)
}

Dig(x, y){
	if(dontHaveTimer)
		return
	UIClick(x, y, 240)
	Sleep 1685 ; time to dig (inclusive closing UI)
}

WalkAndDig(x, y){
	if(dontHaveTimer)
		return
	Sleep 125 ; time to walk half cell
	Dig(x, y)
}

GravediggerClicks()
{	
	if(dontHaveTimer){
		MsgBox("Timer dont Exist")
		return
	}

	SetTimer(CheckForTimer, 1000)

	; ---- Intial Area
	WalkAndDig(1080, 480) ; first dig

	WalkAndDig(978, 484)
	Dig(1021, 511)
	Dig(1029, 565)
	WalkAndDig(1081, 543)
	WalkAndDig(1085, 546)
	
	; ---- Road
	WalkAndDig(1081, 602)
	WalkAndDig(1078, 606)
	Sleep 100 ; fix?
	WalkAndDig(1080, 603)
	Dig(899, 573)
	WalkAndDig(1082, 543)
	Dig(901, 575)
	Dig(1024, 578)

	WalkAndDig(1083, 548)
	Dig(900, 578)
	Dig(1022, 575)
	WalkAndDig(1078, 606)
	Dig(1029, 513)
	Dig(902, 582)
		
	; ---- Turn Down
	WalkAndDig(959, 603)
	WalkAndDig(841, 612)
	Dig(1014, 579)
	WalkAndDig(837, 608)
	Dig(898, 518)

	WalkAndDig(834, 611)
	Dig(900, 519)
	Dig(1020, 579)
	WalkAndDig(846, 608)
	Dig(902, 517)
	Dig(1021, 578)

	SetTimer(CheckForTimer, 0)
	GravediggerEnding()
}

GravediggerEnding()
{
	global dontHaveTimer
	while (SearchForTimerShin(shin)) ; wait until timer dissapear
		Sleep 500
	dontHaveTimer := true
	Sleep 3500 ; winningDance
}