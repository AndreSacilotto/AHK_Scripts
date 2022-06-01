;#region Environment
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ; Enable warnings to assist with detecting common errors.
#SingleInstance force ; Force a single script instance
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

;#region Variables

paused := False

labelWidth := 125
textWidth := 100

idPosXYScr := "idPosXYScr"
idPosXYRel := "idPosXYRel"
idPosXYPer := "idPosXYPer"
idWinXY := "idWinXY"
idWinHW := "idWinHW"

clipboardMsg := True

;#region Create GUI

Gui, +AlwaysOnTop +MinSize200x ; +Resize

CreateGuiItem(idPosXYScr, "1. Mouse (Screen)", "MsXY", labelWidth, textWidth)
CreateGuiItem(idPosXYRel, "2. Mouse (Relative)", "MrXY", labelWidth, textWidth)
CreateGuiItem(idPosXYPer, "3. Mouse (Percentage)", "MpXY", labelWidth, textWidth)
CreateGuiItem(idWinXY, "8. Window XY", "WXY", labelWidth, textWidth)
CreateGuiItem(idWinHW, "9. Window HW","WHW", labelWidth, textWidth)
Gui, Add, Text, xm w%labelWidth% vidPause, % "Paused: " . Bool(paused)

Gui, Show , NA Center AutoSize, % "Gui Mouse"

Bool(bollean){
	return bollean ? "True" : "False"
}

CreateGuiItem(var, txt, placeHolder, leftW, rightW){
	Gui, Add, Text, xm w%leftW%, % txt
	Gui, Add, Edit, x+ w%rightW% v%var% ReadOnly, % placeHolder
}

CoordMode, Mouse, Relative

Loop{

	if(paused){
		Sleep, 250
		continue
	}

	MouseGetPos, posX, posY 
	WinGetPos, winX, winY, winW, winH, A

	GuiControl, Text, idPosXYScr, % posX + winW . ", " . posY + winH
	GuiControl, Text, idPosXYRel, % posX . ", " . posY
	GuiControl, Text, idPosXYPer, % posX / winW . ", " . posY / winH
	GuiControl, Text, idWinXY, % winX . ", " . winY
	GuiControl, Text, idWinHW, % winW . ", " . winH

	Sleep, 100
}

*~Control::
	paused := True
	GuiControl, Text, idPause, % "Paused: " . Bool(paused)
return

*~Control Up::
	paused := False
	GuiControl, Text, idPause, % "Paused: " . Bool(paused)
return

~^Esc::
GuiClose:
ExitApp

;#region Clipboard Hotkeys

^0::
	clipboardMsg := !clipboardMsg
return

^1::
	CoordMode, Mouse, Screen
	MouseGetPos, xpos, ypos 
	if(clipboardMsg)
		MsgBox, Mouse at X:%xpos%, Y:%ypos%
	clipboard = %xpos%, %ypos%
return

^2::
	CoordMode, Mouse, Relative
	MouseGetPos, xpos, ypos 
	if(clipboardMsg)
		MsgBox % "Mouse at X: " . xpos . ", Y: " . ypos
	clipboard := xpos . ", " . ypos
return

^3::
	CoordMode, Mouse, Relative
	MouseGetPos, xpos, ypos 
	WinGetPos,,, winW, winH, A
	xpos := xpos / winW
	ypos := ypos / winH
	if(clipboardMsg)
		MsgBox % "Mouse at X: " . xpos . ", Y: " . ypos
	clipboard := xpos . ", " . ypos
return

^4::
	CoordMode, Mouse, Client
	MouseGetPos, xpos, ypos 
	if(clipboardMsg)
		MsgBox % "Mouse at X: " . xpos . ", Y: " . ypos
	clipboard := xpos . ", " . ypos
return

^8::
	WinGetPos, winX, winY,,, A
	if(clipboardMsg)
		MsgBox % "Mouse at X: " . winX . ", Y: " . winY
	clipboard := winX . ", " . winY
return

^9::
	WinGetPos,,, winW, winH, A
	if(clipboardMsg)
		MsgBox % "Mouse at W: " . winW . ", H: " . winH
	clipboard := winW . ", " . winH
return