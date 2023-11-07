#Requires AutoHotkey v2.0

; #NoTrayIcon
#SingleInstance Force

; #region Global Vars

global myGui
global updateTime := 130

global historic := []

global mousePos := "0 0"
global mouseColor := "#FFFFFF"

global activeWindow := WinExist("A")

; #endregion
; #region Shortcuts

; ^Esc::CloseApp()

~+X::{
	global historic
	A_Clipboard := ArrayToString(historic, "`n")
}

~!X::{
	global historic
	A_Clipboard := mouseColor ; color mouse coords
	historic.Push(mouseColor)
}

~^X::{
	global historic
	A_Clipboard := mousePos ; mouse coords
	historic.Push(mousePos)
}

~^+X::{
	global historic
	historic := []
}

~^Numpad7::{ ; lock
	global myGui
	myGui["GUI_BoxLock"].Click()
}
~^Numpad4::{ ; freeze
	global myGui
	myGui["GUI_BoxFreeze"].Click()
} 
~^Numpad9::{ ; follow mouse
	global myGui
	box := myGui["GUI_FollowMouse"].Click()
}
~^Numpad6::{ ; always on top
	global myGui
	box := myGui["GUI_BoxTop"].Click()
}

; #endregion
; #region MAIN

SetWorkingDir(A_ScriptDir)
CoordMode("Pixel", "Screen")
CreateGui()

; #endregion
; #region UI

CloseApp(*){
	ExitApp()
}

CreateGui() {
	global myGui, updateTime

	try TraySetIcon "picker.ico"
	DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "wstr", "Spectra.Picker") ; set company

	myGui := Gui("AlwaysOnTop Resize MinSize -MaximizeBox +DPIScale", "GUI Input AHK_" A_AhkVersion)
	
	myGui.OnEvent("Close", CloseApp)
	myGui.OnEvent("Escape", CloseApp)
	myGui.OnEvent("Size", GUIResize)
	
	myGui.SetFont('s9', "Segoe UI")
	
	myGui.AddText("Section Center r1", "--------------------------- Options ---------------------------")
	boxLock := myGui.AddCheckbox("vGUI_BoxLock w100 r1 xm ym+25", "Locked") ; Lock the active window
	boxLock.Click := (*) => (boxLock.Value := !boxLock.Value)

	boxFreeze := myGui.AddCheckbox("vGUI_BoxFreeze w100 r1 xm ym+50", "Freezed") ; Freeze updates
	boxFreeze.OnEvent("Click", (GuiControl, Info) => SetTimerMainLoop(!GuiControl.Value))
	boxFreeze.Click := (*) => (boxFreeze.Value := !boxFreeze.Value, SetTimerMainLoop(!boxFreeze.Value))

	boxFM := myGui.AddCheckbox("vGUI_FollowMouse w100 r1 xm+220 ym+25 Right", "Follow Mouse") ; false: get window by focus | true: get window by mouse over
	boxFM.Click := (*) => (boxFM.Value := !boxFM.Value)

	boxTop := myGui.AddCheckbox("vGUI_BoxTop w100 xm+220 ym+50 Right", "AlwaysOnTop")
	boxTop.Value := 1
	boxTop.OnEvent("Click", (GuiControl, Info) => WinSetAlwaysOnTop(GuiControl.Value, myGui))
	boxTop.Click := (*) => (boxTop.Value := !boxTop.Value, WinSetAlwaysOnTop(boxTop.Value, myGui))
	
	; conflict with Freeze 
	; editRefresh := myGui.AddEdit("vGUI_Refresh w80 r1 xm+120 ym+24 Center", "Refresh Rate")
	; editRefresh.Value := updateTime
	; editRefresh.OnEvent("Change", (GuiControl, Info) => updateTime := Integer(GuiControl.Value) )
	; myGui.AddText("yp+25 w80 r1 Center", "Refresh Rate")

	myGui.AddText("Section Center xs r1", "----------------------- Window Process -----------------------")
	myGui.AddEdit("vGUI_Title xm w320 r5 ReadOnly -Wrap", "")

	myGui.AddText("Section Center xs r1", "----------------------- Mouse Position -----------------------")
	myGui.AddEdit("vGUI_MousePos w320 r5 ReadOnly", "")
 
	myGui.AddText("Section Center xs r1", "---------------------- Window Postition ----------------------")
	myGui.AddEdit("vGUI_WinPos w320 r2 ReadOnly", "")

	myGui.AddButton("vGUI_His r1", "History").OnEvent("Click", (GuiControl, Info) => MsgBox(ArrayToString(historic), GuiControl.Text, 4096) )

	myGui.Show("NoActivate")
	; WinGetClientPos(&x_temp, &y_temp2, , , myGui.hwnd)

	myGui.loaded := true

	SetTimerMainLoop(true)
}

