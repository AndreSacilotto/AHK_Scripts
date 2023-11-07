; This is a comment
Toggle = true
Sleep, 1000

F1::
	Toggle = false
return

F2::
Toggle = true
Loop
{
	If Toggle
	{
		MouseClick, left
		Sleep, 0 
	}
	else
		return
}
return

F3::
Toggle = true
If Toggle
   Click, Down
return

Esc::ExitApp
