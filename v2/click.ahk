#Requires AutoHotkey v2.0
#SingleInstance Force

SetControlDelay -1
SendMode "Input"

^Esc::ExitApp

global looping := false

F1 UP::{
	global looping := true
	while looping {
		MouseGetPos &x, &y
		Click x " " y " Left"
		Sleep 200
	}
}
	
F2 UP::{
	global looping := false
}
	