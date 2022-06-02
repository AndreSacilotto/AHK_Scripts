;#region Environment
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ; Enable warnings to assist with detecting common errors.
#SingleInstance force ; Force a single script instance
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

;#region Classes
class Vector2
{
	__New(x, y){
		This.x := x
		This.y := y
	}
	__Get(){
		return this.x . " " . this.y
	}
	Print(){
		return this.x . " " . this.y
	}
	Print2(){
		return "(" . this.x . ", " . this.y . ")"
	}
	ControlPrint(){
		return "x" . this.x . " y" . this.y
	}
	Add(other){
		return new Vector2(this.x + other.x, this.y + other.y)
	}
	Subract(other){
		return new Vector2(this.x - other.x, this.y - other.y)
	}
	Multiply(other){
		return new Vector2(this.x * other.x, this.y * other.y)
	}
	Divide(other){
		return new Vector2(this.x / other.x, this.y / other.y)
	}
}

;#region Variable

framePosY := 0.821208
framePositions := [ new Vector2(0.231579, framePosY)
	, new Vector2(0.357895, framePosY)
	, new Vector2(0.477895, framePosY)
	, new Vector2(0.605614, framePosY)
	, new Vector2(0.724211, framePosY)]

redButtonPos := new Vector2(0.364085, 0.551298)
lobbyLookPos := new Vector2(0.001751, 0.054978)

toggle := False
delay := 200
verifySteps := 4

global winPID := ""

verifyMode := True
click1 := new Vector2(0, 0)
click2 := new Vector2(0, 0)

;#region Util Functions

GetCurrentWindowPID()
{
	WinGet, pid, PID, A
	return pid
}

MouseGetPosVector(){
	MouseGetPos, mX, mY 
	return new Vector2(mX, mY)
}

MouseGetPosPercentVector(winSize){
	MouseGetPos, mX, mY 
	return new Vector2(mX / winSize.x, mY / winSize.y)
}

GetColor(x, y){
	PixelGetColor, cor, %x%, %y%, RGB
	Return cor
}

ColorPrint(col){
	StringTrimLeft, colHex, col, 2
	MsgBox % col
	clipboard := colHex
}

OffsetPixelSearch(winPos, centerX, centerY, dist, col, shades = 0){
	px0 := winPos.x + centerX - dist
	py0 := winPos.y + centerY - dist 
	px1 := winPos.x + centerX + dist
	py1 := winPos.y + centerY + dist
	PixelSearch,,, %px0%, %py0%, %px1%, %py1%, %col%, %shades%, Fast RGB
	return ErrorLevel
}

;#region App Functions

ControlClick2(posStr)
{
	ControlClick, %posStr%, ahk_pid %winPID%,,,, Pos NA
}

ControlClickVector(vector)
{
	ControlClick, % vector.ControlPrint(), ahk_pid %winPID%,,,, Pos NA
}

ControlClickPercent(winSize, percentVector)
{
	vec := winSize.Multiply(percentVector)
	ControlClick, % vec.ControlPrint(), ahk_pid %winPID%,,,, Pos NA
}

GetWinPositon(){
	WinGetPos, winX, winY,,, ahk_pid %winPID%
	return new Vector2(winX, winY)
}

GetWinSize(){
	WinGetPos,,, winW, winH, ahk_pid %winPID%
	return new Vector2(winW, winH)
}

;Vector2 (Pos, Size)
GetWinRect(){
	WinGetPos, winX, winY, winW, winH, ahk_pid %winPID%
	return new Vector2(new Vector2(winX, winY), new Vector2(winW, winH))
}

SetPID(){
	winPID := GetCurrentWindowPID()
}

;#region INPUTS

~+Esc::ExitApp ; Safe Measure

Numpad1::
	SetPID()
	click1 := MouseGetPosPercentVector(GetWinSize())
return

Numpad2::
	SetPID()
	click2 := MouseGetPosPercentVector(GetWinSize())
return

NumpadMult::
	verifyMode := !verifyMode
return

F12::
	toggle := False
return

^F12::
	if(toggle == True)
		return
	toggle := True

	SetPID()
	CoordMode, Mouse, Relative
	CoordMode, Pixel, Screen
	SetControlDelay -1

	verifyCount := verifySteps
	winRect := GetWinRect()
	namedFramePositions := []
	Loop 
	{
		if(verifyMode && --verifyCount <= 0)
		{
			verifyCount := verifySteps
			winRect := GetWinRect()
			if(verifyMode)
				Verify(winRect)
			
			for index, el in framePositions
				namedFramePositions[index] := winRect.y.Multiply(el).ControlPrint()
		}

		if(toggle == False)
			return

		for index, el in namedFramePositions
		{
			ControlClick2(el)
			Sleep, %delay%
		}
	}

return

Verify(rect)
{	
	global click1, click2, lobbyLookPos, redButtonPos

	psPos := rect.y.Multiply(lobbyLookPos)
	psResult := OffsetPixelSearch(rect.x, psPos.x, psPos.y, 1, 0x5F2F26, 23)
	if (psResult <> 0)
		return

	Sleep, 500

	ControlClickPercent(rect.y, click1)
	Sleep, 500

	c2 := rect.y.Multiply(click2)
	ControlClickVector(c2)
	Sleep, 500

	; If has no energy - click the red button
	ControlClickPercent(rect.y, redButtonPos)
	Sleep, 500

	ControlClickVector(c2)
	Sleep, 1000
}