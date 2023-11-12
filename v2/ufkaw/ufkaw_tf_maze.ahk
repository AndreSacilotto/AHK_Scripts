#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../memoryWin.ahk"

^Esc::ExitApp

mem := MemoryWin(windowTitle)

Numpad0::{ ; show zoom
	address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
	mem.WriteMemory(1, "Float", address, 0x18)
}

Numpad1::{ ; show zoom
	address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
	mem.WriteMemory(0.75, "Float", address, 0x18)
}

Numpad2::{ ; show zoom
	address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
	mem.WriteMemory(0.5, "Float", address, 0x18)
}

Numpad3::{ ; show zoom
	address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
	mem.WriteMemory(0.25, "Float", address, 0x18)
}


F1::{
	MazeSeller()
}
+F1::{
	MazeGate()
}

F2::{
	WalkFountainBack()
}

F3::{
	WalkLeft()
}

F4::{
	WalkRight()
}

; #region Pixel

; -22

FindDoor(x, y, box := 10){
	x1 := x - box
	y1 := y - box
	
	x2 := x + box
	y2 := y + box

	if(PixelSearch(&cX, &cY, x1, y1, x2, y2, 0xB9B2A6, 30))
		return 1
	return 0
}

; #region Maze

MazeSeller(){
	MySend("{2}") ; mount
	Sleep 300

	MyClick(840, 440, "Right") ; seller
	Sleep 250
	MyClick(840, 410, "Right") ; seller 2

	Sleep 4100 ; move & loading

	MazeGate()
}

MazeGate(){
	MyClick(1000, 500, "Right") ; gate
	Sleep 300
	MyClick(1000, 465, "Right") ; gate 2
	Sleep 100
	MySend("{2}") ; mount
	
	Sleep 1000 ; gate open
	MyClick(1660, 80, "Left") ; fount click
	Sleep 100
	MySend("{Esc}")
	Sleep 100
}

WalkFountainBack(){
	MyClick(420, 920, "Left")
	Sleep 3000
}

WalkLeft(){
	WalkFountainBack()
	MyClick(144, 366, "Left")
	Sleep 4000
	MyClick(1300, 70, "Left")
	Sleep 8000
}

WalkRight(){
	WalkFountainBack()
	MyClick(1870, 680, "Left")
	Sleep 3850
	MyClick(1720, 50, "Left")
	Sleep 3500
	MyClick(1150, 150, "Left")
	Sleep 8000
}

WalkRightContinue(){
}


; #region Statue Center Way
StatueFountainTop(){
	
}
StatueFountainRight(){

}

; #region Statue Left Way
StatueLeftStraight(){
	WalkLeft()
}
StatueLeftZigZag(){
	WalkLeft()
}

; #region Statue Right Way
StatueRightCorner(){
	WalkRight()
}
StatueRightHidden(){
	WalkRight()
	
}
StatueRightTop(){
	WalkRight()
	
}
StatueRightHidden2(){
	WalkRight()
	
}
StatueRightLast(){
	WalkRight()
	
}