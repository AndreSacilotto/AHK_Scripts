#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

^Esc::ExitApp

+F1 UP::{
	MouseGetPos &x, &y
	Click x " " y " Right"
	Sleep 130
	Click x " " (y-35) " Right"
}

F1 UP::{
	troolFairMaze()
}

F2 UP::{
	Click "420 920 Left"
}

F3 UP::{
	Click "1870 680 Left"
	Sleep 3850
	Click "1720 50 Left"
	Sleep 3500
	Click "1150 150 Left"
}

F4 UP::{
	Click "144 366 Left"
	Sleep 4000
	Click "1300 70 Left"
}


troolFairMaze(){
	Send "{2}" ; mount
	Sleep 200

	Click "840 440 Right" ; seller
	Sleep 200
	Click "840 410 Right" ; seller 2

	Sleep 4100 ; move & loading
	
	Click "1000 500 Right" ; gate
	Sleep 200
	Click "1000 465 Right" ; gate 2
	
	Send "{2}" ; mount
	
	Sleep 1000 ; gate open
	Click "1660 80 Left" ; fount click
	Send "{Esc}"
}