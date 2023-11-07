#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

^Esc::ExitApp

pos1 := "0 0"
pos2 := "0 0"

working := false

F1 UP::{
	MouseGetPos &x, &y
	global pos1 := x " " y
}

F2 UP::{
	MouseGetPos &x, &y
	global pos2 := x " " y
}

F3 UP::{
	working := true
	while working {
		Click pos1 " Right" ; bucket
		Sleep 130 ; UI animation
		Click pos2 " Right" ; bucket 2

		Sleep 2000 ; player animation
	}
}

F4 UP::{
	global working := false
}
