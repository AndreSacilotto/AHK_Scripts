#Requires AutoHotkey v2.0
#SingleInstance Force

SetWorkingDir A_ScriptDir

SetControlDelay -1
SetKeyDelay(-1, 5)
SendMode("Input")

SetTitleMatchMode 3
DetectHiddenWindows true

; Variables ---------------------------------------

global excelFilePath := "C:\Users\Admin\Desktop\PRODUTOS_NEW.xlsx"

global windowExe := "ahk_exe VCash.exe"

global windowList := "ahk_class TfrmHKProduto"
global windowCod := "ahk_class TfrmProdRemaneja"

global xl1000 := 0
global xlNew := 0
global xl1000toNew := 0

ReadXls()

Esc::{
    ExitApp()
}

F4::{
    ControlClick("TPanel13", windowList,,"L", 1, "NA")
}
F6::{
    FromStartToEnd()
}
F7::{
    global xlNew
    FromSelection(xlNew)
}
F8::{
    global xl1000
    FromSelection(xl1000)
}
F9::{
    global xl1000toNew
    FromSelection(xl1000toNew)
}

ReadXls(){
    global xl1000, xlNew, xl1000toNew
    if(xl1000 = 0)
        xl1000 := ReadXL(excelFilePath, "C", "F")
    if(xlNew = 0)
        xlNew := ReadXL(excelFilePath, "C", "B")
    if(xl1000toNew = 0)
        xl1000toNew := ReadXL(excelFilePath, "F", "B")
}

; ------------------- XS -------------------

ReadCellXL(xl, letter, number){
    return xl.Range(letter number).Text ; .Value
}

ReadXL(path, kLeter, vLetter, start := 0){
    xl := ComObject("Excel.Application")
    xl.Visible := False
    xlWorkbook := xl.Workbooks.Open(path)
    xlWorkSheet := xlWorkbook.Worksheets(1)

    items := Map()

    ; A=Category | B="NewID" | C="OldID" | D="Name" 
    loop 
    {
        key := ReadCellXL(xl, kLeter, start + A_Index) or "00000"
        value := ReadCellXL(xl, vLetter, start + A_Index) or "00000"
        if (key or value)
            items[key] := value
        else
            break
    }
    xl.Quit()

    return items
}

GetNewIDFromCSV(xlMap, oldID)
{
    ; if(xlMap != ""){
    ;     MsgBox("No xl")
    ;     ExitApp()
    ; }

    if(StrLen(oldID) != 5){
        MsgBox("Invalid")
        ExitApp()
    }

    ; MsgBox(xlMap.Count " | " oldID)

    newID := xlMap[oldID]

    if(StrLen(newID) != 5){
        MsgBox("Invalid")
        ExitApp()
    }

    return newID
}

; ------------------- Robot -------------------

MasterAccess(){
    Send("{Enter}")
    Sleep(500)
    Send("{0}")
    Sleep(500)
    Send("{Enter}")
}

TableSelectOption(){
    ; ControlClick("TDBGrid1", windowList,, "R",1,"NA x0 y0")
    MouseClick("R")
    Sleep(100)
    loop 16{
        Send("{Down}")
        Sleep(80)
    }
    Send("{Enter}")
}

GetAndSetIDText(xlItems){
    nn_OldID_Field := "TEdit4"
    nn_NewID_Field := "TEdit3"

    currentID := ControlGetText(nn_OldID_Field, windowCod)

    ; if(xlNew.Has(currentID))
    ; {
    ;     MsgBox("Already Updated")
    ;     return
    ; }

    newID := GetNewIDFromCSV(xlItems, currentID)

    ControlFocus(nn_NewID_Field, windowCod)
    ControlSetText(newID, nn_NewID_Field, windowCod)

    ; MsgBox("OldID: " currentID " | NewID: " newID)

    nn_Confirm := "TBitBtn3"
    ControlClick(nn_Confirm, windowCod)
}

FromStartToEnd(){
    ; select first item of first row
    loop 200 {
        Sleep(250)
        ControlClick("TPanel4", windowList) ; search click
        Sleep(250)
        FromSelection(xl1000)
        Sleep(10050)
        Send("{Down}")
        Sleep(200)
    }
}

FromSelection(xlFrom){
    global xl1000, xlNew
    TableSelectOption()
    Sleep(300)
    MasterAccess()
    Sleep(550)
    GetAndSetIDText(xlFrom)
}