#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

^Esc::ExitApp

F1::Benchmark()
Numpad0::Benchmark()

Benchmark(){
	static start := 0
	if(start > 0)
	{
		MsgBox(A_TickCount - start)
		start := 0
	}
	else
		start := A_TickCount
}
