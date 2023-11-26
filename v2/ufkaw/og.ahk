#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

; #Include "%A_ScriptDir%/shared.ahk"

^Esc::ExitApp

arr := [
	7, 800,
	10, 1500,
	20, 3000,
	35, 6000,
	70, 13000,
	140, 28000,
	200, 47000,
]

F1::{
	ib := InputBox("Money",, "w200 h100", 10)
	r := Number(ib.Value)
	ib := InputBox("Ogres",, "w200 h100", 1000)
	og := Number(ib.Value)
	MsgBox RO(r, og)
}

F2::{
	txt := ""
	loop(arr.Length){
		txt .= RO(arr[A_Index], arr[A_Index+1]) "`n"
		A_Index += 1
	}
	MsgBox txt
}

RO(r, og){
	rToOg := og/r
	ogToR := r/og
	return (
		og "/" r "`n" 
		"1 R$ = " rToOg " OG`n" 
		"0.01 R$ = " (og/(r*100)) " OG`n"
		"4750 OG = " ogToR*4750 " OG`n"
		"2200 OG = " ogToR*2200 " OG`n"
		"4000 OG = " ogToR*4000 " OG`n"
	)
}

F3::{
	four := 30/7
	MsgBox (
		"`t(30)`t`t(7)`n"
		"R$:`t" 20 "`t=`t" Round(7.5*four, 2) "`t{+" Round(((7.5*four)/20)*100) "%} `n"
		"OG:`t" 4750 "`t=`t" Round(2200*four, 2) "`t{+" Round(((2200*four)/4750)*100) "%}`n"
	)
}