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
	Print(){
		return % this.x . " " . this.y
	}
	Print2(){
		return % "(" . this.x . ", " . this.y . ")"
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
basePosY := 675
mousePosArr := [ 	new Vector2(1030, basePosY)
, new Vector2(860, basePosY)
, new Vector2(685, basePosY)
, new Vector2(520, basePosY)
, new Vector2(330, basePosY)]

len := mousePosArr.MaxIndex()
mousePosNamed := []
Loop, %len%
	mousePosNamed[A_Index] := mousePosArr[A_Index].ControlPrint()

toggle := False
delay := 200
verifySteps := 3

global winPID := ""

verifyMode := True
click1 := ""
click2 := ""

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

ControlClickPercert(winSize, percentVector)
{
	vec := percentVector.Multiply(winSize)
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

~^Esc::ExitApp ; Safe Measure

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

	verifyCount := 0
	Loop{
		for index, el in mousePosNamed
		{
			ControlClick2(el)
			Sleep, %delay%
		}
		if(toggle == False)
			return
		if(verifyMode && ++verifyCount >= verifySteps){
			Sleep, 1500
			Verify()
			verifyCount := 0
		}
	}
return

NumpadMult::
	verifyMode := !verifyMode
return
Numpad1::
	click1 := MouseGetPosPercentVector(GetWinSize())
return
Numpad2::
	click2 := MouseGetPosPercentVector(GetWinSize())
return

Verify(){	
	rect := GetWinRect()

	v := OffsetPixelSearch(rect.x, 3, 37, 1, 0x5F2F26, 10)
	; MsgBox % v
	if (v <> 0)
		return

	global click1, click2
	ControlClickVector(rect.y.Multiply(click1))
	Sleep, 1000

	c2 := rect.y.Multiply(click2)
	ControlClickVector(vec)
	Sleep, 500

	; If has no energy
	ControlClickVector(rect.y.Multiply(new Vector2(0.364085, 0.551298)))
	Sleep, 500

	ControlClickVector(c2)
	Sleep, 1000

	; redPixel = new Vector2(581, 435)
	; v := OffsetCenterPixelSearch(winPos, redPixel.x, redPixel.y, 1, 0xD77569, 10)
	; if (v == 0){
	;     ControlClickVector("x581 y435")
	;     Sleep, 1000
	;     ControlClickVector(click2)
	;     Sleep, 1000
	; }
}

Numpad0::
	SetPID()
	CoordMode, Mouse, Relative
	winSize := GetWinSize()
	; MsgBox % winSize.Print()
	; tmpV := MouseGetPosPercentVector(winSize)
	p := winSize.Multiply(click1)
	MouseMove, % p.x, % p.y 
return