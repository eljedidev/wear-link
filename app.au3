# =============================================================================
# Aplicación: Wear Link
# Creado por: elJedi
# Sitio web: www.eljedi.com
#
# Nota: Requiere un smartwatch compatible con Wear OS y Windows 10 o posterior.
#
# =============================================================================


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Img\wearlink.ico
#AutoIt3Wrapper_Outfile_x64=WearLink_v1.4.2.Exe
#AutoIt3Wrapper_Res_Fileversion=1.4.2.3
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=WearLink
#AutoIt3Wrapper_Res_ProductVersion=1.4.2
#AutoIt3Wrapper_Res_CompanyName=RocketRC
#AutoIt3Wrapper_Res_Language=1034
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region INCLUDE
#include <AutoItConstants.au3>
#include <GuiConstantsEx.au3>
#include <Constants.au3>
#include <SendMessage.au3>
#include <GUIConstants.au3>
#include <Process.au3>
#include <MsgBoxConstants.au3>
#include <GuiButton.au3>
#include <ProgressConstants.au3>
#include <GuiStatusBar.au3>
#include <file.au3>
#EndRegion INCLUDE
Opt("GUIOnEventMode", 1)


global $idProgressbar1,$label, $hGUI, $hGUIconnect1, $hGUIpair1, $hGUIpair2, $hGUIinstall, $hGUIdpi, $idButton_Connect, $idButton_Install, $idButton_DPI

main()

While 1
    Sleep(100) ; Sleep to reduce CPU usage
WEnd



Func main()

; Creacion del GUI

$hGUI = GUICreate("WearLink v1.4.2", 434, 250)
GUISetBkColor(0x000000)
GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
GUISetIcon("wearlink.ico")

