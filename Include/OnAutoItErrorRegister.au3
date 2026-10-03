#include-once

#Region Header

#CS
	Name: 				OnAutoItErrorRegister - Register AutoIt critical error handler (syntax error usualy).
	Author: 			Copyright © 2011-2015 CreatoR's Lab (G.Sandler), www.creator-lab.ucoz.ru, www.autoit-script.ru. All rights reserved.
	AutoIt version: 	3.3.10.2 - 3.3.12.0
	UDF version:		2.0

	Credits:
						* JScript (João Carlos) - code parts and few ideas from _AutoItErrorTrap UDF.

	Notes:
						* The UDF can not handle crashes that triggered by memory leaks, such as DllCall crashes, "Recursion level has been exceeded..." (when using hook method ($bUseStdOut = False)).
						* When using StdOut method ($bUseStdOut = True), CUI not supported, and additional process executed to allow monitor for errors.
						* After using _OnAutoItErrorUnRegister when $bUseStdOut = True, standard AutoIt error message will not be displayed on following syntax error.
						* To use the "Send bug report" feature, there is need to fill related parameters (variables) under the «User Variables» section in UDF file (check the comments of these variables), or just build your own user function.

						[If $bSetErrLine is True...]
							* Script must be executed before compilation (after any change in it), or use '#AutoIt3Wrapper_Run_Before=%autoitdir%\AutoIt3.exe "%in%" /BC_Strip' in your main script.
							* Do NOT use Au3Stripper when compiling the main script if you want correct error line detection for compiled script.
							* To get correct code line for compiled script, the script is transformed to raw source (merging includes) and FileInstall'ed when it's needed (on error),
								therefore, the script is available in temp dir for few moments (when error is triggered), although it's crypted, but developer should ensure that his script is more protected.

						[If $bSetErrLine is False...]
							* Use supplied GetErrLineCode.au3 to get proper error line code by line number from error that was triggered in compiled script.

	History:
	v2.0
	* UDF rewritten (used methods from AutoItErrorTrap UDF).
	  - Syntax changed, check function header for details.
	* Dropped AutoIt 3.3.8.1 support.
	+ Added last window screen capture feature. File can be sent as attachment when using "Send Bug Report" feature.

	v1.9
	+ Added error line detection for compiled script (to display actual line which caused the error).
		Script must be executed before compilation (after any change in it), or use '#AutoIt3Wrapper_Run_Before=%autoitdir%\AutoIt3.exe "%in%" /BC_Strip' in your main script.
		!!! Do NOT use Au3Stripper when compiling the main script.
	+ Added second function call detection (to prevent multiple recursive execution).
	* Fixed command line issue.

	v1.8
	+ Added 3.3.12.0 compatibility.
	+ Added _OnAutoItErrorUnRegister (see Example 1).
	* Now callback function ($sFunction) in _OnAutoItErrorRegister always recieve 4 parameters ($sScriptPath, $iScriptLine, $sErrDesc, $vParams).
	* Internal functions renamed from __OnAutoItErrorRegister_* to __OAER_*.
	* Removed the usage of command line to detect second script run.
	* More stability in detecting AutoIt error message (when $bUseStdOutMethod = False).
	* Fixed issue when main script (or other UDF) uses Opt('MustDeclareVars', 1).

	v1.7
	* Fixed an issue with showing tray icon even if #NoTrayIcon is specified in the main script.
	* Fixed an issue with not passing the original command line parameters to the main script.
	   Now added /OAER parameter to the command line at the end, it's an identifier for OnAutoItErrorRegister UDF.

	v1.6
	* Fixed an issue with COM errors catching (this UDF should not handle COM errors, it was just for sending email function).
	* Removed unneccessary #include <File.au3>.
	* Fixed bug with auto-ckicked buttons on Windows Vista/7.

	v1.5
	* Fixed issue with high CPU usage
	* "Send bug report" feature improved grately.
	* Added ability to translate all UDF elements (titles, messages, buttons and labels) - see "User Variables" section.
	* Cosmetic changes to the code.

	v1.4
	* UDF rewrited.

#CE

#include <WindowsConstants.au3>
#include <WinAPIShPath.au3>
#include <WinAPIProc.au3>
#include <WinAPILocale.au3>
#include <WinAPIFiles.au3>
#include <WinAPI.au3>
#include <StaticConstants.au3>
;~ #include <ScreenCapture.au3>
#include <GUIConstantsEx.au3>
#include <Date.au3>
#include <Crypt.au3>
#include <Constants.au3>

OnAutoItExitRegister('__OAER_OnExit')

#EndRegion Header

#Region Global Variables

Global Enum _
	$iOAER_bSet_ErrLine, $iOAER_bIn_Proc, $iOAER_bUse_StdOut, $iOAER_iPID, $iOAER_hErr_Callback, $iOAER_hErr_WinHook, $iOAER_sUserFunc, $iOAER_vUserParams, $iOAER_iCOMErrorNumber, $iOAER_sCOMErrorDesc, _
	$iOAER_Total

Global $aOAER_DATA[$iOAER_Total]

#EndRegion Global Variables

#Region User Variables

;Crypt key to protect somehow FileInstall'ed source code (used only if $bSetErrLine = True)
;!!! CHANGE IT TO YOUR PERSONAL UNIQUE KEY !!!
Global Const $sOAER_CRYPT_KEY		= 'MY_CRYPT_KEY'		;Crypt key
Global Const $iOAER_CRYPT_ALG		= $CALG_RC4 			;Crypt algorithm

Global Const $iOAER_ButtonsStyle 	= 1
Global Const $nOAER_DefWndBkColor 	= 0xE0DFE2

