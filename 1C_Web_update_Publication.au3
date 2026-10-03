#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rsln
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ #include <Inet.au3>
#include <File.au3>
#include <Array.au3>
#include <Date.au3>
;~ #include <FTPEx.au3>
;~ Global $ftpserver, $ftplogin, $ftppassword
;~ #include <Crypt.au3>
;Игнорирование ошибок при помощи пустой _MyErrorHandler
#include 'OnAutoItErrorRegister.au3'
_OnAutoItErrorRegister('_MyErrorHandler', '', '', False, True)

$ScriptName = StringRegExpReplace(@ScriptName, '\..{2,3}$', '', 1) ;получаем имя скрипта
$sPath_ini = @ScriptDir & '\' & $ScriptName & '.ini'
Global $logFile = @ScriptDir & '\' & $ScriptName & '.log'
Global $tempLog
;завершение предыдущего запуска программы
_closeLastProc($sPath_ini)
$WorkRestart = True
;~ $WorkRestart = False


; Если есть новая подходящяя для публикации платформа, которая ещё ен опубликована в веб,
; но предыдущяя опубликована, то выполнить перепубликацию с перезапуском веб

;получаем подходящие платформы 64
$aPlatfs = _getLastPlatformWeb64()
If Not $WorkRestart Then _ArrayInsert($aPlatfs, 0, 'C:\Program Files\1cv8\9.9.99.9999')

$newVer = StringRegExp($aPlatfs[0], '\\(\d+\.\d+\.\d+[^\\]*)\\?', 3)
$newVer = $newVer[0]

