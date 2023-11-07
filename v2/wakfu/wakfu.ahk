#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

^Esc::ExitApp

F1 UP::{
	MouseGetPos &x, &y
	Click x " " y " Right"
	Sleep 130
	Click x " " (y-35) " Right"
}