;===================== Should be changed =====================
Global $sOAER_DevEmailAddress 		= 'myemail@gmail.com' 	;Developer email address
Global $sOAER_DevEmailServer 		= 'smtp.gmail.com' 		;Email server (for gmail it's 'smtp.gmail.com')
Global $sOAER_DevEmailPort 			= 465					;Server port (for gmail it's 465 usualy)
Global $sOAER_DevEmailSSL 			= 1						;SSL enabled (for gmail should be 1)
Global $sOAER_DevEmailUsrName 		= 'myemail'				;Developer email user name
Global $sOAER_DevEmailPass 			= 'mypass'				;Developer email user password
;===================== Should be changed =====================

;Translations
Global $sOAER_Main_Title			= 'AutoIt3 Error'
Global $sOAER_Attention_Title		= 'Attention'
Global $sOAER_Error_Title			= 'Error'
Global $sOAER_Success_Title			= 'Success'

Global $sOAER_ErrMsgSendFrmt_Msg	= 'Program Path: %s\r\n\r\nError Line: %i\r\n\r\nError Description:\r\n\r\n%s\r\n\r\n====================\r\n%s'
Global $sOAER_ErrMsgDispFrmt_Msg	= 'Program has been Terminated :(.\r\nPlease report about this bug to developer, sorry for the inconvenience!\r\n\r\n' & $sOAER_ErrMsgSendFrmt_Msg
Global $sOAER_EnvFrmt_Msg			= 'Environment:\r\n\tAutoIt = %s\r\n\tOSLang = %s\r\n\tKBLayout = %s\r\n\tOS = %s\r\n\tCPU = %s\r\n\tRunTime = %s'
Global $sOAER_MainTxt_Msg			= 'An error occurred in the application.'
Global $sOAER_SendBugReport_Btn		= 'Send bug report'
Global $sOAER_ShowBugReport_Btn		= 'Show bug report'
Global $sOAER_ContinueApp_Btn		= 'Continue application'
Global $sOAER_RestartApp_Btn		= 'Restart application'
Global $sOAER_CloseApp_Btn			= 'Close application'
Global $sOAER_ShowLastScreen_Btn	= 'Show last screen'

;Send bug report part
Global $sOAER_BugReport_Title		= 'Bug Report'
Global $sOAER_SendBugReport_Title	= 'Send Bug Report'
Global $sOAER_ShowLastScreen_Title	= 'Last Screen'
Global $sOAER_SendBugReport_Tip		= 'Please fill the following data (* requierd fields):'
Global $sOAER_EmailServer_Lbl		= '* Email Server:'
Global $sOAER_FromName_Lbl			= '* From name:'
Global $sOAER_FromAddress_Lbl		= '* From address:'
Global $sOAER_ToAddress_Lbl			= '* To address:'
Global $sOAER_Subject_Lbl			= '* Subject:'
Global $sOAER_Body_Lbl				= '* Body (bug report):'
Global $sOAER_SendAttachment_Lbl	= 'Send attachment:'
Global $sOAER_SendingStatus_Lbl		= 'Sending, please wait...'
Global $sOAER_RequierdFields_Msg	= 'Please fill all requierd fields'
Global $sOAER_UnableToSend_Msg		= 'Unable to send bug report, please check the fields data.\n\nError Code:\n\t0x%X\nError Description:\n\t%s'
Global $sOAER_BugReportSent_Msg		= 'Bug Report have been sent.'

#EndRegion User Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name...........:	_OnAutoItErrorRegister
; Description....:	Registers a function to be called when AutoIt produces a critical error (syntax error usualy).
; Syntax.........:	_OnAutoItErrorRegister( [$sFunction = '' [, $vParams = '' [, $sTitle = '' [, $bUseStdOut = False [, $bSetErrLine = False]]]]])
; Parameters.....:	$sFunction        - [Optional] The name of the user function to call.
;                                           If this parameter is empty (''), then default (built-in) error message function is called.
;                                           Function always called with these arguments:
;                                           							$sScript_Path 	- Full path to the script / executable
;                                           							$iScript_Line	- Error script line number
;                                           							$sError_Msg		- Error message
;                                           							$vParams		- User parameters passed by $vParams
;                                           							$hBitmap        - hBitmap of last screen capture.
;					$vParams          - [Optional] User defined parameters that passed to $sFunction (default is '' - no parameters).
;					$sTitle           - [Optional] The title of the default error message dialog (used only if $sFunction = '').
;					$bUseStdOut       - [Optional] Defines the method that will be used to catch AutoIt errors (default is False - use hook method).
;					$bSetErrLine      - [Optional] Defines whether to enable error line code detection in compiled script or not (default is False - not enabled).
;
; Return values..:	None.
; Author.........:	G.Sandler (CreatoR), www.autoit-script.ru, www.creator-lab.ucoz.ru
; Remarks........:
; Related........:	_OnAutoItErrorUnRegister
; Example........:	Yes.
; ===============================================================================================================
Func _OnAutoItErrorRegister($sFunction = '', $vParams = '', $sTitle = '', $bUseStdOut = False, $bSetErrLine = False)
	If $aOAER_DATA[$iOAER_bIn_Proc] Then
		Return ;Prevent conflicts
	EndIf

	$aOAER_DATA[$iOAER_bIn_Proc] = True
	$aOAER_DATA[$iOAER_bSet_ErrLine] = ($bSetErrLine = True)

	If Not @Compiled Then
		If $aOAER_DATA[$iOAER_bSet_ErrLine] Then
			If $CmdLine[$CmdLine[0]] == '/BC_Strip' Then
				Opt('TrayIconHide', 1)

				Local $sSrc_Raw = _Crypt_EncryptData(StringStripWS(__OAER_AU3_StripToRaw(@ScriptFullPath), 3), $sOAER_CRYPT_KEY, $iOAER_CRYPT_ALG)
				Local $hFile = FileOpen(@ScriptDir & '\OAER_RAW_SRC.tmp', 2 + 16)
				FileWrite($hFile, $sSrc_Raw)
				FileClose($hFile)

				Exit
			EndIf

			Run(@AutoItExe & ' /AutoIt3ExecuteScript "' & @ScriptFullPath & '" /BC_Strip', @ScriptDir)
		Else
			FileClose(FileOpen(@ScriptDir & '\OAER_RAW_SRC.tmp', 2))
		EndIf
	EndIf

	;Executed with /ErrorStdOut, so we must set $bUseStdOut = True
	If StringInStr($CmdLineRaw, '/ErrorStdOut') Then
		$bUseStdOut = True
	EndIf

	$aOAER_DATA[$iOAER_bUse_StdOut] = $bUseStdOut
	$aOAER_DATA[$iOAER_sUserFunc] = $sFunction
	$aOAER_DATA[$iOAER_vUserParams]	= $vParams

	If $sTitle Then
		$sOAER_Main_Title = $sTitle
	EndIf

	;Trap the error window using callback!!!
	If Not $aOAER_DATA[$iOAER_bUse_StdOut] Then
		$aOAER_DATA[$iOAER_hErr_CallBack] = DllCallbackRegister('__OAER_OnErrorCallback', 'int', 'int;int;int')

		If Not $aOAER_DATA[$iOAER_hErr_CallBack] Then
			$aOAER_DATA[$iOAER_bUse_StdOut] = True
		Else
			$aOAER_DATA[$iOAER_hErr_WinHook] = _WinAPI_SetWindowsHookEx($WH_CBT, DllCallbackGetPtr($aOAER_DATA[$iOAER_hErr_CallBack]), 0, _WinAPI_GetCurrentThreadId())

			If Not $aOAER_DATA[$iOAER_hErr_WinHook] Then
				DllCallbackFree($aOAER_DATA[$iOAER_hErr_CallBack])
				$aOAER_DATA[$iOAER_bUse_StdOut] = True
			Else
				Return 1
			EndIf
		EndIf
	EndIf

	;Trap the error window using stdout!!!

	If StringRegExp($CmdLineRaw, ' /OAER:\d+') Then
		$aOAER_DATA[$iOAER_iPID] = Number(StringRegExpReplace($CmdLineRaw, '.*/OAER:(\d+)', '\1'))
		$CmdLineRaw = StringRegExpReplace($CmdLineRaw, ' /OAER:\d+', '')
		Return 1
	Else
		Opt('TrayIconHide', 1)
	EndIf

	Local $sRunCmd, $iPID, $sError_Msg = '', $hBitmap = 0

	$sRunCmd = @AutoItExe & ' /ErrorStdOut ' & (@Compiled ? '' : '/AutoIt3ExecuteScript "' & @ScriptFullPath & '" ') & $CmdLineRaw & ' /OAER:' & @AutoItPID
	$iPID = Run($sRunCmd, @ScriptDir, 0, $STDERR_MERGED)

	While 1
		$sError_Msg &= StdoutRead($iPID)

		If @error Then
			ExitLoop
		EndIf

		If $hBitmap = 0 And StringRegExp($sError_Msg, '\(\d+\) : ==> .*:') Then
;~ 			$hBitmap = _ScreenCapture_Capture()
		EndIf

		Sleep(10)
	WEnd

	If Not $sError_Msg Then
		Exit
	EndIf

	$sError_Msg = StringRegExpReplace($sError_Msg, '(?<!\r)\n', @CRLF)

	Local $sScriptPath, $iScriptLine

	__OAER_ParseErrorMsg($sScriptPath, $iScriptLine, $sError_Msg)

	If @error Then
		Exit
	EndIf

;~ 	If $sFunction = '' Then
;~ 		__OAER_ShowDefaultErrorDbgMsg($sScriptPath, $iScriptLine, $sError_Msg, $hBitmap)
;~ 	Else
;~ 		Call($sFunction, $sScriptPath, $iScriptLine, $sError_Msg, $vParams, $hBitmap)
;~ 	EndIf

	Exit
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _OnAutoItErrorUnRegister
; Description ...: UnRegister AutoIt Error Handler.
; Syntax ........: _OnAutoItErrorUnRegister()
; Parameters ....: None.
; Return values .: None.
; Author ........: G.Sandler
; Remarks .......: If $bUseStdOut = True is set for _OnAutoItErrorRegister, standard AutoIt error message will not be displayed on syntax error.
; Related .......: _OnAutoItErrorRegister
; Example .......: Yes.
; ===============================================================================================================================
Func _OnAutoItErrorUnRegister()
	$aOAER_DATA[$iOAER_bIn_Proc] = False

	If $aOAER_DATA[$iOAER_bUse_StdOut] Then
		ProcessClose($aOAER_DATA[$iOAER_iPID])
		$aOAER_DATA[$iOAER_iPID] = 0
	EndIf

	__OAER_OnExit()
EndFunc

#EndRegion Public Functions

#Region Internal Functions

Func __OAER_OnExit()
	If $aOAER_DATA[$iOAER_hErr_WinHook] Then
		_WinAPI_UnhookWindowsHookEx($aOAER_DATA[$iOAER_hErr_WinHook])
		$aOAER_DATA[$iOAER_hErr_WinHook] = 0
	EndIf

	If $aOAER_DATA[$iOAER_hErr_CallBack] Then
		DllCallbackFree($aOAER_DATA[$iOAER_hErr_CallBack])
		$aOAER_DATA[$iOAER_hErr_CallBack] = 0
	EndIf
EndFunc

Func __OAER_OnErrorCallback($nCode, $wParam, $lParam)
	If $nCode < 0 Then
		Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
	EndIf

	Switch $nCode
		Case 5 ; HCBT_ACTIVATE
			If Not _WinAPI_FindWindow('#32770', 'AutoIt Error') Then
				Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
			EndIf

			Local $hError_Wnd = HWnd($wParam)
			Local $sError_Msg = StringRegExpReplace(ControlGetText($hError_Wnd, '', 'Static2'), '(?<!\r)\n', @CRLF)

			If (_WinAPI_GetClassName($hError_Wnd) <> '#32770' And WinGetTitle($hError_Wnd) <> 'AutoIt Error') Or Not StringRegExp($sError_Msg, '(?is)^.*Line \d+\s+\(File "(.*?)"\):\s+.*Error: .*') Then
				Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
			EndIf

			_WinAPI_DestroyWindow($hError_Wnd)

			__OAER_OnExit()

;~ 			Local $hBitmap = _ScreenCapture_Capture()
			Local $aEnumWin = _WinAPI_EnumWindows()

			For $i = 1 To $aEnumWin[0][0]
				If WinGetProcess($aEnumWin[$i][0]) = @AutoItPID And $aEnumWin[$i][1] = 'AutoIt v3 GUI' Then
					;$hBitmap = _ScreenCapture_CaptureWnd('', $aEnumWin[$i][0])

					_WinAPI_ShowWindow($aEnumWin[$i][0], @SW_HIDE)
					;ExitLoop
				EndIf
			Next

			Local $sScriptPath, $iScriptLine
			__OAER_ParseErrorMsg($sScriptPath, $iScriptLine, $sError_Msg)

			If @error Then
				Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
			EndIf

;~ 			If $aOAER_DATA[$iOAER_sUserFunc] = '' Then
;~ 				__OAER_ShowDefaultErrorDbgMsg($sScriptPath, $iScriptLine, $sError_Msg, $hBitmap)
;~ 			Else
;~ 				Call($aOAER_DATA[$iOAER_sUserFunc], $sScriptPath, $iScriptLine, $sError_Msg, $aOAER_DATA[$iOAER_vUserParams], $hBitmap)
;~ 			EndIf
	EndSwitch

	Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
EndFunc

Func __OAER_ParseErrorMsg(ByRef $sPath, ByRef $iLine, ByRef $sMsg)
	Local $sScriptPath_Pttrn = ($aOAER_DATA[$iOAER_bUse_StdOut] ? '(?is)^.*"([a-z]:\\.*?)" \(\d+\) : ==> .*' : '(?is)^.*Line \d+\s+\(File "(.*?)"\):\s+.*Error: .*')
	Local $sScriptLine_Pttrn = ($aOAER_DATA[$iOAER_bUse_StdOut] ? '(?is)^.*[a-z]:\\.*? \((\d+)\) : ==> .*' : '(?is)^.*Line (\d+)\s+\(File ".*?"\):\s+.*Error: .*')
	Local $sErrDesc_Pttrn = ($aOAER_DATA[$iOAER_bUse_StdOut] ? '(?is)^.*[a-z]:\\.*? \(\d+\) : ==> (.*)' : '(?is)^.*Line \d+\s+\(File ".*?"\):\s+(.*Error: .*)')

	If Not StringRegExp($sMsg, $sScriptPath_Pttrn) Then
		Return SetError(1, 0, 0)
	EndIf

	$sPath = StringRegExpReplace($sMsg, $sScriptPath_Pttrn, '\1')
	$iLine = StringRegExpReplace($sMsg, $sScriptLine_Pttrn, '\1')
	$sMsg = StringRegExpReplace($sMsg, $sErrDesc_Pttrn, '\1')

	$sMsg = StringStripWS(StringRegExpReplace($sMsg, '(?mi)^Error:\h*|:$', ''), 3)

	If @Compiled And $aOAER_DATA[$iOAER_bSet_ErrLine] Then
		Local $sWorkDir = @WorkingDir

		FileChangeDir(@ScriptDir)
		FileInstall('OAER_RAW_SRC.tmp', @TempDir & '\OAER_RAW_SRC.tmp', 1)
		FileChangeDir($sWorkDir)

		Local $hFile = FileOpen(@TempDir & '\OAER_RAW_SRC.tmp', 16)
		Local $sRead = FileRead($hFile)
		FileClose($hFile)
		FileDelete(@TempDir & '\OAER_RAW_SRC.tmp')

		$sRead = BinaryToString(_Crypt_DecryptData($sRead, $sOAER_CRYPT_KEY, $iOAER_CRYPT_ALG))

		Local $iPos1 = StringInStr($sRead, @LF, 2, $iLine - 1)
		Local $iPos2 = StringInStr($sRead, @LF, 2, $iLine)
		Local $iLen = ($iPos2 > 0 ? $iPos2 - $iPos1 : -1)

		$sMsg &= @CRLF & StringStripWS(StringMid($sRead, $iPos1, $iLen), 3)
	EndIf
EndFunc

Func __OAER_GetErrLineCode($sScript_File, $iLine)
	Local $sSrc_Raw, $iPos1, $iPos2, $iLen

	$sSrc_Raw = __OAER_AU3_StripToRaw($sScript_File)

	If @error Then
		Return SetError(1, 0, '')
	EndIf

	$sSrc_Raw = StringStripWS($sSrc_Raw, 3)
	$iPos1 = StringInStr($sSrc_Raw, @LF, 2, $iLine - 1)
	$iPos2 = StringInStr($sSrc_Raw, @LF, 2, $iLine)
	$iLen = ($iPos2 > 0 ? $iPos2 - $iPos1 : -1)

	Return StringStripWS(StringMid($sSrc_Raw, $iPos1, $iLen), 3)
EndFunc

Func __OAER_AU3_StripToRaw($sSrcFile)
	If $sSrcFile = '' Or Not FileExists($sSrcFile) Then
		Return SetError(1, 0, 0)
	EndIf

	Local Static $sSrcRaw = ''
	Local Static $sIncludes = '|'

	Local $sInclude = ''
	Local $sScriptDir = StringRegExpReplace($sSrcFile, '\\[^\\]+$', '')
	Local $sRead = FileRead($sSrcFile)

	;!!! Strip comment block here (before checking #include-once)...
	__OAER_AU3_StringStripCommentBlocks($sRead)

	If StringRegExp($sRead, '(?mi)^\h*#include-once') Then
		If StringInStr($sIncludes, '|' & $sSrcFile & '|', 2) Then
			$sRead = StringRegExpReplace($sRead, '(?msi)\R?^\h*#include-once.*', '')
		Else
			$sIncludes &= '|' & $sSrcFile & '|'
		EndIf
	EndIf

	Local $aRead = StringSplit(StringStripCR($sRead), @LF)

	For $i = 1 To $aRead[0]
		If StringStripWS($aRead[$i], 8) = '' Or StringRegExp($aRead[$i], '(?i)^\h*(;|#include-once|#pragma\h+compile\()') Then
			ContinueLoop
		EndIf

		__OAER_AU3_StringStripComments($aRead[$i])

		If Not StringRegExp($aRead[$i], '(?i)^\h*#include\h+[<"'']') Then
			If StringRegExp($aRead[$i], '_\h*$') Then
				$sSrcRaw &= StringRegExpReplace($aRead[$i], '[_ ]+$', '')
				$i += 1

				While $i <= $aRead[0]
					__OAER_AU3_StringStripComments($aRead[$i])
					$sSrcRaw &= StringRegExpReplace($aRead[$i], '[_ ]+$', '')
					If @extended = 0 Then ExitLoop

					$i += 1
				WEnd

				$sSrcRaw &= @CRLF
			Else
				$sSrcRaw &= $aRead[$i] & @CRLF
			EndIf

			ContinueLoop
		EndIf

		$sInclude = __OAER_AU3_IncludeToPath($aRead[$i], $sScriptDir)

		If Not @error Then
			$sSrcRaw = __OAER_AU3_StripToRaw($sInclude)
		EndIf
	Next

	Return $sSrcRaw
EndFunc

Func __OAER_AU3_IncludeToPath($sInclude, $sScriptDir = @ScriptDir)
	Local $aRegExp, $aRet, $sSYS, $sAU3, $sWorkDir
	Local $iError = 0, $sRet = ''

	$aRegExp = StringRegExp($sInclude, '(?i)^\h*#include\h+(<|"|'')([^>"'']+)(?:>|"|'')\h*(;.*?)?$', 3)

    If UBound($aRegExp) < 2 Then
		Return SetError(1, 0, '')
	EndIf

    $sInclude = $aRegExp[1]

	;Get AutoIt Include folder
	Local Static $sAutoIt_Incl_Dir = StringRegExpReplace(@AutoItExe, '\\[^\\]+$', '') & '\Include'

	;Get User Include folders
	Local Static $aUDL = StringRegExp(RegRead('HKCU\Software\AutoIt v3\AutoIt', 'Include'), '([^;]+)(?:;|$)', 3)

	While 1
		;Check include type 4 (include with full path)
		If Not _WinAPI_PathIsRelative($sInclude) Then
			If FileExists($sInclude) Then
				$sRet = $sInclude
			Else
				$iError = 2
			EndIf

			ExitLoop
		EndIf

		;Set Current & AutoIt Include file
		$sAU3 = $sScriptDir & '\' & $sInclude
		$sSYS = $sAutoIt_Incl_Dir & '\' & $sInclude

		;Check include type 1 and 2 (before user includes check)
		If $aRegExp[0] == '<' Then
			If FileExists($sSYS) Then
				$sRet = $sSYS
				ExitLoop
			EndIf
		ElseIf $aRegExp[0] == '"' Or $aRegExp[0] == "'" Then
			If FileExists($sAU3) Then
				$sRet = $sAU3
				ExitLoop
			EndIf
		EndIf

		;Check include type 3 (search in user includes)
		For $i = 0 To UBound($aUDL) - 1
			$aUDL[$i] &= '\' & $sInclude

			If FileExists($aUDL[$i]) Then
				$sRet = $aUDL[$i]
				ExitLoop 2
			EndIf
		Next

		;Check include type 1 and 2 (after user includes check)
		If $aRegExp[0] == '<' Then
			If FileExists($sAU3) Then
				$sRet = $sAU3
				ExitLoop
			EndIf
		ElseIf $aRegExp[0] == '"' Or $aRegExp[0] == "'" Then
			If FileExists($sSYS) Then
				$sRet = $sSYS
				ExitLoop
			EndIf
		EndIf

		;Include file not found
		$iError = 3
		ExitLoop
	WEnd

	If Not $iError Then
		$sWorkDir = @WorkingDir

		If $sWorkDir <> $sScriptDir Then
			FileChangeDir($sScriptDir)
		EndIf

		$sRet = _WinAPI_GetFullPathName($sRet)

		If @error Or $sRet = '' Then
			$iError = 4
		EndIf

		If $sWorkDir <> $sScriptDir Then
			FileChangeDir($sWorkDir)
		EndIf
	Else
		$sRet = ''
	EndIf

    Return SetError($iError, 0, $sRet)
EndFunc

Func __OAER_AU3_StringStripCommentBlocks(ByRef $sString)
	Local $aSplit = StringSplit(StringStripCR($sString), @LF)
	Local $iCmntsStart_Count

	$sString = ''

	For $i = 1 To $aSplit[0]
		If StringRegExp($aSplit[$i], '(?i)^\h*#(cs|comments-start)([\h;].*)?$') Then
			$iCmntsStart_Count = 1

			While 1
				If $i + 1 >= $aSplit[0] Then
					ExitLoop
				EndIf

				$i += 1

				If StringRegExp($aSplit[$i], '(?i)^\h*#(cs|comments-start)([\h;].*)?') Then
					$iCmntsStart_Count += 1
					ContinueLoop
				EndIf

				If StringRegExp($aSplit[$i], '(?i)^\h*#(ce|comments-end)([\h;].*)?') Then
					$iCmntsStart_Count -= 1

					If $iCmntsStart_Count <= 0 Then
						ExitLoop
					EndIf
				EndIf
			WEnd

			ContinueLoop
		EndIf

		$sString &= $aSplit[$i] & @CRLF
	Next
EndFunc

Func __OAER_AU3_StringStripComments(ByRef $sString)
	Local $aChars = StringSplit($sString, '')
	Local $sOpenStrChar = ''

	For $iChar = 1 To $aChars[0] - 1
		If $sOpenStrChar And $sOpenStrChar = $aChars[$iChar] Then
			If $aChars[$iChar] = $aChars[$iChar + 1] Then
				$iChar += 1
			Else
				$sOpenStrChar = ''
			EndIf

			ContinueLoop
		EndIf

		If Not $sOpenStrChar And ($aChars[$iChar] = '"' Or $aChars[$iChar] = "'") Then
			$sOpenStrChar = $aChars[$iChar]
			ContinueLoop
		EndIf

		If Not $sOpenStrChar And $aChars[$iChar] = ';' Then
			$sString = StringStripWS(StringLeft($sString, $iChar - 1), 2)
			Return
		EndIf
	Next

	If StringRight($sString, 1) = ';' Then
		$sString = StringTrimRight($sString, 1)
	Else
		SetError(1)
	EndIf
EndFunc

Func __OAER_ShowDefaultErrorDbgMsg($sScriptPath, $iScriptLine, $sErrorMsg, $hBitmap)
	Local $hErrGUI, $nMsg, $SendReport_Button, $ShowBugReport_Button, $ContinueApp_Button, $RestartApp_Button, $CloseApp_Button
	Local $sLastScreen_File = @TempDir & '\OAER_LastScreen.jpg'

	If $hBitmap Then
;~ 		_ScreenCapture_SaveImage($sLastScreen_File, $hBitmap)
	EndIf

	$hErrGUI = GUICreate($sOAER_Main_Title, 385, 120, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), $WS_EX_TOPMOST)

	GUISetIcon('User32.dll', -1)
	GUISetBkColor($nOAER_DefWndBkColor)

	GUICtrlCreateLabel('', 1, 1, 383, 1)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateLabel('', 1, 118, 383, 1)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateLabel('', 1, 1, 1, 118)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateLabel('', 383, 1, 1, 118)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateIcon('user32.dll', 103, 11, 11, 32, 32)

	GUICtrlCreateLabel($sOAER_MainTxt_Msg, 52, 22, 175, 15)
	GUICtrlSetBkColor(-1, -2)

	$SendReport_Button = __OAER_CreateButtonEx($sOAER_SendBugReport_Btn, 10, 88, 110, 23, 'shell32.dll', -157, 0xEFEEF2, 0x0000FF) ;, 0x706E63)
	$ShowBugReport_Button = __OAER_CreateButtonEx($sOAER_ShowBugReport_Btn, 125, 88, 115, 23, 'shell32.dll', 23, 0xEFEEF2)
	$ShowLastScreen_Button = __OAER_CreateButtonEx($sOAER_ShowLastScreen_Btn, 245, 88, 130, 23, 'shell32.dll', -118, 0xEFEEF2)
	$ContinueApp_Button = __OAER_CreateButtonEx($sOAER_ContinueApp_Btn, 245, 5, 130, 23, 'shell32.dll', 290, 0xEFEEF2)
	$RestartApp_Button = __OAER_CreateButtonEx($sOAER_RestartApp_Btn, 245, 32, 130, 23, 'shell32.dll', 255, 0xEFEEF2)
	$CloseApp_Button = __OAER_CreateButtonEx($sOAER_CloseApp_Btn, 245, 60, 130, 23, 'shell32.dll', 240, 0xEFEEF2)

	GUICtrlSetState($ContinueApp_Button[0], $GUI_DISABLE)
	GUICtrlSetState($ContinueApp_Button[1], $GUI_DISABLE)

	If Not $hBitmap Then
		GUICtrlSetState($ShowLastScreen_Button[0], $GUI_DISABLE)
		GUICtrlSetState($ShowLastScreen_Button[1], $GUI_DISABLE)
	EndIf

	If $aOAER_DATA[$iOAER_bUse_StdOut] Then ;Only with StdOut method we need the sound, otherwise the sound is produced by catched message from AutoIt error itself.
;~ 		If FileExists(@WindowsDir & '\Media\chord.wav') Then
;~ 			SoundPlay(@WindowsDir & '\Media\chord.wav', 0)
;~ 		Else
;~ 			DllCall('user32.dll', 'int', 'MessageBeep', 'int', 0x00000010)
;~ 		EndIf
	EndIf

	GUISetState(@SW_SHOW, $hErrGUI)

    While 1
        $nMsg = GUIGetMsg()

		If $nMsg = 0 Or ($nMsg > 0 And Not __OAER_ClickProc($nMsg, $hErrGUI)) Then
			ContinueLoop
		EndIf

		Switch $nMsg
			Case $SendReport_Button[0], $SendReport_Button[1]
				__OAER_ShowSendEmailGUI($sOAER_Main_Title & ' - ' & $sOAER_SendBugReport_Title, StringFormat($sOAER_ErrMsgSendFrmt_Msg, $sScriptPath, $iScriptLine, $sErrorMsg, __OAER_GetEnvironment()), $hErrGUI, $sLastScreen_File)
			Case $ShowBugReport_Button[0], $ShowBugReport_Button[1]
				If @Compiled Then
					$sScriptPath = @ScriptFullPath
				EndIf

				MsgBox(262144 + 4096, $sOAER_Main_Title & ' - ' & $sOAER_BugReport_Title, StringFormat($sOAER_ErrMsgDispFrmt_Msg, $sScriptPath, $iScriptLine, $sErrorMsg, __OAER_GetEnvironment()), 0, $hErrGUI)
			Case $ShowLastScreen_Button[0], $ShowLastScreen_Button[1]
;~ 				If $hBitmap And FileExists($sLastScreen_File) Then
;~ 					__OAER_ShowLastScreenGUI($sLastScreen_File, $hErrGUI)
;~ 				EndIf
			Case $ContinueApp_Button[0], $ContinueApp_Button[1]
				;Not possible ATM.
			Case $RestartApp_Button[0], $RestartApp_Button[1]
				Local $sRunLine = @AutoItExe & (@Compiled ? '' : ' "' & @ScriptFullPath & '"') & ' ' & $CmdLineRaw
				Run($sRunLine, @ScriptDir)
				ContinueCase
			Case $CloseApp_Button[0], $CloseApp_Button[1], $GUI_EVENT_CLOSE
				GUIDelete($hErrGUI)
				ExitLoop
        EndSwitch
    WEnd

	FileDelete($sLastScreen_File)
EndFunc


Func __OAER_ShowSendEmailGUI($sTitle, $sErrorMsg, $hParent, $sAttachment = '')
	Local $hSndBugRprtGUI, $nServer_Input, $nFromName_Input, $nFromAddress_Input, $nToAddress_Input, $nSubject_Input, $nBody_Edit, $nAttachment_CB, $nAttachment_Lbl
	Local $nSendReport_Label, $nSendReport_Icon, $nStatus_Label, $nMsg, $sServer, $sFromName, $sFromAddress, $sToAddress, $sSubject, $sBody
	Local $iError

	GUISetState(@SW_DISABLE, $hParent)
	$hSndBugRprtGUI = GUICreate($sTitle, 400, 350, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), -1, $hParent)

	GUISetIcon('shell32.dll', -157)
	GUISetBkColor(0xE0DFE2)

	GUICtrlCreateLabel('', 1, 1, 398, 1)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateLabel('', 1, 315, 398, 1)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateLabel('', 1, 1, 1, 315)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateLabel('', 398, 1, 1, 315)
	GUICtrlSetBkColor(-1, 0x41689E)

	GUICtrlCreateIcon('user32.dll', 103, 11, 11, 32, 32)

	GUICtrlCreateLabel($sOAER_MainTxt_Msg & @CRLF & $sOAER_SendBugReport_Tip, 50, 20, 300, 30)
	GUICtrlSetBkColor(-1, -2)

	GUICtrlCreateLabel($sOAER_EmailServer_Lbl, 30, 65, -1, 15)
	$nServer_Input = GUICtrlCreateInput($sOAER_DevEmailServer, 30, 80, 150, 20)
	GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel($sOAER_FromName_Lbl, 230, 65, -1, 15)
	$nFromName_Input = GUICtrlCreateInput(@UserName, 230, 80, 150, 20)

	GUICtrlCreateLabel($sOAER_FromAddress_Lbl, 30, 105, -1, 15)
	$nFromAddress_Input = GUICtrlCreateInput('', 30, 120, 150, 20)

	GUICtrlCreateLabel($sOAER_ToAddress_Lbl, 230, 105, -1, 15)
	$nToAddress_Input = GUICtrlCreateInput($sOAER_DevEmailAddress, 230, 120, 150, 20)
	GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel($sOAER_Subject_Lbl, 30, 145, -1, 15)
	$nSubject_Input = GUICtrlCreateInput($sOAER_BugReport_Title & ' - ' & @ScriptName, 30, 160, 350, 20)

	GUICtrlCreateLabel($sOAER_Body_Lbl, 30, 185, -1, 15)
	$nBody_Edit = GUICtrlCreateEdit($sErrorMsg & @CRLF & @CRLF & '======================' & @CRLF & __OAER_GetEnvironment(), 30, 200, 350, 90)

	If $sAttachment <> '' Then
		$nAttachment_CB = GUICtrlCreateCheckbox($sOAER_SendAttachment_Lbl, 30, 295, -1, 15)
		GUICtrlSetState(-1, $GUI_CHECKED)
		$nAttachment_Lbl = GUICtrlCreateLabel(StringRegExpReplace($sAttachment, '^.*\\', ''), 160, 295, -1, 15)
		GUICtrlSetColor(-1, 0x0000FF)
		GUICtrlSetCursor(-1, 0)
		GUICtrlSetFont(-1, 8.5, 200, 4)
		GUICtrlCreateLabel('(' & Round(FileGetSize($sAttachment) / 1024, 1) & ' KB)', 300, 295, 80, 15, $SS_RIGHT)
	EndIf

	GUICtrlCreateLabel('', 30, 320, 85, 22)
	GUICtrlSetBkColor(-1, 0x706E63)
	GUICtrlSetState(-1, $GUI_DISABLE)

	$nSendReport_Label = GUICtrlCreateLabel($sOAER_SendBugReport_Btn, 34, 324, 80, 15)
	GUICtrlSetBkColor(-1, -2)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetCursor(-1, 0)

	$nSendReport_Icon = GUICtrlCreateIcon('shell32.dll', -157, 13, 323, 16, 16) ;'shimgvw.dll', -6
	GUICtrlSetCursor(-1, 0)

	$nStatus_Label = GUICtrlCreateLabel('', 150, 324, 200, 15)
	GUICtrlSetColor(-1, 0xFF0000)

	GUISetState(@SW_SHOW, $hSndBugRprtGUI)

    While 1
        $nMsg = GUIGetMsg()

		If $nMsg = 0 Or ($nMsg > 0 And Not __OAER_ClickProc($nMsg, $hSndBugRprtGUI)) Then
			ContinueLoop
		EndIf

		Switch $nMsg
			Case $nAttachment_CB
				If BitAND(GUICtrlRead($nAttachment_CB), $GUI_CHECKED) = $GUI_CHECKED Then
					GUICtrlSetState($nAttachment_Lbl, $GUI_ENABLE)
				Else
					GUICtrlSetState($nAttachment_Lbl, $GUI_DISABLE)
				EndIf
			Case $nAttachment_Lbl
