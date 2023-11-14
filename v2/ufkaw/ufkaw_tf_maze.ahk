#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../memoryWin.ahk"
#Include "%A_ScriptDir%/../libs/ShinsImageScanClass.ahk"

global mazeZoom := 0.5
global mem := MemoryWin(windowTitle)
global shin := ShinsImageScanClass(windowTitle)

^Esc::ExitApp

F1::{
	MazeSeller()
	MazeGate()
	Mount()
	FindAndGoToObject()
}
^+F1::{
	MazeSeller()
}
+F1::{
	MazeGate()
	CloseMessage()
	FindAndGoToObject()
}
^F1::{
	FindAndGoToObject()
}

F2::{
	SetZoom(mazeZoom)
}
+F2::{ ; test color
	p := GetScreenMPos()
	MsgBox CheckUIFromClick(p.x, p.y-22)
}

global looping := false
F3::{
	global looping
	if(looping){
		looping := false
		return
	}
	looping := true
	while(looping) 
	{
		MazeSeller()
		isGateOpen := MazeGate(true)
		if(!isGateOpen){
			loop 3{ ; try again
				Sleep 600
				if(isGateOpen := MazeGate(false))
					break
			}
			MsgBox("(Exiting) The gate didnt open",, "Icon!")
			return
		}
		if(FindAndGoToObject())
		{
			Sleep 500
			if(SearchForTimerShin(shin))
				MsgBox("(Bug) click and look",, "Icon? T45")
		}
		else
			Sleep 55500 ; wait time run out

		Sleep 7000 ; winAnimationTime + blackScreenTime
	}
	looping := false
}

; #region Util

SetZoom(value){
	address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
	mem.WriteMemory(value, "Float", address, 0x18)
}

global checkUIWait := 300

/** @param confirmDelay : <0 it never confirms | =0 no delay | >0 has delay */
CheckUIFromClick(x, y, confirmDelay := 0){ 
	MyClick(x, y, "Right")
	Sleep checkUIWait
	y -= 22
	found := SearchForUIShin(shin, x, y)
	if(found and confirmDelay >= 0){
		if(confirmDelay > 0)
			Sleep confirmDelay
		MyClick(x, y, "Right")
	}
	return found
}

/** (this action reset zoom) */
Mount(){
	; Shortcut(2) ; shortcut 2 slot
	Shortcut(2, true) ; click 2 slot
}

CloseMessage(){
	MySend("{Esc}")
}

; #region Maze


MazeSeller(){ 
	; this func dont use mazeZoom
	; the FPS drop from inactavating the window
	; dissaper when you enter a instance

	ZoomWheel()
	Mount()
	Sleep 250

	UIClick(840, 440) ; seller

	Sleep 4450 ; move & loading
}

MazeGate(firstTime := true){
	ZoomWheel()

	UIClick(1000, 500)
	Sleep 225 ; gate sleep 1
	Mount()
	Sleep 250 ; gate sleep 2
	SetZoom(mazeZoom)
	if(firstTime)
		CloseMessage()
	Sleep 250 ; gate sleep 3

	if(SearchForTimerShin(shin))
		return 1

	Mount()
	MsgBox("Timer didnt start",, "T1 Icon!")
	return 0
}


; 0-40.5 secs - flush
; 41-50 - furniture
; 50-60 - sword

FindAndGoToObject() ; should have special zoom
{
	amount := 20000 - 500 ; waitForFlush - gateSleep (a bit less just to be sure)
	; amount - walkTime

	; check center
	if(CheckUIFromClick(1642, 96, amount - 9500)){ ; StatueCenterLeft
		Sleep 9500
		return 1
	}
	amount -= checkUIWait
	if(CheckUIFromClick(1731, 226, amount - 7500)){ ; StatueCenterRight
		Sleep 7500
		return 1
	}
	amount -= checkUIWait

	; check left
	if(CheckUIFromClick(1080, 111, amount - 9600)){ ; StatueLeftStraight
		Sleep 9600
		return 1
	}
	amount -= checkUIWait
	if(CheckUIFromClick(1258, 139, -1)){ ; StatueLeftZigZag
		Sleep 200
		MyClick(900, 140, "Left") 
		Sleep(amount - 8600)
		UIClick(1320, 553)
		Sleep 4200
		return 1
	}
	amount -= checkUIWait

	MyClick(1900, 339, "Left") 
	Sleep 8050
	amount -= 8050

	; check right-start
	if(CheckUIFromClick(1228, 242, amount - 4700)) ; StatueRightCorner
	{
		Sleep 4700
		return 1
	}
	amount -= checkUIWait

	if(CheckUIFromClick(1039, 288, amount - 4200)) ; StatueRightHidden
	{
		Sleep 4200
		return 1
	}
	amount -= checkUIWait

	if(CheckUIFromClick(815, 360, amount - 8300)) ; StatueRightCenter
	{
		Sleep 8300
		return 1
	}

	; (amount will always be <0 for these)
	MyClick(900, 221, "Left") 
	Sleep 5500
	
	; Check right-end 
	; if(CheckUIFromClick(1270, 571)){ ; StatueRightCorner
	; 	Sleep 7000
	; 	return 1
	; }
	; if(CheckUIFromClick(871, 685)){ ; StatueRightCenter
	; 	Sleep 3600
	; 	return 1
	; }
	; if(CheckUIFromClick(1101, 603, 1500)){ ; StatueRightHidden
	; 	Sleep 2800
	; 	return 1
	; }
	; the 3 above can be placed before the second move (TODO)

	if(CheckUIFromClick(654, 356)){  ; StatueRightHidden2
		Sleep 4000
		return 1
	}

	if(CheckUIFromClick(342, 477)){  ; StatueRightLast
		Sleep 6400
		return 1
	}

	MsgBox("Cant find a target",,"Icon! T5")
	return 0
}
