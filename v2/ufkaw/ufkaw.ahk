#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../memoryWin.ahk"

SendMode "Input"

^Esc::ExitApp

F1::{
	p := GetClientMPos()
	MyClick(p.x, p.y, " Right")
	Sleep 300
	MyClick(p.x, p.y-22, " Right")
}

+F1::{
	p := GetClientMPos()
	MyClick(p.x, p.y, " Right")
	Sleep 300
	MyClick(p.x, p.y-22, " Right")
}

F2::{ ; show zoom
	mem := MemoryWin(windowTitle)
	address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
	MsgBox mem.ReadMemory("Float", address, 0x18)
}
