#Requires AutoHotkey v2.0
#SingleInstance Force

SetWorkingDir A_ScriptDir
SetTitleMatchMode 3
DetectHiddenWindows true
SetControlDelay -1

; Consts Vars

global windowExe := "ahk_exe VCash.exe"

global windowOrder := "ahk_class TfrmVendasCheckOutF"

global windowSellType := "ahk_class TfrmVendasCheckOutFechaF"

global windowStrangeConfirm := "ahk_class TCaixaMensagem"

global windowOutOpt := "ahk_class TfrmHKImpressoras"

global windowCpf := "ahk_class TInputQueryForm"

global windowNota := "ahk_class TRLPreviewForm"

; Global Vars

global keyTime := 300

global sellType := ""
global outOpt := 0
global winGUI := CreateGUI()

winGUI.Show()

; Hotkeys

^Esc:: {
    ExitApp()
}

^F10:: {
    global winGUI
    if (WinActive(winGUI))
        ; winGUI.Hide()
        winGUI.Minimize()
    else
        winGUI.Restore()
        ; winGUI.Show()
}

; Funcs

CreateGUI() {
    ; try TraySetIcon "picker.ico"
    DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "wstr", "Spectra.Caixa") ; set company

    myGui := Gui("MinSize -MaximizeBox +DPIScale", "GUI Input AHK_" A_AhkVersion)

    myGui.OnEvent("Close", CloseApp)
    myGui.OnEvent("Escape", CloseApp)
    ; myGui.OnEvent("Size", GUIResize)

    myGui.SetFont('s9', "Segoe UI")

    myGui.AddText("Section Center r1 xp+0 y+10", "Sell Type")
    myGui.AddRadio("vGUI_ST1 Group r1 xp+0 ys+25", "Money").OnEvent("Click", (GuiControl, Info) => SetSellType(GuiControl.Text))
    myGui.AddRadio("vGUI_ST2 r1 x+m", "Pix").OnEvent("Click", (GuiControl, Info) => SetSellType(GuiControl.Text))
    myGui.AddRadio("vGUI_ST3 r1 x+m", "Credit").OnEvent("Click", (GuiControl, Info) => SetSellType(GuiControl.Text))
    myGui.AddRadio("vGUI_ST4 r1 x+m Checked", "Debit").OnEvent("Click", (GuiControl, Info) => SetSellType(GuiControl.Text))
    SetSellType("debit")
    
    myGui.AddText("Section Center r1 xm+0 y+25", "Out Option")
    myGui.AddRadio("vGUI_OP1 Group r1 xp+0 ys+25", "1 Email").OnEvent("Click", (GuiControl, Info) => SetOutOption(FirstChar(GuiControl.Text)))
    myGui.AddRadio("vGUI_OP2 r1 x+m", "2 Virtual").OnEvent("Click", (GuiControl, Info) => SetOutOption(FirstChar(GuiControl.Text)))
    myGui.AddRadio("vGUI_OP3 r1 x+m", "3 Termic").OnEvent("Click", (GuiControl, Info) => SetOutOption(FirstChar(GuiControl.Text)))
    myGui.AddRadio("vGUI_OP4 r1 x+m", "4 SAT").OnEvent("Click", (GuiControl, Info) => SetOutOption(FirstChar(GuiControl.Text)))
    myGui.AddRadio("vGUI_OP5 r1 x+m Checked", "5 SAT Virtual").OnEvent("Click", (GuiControl, Info) => SetOutOption(FirstChar(GuiControl.Text)))
    SetOutOption(5)
    
    myGui.AddButton("vGUI_Do w395 r1 xm+0 y+25", "Do It").OnEvent("Click", (GuiControl, Info) => MakeSell())

    return myGui
}

FirstChar(str){
    return substr(str, 1 , 1)
}

CloseApp(*) {
    ExitApp()
}

SetSellType(sellTypeString){
    global sellType := StrLower(sellTypeString)
}
SetOutOption(outOptNumber){
    global outOpt := Integer(outOptNumber)
}

WaitWinExist(winTitle, sleepTime := keyTime){
    WinWait(winTitle)
    Sleep(sleepTime)
}

; string, number -> void
MakeSell() {
    ; transitionTime := 1200

    ; ************ Close Order ************
    WaitWinExist(windowOrder)

    ControlSend("{F10}",, windowOrder)

    ; ************ Sell Type ************
    WaitWinExist(windowSellType)

    field := ""
    switch sellType
    {
        case "money": field := "TEssEdit4"
        case "pix": field := "TEssEdit1"
        case "credit": field := "TEssEdit3"
        case "debit": field := "TEssEdit2"
    }

    ; vias := "TEdit1"
    confirm := "TBitBtn2"

    ControlClick(field, windowSellType, , "Left")
    Sleep(keyTime * 2)
    ControlClick(confirm, windowSellType, , "Left")

    ; ************ Strange Confirmation ************
    WaitWinExist(windowStrangeConfirm)

    ; ControlClick(confirm, windowStrangeConfirm, , "Left", 2)
    ControlSend("{Tab}",,windowStrangeConfirm)
    Sleep(keyTime)
    ControlSend("{Enter}",,windowStrangeConfirm)

    ; ************ Out Opt ************
    WaitWinExist(windowOutOpt)

    ; exit := "TBitBtn1"
    table := "TDBGrid1"

    ControlSend("{PgUp}", table, windowOutOpt)
    Sleep(keyTime)
    if(outOpt > 1){
        ControlSend("{Down " outOpt-1 "}", table, windowOutOpt)
        Sleep(keyTime * 2)
    }
    ControlSend("{Enter}", table, windowOutOpt)
    Sleep(keyTime * 2)

    ; ************ Out Opt (Again) ************
    WaitWinExist(windowOutOpt)

    ControlSend("{Enter}", table, windowOutOpt)

    ; ************ Cpf ************
    if(outOpt <= 3)
        return

    WaitWinExist(windowCpf)
    
    ; cpfEdit := "TEdit1"
    cpfOk := "TButton2"
    
    ; ControlClick(cpfOk, windowCpf)
    ControlSend("{Enter}", cpfOk, windowCpf)
    Sleep(keyTime)
    
    ; ************ Nota ************
    WaitWinExist(windowNota)

    ; pageNN := "TRLPreviewBox1"
    Sleep(2000)
    ControlSend("{Escape}",, windowNota)
}