#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%/shared.ahk"
#Include "%A_ScriptDir%/../memoryWin.ahk"
#Include "%A_ScriptDir%/../libs/ShinsImageScanClass.ahk"

global shin := ShinsImageScanClass(windowTitle)

^Esc::ExitApp

F1::Meow()

F3::MeowLoop()

MeowLoop(){
	static looping := false
	if(looping){
		looping := false
		return
	}
	looping := true
	while(looping) 
	{
		Meow()
		Sleep 4000
	}
	looping := false

}

; Sacrier: 5035-5030-5028-5041-5032-5037-5039-5042-5036-5034-5044-5047-5054-5052-5194-7215-5144-0

CloseGUI(){
	MyFocusSend("{Esc}")
	Sleep 1000
}

BattleTurn(){
	MyFocusSend("{Space}")
	Sleep 3800
}

MeowClick(x, y, button, times := 1){
	MyFocusClick(x, y, button, times)
}

UseSkillSelect(n, x, y){
	MyFocusSend("{" n "}")
	Sleep 400
	MeowClick(x, y, "Left")
	Sleep 600
}

MeowUIClick(x, y, delay := 400, distX := -85, distY := -70){
	MyFocusClick(x, y, "Right")
	Sleep delay
	MyFocusClick(x+distX, y+distY, "Right")
}

Meow(){
	ZoomWheel()

	UIClick(858, 388) ; door click
	Sleep 750
	MeowClick(960, 758, "Right") ; enter GUI
	Sleep 3000
	
	; ----- Battle 1 -----
	MeowUIClick(1250, 621) ; cat pos
	Sleep 4500
	BattleTurn()
	
	UseSkillSelect(1, 1123, 507) ; attack 1
	UseSkillSelect(1, 896, 457) ; attack 2

	Sleep 5000
	CloseGUI()

	; ----- Battle 2 -----

	if(shin.PixelRegion(0xA19371, 310, 425, 300, 300, 10, &x, &y)){ ; check for the white table position
		MeowClick(x, y, "Left")
		Sleep 3000
	}
	else{
		MsgBox("No Table")
		return
	}

	MeowClick(1604, 559, "Left") ; go starting tile
	Sleep 3000

	MeowUIClick(1143, 401) ; cat pos
	Sleep 4500
	BattleTurn()

	UseSkillSelect(1, 1072, 426) ; attack 1
	UseSkillSelect(1, 1197, 425) ; attack 2

	Sleep 7000
	CloseGUI()

	; ----- Battle 3 -----
; }
; f4::{
	found := false
	loop(3){ ; he blinks - try 3 times
		if(shin.PixelRegion(0xF1C93D, 1350, 350, 300, 300, 10, &x, &y)){ ; search for boss yellow eyes
			found := true
			MeowClick(x-350, y-315, "Left")
			break
		}
		Sleep 450
	}

	if(!found){
		MsgBox found
		return
	}

	Sleep 2650
	UIClick(1184, 759, 400) ; cat (boss) pos
	
	Sleep 5000
	MeowClick(1034, 585, "Left") ; start pos
	Sleep 500
	BattleTurn()

	UseSkillSelect(1, 972, 669) ; attack 1
	Sleep 2500
	MeowClick(1323, 435, "Left") ; move
	Sleep 250
	MeowClick(1323, 435, "Left") ; move
	Sleep 3000

	UseSkillSelect(5, 1139, 504) ; attack 2
	UseSkillSelect(3, 1139, 504) ; attack 3
	
	Sleep 4500
	CloseGUI()
	
	MeowClick(1079, 608, "Left") ; exit dg
}
