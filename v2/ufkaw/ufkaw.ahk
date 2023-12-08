#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../memoryWin.ahk"

^Esc::ExitApp

F1::{
	p := GetClientMPos()
	MyClick(p.x, p.y, " Right")
	Sleep 300
	MyClick(p.x, p.y-22, " Right")
}

global mem := MemoryWin(windowTitle)
global address := mem.GetStaticAddress("jvm.dll", 0x00B217B8, 0x38, 0x58, 0x1D0, 0x28, 0x30, 0xE8 + 0x18)
global currentZoom := 1
global changeZoom := 0.1

WriteZoom(){
	global currentZoom
	mem.WriteMemory(currentZoom, "Float", address)
}

Numpad0::{
	global currentZoom := mem.ReadMemory("Float", address)
	MsgBox currentZoom
}
Numpad1::{
	global currentZoom := 0.8
	WriteZoom()
}
Numpad2::{
	global currentZoom := 0.6
	WriteZoom()
}
Numpad3::{
	global currentZoom := 0.4
	WriteZoom()
}
Numpad4::{
	global currentZoom := 0.2
	WriteZoom()
}

NumpadAdd::{
	global currentZoom, changeZoom
	currentZoom += changeZoom
	WriteZoom()
}

NumpadSub::{
	global currentZoom, changeZoom
	currentZoom -= changeZoom
	WriteZoom()
}

F4::{
	MySend("{Space Down}")
	; while true{
	; 	MySend("{Space}")
	; 	Sleep 1200
	; }
}