$idPic = GUICtrlCreatePic(@ScriptDir & "\Img\wearlink.gif", 0, 0, 434,100)
$label = GUICtrlCreateLabel ("Preparado", 12, 105, 400, 20, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetColor ( -1, 0xFFFFFF )
	GUICtrlSetFont(-1, 16)

$idProgressbar1 = GUICtrlCreateProgress(12, 130, 400, 10)

$idButton_Connect = GUICtrlCreateButton("Conectar", 12,147, 130, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "connect_check")

$idButton_Install = GUICtrlCreateButton("Instalar", 147,147, 130, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "drop_install")
	GUICtrlSetState(-1, 128)

$idButton_DPI = GUICtrlCreateButton("Cambiar DPI", 282,147, 130, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "dpi1")
	GUICtrlSetState(-1, 128)

GUICtrlCreateLabel ("by elJedi", 12, 220, 400, 30, $SS_CENTER)
	GUICtrlSetColor ( -1, 0xFFFFFF )


GUISetState(@SW_SHOW)

EndFunc


Func connect_check()

; Selector del tipo de conexion

  GUICtrlSetData($label, "Buscando dispositivo...")

  $paired = MsgBox(4, "Emparejamiento", "¿El dispositivo está emparejado?")

  If $paired = 6 then ; Sí
    connect1()
  Else
	pair1()
  EndIf


EndFunc

func connect1()
; Creacion del Gui para la conexion

	GUISetState(@SW_HIDE, $hGUI)

	$hGUIconnect1 = GUICreate("Conectando...", 320, 435)
	GUISetBkColor(0x000000)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEconnect1")

	Local $idPic = GUICtrlCreatePic(@ScriptDir & "\Img\connect.gif", 10, 10, 300,300)

	GUICtrlCreateLabel ("Ip de conexion", 10, 315, 300, 30)
	GUICtrlSetColor ( -1, 0xFFFFFF )
	GUICtrlSetFont(-1, 16)

	global $IP = GUICtrlCreateInput("", 10, 345, 300, 30)
		GUICtrlSetFont(-1, 16)

	$idButton_next = GUICtrlCreateButton("Siguiente", 10, 380, 300, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "connect2")


	GUISetState(@SW_SHOW)

EndFunc

func connect2()
; Proceso de conexion
	ProgressOn("", "Conectando")

	ProgressSet(10)
    _RunDos(@ScriptDir & "\Adb\adb.exe start-server")

	ProgressSet(20)
	local  $txIP = GUICtrlRead($IP)
	ConsoleWrite($IP)

	ProgressSet(50)
    $runAdb = Run(@ScriptDir & "\Adb\adb.exe connect " & $txIP, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	ProcessWaitClose($runAdb)
	$sOutput = StringStripWS(StdoutRead($runAdb), $STR_STRIPLEADING + $STR_STRIPTRAILING)
	ConsoleWrite($sOutput)
	ProgressSet(80)

	ProgressSet(100)
	sleep(1000)

	if StringRegExp($sOutput, "(?i)\b(connected to)\b") = 1 Then
		CLOSEconnect1()
		ProgressOff()
		GUICtrlSetState($idButton_Connect, 128)
		GUICtrlSetState($idButton_DPI, 64)
		GUICtrlSetState($idButton_Install, 64)
		GUICtrlSetData($idProgressbar1, 100)

		GUICtrlSetData($label, "Conectado!")
	Else
		ProgressOff()
		MsgBox(48, "Error", "Error al conectar")
		ConsoleWrite("No se pudo conectar")
	EndIf
EndFunc


func pair1()
; Creacion de Gui de emparejamiento
GUISetState(@SW_HIDE, $hGUI)

    $hGUIpair1 = GUICreate("Emparejar...", 320, 380)
	GUISetBkColor(0x000000)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEpair1")

	Local $idPic = GUICtrlCreatePic(@ScriptDir & "\Img\pair1.gif", 10, 10, 300,300)

	$idButton_next = GUICtrlCreateButton("Siguiente", 10,320, 300, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "pair2")

GUISetState(@SW_SHOW)

EndFunc

Func pair2()
; Creacion del siguiente GUi de emparejamiento
	GUISetState(@SW_HIDE, $hGUIpair1)

	$hGUIpair_form2 = GUICreate("Emparejar...", 320, 510)
	GUISetBkColor(0x000000)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEpair2")

	Local $idPic = GUICtrlCreatePic(@ScriptDir & "\Img\pair2.gif", 10, 10, 300,300)

	GUICtrlCreateLabel ("Codigo de emparejamiento", 10, 315, 300, 30)
	GUICtrlSetColor ( -1, 0xFFFFFF )
	GUICtrlSetFont(-1, 16)

	global $pairCode = GUICtrlCreateInput("", 10, 345, 300, 30)
		GUICtrlSetFont(-1, 16)


	GUICtrlCreateLabel ("IP de emparejamiento", 10, 380, 300, 30)
	GUICtrlSetColor ( -1, 0xFFFFFF )
	GUICtrlSetFont(-1, 16)

	global $pairIP = GUICtrlCreateInput("", 10, 410, 300, 30)
		GUICtrlSetFont(-1, 16)


	$idButton_next = GUICtrlCreateButton("Siguiente", 10, 455, 300, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "pair_process")


	GUISetState(@SW_SHOW)
EndFunc


func pair_process()
; Proceso de emparejamiento
	ProgressOn("", "Emparejando")

	_RunDos(@ScriptDir & "\Adb\adb.exe kill-server")
	ProgressSet(10)
    _RunDos(@ScriptDir & "\Adb\adb.exe start-server")

	ProgressSet(20)
	local  $txIP = GUICtrlRead($pairIP)
	local  $txCode = GUICtrlRead($pairCode)
	ConsoleWrite($txIP &" \n " & $txCode)

	ProgressSet(50)
    $runAdb = Run(@ScriptDir & "\Adb\adb.exe pair " & $txIP & " " & $txCode, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	ProcessWaitClose($runAdb)
	$sOutput = StringStripWS(StdoutRead($runAdb), $STR_STRIPLEADING + $STR_STRIPTRAILING)
	ConsoleWrite($sOutput)
	ProgressSet(80)


	ProgressSet(100)
	sleep(1000)

	if StringRegExp($sOutput, "(?i)\b(Successfully paired)\b") = 1 Then
		CLOSEpair2()
		ProgressOff()
		connect1()
	Else
		ProgressOff()
		MsgBox(48, "Error", "Error al conectar")
		ConsoleWrite("No se pudo emparejar")
	EndIf
EndFunc


func drop_install()
; Creacion del Gui de instalacion

GUISetState(@SW_HIDE, $hGUI)

    $hGUIinstall = GUICreate("Instalar", 320, 200, Default, Default, -1, $WS_EX_ACCEPTFILES)
	GUISetBkColor(0x000000)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEinstall")

	Global $dropFile = GUICtrlCreateInput ("", 10, 5, 300, 100, -1, $WS_EX_STATICEDGE)
	GUICtrlSetState (-1, $GUI_DROPACCEPTED)
	GUICtrlSetState(-1, 128)

	GUICtrlCreateLabel ("Arrastra el archivo al cuadro", 10, 110, 300, 30, $SS_CENTER)
	GUICtrlSetColor ( -1, 0xFFFFFF )
	GUICtrlSetFont(-1, 16)

	$idButton_next = GUICtrlCreateButton("Instalar", 10, 145, 300, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "install")


	GUISetState($GUI_DROPACCEPTED)



EndFunc

Func install()
; Proceso de instalación

	ProgressOn("", "Instalando apk...")

	$dropFile_1 = CHR(34) & GUICtrlRead($dropFile) & CHR(34)

	ConsoleWrite(@CR & $dropFile_1 & @CR)

	ProgressSet(40)
	$runAdb2 = Run(@ScriptDir & "\Adb\adb.exe install " & $dropFile_1, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	ProgressSet(80)
	ProcessWaitClose($runAdb2)

	$sOutput2 = StringStripWS(StdoutRead($runAdb2), $STR_STRIPLEADING + $STR_STRIPTRAILING)
	ConsoleWrite($sOutput2 & @CR)


	if StringRegExp($sOutput2, "(?i)\b(Success)\b") = 1 Then
		ProgressSet(100)
		sleep(1000)
		ProgressOff()
		CLOSEinstall()

		GUICtrlSetData($label, "Exito!")
		sleep(2000)
		GUICtrlSetData($label, "Conectado!")
		GUISetState(@SW_SHOW, $hGUI)
	Else
		ProgressOff()
		; MsgBox(48, "Error", "Error al instalar")
		ConsoleWrite("No se pudo instalar" & @CR)

	EndIf


EndFunc


Func dpi1()
; Creación de Gui de DPI

GUISetState(@SW_HIDE, $hGUI)

    $hGUIdpi = GUICreate("DPI", 320, 435, Default, Default)
	GUISetBkColor(0x000000)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEdpi")

	Local $idPic = GUICtrlCreatePic(@ScriptDir & "\Img\dpi.gif", 10, 10, 300,300)

	GUICtrlCreateLabel ("Elige el DPI", 10, 315, 300, 30, $SS_CENTER)
	GUICtrlSetColor ( -1, 0xFFFFFF )
	GUICtrlSetFont(-1, 16)

	global $setDPI = GUICtrlCreateCombo("", 10, 345, 300, 30)
		GUICtrlSetFont(-1, 16)
	GUICtrlSetData(-1, "300|280|260|240|220|200|Whatsapp|Whatsapp-mini|Telegram|Restablecer", "Restablecer")

	GUICtrlCreateButton("Cambiar", 10, 380, 300, 50)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "dpi2")

	GUISetState(@SW_SHOW)

EndFunc

Func dpi2()
; Proceso del cambio de DPI
	$rdDPI = GUICtrlRead($setDPI)

	if $rdDPI = "Whatsapp" Then
		$rdDPI = 150
	elseif $rdDPI = "Restablecer" Then
		$rdDPI = "reset"
	elseif $rdDPI = "Whatsapp-mini" Then
		$rdDPI = "90"
	elseif $rdDPI = "Telegram" Then
		$rdDPI = "150"
	EndIf

	ConsoleWrite($rdDPI & @CR)

	$runAdb = Run(@ScriptDir & "\Adb\adb.exe shell wm density " & $rdDPI, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	ProcessWaitClose($runAdb)

	MsgBox(64, "", "DPI Cambiado")
EndFunc



func CLOSEButton()
; Cerrar aplicación y matar adb

   _RunDos(@ScriptDir & "\Adb\adb.exe kill-server")
   Exit
endfunc

func CLOSEconnect1()
; Cerrar GUI
	GUIDelete($hGUIconnect1)
	GUISetState(@SW_SHOW, $hGUI)
EndFunc

func CLOSEpair1()
; Cerrar GUI
	GUIDelete($hGUIpair1)
	GUISetState(@SW_SHOW, $hGUI)
EndFunc

func CLOSEpair2()
; Cerrar GUI

	GUIDelete($hGUIpair2)
	GUISetState(@SW_SHOW, $hGUI)
EndFunc

Func CLOSEinstall()
; Cerrar GUI

	GUIDelete($hGUIinstall)
	GUISetState(@SW_SHOW, $hGUI)
EndFunc

func CLOSEdpi()
; Cerrar GUI

	GUIDelete($hGUIdpi)
	GUISetState(@SW_SHOW, $hGUI)

EndFunc