#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Input"

; auto-give-up
F1 UP::{
	t1 := 100
	t2 := 500

	Send "{Esc Down}"
	Sleep t1
	Send "{Esc Up}"

	Sleep t2
	
	; p := "157 787 Left" ; 1600x900
	p := "140 666 Left" ; 1360x768
	Click p
	Sleep t1
	Click p
	
	Sleep t2

	; p := "740 475 Left" ; 1600x900
	p := "620 400 Left" ; 1360x768
	Click p
	Sleep t1
	Click p
}

questCount := 0
questNpcPos := "0 0"
questIconPos := "0 0"

; select battle
F2 UP::{
	global questCount, questNpcPos, questIconPos
	if(questCount = 0)
	{
		MouseGetPos &x, &y
		questNpcPos := x " " y
	}
	else if(questCount = 1)
	{
		MouseGetPos &x, &y
		questIconPos := x " " y
	}
	else
	{
		t1 := 200
		t2 := 500

		Click questNpcPos " Left"
		Sleep t1
		Click questNpcPos " Left Down"
		Sleep t1
		Click questNpcPos " Left Up"

		Sleep t2

		Click questIconPos " Left Down"
		Click questIconPos " Left Up"

		Sleep t2 * 2

		; p := "800 800 Left" ; 1600x900
		p := "680 700 Left" ; 1360x768
		Click p
		Sleep t1
		Click p
	}
	questCount++
}

^F2 UP::{
	global questCount := 0
}

^Esc::ExitApp