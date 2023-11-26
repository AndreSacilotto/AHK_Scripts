#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../libs/ShinsImageScanClass.ahk"

; #region vars

global doors := [ 
	Point(1077, 197), ; (green)
	Point(1253, 286), ; (yellow)
	Point(1486, 406), ; (red)
	Point(1668, 493), ; (blue)
]

global shin := ShinsImageScanClass(windowTitle)

; #region Entry Point

^Esc::ExitApp

F1::{
	GoPray()
}
+F1::{
	GoPrayMounted()
}

F2::{
	ChangeChar()
	SelectChar(4)
}

F3::{
	; be on character select screen
	start := 1
	end := 5
	loop(end-start+1) {
		Sleep 500
		SelectChar(A_Index+start-1)
		GoPray()
		Sleep 500
		ChangeChar()
	}
}

; #region Pixel Search

WaitLoadingScreen(){
	while (PixelSearchBoxShin(shin, 1535, 560, 0xFFFFFF, 0, 3, 3))
		Sleep 1500
	; MsgBox "I have waited",,"T1"
}

FindDoorShin(){
	size := 10
	for(index, door in doors)
		if(shin.PixelRegion(0x496E79, door.x-size, door.y-size, size, size, 30))
			return door
	return 0
}

DoorClick(){
	door := FindDoorShin()
	if(!door)
	{
		MsgBox("I'm NOT Pixel Perfect",,"Icon!")
		return 0
	}
	MyClick(door.x, door.y, "Left")
	return 1
}

; #region Bot Stuff


PraySetup(){
	Shortcut(8)
	Sleep 2200 ; tp
	ZoomWheel()
	Sleep 600 ; just a little more
}

PrayAltar(){
	UIClick(1317,326) ; altar click
	
	Sleep 400 ; wait dialog anim
	MyClick(1022, 891,"Left") ; skip dialog
	Sleep 300
	MyClick(1022, 891,"Left") ; pray
	Sleep 300
}

GoPray(){
	PraySetup()

	MyClick(1116,436,"Left")
	Sleep 3800 ; sala 1 (guy)
	
	MyClick(1609,228,"Left")
	Sleep 6700 ; sala 2 (doors)
	
	if(!DoorClick())
		ExitApp()
	Sleep 5700 ; sala 3 (temple)

	PrayAltar()
}

GoPrayMounted(){
	PraySetup()

	Shortcut(2) ; mount
	Sleep 300

	MyClick(1116, 436, "Left")
	Sleep 4000 ; sala 1 (guy)
	
	MyClick(1609, 228, "Left")
	Sleep 5000 ; sala 2 (doors)
	
	if(!DoorClick())
		ExitApp()
	Sleep 4900 ; sala 3 (temple)
	
	PrayAltar()
}

ChangeChar(){
	; MyClick(814, 1055, "Right")
	MySend("{Escape}") ; Open Menu
	Sleep 400
	MyClick(964, 520, "Left") ; Select Opt
	Sleep 400
	MyClick(922, 564, "Left") ; Confirmation
	Sleep 3000 ; logout animation

	WaitLoadingScreen()
}

SelectChar(num := 1){
	; start at 1
	MyClick(525, 180 + num * 61, "Left")
	Sleep 500
	MyClick(525, 180 + num * 61, "Left", 2) 

	Sleep 1500

	WaitLoadingScreen()
}
