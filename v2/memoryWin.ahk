#Requires AutoHotkey v2.0
#SingleInstance Force

; windowTitle := ""

; ^Esc::ExitApp

; mem := MemoryWin(windowTitle)

; F3::{
	; MsgBox mem.ReadMemory("Float", 0x1F85578B268)

	; address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
	; MemoryWin.HexMsgBox address
	; MsgBox mem.ReadMemory("Float", address, 0x18)
; }

; F4::{
	; MsgBox mem.WriteMemory(0.5, "Float", 0x1F85578B268)

; 	address := mem.GetStaticAddress("jvm.dll", 0x00AE05F8, 0x38, 0x58, 0x208, 0x80, 0xC0, 0x28, 0x130)
; 	MemoryWin.HexMsgBox address
; 	MsgBox mem.WriteMemory(0.5, "Float", address, 0x18)
; }

; #region Class

; address/offset need to start with 0x (if they are hex)
class MemoryWin 
{
	static TypeSize := Map( "UChar",1, "Char",1, "UShort",2, "Short",2, "UInt",4, "Int",4, "UFloat",4, "Float",4, "Int64",8, "Double",8 )
	static ProcRights := {
		PROCESS_ALL_ACCESS: 0x001F0FFF,
		PROCESS_CREATE_PROCESS: 0x0080,
		PROCESS_CREATE_THREAD: 0x0002,
		PROCESS_DUP_HANDLE: 0x0040,
		PROCESS_QUERY_INFORMATION: 0x0400,
		PROCESS_QUERY_LIMITED_INFORMATION: 0x1000,
		PROCESS_SET_INFORMATION: 0x0200,
		PROCESS_SET_QUOTA: 0x0100,
		PROCESS_SUSPEND_RESUME: 0x0800,
		PROCESS_TERMINATE: 0x0001,
		PROCESS_VM_OPERATION: 0x0008,
		PROCESS_VM_READ: 0x0010,
		PROCESS_VM_WRITE: 0x0020,
		SYNCHRONIZE: 0x00100000,
	}
	
	hwnd := 0
	procHandle := 0
	PID := 0 ; process ID
	ptrType := ""
	is64x := 0

	procBytesRead := 0 ; pointer
	procBytesWritten := 0 ; pointer

	; #region Ctor