SafeMainLoop() {
	try MainLoop()
}

SetTimerMainLoop(enabled){
	global myGui, updateTime
	if(enabled)
	{
		SetTimer(SafeMainLoop, updateTime)
		myGui["GUI_BoxFreeze"].Value = 0
	}
	else{
		SetTimer(SafeMainLoop, 0)
		myGui["GUI_BoxFreeze"].Value = 1
	}
}

GUIResize(GuiObj, MinMax, Width, Height) 
{
	If !GuiObj.HasProp("loaded") ; GUI is not done
		return

	SetTimerMainLoop(MinMax>=0)

	ctrlW := Width - (GuiObj.MarginX * 2) ; ctrlW := Width - horzMargin

	for index, element in ["Title", "MousePos", "WinPos", "His"]
		GuiObj["GUI_" element].Move(,,ctrlW)
}

MainLoop()
{
	global myGui, activeWindow
	
	If !myGui.HasProp("loaded") ; GUI is not done
		return

    CoordMode("Mouse", "Screen")
	MouseGetPos(&msX, &msY, &hWindow, , 2)

	if(!myGui["GUI_BoxLock"].Value)
	{
		MouseGetPos()
		if (myGui["GUI_FollowMouse"].Value){
			WinExist("ahk_id " hWindow) ; triggers window update
			activeWindow := hWindow
		}
		else
			activeWindow := WinExist("A")
	}
	else
		WinExist("ahk_id " activeWindow) ; triggers window update

    winGet1 := WinGetTitle()
    winGet2 := WinGetClass()
    winGet3 := WinGetProcessName()
    winGet4 := WinGetPID()
    
    winDataText := "Title:`t" winGet1 "`n"
                 . "Class:`t" winGet2 "`n"
                 . "EXE:`t" winGet3 "`n"
                 . "PID:`t" winGet4 "`n"
                 . "ID:`t" activeWindow
    
    UpdateText("GUI_Title", winDataText)

    CoordMode("Mouse", "Window")
    MouseGetPos(&mrX, &mrY)
    CoordMode("Mouse", "Client")
    MouseGetPos(&mcX, &mcY)
    mClr := PixelGetColor(mcX, mcX, "RGB")
    mClr := SubStr(mClr, 3)

	global mousePos := mcX " " mcY
	global mouseColor := "#" mClr

	mpText := 
	  "Screen:`t" msX " " msY "`n"
	. "Client:`t" mcX " " mcY " (default)`n"
	. "Window:`t" mrX " " mrY "`n"
	. "Color:`t" mClr "`n"
	. "RGB:`t" HexToDec(SubStr(mClr, 1, 2)) " " HexToDec(SubStr(mClr, 3, 2)) " " HexToDec(SubStr(mClr, 5))

	UpdateText("GUI_MousePos", mpText)

    wX := "", wY := "", wW := "", wH := ""
    WinGetPos &wX, &wY, &wW, &wH, "ahk_id " activeWindow
    WinGetClientPos(&wcX, &wcY, &wcW, &wcH, "ahk_id " activeWindow)
    
    wText := "Screen:`tx: " wX "`ty: " wY "`tw: " wW "`th: " wH "`n"
           . "Client:`tx: " wcX "`ty: " wcY "`tw: " wcW "`th: " wcH
    
    UpdateText("GUI_WinPos", wText)
}

UpdateText(vGUI, newText) {
    global myGui

    static oldText := {}
    currentGUI := myGui[vGUI]
	currentGUI_hwnd := Integer(currentGUI.hwnd)
    
    if (!oldText.HasProp(currentGUI_hwnd) or oldText.%currentGUI_hwnd% != newText) {
        currentGUI.Value := newText
        oldText.%currentGUI_hwnd% := newText
    }
}

; #endregion
; #region UTIL

ArrayToString(array, separator := ", "){
	str := ""
	for index, value In array
		str .= separator . Value
	return SubStr(str, StrLen(separator)+1)
}

HexToDec(Hex)
{
	if (InStr(Hex, "0x") != 1)
		Hex := "0x" Hex
	return Hex + 0
}
