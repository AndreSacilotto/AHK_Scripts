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

F2::{ ; test color
	p := GetScreenMPos()
	MsgBox PixelSearchBox(p.x, p.y, 0x496E79, 30, 10, 10)
}

F3::{
	; setup: be in game with first char
	loop 5 {
		GoPray()
		Sleep 1000
		ChangeChar(A_Index+1)
		WaitLogin()
	}
}

; #region Pixel Search

WaitLogin(){
	while (PixelSearchBoxShin(shin, 1535, 560, 0xFFFFFF, 5, 3, 3))
		Sleep 1000
}

FindDoorAhk(){
	for(index, door in doors)
		if(PixelSearchBox(door.x, door.y, 0x496E79, 30, 10, 10))
			return door
	return 0
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
	Sleep 2000 ; tp
	ZoomWheel()
}

PrayAltar(){
	UIClick(1317,326) ; altar click
	
	Sleep 400 ; wait dialog anim
	MyClick(1022, 891,"Left") ; skip dialog
	Sleep 220
	MyClick(1022, 891,"Left") ; pray
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

ChangeChar(num := 1, wait := true){
	MySend("{Escape}") ; Open Menu
	Sleep 300
	MyClick(964, 520, "Left") ; Select Opt
	Sleep 300
	MyClick(922, 564, "Left") ; Confirmation
	Sleep 2000 ; logout animation
	
	WaitLogin()

	; start at 1
	MyClick(525, 180 + num * 61, "Left", 2) 
}

