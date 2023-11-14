#Requires AutoHotkey v2.0

; #NoTrayIcon
#SingleInstance Force

; #region Global Vars

global myGui
global updateRate := 130

global historic := []

global mousePos := "0 0"
global mouseColor := "FFFFFF"

global activeWindow := WinExist("A")

; #endregion
; #region HotKeys

; ^Esc::CloseApp()

~!S::{
	global historic
	A_Clipboard := mousePos ; mouse coords
	historic.Push(mousePos)
}

~!X::{
	global historic
	A_Clipboard := mouseColor ; color mouse coords
	historic.Push(mouseColor)
}

~!C::CopyHistoric()

~!Z::ClearHistoric()

~^Numpad7::{ ; always on top
	global myGui
	box := myGui["GUI_BoxTop"].Click()
}
~^Numpad4::{ ; follow mouse
	global myGui
	box := myGui["GUI_BoxFollowMouse"].Click()
}
~^Numpad1::{ ; freeze
	global myGui
	myGui["GUI_BoxFocus"].Click()
} 
~^Numpad8::{ ; freeze
	global myGui
	myGui["GUI_BoxFreeze"].Click()
} 

; #endregion
; #region MAIN

SetWorkingDir(A_ScriptDir)
CoordMode("Pixel", "Screen")
CreateGui()

; #endregion
; #region UI

CopyHistoric(){
	global historic
	A_Clipboard := ArrayToString(historic, "`n")
}
ClearHistoric(){
	global historic
	historic := []
}

CloseApp(*){
	ExitApp()
}

CreateGui() {
	global myGui, updateRate

	try TraySetIcon "picker.ico"
	DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "wstr", "Spectra.Picker") ; set company

	myGui := Gui("AlwaysOnTop Resize MinSize -MaximizeBox +DPIScale", "GUI Input AHK_" A_AhkVersion)
	
	myGui.OnEvent("Close", CloseApp)
	myGui.OnEvent("Escape", CloseApp)
	myGui.OnEvent("Size", GUIResize)
	
	myGui.SetFont('s9', "Segoe UI")
	
	myGui.AddText("Section Center r1", "--------------------------- Options ---------------------------")

	boxTop := myGui.AddCheckbox("vGUI_BoxTop w100", "AlwaysOnTop")
	boxTop.Value := 1
	boxTop.OnEvent("Click", (GuiControl, Info) => WinSetAlwaysOnTop(GuiControl.Value, myGui))
	boxTop.Click := (*) => (boxTop.Value := !boxTop.Value, WinSetAlwaysOnTop(boxTop.Value, myGui))
	
	boxFM := myGui.AddCheckbox("vGUI_BoxFollowMouse w100", "Follow Mouse") ; false: get window by focus | true: get window by mouse over
	boxFM.Value := 1
	boxFM.Click := (*) => (boxFM.Value := !boxFM.Value)
	
	boxFocus := myGui.AddCheckbox("vGUI_BoxFocus w100", "Send Focus") ; keep hovered window always focused (only works with follow mouse)
	boxFocus.Value := 1
	boxFocus.Click := (*) => (boxFocus.Value := !boxFocus.Value)

	boxFreeze := myGui.AddCheckbox("vGUI_BoxFreeze w100", "Freezed") ; Freeze updates
	boxFreeze.OnEvent("Click", (GuiControl, Info) => SetTimerMainLoop(!GuiControl.Value))
	boxFreeze.Click := (*) => (boxFreeze.Value := !boxFreeze.Value, SetTimerMainLoop(!boxFreeze.Value))

	; refresh rate
	editRefresh := myGui.AddSlider("vGUI_Refresh range45-300 w80 r1 xm+220 ym+33 Thick15", updateRate)
	editRefresh.OnEvent("Change", (GuiControl, Info) => TryUpdateRefreshRate(GuiControl.Value) )
	myGui.AddText("yp+25 w80 r1 Center", "Refresh Rate")

	myGui.AddText("Section Center xs r1", "----------------------- Window Process -----------------------")
	myGui.AddEdit("vGUI_Title xm w320 r6 ReadOnly -Wrap", "")

	myGui.AddText("Section Center xs r1", "----------------------- Mouse Position -----------------------")
	myGui.AddEdit("vGUI_MousePos w320 r5 ReadOnly", "")
 
	myGui.AddText("Section Center xs r1", "---------------------- Window Postition ----------------------")
	myGui.AddEdit("vGUI_WinPos w320 r2 ReadOnly", "")

	myGui.AddButton("vGUI_His w107 r1 xp+0 yp+45", "History").OnEvent("Click", (GuiControl, Info) => MsgBox(ArrayToString(historic, "`n"), GuiControl.Text, 4096) )

	myGui.AddButton("w107 r1 xp+107 yp", "Copy").OnEvent("Click", (GuiControl, Info) => CopyHistoric() )
	myGui.AddButton("w107 r1 xp+107 yp", "Clear").OnEvent("Click", (GuiControl, Info) => ClearHistoric() )

	myGui.Show("NoActivate")
	; WinGetClientPos(&x_temp, &y_temp2, , , myGui.hwnd)

	myGui.loaded := true

	SetTimerMainLoop(true)
}

TryUpdateRefreshRate(value){
	updateTime := Integer(value)
	if(updateTime>0)
		SetTimer(SafeMainLoop, updateTime)
}

SafeMainLoop() {
	try MainLoop()
}

SetTimerMainLoop(enabled){
	global myGui, updateRate
	if(enabled)
	{
		SetTimer(SafeMainLoop, updateRate)
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

	for index, element in ["Title", "MousePos", "WinPos"]
		GuiObj["GUI_" element].Move(,,ctrlW)
}

MainLoop()
{
	global myGui, activeWindow
	
	If !myGui.HasProp("loaded") ; GUI is not done
		return

	CoordMode("Mouse", "Screen")
	MouseGetPos(&msX, &msY, &hWindow, &hControl, 2)

	if (myGui["GUI_BoxFollowMouse"].Value and WinExist("ahk_id " hWindow))
	{
		if(myGui["GUI_BoxFocus"].Value)
			WinActivate("ahk_id " hWindow) ; the coords are relative to last focused window
		activeWindow := hWindow
	}
	else{
		activeWindow := WinExist("A")
		hControl := ControlGetFocus()
	}
	
	winGet1 := WinGetTitle()
	winGet2 := WinGetClass()
	winGet3 := WinGetProcessName()
	winGet4 := WinGetPID()
	hControlClassNN := ""
	try hControlClassNN := ControlGetClassNN(hControl)
	
	winDataText := "Title:`t" winGet1 "`n"
				 . "Class:`t" winGet2 "`n"
				 . "EXE:`t" winGet3 "`n"
				 . "PID:`t" winGet4 "`n"
				 . "ID:`t" activeWindow "`n"
				 . "ClassNN:`t" hControlClassNN
	
	UpdateText("GUI_Title", winDataText)

	CoordMode("Mouse", "Window")
	MouseGetPos(&mrX, &mrY)
	CoordMode("Mouse", "Client")
	MouseGetPos(&mcX, &mcY)
	mClr := PixelGetColor(msX, msY, "RGB")
	mClr := SubStr(mClr, 3)

	global mousePos := mcX " " mcY
	global mouseColor := mClr

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
