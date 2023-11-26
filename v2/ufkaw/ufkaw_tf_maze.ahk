#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../memoryWin.ahk"
#Include "%A_ScriptDir%/../libs/ShinsImageScanClass.ahk"

global shin := ShinsImageScanClass(windowTitle)

global mazeZoom := 0.5
global mem := MemoryWin(windowTitle)
global zoomAddress := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130 + 0x18)

; #region Hotkeys

^Esc::ExitApp

F1::{
	; MazeSeller()
	MazeGate()
	FindAndGoToObject()
}

F2::{
	; MsgBox PixelSearchBoxShin(shin, 1003, 490, 0x32331A, 0, 10, 10)
	SetZoom(mazeZoom)
}
+F2::{ ; test color
	p := GetScreenMPos()
	; MsgBox CheckUIFromClick(p.x, p.y-22)
	MsgBox PixelSearchBoxShin(shin, 868, 314, 0x7E742B, 50, 4, 4)
}

F3::MazeLoop()

; #region Util

SetZoom(value){
	mem.WriteMemory(value, "Float", zoomAddress, 0)
}
GetZoom(){
	mem.ReadMemory("Float", zoomAddress, 0)
}

/** (this action reset zoom) */
RideMount(useMouse := true){
	Shortcut(2, useMouse) ; click/send 2 slot
}

CloseMessage(){
	MySend("{Esc}")
}

global checkUIWait := 350

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

; #region Maze

global tries := 10

MazeSeller(){ 
	; loadtime := 2000
	; movetime := 2200

	x := 867, y := 312, y2 := y-22

	loop(tries) ; see if UI appear
	{
		if(GetZoom() != 1)
			ZoomWheel()
		Sleep 200
		MyClick(x, y, "Right")
		Sleep 300
		if(SearchForUIShin(shin, x, y2)){
			; RideMount(false) ; unmounting sometimes will override the last action 
			Sleep 400
			UIClick(x, y, 400) ; seller
			Sleep 4600

			; quick fix for for bug that click moves but does nothing
			x := 1040, y := 330, y2 := y-22
			MyClick(x, y, "Right")
			Sleep 400
			if(SearchForUIShin(shin, x, y2)){
				Sleep 100
				UIClick(x, y2, 400)
				Sleep 1000 ; loading
			}

			return 1
		}
		Sleep 500
	}



	return 0
}

MazeMessage(){
	loop(tries) ; wait for message
	{
		if(PixelSearchBoxShin(shin, 1006, 251, 0xD1B36A, 30)){
			CloseMessage()
			break
		}
		Sleep 400
	}
}

MazeGate()
{
	Sleep 1000 ; wait for message

	if(GetZoom() != 1)
		ZoomWheel()

	SetTimer(MazeMessage, -2000)

	loop(tries) ; search for gate
	{
		if(PixelSearchBoxShin(shin, 1003, 490, 0x32331A, 10)){ ; search for closed gate
			Sleep 500
			UIClick(1003, 490, checkUIWait)
			loop(tries) ; wait timer start
			{
				if(SearchForTimerShin(shin))
					return 1
				Sleep 500
			}
			return 0
		}
		Sleep 400
	}
	return 0
}

; 0-40.5 secs - flush
; 41-50 - furniture
; 50-60 - sword

FindAndGoToObject() ; should have special zoom
{
	Sleep 200
	RideMount()
	Sleep 700
	SetZoom(mazeZoom)
	Sleep 900

	amount := 20000 - 1800 ; waitForFlush - preparation
	
	; amount - walkTime

	; check center
	if(CheckUIFromClick(1642, 96, amount - 9450)) ; StatueCenterLeft
		return 1
	amount -= checkUIWait
	if(CheckUIFromClick(1731, 226, amount - 7500)) ; StatueCenterRight
		return 1
	amount -= checkUIWait

	; check left
	if(CheckUIFromClick(1080, 111, amount - 9420)) ; StatueLeftStraight
		return 1
	amount -= checkUIWait
	if(CheckUIFromClick(1258, 139, -1)){ ; StatueLeftZigZag
		Sleep 200
		MyClick(900, 140, "Left")
		Sleep(amount - 200 - 3550 - 300) ; sleep + objectiveWalkTime + clickDelay : (amount already cover the leftWalkTime)
		UIClick(1320, 553, 300) 
		return 1
	}
	amount -= checkUIWait

	MyClick(1900, 339, "Left") 
	Sleep 8000
	amount -= 8000

	; check right-start
	if(CheckUIFromClick(1228, 242, amount - 4700)) ; StatueRightCorner
		return 1
	amount -= checkUIWait

	if(CheckUIFromClick(1039, 288, amount - 4200)) ; StatueRightHidden
		return 1
	amount -= checkUIWait

	; MsgBox amount
	if(CheckUIFromClick(815, 358, amount - 8000)) ; StatueRightCenter
		return 1
	; amount -= checkUIWait ; (there is waiting here these)
	
	MyClick(900, 221, "Left") 
	Sleep 5500
	
	if(CheckUIFromClick(654, 356))  ; StatueRightHidden2
		return 1

	if(CheckUIFromClick(342, 477))  ; StatueRightLast
		return 1

	return 0
}

MazeEnding()
{
	static winningDance := 3500

	loop(20) ; wait until timer dissapear for 20 seconds
	{
		Sleep 1000
		if(!SearchForTimerShin(shin)){
			Sleep winningDance
			return
		}
	}

	; maybe it bug: try clicking all directions

	UIClick(930, 508, checkUIWait) ; left
	Sleep checkUIWait
	UIClick(991, 538, checkUIWait) ; right
	Sleep checkUIWait
	UIClick(992, 504, checkUIWait) ; north
	Sleep checkUIWait
	UIClick(912, 552, checkUIWait) ; south
	Sleep checkUIWait

	; truly wait timer dissapear
	while(SearchForTimerShin(shin))
		Sleep 1000
	
	Sleep winningDance
}

MazeLoop(){
	static looping := false
	if(looping){
		looping := false
		return
	}
	looping := true
	while(looping) 
	{
		if(!MazeSeller()){
			MsgBox("Exiting - No Seller",,"Icon!")
			break ; exit
		}

		if(!MazeGate()){
			MsgBox("Exiting - No Gate or Timer",, "Icon!")
			break ; exit
		}

		if(!FindAndGoToObject())
			MsgBox("Wating Time End - No objective found",,"T2")

		MazeEnding()
	}
	looping := false
}