;~ 				__OAER_ShowLastScreenGUI($sAttachment, $hSndBugRprtGUI)
			Case $nSendReport_Label, $nSendReport_Icon
				$sServer = GUICtrlRead($nServer_Input)
				$sFromName = GUICtrlRead($nFromName_Input)
				$sFromAddress = GUICtrlRead($nFromAddress_Input)
				$sToAddress = GUICtrlRead($nToAddress_Input)
				$sSubject = GUICtrlRead($nSubject_Input)
				$sBody = GUICtrlRead($nBody_Edit)
				;$sBody = StringSplit(StringStripCR(GUICtrlRead($nBody_Edit)), @LF)
				$sAttach = (BitAND(GUICtrlRead($nAttachment_CB), $GUI_CHECKED) ? $sAttachment : '')

				If $sServer = '' Or $sFromName = '' Or $sFromAddress = '' Or $sToAddress = '' Or $sSubject = '' Or $sBody = '' Then
					MsgBox(48, $sOAER_SendBugReport_Title & ' - ' & $sOAER_Attention_Title, $sOAER_RequierdFields_Msg, 0, $hSndBugRprtGUI)
					ContinueLoop
				EndIf

				GUICtrlSetData($nStatus_Label, $sOAER_SendingStatus_Lbl)
				GUICtrlSetState($nSendReport_Label, $GUI_DISABLE)
				GUICtrlSetState($nSendReport_Icon, $GUI_DISABLE)

				Local $oErrorEvent = ObjEvent('AutoIt.Error', '__OAER_ISMComErrHndlr')

				__OAER_INetSmtpMailCom($sServer, $sFromName, $sFromAddress, $sToAddress, $sSubject, $sBody, $sAttach, $sOAER_DevEmailUsrName, $sOAER_DevEmailPass, $sOAER_DevEmailPort, $sOAER_DevEmailSSL)

				$iError = @error
				$oErrorEvent = 0

				GUICtrlSetData($nStatus_Label, '')
				GUICtrlSetState($nSendReport_Label, $GUI_ENABLE)
				GUICtrlSetState($nSendReport_Icon, $GUI_ENABLE)

				If $iError Then
					MsgBox(16, $sOAER_SendBugReport_Title & ' - ' & $sOAER_Error_Title, StringFormat($sOAER_UnableToSend_Msg, $aOAER_DATA[$iOAER_iCOMErrorNumber], $aOAER_DATA[$iOAER_sCOMErrorDesc]), 0, $hSndBugRprtGUI)
				Else
					MsgBox(64, $sOAER_SendBugReport_Title & ' - ' & $sOAER_Success_Title, $sOAER_BugReportSent_Msg, 0, $hSndBugRprtGUI)
				EndIf

				$aOAER_DATA[$iOAER_iCOMErrorNumber] = 0
				$aOAER_DATA[$iOAER_sCOMErrorDesc] = ''
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_ENABLE, $hParent)
				GUIDelete($hSndBugRprtGUI)
				ExitLoop
        EndSwitch
    WEnd
