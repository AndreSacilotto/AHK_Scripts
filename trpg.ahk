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
        return % "(" . this.x . ", " . this.y . ")"
    }
	ControlPrint(){
        return "x" . this.x . " y" . this.y
    }
}

;#region Variable
; basePosY := 672
mousePosArr := [ 	new Vector2(1030, 672)
, new Vector2(860, 672)
, new Vector2(685, 672)
, new Vector2(520, 672)
, new Vector2(330, 672)]

len := mousePosArr.MaxIndex()
mousePosNamed := []
Loop, %len%
	mousePosNamed[A_Index] := mousePosArr[A_Index].ControlPrint()

toggle := False
delay := 200

winPID := ""

click1 := ""
click2 := ""

;#region Functions

GetCurrentWindowPID()
{
    WinGet, pid, PID, A
	return pid
}

MouseToRelativeVector(){
    CoordMode, Mouse, Relative
    MouseGetPos, mX, mY 
	return new Vector2(mX, mY)
}

ControlClickActive(posStr)
{
	ControlClick, %posStr%, ahk_pid %winPID%,,,, Pos NA
}

GetColor(x, y){
    CoordMode, Pixel, Relative
	PixelGetColor, cor, %x%, %y%, RGB
	Return cor
}

ColorPrint(col){
	StringTrimLeft, colHex, col, 2
	MsgBox % col
    clipboard := colHex
}

OffsetPixelSearch(winPos, x, y, col, shades){
	px := winPos.x + x
	py := winPos.y + y
	; MsgBox % winPos.Print() . " | " . new Vector2(x, y).Print()
	PixelSearch, pxX, pxY, %px%, %py%, %px%, %py%, %col%, %shades%, Fast RGB
	return ErrorLevel
}

GetWinPositon(){
	WinGetPos, winX, winY,,, ahk_pid %winPID%
	return new Vector2(winX, winY)
}

;#region INPUTS

Esc::ExitApp ; Safe Measure

^1::
    CoordMode, Mouse, Screen
    MouseGetPos, xpos, ypos 
    MsgBox, Mouse at X:%xpos%, Y:%ypos%
	clipboard = %xpos%, %ypos%
return

^2::
    CoordMode, Mouse, Relative
    MouseGetPos, xpos, ypos 
    MsgBox % "Mouse at X: " . xpos . ", Y: " . ypos
    clipboard := xpos . ", " . ypos
return

^3::
    CoordMode, Mouse, Client
    MouseGetPos, xpos, ypos 
    MsgBox % "Mouse at X: " . xpos . ", Y: " . ypos
    clipboard := xpos . ", " . ypos
return


F12::
    toggle := False
return

^F12::
	if(toggle == True)
		return
    toggle := True
	if(!winPID)
		global winPID := GetCurrentWindowPID()
    CoordMode, Mouse, Relative
    SetControlDelay -1

	verifyCount := 0
    Loop{
        if(toggle == False)
            return
        for index, el in mousePosNamed
        {
            ControlClickActive(el)
            Sleep, %delay%
        }
		verifyCount++
		if(verifyCount > 5){
			Verify()
			verifyCount := 0
		}
    }
return

Numpad1::
	global click1 := MouseToRelativeVector()
return
Numpad2::
	global click2 := MouseToRelativeVector()
return

Verify(){
    CoordMode, Pixel, Screen
	
	winPos := GetWinPositon()
	; PixelSearch, pxX, pxY, 3, 37, 3, 37, 0x5F2F26, 10, Fast RGB
	v := OffsetPixelSearch(winPos, 3, 37, 0x5F2F26, 10)
	; MsgBox % v
	if (v <> 0)
		return

	Sleep, 2000

	global click1
	ControlClickActive(click1.ControlPrint())
	Sleep, 1500

	global click2
	ControlClickActive(click2.ControlPrint())
	Sleep, 1500

	; PixelSearch, pxX, pxY, 585, 446, 585, 446, 0xDF796D, 8, Fast RGB
	if (OffsetPixelSearch(winPos, 585, 446, 0xDF796D, 10) == 0){
		ControlClickActive("x585 y446")
		Sleep, 1000
		ControlClickActive(click2.ControlPrint())
		Sleep, 1000
	}
}
