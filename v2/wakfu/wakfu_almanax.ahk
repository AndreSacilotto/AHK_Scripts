#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

^Esc::ExitApp

F1::{
	; Send "{8}"
	WheelOut()
}

F2::{
	; Send "{8}"
	WheelIn()
}

WheelIn(){
	Loop 13 {
		Send "{WheelUp}"
		Sleep 25
	}
}
WheelOut(){
	Loop 13 {
		Send "{WheelDown}"
		Sleep 25
	}
}
