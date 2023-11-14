#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

#Include "%A_ScriptDir%/shared.ahk"

F1::MsgBox(WinGetList(windowTitle)[1])
F2::MsgBox(WinGetList(windowTitle)[2])