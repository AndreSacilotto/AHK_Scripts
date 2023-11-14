#Requires AutoHotkey v2.0
#SingleInstance Force

SetWorkingDir A_ScriptDir

SetControlDelay -1
SetKeyDelay(-1, 5)
SendMode "Input"

SetTitleMatchMode 3
DetectHiddenWindows true

; #region Vars

global windowTitle := "WAKFU ahk_class SunAwtFrame"
global hwnd := WinExist(windowTitle)

if(!hwnd)
	ExitApp(127)
; global windowSize := GetWindowRect()

global windowClassNN := "SunAwtCanvas1"

; #region Get

GetWindowRect(&pos){
	WinGetPos(&x, &y, &width, &height, windowTitle)
	return Rect(x, y, width, height)
}

GetWindowMPos(){
	CoordMode("Mouse", "Window")
	MouseGetPos(&x, &y)
	return Point(x, y)
}
GetClientMPos(){
	CoordMode("Mouse", "Client")
	MouseGetPos(&x, &y)
	return Point(x, y)
}
GetScreenMPos(){
	CoordMode("Mouse", "Screen")
	MouseGetPos(&x, &y)
	return Point(x, y)
}

Benchmark(){
	static start := 0
	if(start > 0)
	{
		MsgBox(A_TickCount - start)
		start := 0
	}
	else
		start := A_TickCount
}

; #region Pixel

; box = x/y center pos | boxX left/right dist | boxY top/bottom dist

PixelSearchBox(x, y, color, variance := 0, boxX := 5, boxY := 5){
	return PixelSearch(&cX, &cY, x - boxX, y - boxY, x - boxX, y + boxY, color, variance)
}

PixelSearchBoxShin(shin, x, y, color, variance := 0, boxX := 5, boxY := 5){
	return shin.PixelRegion(x - boxX, y - boxY, boxX * 2, boxY * 2, color, variance)
}

PixelSearchShin(shin, x1, y1, x2, y2, color, variance := 0){
	return shin.PixelRegion(x1, y1, x2-x1, y2-y1, color, variance)
}

; #region Static Funcs

MyClick(x, y, button, times := 1){
	MyControlClick(x, y, button, times)
}
MySend(command){
	MyControlSend(command)
}

MyFocusClick(x, y, button, times := 1){
	Click(x " " y " " button " " times)
}
MyControlClick(x, y, button, times := 1){
	ControlClick(windowClassNN, windowTitle,, button, times, "x" x " y" y " NA")
}
; MyPostClick(x, y, button, delay := 0) { ; similar ControlClick
;     lParam := (y << 16) | (x & 0xFFFF)
; 	if(button = "Left" or button = "L")
; 	{
; 		PostMessage(0x201, 1, lParam, windowClassNN, windowTitle) ; WM_LBUTTONDOWN 
; 		Sleep delay
; 		PostMessage(0x202, 0, lParam, windowClassNN,  windowTitle) ; WM_LBUTTONUP 
; 	}
; 	else if(button = "Right" or button = "R")
; 	{
; 		PostMessage(0x204, 1, lParam, windowClassNN, windowTitle) ; WM_RBUTTONDOWN  
; 		Sleep delay
; 		PostMessage(0x205, 0, lParam, windowClassNN,  windowTitle) ; WM_LBUTTONUP 
; 	}
; 	else if(button = "Middle" or button = "M")
; 	{
; 		PostMessage(0x207, 1, lParam, windowClassNN, windowTitle) ; WM_MBUTTONDOWN  
; 		Sleep delay
; 		PostMessage(0x208, 0, lParam, windowClassNN,  windowTitle) ; WM_MBUTTONUP 
; 	}
; }

MyFocusSend(command){
	Send(command)
}
MyControlSend(command){
	ControlFocus(windowClassNN, windowTitle)
	ControlSend(command, windowClassNN, windowTitle)
}
; MyPostSend(command, delay := 0){
; 	PostMessage(0x100, 0x45, MapVirtualKey(0x45, MAPVK_VK_TO_VSC), windowClassNN, windowTitle) ; WM_KEYDOWN
; 	Sleep delay
; 	PostMessage(0x101, 0x45, MapVirtualKey(0x45, MAPVK_VK_TO_VSC), windowClassNN, windowTitle) ; WM_KEYUP
; }

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

class Rect {
	position := 0
	size := 0
	__New(x, y, width, height) {
		this.position := Point(x, y)
		this.size := Point(width, height)
	}
	ToString(fmt := "({1}, {2} : {3}, {4})"){
		return Format(fmt, this.position.x, this.position.y, this.size.x, this.size.y)
	}
} 

; #region Macro Funcs


/**
 * @param num should be a value between 1-8
 * @param useClick : use mouse instead of keyboard 0
 * @param specialKey : can be used for modKeys {Ctrl}{Shift}{Alt} (dont work with useClick)
 */
Shortcut(num := 1, useClick := false, extraCommand := ""){
	if(useClick)
		MyClick(1090 + 39 * (num-1), 1055, "Right")
	else
		MySend(extraCommand " {" num "}")
	Sleep 300
}

; Single Option UI click
UIClick(x, y, delay := 300){
	MyClick(x, y, "Right")
	Sleep delay
	MyClick(x, y-22, "Right")
}

ZoomWheel(zoomOut := true, useClick := true){
	if(useClick){
		command := zoomOut ? "WheelDown" : "WheelUp"
		loop 13 {
			MyClick(960, 600, command)
			Sleep 25
		}
	}
	else{
		command := zoomOut ? "{NumpadSub}" : "{NumpadAdd}"
		loop 13 {
			MySend(command)
			Sleep 25
		}
	}
	Sleep 150
}

; #region Pixel Funcs

SearchForUIAhk(x, y, size := 8){ ; check for the "white" color of the UI
	return PixelSearchBox(x, y, 0xB9B2A6, 30, size, size)
}
SearchForUIShin(shin, x, y, size := 8){
	return shin.PixelRegion(0xB9B2A6, x-size, y-size, size, size, 30)
}
SearchForTimerAhk(){ ; search for the white color of timerUI text
	return PixelSearchBox(50, 56, 0xFFFBFF, 10, 15, 10)
}
SearchForTimerShin(shin){
	return shin.PixelRegion(0xFFFBFF, 35, 46, 30, 20, 10)
}