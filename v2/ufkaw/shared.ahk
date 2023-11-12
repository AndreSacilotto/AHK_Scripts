#Requires AutoHotkey v2.0

SetWorkingDir A_ScriptDir

SetControlDelay -1
SendMode "Input"

; #region Vars

global windowTitle := "WAKFU"

; if(!WinExist(windowTitle))
; 	ExitApp(127)
; global windowSize := GetWindowSize()

global windowClassNN := "SunAwtCanvas1"

; #region Get

GetWindowSize(){
	WingetPos(,, &width, &height, windowTitle)
	return Point(width, height)
}

; #region Static Funcs

MyClick(x, y, button, times := 1){
	ControlClick(windowClassNN, windowTitle,, button, times, "x" x " y" y " NA")
}
MyClick2(x, y, button, times := 1){
	Click(x " " y " " button " " times)
}

MySend(command){
	ControlSend(command, windowClassNN, windowTitle)
}
MySend2(command){
	Send(command)
}

; #region Classes

class Point {
	x := 0
	y := 0
	__New(x := 0, y := 0) {
		this.x := x
		this.y := y
	}
	ToString(fmt := "({1}, {2})"){
		return Format(fmt, this.x, this.y)
	}
	ToStringControl(){
		return this.ToString("x{1} y{2}")
	}
	ToStringSpace(){
		return this.ToString("{1} {2}")
	}
} 


; #region Macro Funcs

WheelOut(){
	Loop 13 {
		MySend("{NumpadSub}")
		Sleep(25)
	}
}

WheelIn(){
	Loop 13 {
		MySend("{NumpadAdd}")
		Sleep(25)
	}
}