EndFunc

Func __OAER_ClickProc($nCtrlID, $hWnd)
	Local $aCursorInfo

	While 1
		$aCursorInfo = GUIGetCursorInfo($hWnd)

		If Not @error And $aCursorInfo[2] <> 1 Then
			ExitLoop
		EndIf
	WEnd

	If IsArray($aCursorInfo) And $aCursorInfo[4] = $nCtrlID Then
		Return 1
	EndIf

	Return 0
EndFunc

Func __OAER_CreateButtonEx($sText, $iLeft, $iTop, $iWidth, $iHeight, $sIconFile = '', $nIconIndex = 0, $nFrameBkColor = -1, $nTxtColor = -1)
	Local $aRet[2]

	If $iOAER_ButtonsStyle = 1 Then
		$aRet[0] = GUICtrlCreateIcon($sIconFile, $nIconIndex, $iLeft + 5, $iTop + (($iHeight - 15) / 2), 15, 15)
		$aRet[1] = GUICtrlCreateButton('       ' & $sText & ' ', $iLeft, $iTop, $iWidth, $iHeight, $WS_CLIPSIBLINGS)
		GUICtrlSetBkColor(-1, $nOAER_DefWndBkColor)
	Else
		GUICtrlCreateLabel('', $iLeft, $iTop, $iWidth, $iHeight, $SS_BLACKFRAME)
		GUICtrlSetBkColor(-1, $nFrameBkColor)
		GUICtrlSetState(-1, $GUI_DISABLE)

		$aRet[0] = GUICtrlCreateIcon($sIconFile, $nIconIndex, $iLeft + 3, $iTop + (($iHeight - 15) / 2), 15, 15)
		GUICtrlSetCursor(-1, 0)

		$aRet[1] = GUICtrlCreateLabel('   ' & $sText, $iLeft + 19, $iTop + 4, $iWidth - 15, $iHeight - 7)
		GUICtrlSetColor(-1, $nTxtColor)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetCursor(-1, 0)
	EndIf

	Return $aRet
