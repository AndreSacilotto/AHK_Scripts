#Requires AutoHotkey v2.0
#SingleInstance Off ; Force
#MaxThreadsPerHotkey 2

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../libs/ShinsImageScanClass.ahk"

global looping := false
global shin := ShinsImageScanClass(windowTitle)

; #region Entry Point

^Esc::ExitApp

F1::{
	ZoomWheel()
	GravediggerSetup()
	if(GravediggerGate())
		GravediggerClicks()
}
+F1::{
	if(GravediggerGate())
		GravediggerClicks()
}

~F3::{
	global looping
	if(looping)
	{
		looping := false
		return
	}

	ZoomWheel()
	looping := true
	while looping {
		GravediggerSetup()
		if(GravediggerGate())
			GravediggerClicks()
		Sleep 5000 ; winAnimation
	}
	looping := false
}

; #region Coord Stuff

DontHaveTimer(){
	return !SearchForTimerShin(shin)
}

GravediggerSetup(){
	UIClick(708, 211, 350) ; seller
	Sleep 4550 ; move & loading
}

GravediggerGate(){
	UIClick(1000, 525, 400) ; gate
	Sleep 1500 ; gate open

	if(DontHaveTimer())
	{
		MsgBox("Timer didnt start",, "T1 Icon!")
		return 0
	}
	return 1
}

Dig(x, y){
	UIClick(x, y, 240)
	Sleep 1700 ; time to dig (inclusive closing UI)
}

WalkAndDig(x, y){
	Sleep 125 ; time to walk half cell
	Dig(x, y)
}

GravediggerClicks()
{
	; ---- Intial Area
	WalkAndDig(1080, 480) ; first dig

	if(DontHaveTimer())
		return

	WalkAndDig(978, 484)
	Dig(1021, 511)
	Dig(1029, 565)
	WalkAndDig(1081, 543)
	WalkAndDig(1085, 546)
	
	if(DontHaveTimer())
		return
	
	; ---- Road
	WalkAndDig(1081, 602)
	WalkAndDig(1078, 606)
	Sleep 100 ; fix?
	WalkAndDig(1080, 603)
	Dig(899, 573)
	WalkAndDig(1082, 543)
	Dig(901, 575)
	Dig(1024, 578)

	if(DontHaveTimer())
		return

	WalkAndDig(1083, 548)
	Dig(900, 578)
	Dig(1022, 575)
	WalkAndDig(1078, 606)
	Dig(1029, 513)
	Dig(902, 582)
		
	if(DontHaveTimer())
		return

	; ---- Turn Down
	WalkAndDig(959, 603)
	WalkAndDig(841, 612)
	Dig(1014, 579)
	WalkAndDig(837, 608)
	Dig(898, 518)

	if(DontHaveTimer())
		return

	WalkAndDig(834, 611)
	Dig(900, 519)
	Dig(1020, 579)
	WalkAndDig(846, 608)
	Dig(902, 517)
	Dig(1021, 578)
}


