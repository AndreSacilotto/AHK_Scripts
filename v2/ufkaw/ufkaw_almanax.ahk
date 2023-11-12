#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%/shared.ahk"

; #region vars

doors := [ 
	Point(1077, 197), ; (green)
	Point(1253, 286), ; (yellow)
	Point(1486, 406), ; (red)
	Point(1668, 493), ; (blue)
]

; #region Entry Point

^Esc::ExitApp

F1::{
	GoPray()
}

F2::{
	GoPrayMounted()
}

F3::{
	; setup: be in game with first char
	loop 5 {
		GoPray()
		Sleep 1000
		ChangeChar(A_Index+1)
		Sleep 4000
	}
}

; #region Pixel Search

FindDoor(){
	offset := 10
	for(index, door in doors)
	{
		x1 := door.x - offset
		y1 := door.y - offset
		
		x2 := door.x + offset
		y2 := door.y + offset

		if(PixelSearch(&cX, &cY, x1, y1, x2, y2, 0x496E79, 30))
			return door
	}
	return false
}

; #region Bot Stuff

PraySetup(){
	MySend "{8}"
	Sleep 1800 ; tp
	WheelOut()
	Sleep 300 ; wheelout
}

PrayAltar(){
	MyClick(1317,326,"Right") ; click 1
	Sleep 300
	MyClick(1318,291,"Right") ; click 2
	
	Sleep 400 ; wait dialog anim
	MyClick(1022,891,"Left") ; skip dialog
	Sleep 200
	MyClick(1022,891,"Left") ; pray
}

GoPray(){
	PraySetup()

	MyClick(1116,436,"Left")
	Sleep 3800 ; sala 1 (guy)
	
	MyClick(1609,228,"Left")
	Sleep 6700 ; sala 2 (doors)
	
	DoorClick()
	Sleep 5700 ; sala 3 (temple)

	PrayAltar()
}

GoPrayMounted(){
	PraySetup()

	MySend "{2}" ; mount
	Sleep 300

	MyClick(1116,436,"Left")
	Sleep 4000 ; sala 1 (guy)
	
	MyClick(1609,228,"Left")
	Sleep 5000 ; sala 2 (doors)
	
	DoorClick()
	Sleep 4900 ; sala 3 (temple)
	
	PrayAltar()
}

DoorClick(){
	door := FindDoor()
	if(!door)
	{
		MsgBox "I'm NOT Pixel Perfect"
		ExitApp
	}
	MyClick(door.x, door.y, "Left")
}

ChangeChar(num){
	MySend("{Escape}") ; Open Menu
	Sleep 300
	MyClick(964, 520, "Left") ; Select Opt
	Sleep 300
	MyClick(922, 564, "Left") ; Confirmation
	Sleep 5000 ; logoff anitmatuin
	
	; start at 1
	MyClick(525, 180 + num * 61, "Left", 2) 
}