EndFunc

Func __OAER_GetEnvironment()
	Local $AutoItVer = @AutoItVersion & (@AutoItX64 ? ' x64' : '')
	Local $sOS = @OSVersion & (@OSArch = 'x86' ? '' : ' ' & @OSArch) & ' (' & @OSBuild & (@OSServicePack = '' ? '' : ', Service Pack: ' & @OSServicePack) & ')'
	Return StringFormat($sOAER_EnvFrmt_Msg, $AutoItVer, @OSLang, @KBLayout, $sOS, @CPUArch, __OAER_ProcessGetRunTime($aOAER_DATA[$iOAER_bUse_StdOut] ? $aOAER_DATA[$iOAER_iPID] : @AutoItPID))
EndFunc

Func __OAER_ProcessGetRunTime($iPID)
	Local $aFT, $tFT, $tST, $iDiff

	$aFT = _WinAPI_GetProcessTimes($iPID)
	$tFT = _Date_Time_FileTimeToLocalFileTime(DllStructGetPtr($aFT[0]))
	$tST = _Date_Time_FileTimeToSystemTime(DllStructGetPtr($tFT))

	$iDiff = _DateDiff('s', _WinAPI_GetDateFormat(0, $tST, 0, 'yyyy/MM/dd') & ' ' & _WinAPI_GetTimeFormat(0, $tST, $TIME_NOTIMEMARKER), _NowCalc())

	Return __OAER_SecondsToTimeStringEx($iDiff, 0409)