If UBound($aPlatfs) < 2 Then _quit('Нет новых платформ')
ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') :  UBound($aPlatfs) = ' & UBound($aPlatfs) & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;получаем публикации Apache
$aPublic = _getApachePublication()
For $ii = 0 To UBound($aPublic) - 1
	If StringInStr($aPlatfs[0], $aPublic[$ii][0]) Then
		_log('Уже стоит новая версия ' & $aPublic[$ii][0])
		ExitLoop
	ElseIf StringInStr($aPlatfs[1], $aPublic[$ii][0]) Then
		_log('Начинаем публикацию Apache с версии ' & $aPublic[$ii][0] & ' на ' & $aPlatfs[0]& ' для файла '&$aPublic[$ii][1])
		$sRead=FileRead($aPublic[$ii][1])
		$sNewText = StringRegExpReplace($sRead, '(_1cws_module.*)/(\d+\.\d+\.\d+[^/]*)/', '\1/' & $newVer & '/')
		$atestfile = StringRegExp($sNewText, '_1cws_module "([^"]*)"', 3)
		$atestfile=StringReplace($atestfile[0],'/','\')
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $atestfile = ' & $atestfile & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
		If Not FileExists($atestfile) Then
			_log('Нет нужного файла ' & $atestfile)
			ExitLoop
		EndIf
		If Not $WorkRestart Then $aPublic[$ii][2] = 'Schedule'
		If $WorkRestart Then FileDelete($aPublic[$ii][1])
		If $WorkRestart Then FileWrite($aPublic[$ii][1], $sNewText)
		$t = RunWait(@ComSpec & " /c " & 'net stop "' & $aPublic[$ii][2] & '"', "", @SW_HIDE)
		If $t = 0 Then _log('Служба ' & $aPublic[$ii][2] & ' успешно остановлена')
		Sleep(1000)
		If $WorkRestart Then FileDelete($aPublic[$ii][1])
		If $WorkRestart Then FileWrite($aPublic[$ii][1], $sNewText)
		$t = RunWait(@ComSpec & " /c " & 'net start "' & $aPublic[$ii][2] & '"', "", @SW_HIDE)
		If $t = 0 Then _log('Служба ' & $aPublic[$ii][2] & ' успешно запущена')
		Sleep(1000)
		$t = RunWait(@ComSpec & " /c " & 'net start "' & $aPublic[$ii][2] & '"', "", @SW_HIDE)
		If $t = 0 Then _log('Служба ' & $aPublic[$ii][2] & ' успешно запущена')
	EndIf
Next

;получаем публикации IIS
$aPublic = _getWebIISPublication()
For $ii = 0 To UBound($aPublic) - 1
	If StringInStr($aPlatfs[0], $aPublic[$ii][0]) Then
		_log('Уже стоит новая версия ' & $aPublic[$ii][0])
		ExitLoop
	ElseIf StringInStr($aPlatfs[1], $aPublic[$ii][0]) Then
		_log('Начинаем публикацию IIS с версии ' & $aPublic[$ii][0] & ' на ' & $aPlatfs[0] & ' для файла '&$aPublic[$ii][1])
		$sRead=FileRead($aPublic[$ii][1])
		$sNewText = StringRegExpReplace($sRead, '(scriptProcessor="[^"]*?)\\(\d+\.\d+\.\d+[^/\\]*)\\', '\1/' & $newVer & '/')
;~ 		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sNewText = ' & $sNewText & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
		$atestfile = StringRegExp($sNewText, 'scriptProcessor="([^"]*)"', 3)
		$atestfile=StringReplace($atestfile[0],'/','\')
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $atestfile = ' & $atestfile & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
		If Not FileExists($atestfile) Then
			_log('Нет нужного файла ' & $atestfile)
			ExitLoop
		EndIf
		If Not $WorkRestart Then $aPublic[$ii][2] = 'Schedule'
		If $WorkRestart Then FileDelete($aPublic[$ii][1])
		If $WorkRestart Then FileWrite($aPublic[$ii][1], $sNewText)
		$t = RunWait(@ComSpec & " /c " & 'net stop "' & $aPublic[$ii][2] & '"', "", @SW_HIDE)
		If $t = 0 Then _log('Служба ' & $aPublic[$ii][2] & ' успешно остановлена')
		Sleep(1000)
		If $WorkRestart Then FileDelete($aPublic[$ii][1])
		If $WorkRestart Then FileWrite($aPublic[$ii][1], $sNewText)
		$t = RunWait(@ComSpec & " /c " & 'net start "' & $aPublic[$ii][2] & '"', "", @SW_HIDE)
		If $t = 0 Then _log('Служба ' & $aPublic[$ii][2] & ' успешно запущена')
		Sleep(1000)
		$t = RunWait(@ComSpec & " /c " & 'net start "' & $aPublic[$ii][2] & '"', "", @SW_HIDE)
		If $t = 0 Then _log('Служба ' & $aPublic[$ii][2] & ' успешно запущена')
	EndIf
Next

;~ exit
; Завершение работы
$tmpf=_TempFile(@TempDir,'','.txt')
FileWriteLine($tmpf,$tempLog)
;~ ShellExecute($tmpf)
exit


;~ $aServ = _GetServicesList()
;~ _ArrayDisplay($aPublic)

;~ $aver=StringRegExp('LoadModule _1cws_module "C:/Program Files/1cv8/8.3.27.1786/bin/wsap24.dll"','_1cws_module.*/(\d+\.\d+\.\d+[^/]*)/',3)


;~ ConsoleWrite('@@ Debug(' & $aver[0] & ') : $aver = ' & $aver & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

Func _getWebIISPublication()
	Local $aRes[0][3]
;~ 	_ArrayAdd($aRes,$objItem.PathName)
	$aServ = _FileListToArrayRec('C:\inetpub\wwwroot', 'web.config', $FLTA_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
	_ArrayDelete($aServ, 0)
	For $ii = 0 To UBound($aServ) - 1

		$conf = $aServ[$ii]
;~ 		$conf=StringReplace($conf,'"','')
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $conf = ' & $conf & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
		$sRead=FileRead($conf)
		$aver=StringRegExp($sRead,'scriptProcessor="[^"]*\\(\d+\.\d+\.\d+[^/\\"]*)\\',3)
		if @error then ContinueLoop
;~ 		_ArrayAdd($aRes,$aver[0]&'|'&$conf&'|'&$aServ[$ii][0])
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $aver[0] = ' & $aver[0] & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
		_ArrayAdd($aRes, $aver[0] & '|' & $conf & '|' & 'W3SVC')

	Next
	Return $aRes
EndFunc   ;==>_getWebIISPublication

Func _getApachePublication()
	Local $aRes[0][3]
;~ 	_ArrayAdd($aRes,$objItem.PathName)
	$aServ = _GetServicesList()
	For $ii = 0 To UBound($aServ) - 1
		If StringInStr($aServ[$ii][1], 'Apache') > 0 Or StringInStr($aServ[$ii][1], 'httpd.exe') Then
			$conf = StringRegExpReplace($aServ[$ii][1], '\\bin\\.*', '\\conf\\httpd.conf')
			$conf = StringReplace($conf, '"', '')
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $conf = ' & $conf & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
			$sRead = FileRead($conf)
			$aver = StringRegExp($sRead, '_1cws_module.*/(\d+\.\d+\.\d+[^/]*)/', 3)

			If @error Then ContinueLoop
			_ArrayAdd($aRes, $aver[0] & '|' & $conf & '|' & $aServ[$ii][0])
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $aver[0] = ' & $aver[0] & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

		EndIf
	Next
	Return $aRes
EndFunc   ;==>_getApachePublication
Func _GetServicesList() ;[0][0] Services Count, [x][0] Service name, [x][1] Service State
;~     Local $iExitCode, $st,$a,$aServicesList[1][2],$x
;~     $iExitCode = Run(@ComSpec & ' /C sc queryex type= service state= all', '', @SW_HIDE, 0x2)
;~     While 1
;~         $st &= StdoutRead($iExitCode)
;~         If @error Then ExitLoop
;~         Sleep(10)
;~     WEnd
;~     $a = StringRegExp($st,'(?m)(?i)(?s)(?:SERVICE_NAME|NOME_SERVI€O)\s*?:\s+?(\w+).+?(?:STATE|ESTADO)\s+?:\s+?\d+?\s+?(\w+)',3)
;~     For $x = 0 To UBound($a)-1 Step 2
;~         ReDim $aServicesList[UBound($aServicesList)+1][2]
;~         $aServicesList[UBound($aServicesList)-1][0]=$a[$x]
;~         $aServicesList[UBound($aServicesList)-1][1]=$a[$x+1]
;~     Next
;~     $aServicesList[0][0]=UBound($aServicesList)-1
;~     Return $aServicesList
	$strComputer = "."
	$objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Service WHERE Started = 'True' ")
;~ 	ConsoleWrite ("-------- Запущенные службы: --------" & @CRLF)
	Local $aRes[0][2]
	For $objItem In $colItems
;~ 		ConsoleWrite($objItem.Name& ' - '&$objItem.PathName & @CRLF)
		_ArrayAdd($aRes, $objItem.Name & '|' & $objItem.PathName)
	Next
	Return $aRes
EndFunc   ;==>_GetServicesList

;восстанавливаем дату из 20250928000000 в YYYY/MM/DD[ HH:MM:SS]
Func _dr($text)
	$ret = StringMid($text, 1, 4) & '/' & StringMid($text, 5, 2) & '/' & StringMid($text, 7, 2)
	If StringMid($text, 9, 2) <> '' Then $ret &= ' ' & StringMid($text, 9, 2) & ':' & StringMid($text, 11, 2)
	If StringMid($text, 13, 2) <> '' Then $ret &= ':' & StringMid($text, 13, 2)
	Return $ret
EndFunc   ;==>_dr

Func _getLastPlatformWeb64()
	$t = _FileListToArray('C:\Program Files\1cv8', '*', $FLTA_FOlders, True)
	_ArraySort($t, 1, 1)
	For $ii = $t[0] To 1 Step -1
		If Not StringRegExp($t[$ii], '\d+\.\d+\.\d+') Then _ArrayDelete($t, $ii)
		If Not FileExists($t[$ii] & '\bin\webinst.exe') Then _ArrayDelete($t, $ii)
	Next
	_ArrayDelete($t, 0)
;~ 	_ArrayDisplay($t)
	Return $t
EndFunc   ;==>_getLastPlatformWeb64

Func _PathGetLast($path, $mask = '*', $numlast = -1, $daylast = 0) ; $numlast сколько последних -1 не массивом один эл.
	$aFiles = _FileListToArray($path, $mask, $FLTA_FOlders, True)
	If @error Then
		If $numlast = -1 Then Return -1
		Local $aTmp[0][2]
		Return $aTmp
	EndIf
	Local $aTmp[$aFiles[0]][2]
	For $ii = 1 To $aFiles[0]
		$aTmp[$ii - 1][1] = $aFiles[$ii]
		$aTmp[$ii - 1][0] = FileGetTime($aFiles[$ii], 0, 1)
	Next
	_ArraySort($aTmp, 1)
	If $numlast = -1 Then Return $aTmp[0][1]
	If $numlast = 0 And $daylast <> 0 Then
		$dateStartT = _DateAdd('D', -1 * $daylast, _NowCalc())
		$dateStartT = StringRegExpReplace($dateStartT, '[^0-9]', '')
;~ 		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $dateStartT = ' & $dateStartT & @CRLF) ;### Debug Console
		For $ii = 0 To UBound($aTmp) - 1
			If $aTmp[$ii][0] > $dateStartT Then $numlast += 1
;~ 				ConsoleWrite('@@ Debug(' & $numlast & ') : $aTmp[$ii][0] = ' & $aTmp[$ii][0] & @CRLF) ;### Debug Console
		Next
	EndIf
	ReDim $aTmp[$numlast][2]
	_ArrayColDelete($aTmp, 0, True)

	Return $aTmp
EndFunc   ;==>_PathGetLast

Func _log($text, $parm2 = '', $parm3 = '', $parm4 = '', $parm5 = '')
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $text = ' & ($text) & @CRLF) ;### Debug Console
	$time = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & '-' & @MIN & '-' & @SEC
	$nameThis = @ComputerName
	$textl = $nameThis & @TAB & $text & @TAB & $parm2 & @TAB & $parm3 & @TAB & $parm4 & @TAB & $parm5
	$tempLog=Eval('tempLog')&$textl&@CRLF
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $tempLog = ' & $tempLog & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	;проверяем если последний текст в файле лога уже есть, то не дозаписываем
	$hFile = FileOpen($logFile, 0)
	FileSetPos($hFile, StringLen($textl) * -1.99, $FILE_END)
	$chl = FileRead($hFile, StringLen($textl) * 1.99) ; Запись данных от установленной позиции
	FileClose($hFile)
	If StringInStr($chl, $textl) Then Return 0
		ConsoleWrite('@@ Debug(' & $textl & ') : $chl = ' & $chl & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

	FileWriteLine($logFile, $time & @TAB & $textl)
;~ 	If $parm2 <> '' Then _SendLog($nameThis, $parm2, $parm3, $parm4, $parm5)
EndFunc   ;==>_log

Func _closeLastProc($sPath_ini) ;завершение предыдущего запуска программы
	$last_pid = IniRead($sPath_ini, "Settings", '$last_pid', '-1')
	$last_pid2 = IniRead($sPath_ini, "Settings", '$last_pid2', '-1')
	IniWrite($sPath_ini, "Settings", "$last_pid", @AutoItPID) ;записываем ПИД в ини файл
	IniWrite($sPath_ini, "Settings", "$last_pid2", $last_pid) ;записываем ПИД в ини файл
	If $last_pid <> '-1' Then
		If ProcessExists($last_pid) Then
			$aList = ProcessList(@ScriptName)
			If Not @error Then
				For $i = 1 To $aList[0][0]
					If $last_pid = $aList[$i][1] Then ProcessClose($last_pid)
				Next
			EndIf
			$aList = ProcessList(StringRegExpReplace(@AutoItExe, '^.*\\', ''))
			If Not @error Then
				For $i = 1 To $aList[0][0]
					If $last_pid = $aList[$i][1] Then ProcessClose($last_pid)
				Next
			EndIf

		EndIf
	EndIf
	If $last_pid2 <> '-1' Then
		If ProcessExists($last_pid2) Then
			$aList = ProcessList(@ScriptName)
			For $i = 1 To $aList[0][0]
				If $last_pid2 = $aList[$i][1] Then ProcessClose($last_pid2)
			Next
			$aList = ProcessList(StringRegExpReplace(@AutoItExe, '^.*\\', ''))
			For $i = 1 To $aList[0][0]
				If $last_pid2 = $aList[$i][1] Then ProcessClose($last_pid2)
			Next
		EndIf
	EndIf
EndFunc   ;==>_closeLastProc

Func _PathSplitByRegExp($sPath, $mod = 0)
	If $sPath = "" Or (StringInStr($sPath, "\") And StringInStr($sPath, "/")) Then Return SetError(1, 0, -1)

	Local $aRetArray[8], $pDelim = ""

	If StringRegExp($sPath, '^(?i)([A-Z]:|\\)(\\[^\\]+)+$') Then $pDelim = "\"
	If StringRegExp($sPath, '(?i)(^.*:/)(/[^/]+)+$') Then $pDelim = "//"

	If $pDelim = "" Then $pDelim = "/"
	If Not StringInStr($sPath, $pDelim) Then Return $sPath
	If $pDelim = "\" Then $pDelim &= "\"

	Switch $mod
		Case 0
			$aRetArray[0] = $sPath ;Full path
			$aRetArray[1] = StringRegExpReplace($sPath, $pDelim & '.*', $pDelim) ;Drive letter
			$aRetArray[2] = StringRegExpReplace($sPath, $pDelim & '[^' & $pDelim & ']*$', '') ;Path without FileName and extension
			$aRetArray[3] = StringRegExpReplace($sPath, '\.[^.]*$', '') ;Full path without File Extension
			$aRetArray[4] = StringRegExpReplace($sPath, '(?i)([A-Z]:' & $pDelim & ')', '') ;Full path without drive letter
			$aRetArray[5] = StringRegExpReplace($sPath, '^.*' & $pDelim, '') ;FileName and extension
			$aRetArray[6] = StringRegExpReplace($sPath, '.*' & $pDelim & '|\.[^.]*$', '') ;Just Filename
			$aRetArray[7] = StringRegExpReplace($sPath, '^.*\.', '') ;Just Extension of a file
		Case 1
			Return StringRegExpReplace($sPath, $pDelim & '.*', $pDelim) ;Drive letter
		Case 2
			Return StringRegExpReplace($sPath, $pDelim & '[^' & $pDelim & ']*$', '') ;Path without FileName and extension
		Case 3
			Return StringRegExpReplace($sPath, '\.[^.]*$', '') ;Full path without File Extension
		Case 4
			Return StringRegExpReplace($sPath, '(?i)([A-Z]:' & $pDelim & ')', '') ;Full path without drive letter
		Case 5
			Return StringRegExpReplace($sPath, '^.*' & $pDelim, '') ;FileName and extension
		Case 6
			Return StringRegExpReplace($sPath, '.*' & $pDelim & '|\.[^.]*$', '') ;Just Filename
		Case 7
			Return StringRegExpReplace($sPath, '^.*\.', '') ;Just Extension of a file

	EndSwitch


	Return $aRetArray
EndFunc   ;==>_PathSplitByRegExp

Func _quit($msg = '')
	If $msg <> '' Then _log($msg)
;~ 	IniWrite($sPath_ini, "Settings", "$WorkStart", '1970/01/01 00:00:00')
	Exit
EndFunc   ;==>_quit

Func _Trans($iText)
	Dim $aLetters[33 + 33][2] = [['а', 'a'], ['б', 'b'], ['в', 'v'], ['г', 'g'], ['д', 'd'], ['е', 'e'], ['ё', 'e'], ['ж', 'zh'], ['з', 'z'], ['и', 'i'], _
			['й', 'y'], ['к', 'k'], ['л', 'l'], ['м', 'm'], ['н', 'n'], ['о', 'o'], ['п', 'p'], ['р', 'r'], ['с', 's'], ['т', 't'], _
			['у', 'u'], ['ф', 'f'], ['х', 'h'], ['ц', 'ts'], ['ч', 'ch'], ['ш', 'sh'], ['щ', 'shch'], ['ъ', "'"], ['ы', 'i'], ['ь', ''], _
			['э', 'ie'], ['ю', 'yu'], ['я', 'ya'], ['А', 'A'], ['Б', 'B'], ['В', 'V'], ['Г', 'G'], ['Д', 'D'], ['Е', 'E'], ['Ё', 'E'], ['Ж', 'Zh'], ['З', 'Z'], ['И', 'i'], _
			['Й', 'Y'], ['К', 'K'], ['Л', 'L'], ['М', 'M'], ['Н', 'N'], ['О', 'O'], ['П', 'P'], ['Р', 'R'], ['С', 'S'], ['Т', 'T'], _
			['У', 'U'], ['Ф', 'F'], ['Х', 'H'], ['Ц', 'Ts'], ['Ч', 'Ch'], ['Ш', 'Sh'], ['Щ', 'Shch'], ['Ъ', "'"], ['Ы', 'I'], ['Ь', ''], _
			['Э', 'Ie'], ['Ю', 'Yu'], ['Я', 'Ya']]
	$sBuffer = $iText
	For $i = 0 To UBound($aLetters) - 1
		$sBuffer = StringRegExpReplace($sBuffer, $aLetters[$i][0], $aLetters[$i][1])
	Next
	Return $sBuffer
EndFunc   ;==>_Trans