	__New(WinTitle := "", WinText := "", ExcludeTitle := "", ExcludeText := "") 
	{
		if(this.hwnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)){

			this.PID :=	WinGetPID(WinTitle)
			this.procHandle := this.OpenProcess()

			this.procBytesRead := MemoryWin.GlobalAllocPointer()
			this.procBytesWritten := MemoryWin.GlobalAllocPointer()
			
			this.ptrType := (is64x := this.IsProcess64Bit()) ? "Int64" : "UInt"
				 
			return this
		}
		return 0
	}

	__Delete()
	{
		this.CloseHandle()
		if(this.procBytesRead)
			MemoryWin.GlobalFreePointer(this.procBytesRead)
		if(this.procBytesWritten)
			MemoryWin.GlobalFreePointer(this.procBytesWritten)
	}

	; #region Static Funcs

	static HexFormat(value){
		return Format("{1:p}", value)
	}

	static HexMsgBox(value){
		MsgBox Format("{1:p}", value)
	}

	static ShowLastError(from := ""){
		MsgBox ("Error: " A_LastError " - " from)
	}

	static GlobalAllocPointer(){
		return DllCall("GlobalAlloc", "UInt", 0x0040, "Ptr", A_PtrSize)
	}
	static GlobalFreePointer(ptr){
		return DllCall("GlobalFree", "Ptr", ptr)
	}

	static HasType(type){
		if (MemoryWin.TypeSize.Has(type))
			return MemoryWin.TypeSize[type]
		A_LastError := "X"
		MemoryWin.ShowLastError("Type")
		return 0
	}

	; #region Handle

	OpenProcess(dwDesiredAccess := MemoryWin.ProcRights.PROCESS_ALL_ACCESS)
	{
		if (handle := DllCall("OpenProcess", "UInt", dwDesiredAccess, "Int", false, "UInt", this.PID))
			return handle
		MemoryWin.ShowLastError("OpenProcess")
		return 0
	}

	CloseHandle()
	{
		if(DllCall("CloseHandle", "Ptr", this.procHandle)){
			this.procHandle := 0
			return 1
		}
		; SimpleMemory.ShowLastError("CloseHandle")
		return 0
	}

	IsHandleValid()
	{
		; 0x102 WAIT_TIMEOUT
		return 0x102 = DllCall("WaitForSingleObject", "Ptr", this.procHandle, "UInt", 0)
	}

	IsProcess64Bit()
	{
		if(A_Is64bitOS)
			return true
		if (DllCall("IsWow64Process", "Ptr", this.procHandle, "Int*", &Wow64Process))
			return Wow64Process
		return false
	}

	; #region Memory

	; this function gives the final address, use the return to read the wanted value
	GetStaticAddress(moduleName, moduleOffset := 0, offsets*){
		if(!size := MemoryWin.HasType(this.ptrType))
			return 0
		lpBuffer := Buffer(size)

		address := this.GetModule(moduleName).lpBaseOfDll + moduleOffset
		if(this.ReadRaw(address, lpBuffer))
			address := NumGet(lpBuffer, this.ptrType)

		if(!offsets.Length)
			return address
		
		loop(offsets.Length-1)
		{
			if(this.ReadRaw(address + offsets[A_Index], lpBuffer))
				address := NumGet(lpBuffer, this.ptrType)
		}
		return address + offsets[offsets.Length]
	}

	ReadRaw(lpBaseAddress, lpBuffer){
		if(DllCall("ReadProcessMemory", "Ptr", this.procHandle, "Ptr", lpBaseAddress, "Ptr", lpBuffer.Ptr, "Ptr", lpBuffer.Size, "Ptr", this.procBytesRead))
			return 1
		MemoryWin.ShowLastError("ReadProcessMemory")
		return 0
	}
	ReadMemory(type, address, adjustOffset := 0){
		if(!size := MemoryWin.HasType(type))
			return 0
		lpBuffer := Buffer(size)
		if(this.ReadRaw(address + adjustOffset, lpBuffer))
			return NumGet(lpBuffer, type)
		return 0
	}
	
	WriteRaw(lpBaseAddress, lpBuffer){
		if(DllCall("WriteProcessMemory", "Ptr", this.procHandle, "Ptr", lpBaseAddress, "Ptr", lpBuffer.Ptr, "Ptr", lpBuffer.Size, "Ptr", this.procBytesWritten))
			return 1
		MemoryWin.ShowLastError("WriteProcessMemory")
		return 0
	}
	; address need to start with 0x
	WriteMemory(value, type, address, adjustOffset := 0){
		if(!size := MemoryWin.HasType(type))
			return 0
		lpBuffer := Buffer(size)
		NumPut(type, value, lpBuffer)
		if(this.WriteRaw(address + adjustOffset, lpBuffer))
			return 1
		return 0
	}

	; #region Module

	GetModule(moduleName)
	{
		moduleCount := this.EnumProcessModulesEx(&lphModule)
		loop(moduleCount)
		{
			hModule := NumGet(lphModule.Ptr, (A_index - 1) * A_PtrSize, this.ptrType)

			moduleInfo := this.GetModuleInformation(hModule)

			moduleInfo.FilePath := this.GetModuleFileNameEx(hModule)
			
			SplitPath(moduleInfo.FilePath, &fileName)

			if(moduleName = fileName)
				return moduleInfo
		}
		return 0
	}

	GetModuleInformation(hModule)
	{
		lpModInfo := Buffer(A_PtrSize * 3)
		if(!DllCall("psapi\GetModuleInformation", "Ptr", this.procHandle, "Ptr", hModule, "Ptr", lpModInfo.Ptr, "UInt", lpModInfo.Size))
		{
			MemoryWin.ShowLastError("GetModuleInformation")
			return 0
		}
		return {
			lpBaseOfDll: NumGet(lpModInfo.Ptr, 0, "Ptr"),
			SizeOfImage: NumGet(lpModInfo.Ptr, A_PtrSize, "UInt"),
			EntryPoint: NumGet(lpModInfo.Ptr, A_PtrSize * 2, "Ptr"),
		}
	}

	GetModuleFileNameEx(hModule)
	{
		lpFilename := Buffer(2048 * 2)
        if(DllCall("psapi\GetModuleFileNameEx", "Ptr", this.procHandle, "Ptr", hModule, "Ptr", lpFilename.Ptr, "Uint", lpFilename.Size))
			return StrGet(lpFilename)
		MemoryWin.ShowLastError("GetModuleFileNameEx")
		return 0
	}

	EnumProcessModulesEx(&lphModule, dwFilterFlag := 0x03)
	{
		reqSize := 0
		lphModule := Buffer(A_PtrSize)
		while(true)
		{
			if(!DllCall("psapi\EnumProcessModulesEx", "Ptr", this.procHandle, "Ptr", lphModule.Ptr, "Uint", lphModule.Size, "Uint*", &reqSize, "Uint", dwFilterFlag))
			{
				MemoryWin.ShowLastError("EnumProcessModulesEx")
				return 0
			}

			if (lphModule.Size >= reqSize)
				break
			else
				lphModule := Buffer(reqSize)
		}
		return reqSize // A_PtrSize 
	}


}