EndFunc

Func __OAER_SecondsToTimeStringEx($iSeconds, $iOSLang = @OSLang, $iFlag = 2, $sDelim = ', ')
	Local $sYear, $sYears, $s5Years
	Local $sDay, $sDays, $s5Days
	Local $sHour, $sHours, $s5Hours
	Local $sMin, $sMins, $s5Mins
	Local $sSec, $sSecs, $s5Secs

	If StringInStr('0419', $iOSLang) Then ;Russian support
		Dim $sYear = 'Ãîä', $sYears = 'Ãîäà', $s5Years = 'Ëåò'
		Dim $sDay = 'Äåíü', $sDays = 'Äíÿ', $s5Days = 'Äíåé'
		Dim $sHour = '×àñ', $sHours = '×àñà', $s5Hours = '×àñîâ'
		Dim $sMin = 'Ìèíóòà', $sMins = 'Ìèíóòû', $s5Mins = 'Ìèíóò'
		Dim $sSec = 'Ñåêóíäà', $sSecs = 'Ñåêóíäû', $s5Secs = 'Ñåêóíä'
	Else
		Dim $sYear = 'Year', $sYears = 'Years', $s5Years = 'Years'
		Dim $sDay = 'Day', $sDays = 'Days', $s5Days = 'Days'
		Dim $sHour = 'Hour', $sHours = 'Hours', $s5Hours = 'Hours'
		Dim $sMin = 'Minute', $sMins = 'Minutes', $s5Mins = 'Minutes'
		Dim $sSec = 'Second', $sSecs = 'Seconds', $s5Secs = 'Seconds'
	EndIf

	If Number($iSeconds) >= 0 Then
		Local $iTicks = Int($iSeconds / 3600), $iDays, $iYears
		Local $iHours = Mod($iTicks, 24)

		If $iTicks >= 24 Then
			$iDays = ($iTicks - $iHours) / 24
		EndIf

		If $iDays >= 365 Or BitAND($iFlag, 2) = 0 Then
			$iYears = Int($iDays / 365)

			If ($iYears >= 20 And StringRight($iYears, 1) >= 2) Or ($iYears < 20 And $iYears >= 2) Then
				$sYear = $sYears
			EndIf

			If ($iYears >= 20 And (StringRight($iYears, 1) >= 5 Or StringRight($iYears, 1) < 1)) Or ($iYears < 20 And $iYears >= 5) Or $iYears = 0 Then
				$sYear = $s5Years
			EndIf

			$iYears &= ' ' & $sYear & $sDelim
		EndIf

		If $iDays > 0 Or BitAND($iFlag, 2) = 0 Then
			$iDays = Mod($iDays, 365)

			If ($iDays >= 20 And StringRight($iDays, 1) >= 2) Or ($iDays < 20 And $iDays >= 2) Then
				$sDay = $sDays
			EndIf

			If ($iDays >= 20 And (StringRight($iDays, 1) >= 5) Or StringRight($iDays, 1) < 1) Or ($iDays < 20 And $iDays >= 5) Or $iDays = 0 Then
				$sDay = $s5Days
			EndIf

			$iDays &= ' ' & $sDay & $sDelim
		EndIf

		$iTicks = Mod($iSeconds, 3600)

		Local $iMins = Int($iTicks / 60)
		Local $iSecs = Round(Mod($iTicks, 60))

		If BitAND($iFlag, 1) = 1 Then
			If StringLen($iHours) = 1 Then
				$iHours = '0' & $iHours
			EndIf

			If StringLen($iMins) = 1 Then
				$iMins = '0' & $iMins
			EndIf

			If StringLen($iSecs) = 1 Then
				$iSecs = '0' & $iSecs
			EndIf
		EndIf

		If ($iHours >= 20 And StringRight($iHours, 1) >= 2) Or ($iHours < 20 And $iHours >= 2) Then
			$sHour = $sHours
		EndIf
		If ($iHours >= 20 And (StringRight($iHours, 1) >= 5 Or StringRight($iHours, 1) < 1)) Or ($iHours < 20 And $iHours >= 5) Or $iHours = 0 Then
			$sHour = $s5Hours
		EndIf
		If ($iMins >= 20 And StringRight($iMins, 1) >= 2) Or ($iMins < 20 And $iMins >= 2) Then
			$sMin = $sMins
		EndIf
		If ($iMins >= 20 And (StringRight($iMins, 1) >= 5 Or StringRight($iMins, 1) < 1)) Or ($iMins < 20 And $iMins >= 5) Or $iMins = 0 Then
			$sMin = $s5Mins
		EndIf
		If ($iSecs >= 20 And StringRight($iSecs, 1) >= 2) Or ($iSecs < 20 And $iSecs >= 2) Then
			$sSec = $sSecs
		EndIf
		If ($iSecs >= 20 And (StringRight($iSecs, 1) >= 5 Or StringRight($iSecs, 1) < 1)) Or ($iSecs < 20 And $iSecs >= 5) Or $iSecs = 0 Then
			$sSec = $s5Secs
		EndIf

		If BitAND($iFlag, 2) = 2 Then
			If Number($iHours) = 0 Then
				$iHours = ''
			Else
				$iHours &= ' ' & $sHour & $sDelim
			EndIf

			If Number($iMins) = 0 Then
				$iMins = ''
			Else
				$iMins &= ' ' & $sMin & $sDelim
			EndIf
		Else
			$iHours &= ' ' & $sHour & $sDelim
			$iMins &= ' ' & $sMin & $sDelim
		EndIf

		$iSecs &= ' ' & $sSec

		Return $iYears & $iDays & $iHours & $iMins & $iSecs
	EndIf

	Return SetError(1, 0, 0)
