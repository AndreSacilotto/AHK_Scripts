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
mousePosArr := [ 	new Vector2(1030, 736)
, new Vector2(860, 736)
, new Vector2(685, 736)
, new Vector2(520, 736)
, new Vector2(330, 736)]

len := mousePosArr.MaxIndex()
mousePosNamed := []
Loop, %len%
	mousePosNamed[A_Index] := mousePosArr[A_Index].ControlPrint()

toggle := False
active := ""
delay := 200

;#region Functions

GetCurrentWindowPID()
{
    WinGet, pid, PID, A
	return pid
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

F12::
    toggle := False
return

+F12::
    toggle := True
	if(!active)
		active := GetCurrentWindowPID()
    CoordMode, Mouse, Relative
    Loop{
        if(toggle == False)
            return
        Loop % len
        {
			el := mousePosArr[A_Index]
            MouseClick, left, el.x, el.y
            Sleep, %delay%
        }
        Sleep, 100
    }
return

^F12::
    toggle := True
	if(!active)
		active := GetCurrentWindowPID()
    CoordMode, Mouse, Relative
    SetControlDelay -1
    Loop{
        if(toggle == False)
            return
        Loop % len
        {
            ControlClick, % mousePosNamed[A_Index], ahk_pid %active%,,,, Pos NA
            Sleep, %delay%
        }
        Sleep, 100
    }
return