EndFunc

Func __OAER_INetSmtpMailCom($s_SmtpServer, $s_FromName, $s_FromAddress, $s_ToAddress, $s_Subject = '', $s_Body = '', $s_Attachment = '', $s_Username = '', $s_Password = '', $IPPort = 25, $ssl = 0)
	Local $objEmail = ObjCreate('CDO.Message')
	If @error Or Not IsObj($objEmail) Then Return SetError(1, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

	If FileExists($s_Attachment) And $s_Body = '' Then
		Return SetError(2, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])
	EndIf

    $objEmail.From = '"' & $s_FromName & '" <' & $s_FromAddress & '>'
	If @error Then Return SetError(3, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

    $objEmail.To = $s_ToAddress
	If @error Then Return SetError(4, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

	$objEmail.Subject = $s_Subject
	If @error Then Return SetError(5, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

	If StringInStr($s_Body, '<') And StringInStr($s_Body, '>') Then
        $objEmail.HTMLBody = $s_Body
    Else
        $objEmail.Textbody = $s_Body & @CRLF
    EndIf

	If @error Then Return SetError(6, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

	If FileExists($s_Attachment) Then
		$objEmail.AddAttachment($s_Attachment)
		If @error Then Return SetError(7, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])
	EndIf

	$objEmail.Configuration.Fields.Item('http://schemas.microsoft.com/cdo/configuration/sendusing') = 2
	If @error Then Return SetError(8, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

    $objEmail.Configuration.Fields.Item('http://schemas.microsoft.com/cdo/configuration/smtpserver') = $s_SmtpServer
	If @error Then Return SetError(9, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

    $objEmail.Configuration.Fields.Item('http://schemas.microsoft.com/cdo/configuration/smtpserverport') = $IPPort
   If @error Then Return SetError(10, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

   If $s_Username <> '' Then
        $objEmail.Configuration.Fields.Item('http://schemas.microsoft.com/cdo/configuration/smtpauthenticate') = 1
		If @error Then Return SetError(11, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

        $objEmail.Configuration.Fields.Item('http://schemas.microsoft.com/cdo/configuration/sendusername') = $s_Username
		If @error Then Return SetError(12, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

        $objEmail.Configuration.Fields.Item('http://schemas.microsoft.com/cdo/configuration/sendpassword') = $s_Password
		If @error Then Return SetError(13, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])
    EndIf

	If $ssl Then
        $objEmail.Configuration.Fields.Item('http://schemas.microsoft.com/cdo/configuration/smtpusessl') = True
		If @error Then Return SetError(14, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])
    EndIf

	$objEmail.Configuration.Fields.Update
	If @error Then Return SetError(15, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])

    $objEmail.Send
	If @error Then Return SetError(16, 0, $aOAER_DATA[$iOAER_sCOMErrorDesc])
EndFunc

Func __OAER_ISMComErrHndlr($oError)
	$aOAER_DATA[$iOAER_iCOMErrorNumber] = $oError.Number
	$aOAER_DATA[$iOAER_sCOMErrorDesc] = StringStripWS(StringStripWS($oError.WinDescription, 3) & ' ' & StringStripWS($oError.Description, 3), 3)

	Return SetError(1, 0, 0)
EndFunc

#EndRegion Internal Functions
