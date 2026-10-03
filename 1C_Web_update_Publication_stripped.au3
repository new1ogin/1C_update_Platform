#RequireAdmin
Global Const $STDERR_MERGED = 8
Global Const $UBOUND_DIMENSIONS = 0
Global Const $UBOUND_ROWS = 1
Global Const $UBOUND_COLUMNS = 2
Global Const $STR_NOCASESENSEBASIC = 2
Global Const $STR_STRIPLEADING = 1
Global Const $STR_STRIPTRAILING = 2
Global Const $STR_ENTIRESPLIT = 1
Global Const $STR_NOCOUNT = 2
Global Enum $ARRAYFILL_FORCE_DEFAULT, $ARRAYFILL_FORCE_SINGLEITEM, $ARRAYFILL_FORCE_INT, $ARRAYFILL_FORCE_NUMBER, $ARRAYFILL_FORCE_PTR, $ARRAYFILL_FORCE_HWND, $ARRAYFILL_FORCE_STRING
Func _ArrayAdd(ByRef $aArray, $vValue, $iStart = 0, $sDelim_Item = "|", $sDelim_Row = @CRLF, $iForce = $ARRAYFILL_FORCE_DEFAULT)
If $iStart = Default Then $iStart = 0
If $sDelim_Item = Default Then $sDelim_Item = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iForce = Default Then $iForce = $ARRAYFILL_FORCE_DEFAULT
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, $UBOUND_ROWS)
Local $hDataType = 0
Switch $iForce
Case $ARRAYFILL_FORCE_INT
$hDataType = Int
Case $ARRAYFILL_FORCE_NUMBER
$hDataType = Number
Case $ARRAYFILL_FORCE_PTR
$hDataType = Ptr
Case $ARRAYFILL_FORCE_HWND
$hDataType = Hwnd
Case $ARRAYFILL_FORCE_STRING
$hDataType = String
EndSwitch
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
If $iForce = $ARRAYFILL_FORCE_SINGLEITEM Then
ReDim $aArray[$iDim_1 + 1]
$aArray[$iDim_1] = $vValue
Return $iDim_1
EndIf
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 1 Then Return SetError(5, 0, -1)
$hDataType = 0
Else
Local $aTmp = StringSplit($vValue, $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
If UBound($aTmp, $UBOUND_ROWS) = 1 Then
$aTmp[0] = $vValue
EndIf
$vValue = $aTmp
EndIf
Local $iAdd = UBound($vValue, $UBOUND_ROWS)
ReDim $aArray[$iDim_1 + $iAdd]
For $i = 0 To $iAdd - 1
If IsFunc($hDataType) Then
$aArray[$iDim_1 + $i] = $hDataType($vValue[$i])
Else
$aArray[$iDim_1 + $i] = $vValue[$i]
EndIf
Next
Return $iDim_1 + $iAdd - 1
Case 2
Local $iDim_2 = UBound($aArray, $UBOUND_COLUMNS)
If $iStart < 0 Or $iStart > $iDim_2 - 1 Then Return SetError(4, 0, -1)
Local $iValDim_1, $iValDim_2 = 0, $iColCount
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 2 Then Return SetError(5, 0, -1)
$iValDim_1 = UBound($vValue, $UBOUND_ROWS)
$iValDim_2 = UBound($vValue, $UBOUND_COLUMNS)
$hDataType = 0
Else
Local $aSplit_1 = StringSplit($vValue, $sDelim_Row, $STR_NOCOUNT + $STR_ENTIRESPLIT)
$iValDim_1 = UBound($aSplit_1, $UBOUND_ROWS)
Local $aTmp[$iValDim_1][0], $aSplit_2
For $i = 0 To $iValDim_1 - 1
$aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
$iColCount = UBound($aSplit_2)
If $iColCount > $iValDim_2 Then
$iValDim_2 = $iColCount
ReDim $aTmp[$iValDim_1][$iValDim_2]
EndIf
For $j = 0 To $iColCount - 1
$aTmp[$i][$j] = $aSplit_2[$j]
Next
Next
$vValue = $aTmp
EndIf
If UBound($vValue, $UBOUND_COLUMNS) + $iStart > UBound($aArray, $UBOUND_COLUMNS) Then Return SetError(3, 0, -1)
ReDim $aArray[$iDim_1 + $iValDim_1][$iDim_2]
For $iWriteTo_Index = 0 To $iValDim_1 - 1
For $j = 0 To $iDim_2 - 1
If $j < $iStart Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
ElseIf $j - $iStart > $iValDim_2 - 1 Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
Else
If IsFunc($hDataType) Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = $hDataType($vValue[$iWriteTo_Index][$j - $iStart])
Else
$aArray[$iWriteTo_Index + $iDim_1][$j] = $vValue[$iWriteTo_Index][$j - $iStart]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($aArray, $UBOUND_ROWS) - 1
EndFunc
Func _ArrayConcatenate(ByRef $aArrayTarget, Const ByRef $aArraySource, $iStart = 0)
If $iStart = Default Then $iStart = 0
If Not IsArray($aArrayTarget) Then Return SetError(1, 0, -1)
If Not IsArray($aArraySource) Then Return SetError(2, 0, -1)
Local $iDim_Total_Tgt = UBound($aArrayTarget, $UBOUND_DIMENSIONS)
Local $iDim_Total_Src = UBound($aArraySource, $UBOUND_DIMENSIONS)
Local $iDim_1_Tgt = UBound($aArrayTarget, $UBOUND_ROWS)
Local $iDim_1_Src = UBound($aArraySource, $UBOUND_ROWS)
If $iStart < 0 Or $iStart > $iDim_1_Src - 1 Then Return SetError(6, 0, -1)
Switch $iDim_Total_Tgt
Case 1
If $iDim_Total_Src <> 1 Then Return SetError(4, 0, -1)
ReDim $aArrayTarget[$iDim_1_Tgt + $iDim_1_Src - $iStart]
For $i = $iStart To $iDim_1_Src - 1
$aArrayTarget[$iDim_1_Tgt + $i - $iStart] = $aArraySource[$i]
Next
Case 2
If $iDim_Total_Src <> 2 Then Return SetError(4, 0, -1)
Local $iDim_2_Tgt = UBound($aArrayTarget, $UBOUND_COLUMNS)
If UBound($aArraySource, $UBOUND_COLUMNS) <> $iDim_2_Tgt Then Return SetError(5, 0, -1)
ReDim $aArrayTarget[$iDim_1_Tgt + $iDim_1_Src - $iStart][$iDim_2_Tgt]
For $i = $iStart To $iDim_1_Src - 1
For $j = 0 To $iDim_2_Tgt - 1
$aArrayTarget[$iDim_1_Tgt + $i - $iStart][$j] = $aArraySource[$i][$j]
Next
Next
Case Else
Return SetError(3, 0, -1)
EndSwitch
Return UBound($aArrayTarget, $UBOUND_ROWS)
EndFunc
Func _ArrayDelete(ByRef $aArray, $vRange)
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, $UBOUND_ROWS) - 1
If IsArray($vRange) Then
If UBound($vRange, $UBOUND_DIMENSIONS) <> 1 Or UBound($vRange, $UBOUND_ROWS) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$aArray[$iCopyTo_Index] = $aArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($aArray, $UBOUND_COLUMNS) - 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$aArray[$iCopyTo_Index][$j] = $aArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($aArray, $UBOUND_ROWS)
EndFunc
Func _ArrayInsert(ByRef $aArray, $vRange, $vValue = "", $iStart = 0, $sDelim_Item = "|", $sDelim_Row = @CRLF, $iForce = $ARRAYFILL_FORCE_DEFAULT)
If $vValue = Default Then $vValue = ""
If $iStart = Default Then $iStart = 0
If $sDelim_Item = Default Then $sDelim_Item = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iForce = Default Then $iForce = $ARRAYFILL_FORCE_DEFAULT
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, $UBOUND_ROWS) - 1
Local $hDataType = 0
Switch $iForce
Case $ARRAYFILL_FORCE_INT
$hDataType = Int
Case $ARRAYFILL_FORCE_NUMBER
$hDataType = Number
Case $ARRAYFILL_FORCE_PTR
$hDataType = Ptr
Case $ARRAYFILL_FORCE_HWND
$hDataType = Hwnd
Case $ARRAYFILL_FORCE_STRING
$hDataType = String
EndSwitch
Local $aSplit_1, $aSplit_2
If IsArray($vRange) Then
If UBound($vRange, $UBOUND_DIMENSIONS) <> 1 Or UBound($vRange, $UBOUND_ROWS) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
For $i = 2 To $vRange[0]
If $vRange[$i] < $vRange[$i - 1] Then Return SetError(3, 0, -1)
Next
Local $iCopyTo_Index = $iDim_1 + $vRange[0]
Local $iInsertPoint_Index = $vRange[0]
Local $iInsert_Index = $vRange[$iInsertPoint_Index]
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
If $iForce = $ARRAYFILL_FORCE_SINGLEITEM Then
ReDim $aArray[$iDim_1 + $vRange[0] + 1]
For $iReadFromIndex = $iDim_1 To 0 Step -1
$aArray[$iCopyTo_Index] = $aArray[$iReadFromIndex]
$iCopyTo_Index -= 1
$iInsert_Index = $vRange[$iInsertPoint_Index]
While $iReadFromIndex = $iInsert_Index
$aArray[$iCopyTo_Index] = $vValue
$iCopyTo_Index -= 1
$iInsertPoint_Index -= 1
If $iInsertPoint_Index < 1 Then ExitLoop 2
$iInsert_Index = $vRange[$iInsertPoint_Index]
WEnd
Next
Return $iDim_1 + $vRange[0] + 1
EndIf
ReDim $aArray[$iDim_1 + $vRange[0] + 1]
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 1 Then Return SetError(5, 0, -1)
$hDataType = 0
Else
Local $aTmp = StringSplit($vValue, $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
If UBound($aTmp, $UBOUND_ROWS) = 1 Then
$aTmp[0] = $vValue
$hDataType = 0
EndIf
$vValue = $aTmp
EndIf
For $iReadFromIndex = $iDim_1 To 0 Step -1
$aArray[$iCopyTo_Index] = $aArray[$iReadFromIndex]
$iCopyTo_Index -= 1
$iInsert_Index = $vRange[$iInsertPoint_Index]
While $iReadFromIndex = $iInsert_Index
If $iInsertPoint_Index <= UBound($vValue, $UBOUND_ROWS) Then
If IsFunc($hDataType) Then
$aArray[$iCopyTo_Index] = $hDataType($vValue[$iInsertPoint_Index - 1])
Else
$aArray[$iCopyTo_Index] = $vValue[$iInsertPoint_Index - 1]
EndIf
Else
$aArray[$iCopyTo_Index] = ""
EndIf
$iCopyTo_Index -= 1
$iInsertPoint_Index -= 1
If $iInsertPoint_Index = 0 Then ExitLoop 2
$iInsert_Index = $vRange[$iInsertPoint_Index]
WEnd
Next
Case 2
Local $iDim_2 = UBound($aArray, $UBOUND_COLUMNS)
If $iStart < 0 Or $iStart > $iDim_2 - 1 Then Return SetError(6, 0, -1)
Local $iValDim_1, $iValDim_2
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 2 Then Return SetError(7, 0, -1)
$iValDim_1 = UBound($vValue, $UBOUND_ROWS)
$iValDim_2 = UBound($vValue, $UBOUND_COLUMNS)
$hDataType = 0
Else
$aSplit_1 = StringSplit($vValue, $sDelim_Row, $STR_NOCOUNT + $STR_ENTIRESPLIT)
$iValDim_1 = UBound($aSplit_1, $UBOUND_ROWS)
StringReplace($aSplit_1[0], $sDelim_Item, "")
$iValDim_2 = @extended + 1
Local $aTmp[$iValDim_1][$iValDim_2]
For $i = 0 To $iValDim_1 - 1
$aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
For $j = 0 To $iValDim_2 - 1
$aTmp[$i][$j] = $aSplit_2[$j]
Next
Next
$vValue = $aTmp
EndIf
If UBound($vValue, $UBOUND_COLUMNS) + $iStart > UBound($aArray, $UBOUND_COLUMNS) Then Return SetError(8, 0, -1)
ReDim $aArray[$iDim_1 + $vRange[0] + 1][$iDim_2]
For $iReadFromIndex = $iDim_1 To 0 Step -1
For $j = 0 To $iDim_2 - 1
$aArray[$iCopyTo_Index][$j] = $aArray[$iReadFromIndex][$j]
Next
$iCopyTo_Index -= 1
$iInsert_Index = $vRange[$iInsertPoint_Index]
While $iReadFromIndex = $iInsert_Index
For $j = 0 To $iDim_2 - 1
If $j < $iStart Then
$aArray[$iCopyTo_Index][$j] = ""
ElseIf $j - $iStart > $iValDim_2 - 1 Then
$aArray[$iCopyTo_Index][$j] = ""
Else
If $iInsertPoint_Index - 1 < $iValDim_1 Then
If IsFunc($hDataType) Then
$aArray[$iCopyTo_Index][$j] = $hDataType($vValue[$iInsertPoint_Index - 1][$j - $iStart])
Else
$aArray[$iCopyTo_Index][$j] = $vValue[$iInsertPoint_Index - 1][$j - $iStart]
EndIf
Else
$aArray[$iCopyTo_Index][$j] = ""
EndIf
EndIf
Next
$iCopyTo_Index -= 1
$iInsertPoint_Index -= 1
If $iInsertPoint_Index = 0 Then ExitLoop 2
$iInsert_Index = $vRange[$iInsertPoint_Index]
WEnd
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($aArray, $UBOUND_ROWS)
EndFunc
Func _ArrayReverse(ByRef $aArray, $iStart = 0, $iEnd = 0)
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
If UBound($aArray, $UBOUND_DIMENSIONS) <> 1 Then Return SetError(3, 0, 0)
If Not UBound($aArray) Then Return SetError(4, 0, 0)
Local $vTmp, $iUBound = UBound($aArray) - 1
If $iEnd < 1 Or $iEnd > $iUBound Then $iEnd = $iUBound
If $iStart < 0 Then $iStart = 0
If $iStart > $iEnd Then Return SetError(2, 0, 0)
For $i = $iStart To Int(($iStart + $iEnd - 1) / 2)
$vTmp = $aArray[$i]
$aArray[$i] = $aArray[$iEnd]
$aArray[$iEnd] = $vTmp
$iEnd -= 1
Next
Return 1
EndFunc
Func _ArraySort(ByRef $aArray, $iDescending = 0, $iStart = 0, $iEnd = 0, $iSubItem = 0, $iPivot = 0)
If $iDescending = Default Then $iDescending = 0
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If $iSubItem = Default Then $iSubItem = 0
If $iPivot = Default Then $iPivot = 0
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
Local $iUBound = UBound($aArray) - 1
If $iUBound = -1 Then Return SetError(5, 0, 0)
If $iEnd = Default Then $iEnd = 0
If $iEnd < 1 Or $iEnd > $iUBound Or $iEnd = Default Then $iEnd = $iUBound
If $iStart < 0 Or $iStart = Default Then $iStart = 0
If $iStart > $iEnd Then Return SetError(2, 0, 0)
If $iDescending = Default Then $iDescending = 0
If $iPivot = Default Then $iPivot = 0
If $iSubItem = Default Then $iSubItem = 0
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
If $iPivot Then
__ArrayDualPivotSort($aArray, $iStart, $iEnd)
Else
__ArrayQuickSort1D($aArray, $iStart, $iEnd)
EndIf
If $iDescending Then _ArrayReverse($aArray, $iStart, $iEnd)
Case 2
If $iPivot Then Return SetError(6, 0, 0)
Local $iSubMax = UBound($aArray, $UBOUND_COLUMNS) - 1
If $iSubItem > $iSubMax Then Return SetError(3, 0, 0)
If $iDescending Then
$iDescending = -1
Else
$iDescending = 1
EndIf
__ArrayQuickSort2D($aArray, $iDescending, $iStart, $iEnd, $iSubItem, $iSubMax)
Case Else
Return SetError(4, 0, 0)
EndSwitch
Return 1
EndFunc
Func __ArrayQuickSort1D(ByRef $aArray, Const ByRef $iStart, Const ByRef $iEnd)
If $iEnd <= $iStart Then Return
Local $vTmp
If($iEnd - $iStart) < 15 Then
Local $vCur
For $i = $iStart + 1 To $iEnd
$vTmp = $aArray[$i]
If IsNumber($vTmp) Then
For $j = $i - 1 To $iStart Step -1
$vCur = $aArray[$j]
If($vTmp >= $vCur And IsNumber($vCur)) Or(Not IsNumber($vCur) And StringCompare($vTmp, $vCur) >= 0) Then ExitLoop
$aArray[$j + 1] = $vCur
Next
Else
For $j = $i - 1 To $iStart Step -1
If(StringCompare($vTmp, $aArray[$j]) >= 0) Then ExitLoop
$aArray[$j + 1] = $aArray[$j]
Next
EndIf
$aArray[$j + 1] = $vTmp
Next
Return
EndIf
Local $L = $iStart, $R = $iEnd, $vPivot = $aArray[Int(($iStart + $iEnd) / 2)], $bNum = IsNumber($vPivot)
Do
If $bNum Then
While($aArray[$L] < $vPivot And IsNumber($aArray[$L])) Or(Not IsNumber($aArray[$L]) And StringCompare($aArray[$L], $vPivot) < 0)
$L += 1
WEnd
While($aArray[$R] > $vPivot And IsNumber($aArray[$R])) Or(Not IsNumber($aArray[$R]) And StringCompare($aArray[$R], $vPivot) > 0)
$R -= 1
WEnd
Else
While(StringCompare($aArray[$L], $vPivot) < 0)
$L += 1
WEnd
While(StringCompare($aArray[$R], $vPivot) > 0)
$R -= 1
WEnd
EndIf
If $L <= $R Then
$vTmp = $aArray[$L]
$aArray[$L] = $aArray[$R]
$aArray[$R] = $vTmp
$L += 1
$R -= 1
EndIf
Until $L > $R
__ArrayQuickSort1D($aArray, $iStart, $R)
__ArrayQuickSort1D($aArray, $L, $iEnd)
EndFunc
Func __ArrayQuickSort2D(ByRef $aArray, Const ByRef $iStep, Const ByRef $iStart, Const ByRef $iEnd, Const ByRef $iSubItem, Const ByRef $iSubMax)
If $iEnd <= $iStart Then Return
Local $vTmp, $L = $iStart, $R = $iEnd, $vPivot = $aArray[Int(($iStart + $iEnd) / 2)][$iSubItem], $bNum = IsNumber($vPivot)
Do
If $bNum Then
While($iStep *($aArray[$L][$iSubItem] - $vPivot) < 0 And IsNumber($aArray[$L][$iSubItem])) Or(Not IsNumber($aArray[$L][$iSubItem]) And $iStep * StringCompare($aArray[$L][$iSubItem], $vPivot) < 0)
$L += 1
WEnd
While($iStep *($aArray[$R][$iSubItem] - $vPivot) > 0 And IsNumber($aArray[$R][$iSubItem])) Or(Not IsNumber($aArray[$R][$iSubItem]) And $iStep * StringCompare($aArray[$R][$iSubItem], $vPivot) > 0)
$R -= 1
WEnd
Else
While($iStep * StringCompare($aArray[$L][$iSubItem], $vPivot) < 0)
$L += 1
WEnd
While($iStep * StringCompare($aArray[$R][$iSubItem], $vPivot) > 0)
$R -= 1
WEnd
EndIf
If $L <= $R Then
For $i = 0 To $iSubMax
$vTmp = $aArray[$L][$i]
$aArray[$L][$i] = $aArray[$R][$i]
$aArray[$R][$i] = $vTmp
Next
$L += 1
$R -= 1
EndIf
Until $L > $R
__ArrayQuickSort2D($aArray, $iStep, $iStart, $R, $iSubItem, $iSubMax)
__ArrayQuickSort2D($aArray, $iStep, $L, $iEnd, $iSubItem, $iSubMax)
EndFunc
Func __ArrayDualPivotSort(ByRef $aArray, $iPivot_Left, $iPivot_Right, $bLeftMost = True)
If $iPivot_Left > $iPivot_Right Then Return
Local $iLength = $iPivot_Right - $iPivot_Left + 1
Local $i, $j, $k, $iAi, $iAk, $iA1, $iA2, $iLast
If $iLength < 45 Then
If $bLeftMost Then
$i = $iPivot_Left
While $i < $iPivot_Right
$j = $i
$iAi = $aArray[$i + 1]
While $iAi < $aArray[$j]
$aArray[$j + 1] = $aArray[$j]
$j -= 1
If $j + 1 = $iPivot_Left Then ExitLoop
WEnd
$aArray[$j + 1] = $iAi
$i += 1
WEnd
Else
While 1
If $iPivot_Left >= $iPivot_Right Then Return 1
$iPivot_Left += 1
If $aArray[$iPivot_Left] < $aArray[$iPivot_Left - 1] Then ExitLoop
WEnd
While 1
$k = $iPivot_Left
$iPivot_Left += 1
If $iPivot_Left > $iPivot_Right Then ExitLoop
$iA1 = $aArray[$k]
$iA2 = $aArray[$iPivot_Left]
If $iA1 < $iA2 Then
$iA2 = $iA1
$iA1 = $aArray[$iPivot_Left]
EndIf
$k -= 1
While $iA1 < $aArray[$k]
$aArray[$k + 2] = $aArray[$k]
$k -= 1
WEnd
$aArray[$k + 2] = $iA1
While $iA2 < $aArray[$k]
$aArray[$k + 1] = $aArray[$k]
$k -= 1
WEnd
$aArray[$k + 1] = $iA2
$iPivot_Left += 1
WEnd
$iLast = $aArray[$iPivot_Right]
$iPivot_Right -= 1
While $iLast < $aArray[$iPivot_Right]
$aArray[$iPivot_Right + 1] = $aArray[$iPivot_Right]
$iPivot_Right -= 1
WEnd
$aArray[$iPivot_Right + 1] = $iLast
EndIf
Return 1
EndIf
Local $iSeventh = BitShift($iLength, 3) + BitShift($iLength, 6) + 1
Local $iE1, $iE2, $iE3, $iE4, $iE5, $t
$iE3 = Ceiling(($iPivot_Left + $iPivot_Right) / 2)
$iE2 = $iE3 - $iSeventh
$iE1 = $iE2 - $iSeventh
$iE4 = $iE3 + $iSeventh
$iE5 = $iE4 + $iSeventh
If $aArray[$iE2] < $aArray[$iE1] Then
$t = $aArray[$iE2]
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
If $aArray[$iE3] < $aArray[$iE2] Then
$t = $aArray[$iE3]
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
If $aArray[$iE4] < $aArray[$iE3] Then
$t = $aArray[$iE4]
$aArray[$iE4] = $aArray[$iE3]
$aArray[$iE3] = $t
If $t < $aArray[$iE2] Then
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
EndIf
If $aArray[$iE5] < $aArray[$iE4] Then
$t = $aArray[$iE5]
$aArray[$iE5] = $aArray[$iE4]
$aArray[$iE4] = $t
If $t < $aArray[$iE3] Then
$aArray[$iE4] = $aArray[$iE3]
$aArray[$iE3] = $t
If $t < $aArray[$iE2] Then
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
EndIf
EndIf
Local $iLess = $iPivot_Left
Local $iGreater = $iPivot_Right
If(($aArray[$iE1] <> $aArray[$iE2]) And($aArray[$iE2] <> $aArray[$iE3]) And($aArray[$iE3] <> $aArray[$iE4]) And($aArray[$iE4] <> $aArray[$iE5])) Then
Local $iPivot_1 = $aArray[$iE2]
Local $iPivot_2 = $aArray[$iE4]
$aArray[$iE2] = $aArray[$iPivot_Left]
$aArray[$iE4] = $aArray[$iPivot_Right]
Do
$iLess += 1
Until $aArray[$iLess] >= $iPivot_1
Do
$iGreater -= 1
Until $aArray[$iGreater] <= $iPivot_2
$k = $iLess
While $k <= $iGreater
$iAk = $aArray[$k]
If $iAk < $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
ElseIf $iAk > $iPivot_2 Then
While $aArray[$iGreater] > $iPivot_2
$iGreater -= 1
If $iGreater + 1 = $k Then ExitLoop 2
WEnd
If $aArray[$iGreater] < $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $aArray[$iGreater]
$iLess += 1
Else
$aArray[$k] = $aArray[$iGreater]
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
$aArray[$iPivot_Left] = $aArray[$iLess - 1]
$aArray[$iLess - 1] = $iPivot_1
$aArray[$iPivot_Right] = $aArray[$iGreater + 1]
$aArray[$iGreater + 1] = $iPivot_2
__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 2, True)
__ArrayDualPivotSort($aArray, $iGreater + 2, $iPivot_Right, False)
If($iLess < $iE1) And($iE5 < $iGreater) Then
While $aArray[$iLess] = $iPivot_1
$iLess += 1
WEnd
While $aArray[$iGreater] = $iPivot_2
$iGreater -= 1
WEnd
$k = $iLess
While $k <= $iGreater
$iAk = $aArray[$k]
If $iAk = $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
ElseIf $iAk = $iPivot_2 Then
While $aArray[$iGreater] = $iPivot_2
$iGreater -= 1
If $iGreater + 1 = $k Then ExitLoop 2
WEnd
If $aArray[$iGreater] = $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iPivot_1
$iLess += 1
Else
$aArray[$k] = $aArray[$iGreater]
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
EndIf
__ArrayDualPivotSort($aArray, $iLess, $iGreater, False)
Else
Local $iPivot = $aArray[$iE3]
$k = $iLess
While $k <= $iGreater
If $aArray[$k] = $iPivot Then
$k += 1
ContinueLoop
EndIf
$iAk = $aArray[$k]
If $iAk < $iPivot Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
Else
While $aArray[$iGreater] > $iPivot
$iGreater -= 1
WEnd
If $aArray[$iGreater] < $iPivot Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $aArray[$iGreater]
$iLess += 1
Else
$aArray[$k] = $iPivot
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 1, True)
__ArrayDualPivotSort($aArray, $iGreater + 1, $iPivot_Right, False)
EndIf
EndFunc
Global Const $FILE_END = 2
Global Const $FLTA_FILESFOLDERS = 0
Global Const $FLTA_FILES = 1
Global Const $FLTA_FOLDERS = 2
Global Const $FLTAR_FILESFOLDERS = 0
Global Const $FLTAR_NOHIDDEN = 4
Global Const $FLTAR_NOSYSTEM = 8
Global Const $FLTAR_NOLINK = 16
Global Const $FLTAR_NORECUR = 0
Global Const $FLTAR_RECUR = 1
Global Const $FLTAR_NOSORT = 0
Global Const $FLTAR_RELPATH = 1
Global Const $FLTAR_FULLPATH = 2
Func _FileListToArray($sFilePath, $sFilter = "*", $iFlag = $FLTA_FILESFOLDERS, $bReturnPath = False)
Local $sDelimiter = "|", $sFileList = "", $sFileName = "", $sFullPath = ""
$sFilePath = StringRegExpReplace($sFilePath, "[\\/]+$", "") & "\"
If $iFlag = Default Then $iFlag = $FLTA_FILESFOLDERS
If $bReturnPath Then $sFullPath = $sFilePath
If $sFilter = Default Then $sFilter = "*"
If Not FileExists($sFilePath) Then Return SetError(1, 0, 0)
If StringRegExp($sFilter, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 0, 0)
Local $hSearch = FileFindFirstFile($sFilePath & $sFilter)
If @error Then Return SetError(4, 0, 0)
While 1
$sFileName = FileFindNextFile($hSearch)
If @error Then ExitLoop
If($iFlag + @extended = 2) Then ContinueLoop
$sFileList &= $sDelimiter & $sFullPath & $sFileName
WEnd
FileClose($hSearch)
If $sFileList = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($sFileList, 1), $sDelimiter)
EndFunc
Func _FileListToArrayRec($sFilePath, $sMask = "*", $iReturn = $FLTAR_FILESFOLDERS, $iRecur = $FLTAR_NORECUR, $iSort = $FLTAR_NOSORT, $iReturnPath = $FLTAR_RELPATH)
If Not FileExists($sFilePath) Then Return SetError(1, 1, "")
If $sMask = Default Then $sMask = "*"
If $iReturn = Default Then $iReturn = $FLTAR_FILESFOLDERS
If $iRecur = Default Then $iRecur = $FLTAR_NORECUR
If $iSort = Default Then $iSort = $FLTAR_NOSORT
If $iReturnPath = Default Then $iReturnPath = $FLTAR_RELPATH
If $iRecur > 1 Or Not IsInt($iRecur) Then Return SetError(1, 6, "")
Local $bLongPath = False
If StringLeft($sFilePath, 4) == "\\?\" Then
$bLongPath = True
EndIf
Local $sFolderSlash = ""
If StringRight($sFilePath, 1) = "\" Then
$sFolderSlash = "\"
Else
$sFilePath = $sFilePath & "\"
EndIf
Local $asFolderSearchList[100] = [1]
$asFolderSearchList[1] = $sFilePath
Local $iHide_HS = 0, $sHide_HS = ""
If BitAND($iReturn, $FLTAR_NOHIDDEN) Then
$iHide_HS += 2
$sHide_HS &= "H"
$iReturn -= $FLTAR_NOHIDDEN
EndIf
If BitAND($iReturn, $FLTAR_NOSYSTEM) Then
$iHide_HS += 4
$sHide_HS &= "S"
$iReturn -= $FLTAR_NOSYSTEM
EndIf
Local $iHide_Link = 0
If BitAND($iReturn, $FLTAR_NOLINK) Then
$iHide_Link = 0x400
$iReturn -= $FLTAR_NOLINK
EndIf
Local $iMaxLevel = 0
If $iRecur < 0 Then
StringReplace($sFilePath, "\", "", 0, $STR_NOCASESENSEBASIC)
$iMaxLevel = @extended - $iRecur
EndIf
Local $sExclude_List = "", $sExclude_List_Folder = "", $sInclude_List = "*"
Local $aMaskSplit = StringSplit($sMask, "|")
Switch $aMaskSplit[0]
Case 3
$sExclude_List_Folder = $aMaskSplit[3]
ContinueCase
Case 2
$sExclude_List = $aMaskSplit[2]
ContinueCase
Case 1
$sInclude_List = $aMaskSplit[1]
EndSwitch
Local $sInclude_File_Mask = ".+"
If $sInclude_List <> "*" Then
If Not __FLTAR_ListToMask($sInclude_File_Mask, $sInclude_List) Then Return SetError(1, 2, "")
EndIf
Local $sInclude_Folder_Mask = ".+"
Switch $iReturn
Case 0
Switch $iRecur
Case 0
$sInclude_Folder_Mask = $sInclude_File_Mask
EndSwitch
Case 2
$sInclude_Folder_Mask = $sInclude_File_Mask
EndSwitch
Local $sExclude_File_Mask = ":"
If $sExclude_List <> "" Then
If Not __FLTAR_ListToMask($sExclude_File_Mask, $sExclude_List) Then Return SetError(1, 3, "")
EndIf
Local $sExclude_Folder_Mask = ":"
If $iRecur Then
If $sExclude_List_Folder Then
If Not __FLTAR_ListToMask($sExclude_Folder_Mask, $sExclude_List_Folder) Then Return SetError(1, 4, "")
EndIf
If $iReturn = 2 Then
$sExclude_Folder_Mask = $sExclude_File_Mask
EndIf
Else
$sExclude_Folder_Mask = $sExclude_File_Mask
EndIf
If Not($iReturn = 0 Or $iReturn = 1 Or $iReturn = 2) Then Return SetError(1, 5, "")
If Not($iSort = 0 Or $iSort = 1 Or $iSort = 2) Then Return SetError(1, 7, "")
If Not($iReturnPath = 0 Or $iReturnPath = 1 Or $iReturnPath = 2) Then Return SetError(1, 8, "")
If $iHide_Link Then
Local $tFile_Data = DllStructCreate("struct;align 4;dword FileAttributes;uint64 CreationTime;uint64 LastAccessTime;uint64 LastWriteTime;" & "dword FileSizeHigh;dword FileSizeLow;dword Reserved0;dword Reserved1;wchar FileName[260];wchar AlternateFileName[14];endstruct")
Local $hDLL = DllOpen('kernel32.dll'), $aDLL_Ret
EndIf
Local $asReturnList[100] = [0]
Local $asFileMatchList = $asReturnList, $asRootFileMatchList = $asReturnList, $asFolderMatchList = $asReturnList
Local $bFolder = False, $hSearch = 0, $sCurrentPath = "", $sName = "", $sRetPath = ""
Local $iAttribs = 0, $sAttribs = ''
Local $asFolderFileSectionList[100][2] = [[0, 0]]
While $asFolderSearchList[0] > 0
$sCurrentPath = $asFolderSearchList[$asFolderSearchList[0]]
$asFolderSearchList[0] -= 1
Switch $iReturnPath
Case 1
$sRetPath = StringReplace($sCurrentPath, $sFilePath, "")
Case 2
If $bLongPath Then
$sRetPath = StringTrimLeft($sCurrentPath, 4)
Else
$sRetPath = $sCurrentPath
EndIf
EndSwitch
If $iHide_Link Then
$aDLL_Ret = DllCall($hDLL, 'handle', 'FindFirstFileW', 'wstr', $sCurrentPath & "*", 'struct*', $tFile_Data)
If @error Or Not $aDLL_Ret[0] Then
ContinueLoop
EndIf
$hSearch = $aDLL_Ret[0]
Else
$hSearch = FileFindFirstFile($sCurrentPath & "*")
If $hSearch = -1 Then
ContinueLoop
EndIf
EndIf
If $iReturn = 0 And $iSort And $iReturnPath Then
__FLTAR_AddToList($asFolderFileSectionList, $sRetPath, $asFileMatchList[0] + 1)
EndIf
$sAttribs = ''
While 1
If $iHide_Link Then
$aDLL_Ret = DllCall($hDLL, 'int', 'FindNextFileW', 'handle', $hSearch, 'struct*', $tFile_Data)
If @error Or Not $aDLL_Ret[0] Then
ExitLoop
EndIf
$sName = DllStructGetData($tFile_Data, "FileName")
If $sName = ".." Or $sName = "." Then
ContinueLoop
EndIf
$iAttribs = DllStructGetData($tFile_Data, "FileAttributes")
If $iHide_HS And BitAND($iAttribs, $iHide_HS) Then
ContinueLoop
EndIf
If BitAND($iAttribs, $iHide_Link) Then
ContinueLoop
EndIf
$bFolder = False
If BitAND($iAttribs, 16) Then
$bFolder = True
EndIf
Else
$bFolder = False
$sName = FileFindNextFile($hSearch, 1)
If @error Then
ExitLoop
EndIf
If $sName = ".." Or $sName = "." Then
ContinueLoop
EndIf
$sAttribs = @extended
If StringInStr($sAttribs, "D") Then
$bFolder = True
EndIf
If StringRegExp($sAttribs, "[" & $sHide_HS & "]") Then
ContinueLoop
EndIf
EndIf
If $bFolder Then
Select
Case $iRecur < 0
StringReplace($sCurrentPath, "\", "", 0, $STR_NOCASESENSEBASIC)
If @extended < $iMaxLevel Then
ContinueCase
EndIf
Case $iRecur = 1
If Not StringRegExp($sName, $sExclude_Folder_Mask) Then
__FLTAR_AddToList($asFolderSearchList, $sCurrentPath & $sName & "\")
EndIf
EndSelect
EndIf
If $iSort Then
If $bFolder Then
If StringRegExp($sName, $sInclude_Folder_Mask) And Not StringRegExp($sName, $sExclude_Folder_Mask) Then
__FLTAR_AddToList($asFolderMatchList, $sRetPath & $sName & $sFolderSlash)
EndIf
Else
If StringRegExp($sName, $sInclude_File_Mask) And Not StringRegExp($sName, $sExclude_File_Mask) Then
If $sCurrentPath = $sFilePath Then
__FLTAR_AddToList($asRootFileMatchList, $sRetPath & $sName)
Else
__FLTAR_AddToList($asFileMatchList, $sRetPath & $sName)
EndIf
EndIf
EndIf
Else
If $bFolder Then
If $iReturn <> 1 And StringRegExp($sName, $sInclude_Folder_Mask) And Not StringRegExp($sName, $sExclude_Folder_Mask) Then
__FLTAR_AddToList($asReturnList, $sRetPath & $sName & $sFolderSlash)
EndIf
Else
If $iReturn <> 2 And StringRegExp($sName, $sInclude_File_Mask) And Not StringRegExp($sName, $sExclude_File_Mask) Then
__FLTAR_AddToList($asReturnList, $sRetPath & $sName)
EndIf
EndIf
EndIf
WEnd
If $iHide_Link Then
DllCall($hDLL, 'int', 'FindClose', 'ptr', $hSearch)
Else
FileClose($hSearch)
EndIf
WEnd
If $iHide_Link Then
DllClose($hDLL)
EndIf
If $iSort Then
Switch $iReturn
Case 2
If $asFolderMatchList[0] = 0 Then Return SetError(1, 9, "")
ReDim $asFolderMatchList[$asFolderMatchList[0] + 1]
$asReturnList = $asFolderMatchList
__ArrayDualPivotSort($asReturnList, 1, $asReturnList[0])
Case 1
If $asRootFileMatchList[0] = 0 And $asFileMatchList[0] = 0 Then Return SetError(1, 9, "")
If $iReturnPath = 0 Then
__FLTAR_AddFileLists($asReturnList, $asRootFileMatchList, $asFileMatchList)
__ArrayDualPivotSort($asReturnList, 1, $asReturnList[0])
Else
__FLTAR_AddFileLists($asReturnList, $asRootFileMatchList, $asFileMatchList, 1)
EndIf
Case 0
If $asRootFileMatchList[0] = 0 And $asFolderMatchList[0] = 0 Then Return SetError(1, 9, "")
If $iReturnPath = 0 Then
__FLTAR_AddFileLists($asReturnList, $asRootFileMatchList, $asFileMatchList)
$asReturnList[0] += $asFolderMatchList[0]
ReDim $asFolderMatchList[$asFolderMatchList[0] + 1]
_ArrayConcatenate($asReturnList, $asFolderMatchList, 1)
__ArrayDualPivotSort($asReturnList, 1, $asReturnList[0])
Else
Local $asReturnList[$asFileMatchList[0] + $asRootFileMatchList[0] + $asFolderMatchList[0] + 1]
$asReturnList[0] = $asFileMatchList[0] + $asRootFileMatchList[0] + $asFolderMatchList[0]
__ArrayDualPivotSort($asRootFileMatchList, 1, $asRootFileMatchList[0])
For $i = 1 To $asRootFileMatchList[0]
$asReturnList[$i] = $asRootFileMatchList[$i]
Next
Local $iNextInsertionIndex = $asRootFileMatchList[0] + 1
__ArrayDualPivotSort($asFolderMatchList, 1, $asFolderMatchList[0])
Local $sFolderToFind = ""
For $i = 1 To $asFolderMatchList[0]
$asReturnList[$iNextInsertionIndex] = $asFolderMatchList[$i]
$iNextInsertionIndex += 1
If $sFolderSlash Then
$sFolderToFind = $asFolderMatchList[$i]
Else
$sFolderToFind = $asFolderMatchList[$i] & "\"
EndIf
Local $iFileSectionEndIndex = 0, $iFileSectionStartIndex = 0
For $j = 1 To $asFolderFileSectionList[0][0]
If $sFolderToFind = $asFolderFileSectionList[$j][0] Then
$iFileSectionStartIndex = $asFolderFileSectionList[$j][1]
If $j = $asFolderFileSectionList[0][0] Then
$iFileSectionEndIndex = $asFileMatchList[0]
Else
$iFileSectionEndIndex = $asFolderFileSectionList[$j + 1][1] - 1
EndIf
If $iSort = 1 Then
__ArrayDualPivotSort($asFileMatchList, $iFileSectionStartIndex, $iFileSectionEndIndex)
EndIf
For $k = $iFileSectionStartIndex To $iFileSectionEndIndex
$asReturnList[$iNextInsertionIndex] = $asFileMatchList[$k]
$iNextInsertionIndex += 1
Next
ExitLoop
EndIf
Next
Next
EndIf
EndSwitch
Else
If $asReturnList[0] = 0 Then Return SetError(1, 9, "")
ReDim $asReturnList[$asReturnList[0] + 1]
EndIf
Return $asReturnList
EndFunc
Func __FLTAR_AddFileLists(ByRef $asTarget, $asSource_1, $asSource_2, $iSort = 0)
ReDim $asSource_1[$asSource_1[0] + 1]
If $iSort = 1 Then __ArrayDualPivotSort($asSource_1, 1, $asSource_1[0])
$asTarget = $asSource_1
$asTarget[0] += $asSource_2[0]
ReDim $asSource_2[$asSource_2[0] + 1]
If $iSort = 1 Then __ArrayDualPivotSort($asSource_2, 1, $asSource_2[0])
_ArrayConcatenate($asTarget, $asSource_2, 1)
EndFunc
Func __FLTAR_AddToList(ByRef $aList, $vValue_0, $vValue_1 = -1)
If $vValue_1 = -1 Then
$aList[0] += 1
If UBound($aList) <= $aList[0] Then ReDim $aList[UBound($aList) * 2]
$aList[$aList[0]] = $vValue_0
Else
$aList[0][0] += 1
If UBound($aList) <= $aList[0][0] Then ReDim $aList[UBound($aList) * 2][2]
$aList[$aList[0][0]][0] = $vValue_0
$aList[$aList[0][0]][1] = $vValue_1
EndIf
EndFunc
Func __FLTAR_ListToMask(ByRef $sMask, $sList)
If StringRegExp($sList, "\\|/|:|\<|\>|\|") Then Return 0
$sList = StringReplace(StringStripWS(StringRegExpReplace($sList, "\s*;\s*", ";"), BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING)), ";", "|")
$sList = StringReplace(StringReplace(StringRegExpReplace($sList, "[][$^.{}()+\-]", "\\$0"), "?", "."), "*", ".*?")
$sMask = "(?i)^(" & $sList & ")\z"
Return 1
EndFunc
Func _TempFile($sDirectoryName = @TempDir, $sFilePrefix = "~", $sFileExtension = ".tmp", $iRandomLength = 7)
If $iRandomLength = Default Or $iRandomLength <= 0 Then $iRandomLength = 7
If $sDirectoryName = Default Or(Not FileExists($sDirectoryName)) Then $sDirectoryName = @TempDir
If $sFileExtension = Default Then $sFileExtension = ".tmp"
If $sFilePrefix = Default Then $sFilePrefix = "~"
If Not FileExists($sDirectoryName) Then $sDirectoryName = @ScriptDir
$sDirectoryName = StringRegExpReplace($sDirectoryName, "[\\/]+$", "")
$sFileExtension = StringRegExpReplace($sFileExtension, "^\.+", "")
$sFilePrefix = StringRegExpReplace($sFilePrefix, '[\\/:*?"<>|]', "")
Local $sTempName = ""
Do
$sTempName = ""
While StringLen($sTempName) < $iRandomLength
$sTempName &= Chr(Random(97, 122, 1))
WEnd
$sTempName = $sDirectoryName & "\" & $sFilePrefix & $sTempName & "." & $sFileExtension
Until Not FileExists($sTempName)
Return $sTempName
EndFunc
Func _WinAPI_GetLastError(Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
Local $aCall = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($_iCallerError, $_iCallerExtended, $aCall[0])
EndFunc
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Func _WinAPI_PathIsRelative($sFilePath)
Local $aCall = DllCall('shlwapi.dll', 'bool', 'PathIsRelativeW', 'wstr', $sFilePath)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _WinAPI_GetCurrentThreadId()
Local $aCall = DllCall("kernel32.dll", "dword", "GetCurrentThreadId")
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_GetFullPathName($sFilePath)
Local $aCall = DllCall('kernel32.dll', 'dword', 'GetFullPathNameW', 'wstr', $sFilePath, 'dword', 4096, 'wstr', '', 'ptr', 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, '')
Return $aCall[3]
EndFunc
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $WH_CBT = 5
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global $__g_aWinList_WinAPI[64][2] = [[0, 0]]
Global Const $GW_HWNDNEXT = 2
Global Const $GW_CHILD = 5
Func _WinAPI_GetDesktopWindow()
Local $aCall = DllCall("user32.dll", "hwnd", "GetDesktopWindow")
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_DestroyWindow($hWnd)
Local $aCall = DllCall("user32.dll", "bool", "DestroyWindow", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _WinAPI_EnumWindows($bVisible = True, $hWnd = Default)
__WinAPI_EnumWindowsInit()
If $hWnd = Default Then $hWnd = _WinAPI_GetDesktopWindow()
__WinAPI_EnumWindowsChild($hWnd, $bVisible)
Return $__g_aWinList_WinAPI
EndFunc
Func _WinAPI_GetClassName($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aCall = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, '')
Return SetExtended($aCall[0], $aCall[2])
EndFunc
Func _WinAPI_GetWindow($hWnd, $iCmd)
Local $aCall = DllCall("user32.dll", "hwnd", "GetWindow", "hwnd", $hWnd, "uint", $iCmd)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_IsWindowVisible($hWnd)
Local $aCall = DllCall("user32.dll", "bool", "IsWindowVisible", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_ShowWindow($hWnd, $iCmdShow = 5)
Local $aCall = DllCall("user32.dll", "bool", "ShowWindow", "hwnd", $hWnd, "int", $iCmdShow)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func __WinAPI_EnumWindowsAdd($hWnd, $sClass = "")
If $sClass = "" Then $sClass = _WinAPI_GetClassName($hWnd)
$__g_aWinList_WinAPI[0][0] += 1
Local $iCount = $__g_aWinList_WinAPI[0][0]
If $iCount >= $__g_aWinList_WinAPI[0][1] Then
ReDim $__g_aWinList_WinAPI[$iCount + 64][2]
$__g_aWinList_WinAPI[0][1] += 64
EndIf
$__g_aWinList_WinAPI[$iCount][0] = $hWnd
$__g_aWinList_WinAPI[$iCount][1] = $sClass
EndFunc
Func __WinAPI_EnumWindowsChild($hWnd, $bVisible = True)
$hWnd = _WinAPI_GetWindow($hWnd, $GW_CHILD)
While $hWnd <> 0
If(Not $bVisible) Or _WinAPI_IsWindowVisible($hWnd) Then
__WinAPI_EnumWindowsAdd($hWnd)
__WinAPI_EnumWindowsChild($hWnd, $bVisible)
EndIf
$hWnd = _WinAPI_GetWindow($hWnd, $GW_HWNDNEXT)
WEnd
EndFunc
Func __WinAPI_EnumWindowsInit()
ReDim $__g_aWinList_WinAPI[64][2]
$__g_aWinList_WinAPI[0][0] = 0
$__g_aWinList_WinAPI[0][1] = 64
EndFunc
Func _WinAPI_FindWindow($sClassName, $sWindowName)
Local $aCall = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $sClassName, "wstr", $sWindowName)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_CallNextHookEx($hHook, $iCode, $wParam, $lParam)
Local $aCall = DllCall("user32.dll", "lresult", "CallNextHookEx", "handle", $hHook, "int", $iCode, "wparam", $wParam, "lparam", $lParam)
If @error Then Return SetError(@error, @extended, -1)
Return $aCall[0]
EndFunc
Func _WinAPI_SetWindowsHookEx($iHook, $pProc, $hDll, $iThreadId = 0)
Local $aCall = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", $iHook, "ptr", $pProc, "handle", $hDll, "dword", $iThreadId)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_UnhookWindowsHookEx($hHook)
Local $aCall = DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $hHook)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Global Const $PROV_RSA_AES = 24
Global Const $CRYPT_VERIFYCONTEXT = 0xF0000000
Global Const $CRYPT_EXPORTABLE = 0x00000001
Global Const $CRYPT_USERDATA = 1
Global Const $KP_ALGID = 0x00000007
Global Const $CALG_MD5 = 0x00008003
Global Const $CALG_RC4 = 0x00006801
Global Const $CALG_USERKEY = 0
Global $__g_aCryptInternalData[3]
Func _Crypt_Startup()
If __Crypt_RefCount() = 0 Then
Local $hAdvapi32 = DllOpen("Advapi32.dll")
If $hAdvapi32 = -1 Then Return SetError(1001, 0, False)
__Crypt_DllHandleSet($hAdvapi32)
Local $iProviderID = $PROV_RSA_AES
Local $aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptAcquireContext", "handle*", 0, "ptr", 0, "ptr", 0, "dword", $iProviderID, "dword", $CRYPT_VERIFYCONTEXT)
If @error Or Not $aCall[0] Then
Local $iError = @error + 1002, $iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
DllClose(__Crypt_DllHandle())
Return SetError($iError, $iExtended, False)
Else
__Crypt_ContextSet($aCall[1])
EndIf
EndIf
__Crypt_RefCountInc()
Return True
EndFunc
Func _Crypt_Shutdown()
__Crypt_RefCountDec()
If __Crypt_RefCount() = 0 Then
DllCall(__Crypt_DllHandle(), "bool", "CryptReleaseContext", "handle", __Crypt_Context(), "dword", 0)
DllClose(__Crypt_DllHandle())
EndIf
EndFunc
Func _Crypt_DeriveKey($vPassword, $iAlgID, $iHashPasswordID = $CALG_MD5)
Local $aCall, $tBuff = 0, $hCryptHash = 0, $iError = 0, $iExtended = 0, $vReturn = 0
_Crypt_Startup()
If @error Then Return SetError(@error, @extended, -1)
Do
$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptCreateHash", "handle", __Crypt_Context(), "uint", $iHashPasswordID, "ptr", 0, "dword", 0, "handle*", 0)
If @error Or Not $aCall[0] Then
$iError = @error + 10
$iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
$vReturn = -1
ExitLoop
EndIf
$hCryptHash = $aCall[5]
$tBuff = DllStructCreate("byte[" & BinaryLen($vPassword) & "]")
DllStructSetData($tBuff, 1, $vPassword)
$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptHashData", "handle", $hCryptHash, "struct*", $tBuff, "dword", DllStructGetSize($tBuff), "dword", $CRYPT_USERDATA)
If @error Or Not $aCall[0] Then
$iError = @error + 20
$iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
$vReturn = -1
ExitLoop
EndIf
$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptDeriveKey", "handle", __Crypt_Context(), "uint", $iAlgID, "handle", $hCryptHash, "dword", $CRYPT_EXPORTABLE, "handle*", 0)
If @error Or Not $aCall[0] Then
$iError = @error + 30
$iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
$vReturn = -1
ExitLoop
EndIf
$vReturn = $aCall[5]
Until True
If $hCryptHash <> 0 Then DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyHash", "handle", $hCryptHash)
Return SetError($iError, $iExtended, $vReturn)
EndFunc
Func _Crypt_DestroyKey($hCryptKey)
Local $aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyKey", "handle", $hCryptKey)
Local $iError = @error
If $iError Or Not $aCall[0] Then
Return SetError($iError + 10, _WinAPI_GetLastError(), False)
Else
_Crypt_Shutdown()
Return True
EndIf
EndFunc
Func _Crypt_EncryptData($vData, $vCryptKey, $iAlgID, $bFinal = True)
Switch $iAlgID
Case $CALG_USERKEY
Local $iCalgUsed = __Crypt_GetCalgFromCryptKey($vCryptKey)
If @error Then Return SetError(@error, @extended, -1)
If $iCalgUsed = $CALG_RC4 Then ContinueCase
Case $CALG_RC4
If BinaryLen($vData) = 0 Then Return SetError(0, 0, Binary(''))
EndSwitch
Local $iReqBuffSize = 0, $aCall, $tBuff = 0, $iError = 0, $iExtended = 0, $vReturn = 0
_Crypt_Startup()
If @error Then Return SetError(@error, @extended, -1)
Do
If $iAlgID <> $CALG_USERKEY Then
$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
If @error Then
$iError = @error
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
EndIf
$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptEncrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "ptr", 0, "dword*", BinaryLen($vData), "dword", 0)
If @error Or Not $aCall[0] Then
$iError = @error + 50
$iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
$vReturn = -1
ExitLoop
EndIf
$iReqBuffSize = $aCall[6]
$tBuff = DllStructCreate("byte[" & $iReqBuffSize + 1 & "]")
DllStructSetData($tBuff, 1, $vData)
$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptEncrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "struct*", $tBuff, "dword*", BinaryLen($vData), "dword", $iReqBuffSize)
If @error Or Not $aCall[0] Then
$iError = @error + 60
$iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
$vReturn = -1
ExitLoop
EndIf
$vReturn = BinaryMid(DllStructGetData($tBuff, 1), 1, $iReqBuffSize)
Until True
If $iAlgID <> $CALG_USERKEY Then _Crypt_DestroyKey($vCryptKey)
_Crypt_Shutdown()
Return SetError($iError, $iExtended, $vReturn)
EndFunc
Func _Crypt_DecryptData($vData, $vCryptKey, $iAlgID, $bFinal = True)
Switch $iAlgID
Case $CALG_USERKEY
Local $iCalgUsed = __Crypt_GetCalgFromCryptKey($vCryptKey)
If @error Then Return SetError(@error, @extended, -1)
If $iCalgUsed = $CALG_RC4 Then ContinueCase
Case $CALG_RC4
If BinaryLen($vData) = 0 Then Return SetError(0, 0, Binary(''))
EndSwitch
Local $aCall, $tBuff = 0, $tTempStruct = 0, $iError = 0, $iExtended = 0, $iPlainTextSize = 0, $vReturn = 0
_Crypt_Startup()
If @error Then Return SetError(@error, @extended, -1)
Do
If $iAlgID <> $CALG_USERKEY Then
$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
If @error Then
$iError = @error
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
EndIf
$tBuff = DllStructCreate("byte[" & BinaryLen($vData) + 1000 & "]")
If BinaryLen($vData) > 0 Then DllStructSetData($tBuff, 1, $vData)
$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptDecrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "struct*", $tBuff, "dword*", BinaryLen($vData))
If @error Or Not $aCall[0] Then
$iError = @error + 70
$iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
$vReturn = -1
ExitLoop
EndIf
$iPlainTextSize = $aCall[6]
$tTempStruct = DllStructCreate("byte[" & $iPlainTextSize + 1 & "]", DllStructGetPtr($tBuff))
$vReturn = BinaryMid(DllStructGetData($tTempStruct, 1), 1, $iPlainTextSize)
Until True
If $iAlgID <> $CALG_USERKEY Then _Crypt_DestroyKey($vCryptKey)
_Crypt_Shutdown()
Return SetError($iError, $iExtended, $vReturn)
EndFunc
Func __Crypt_RefCount()
Return $__g_aCryptInternalData[0]
EndFunc
Func __Crypt_RefCountInc()
$__g_aCryptInternalData[0] += 1
EndFunc
Func __Crypt_RefCountDec()
If $__g_aCryptInternalData[0] > 0 Then $__g_aCryptInternalData[0] -= 1
EndFunc
Func __Crypt_DllHandle()
Return $__g_aCryptInternalData[1]
EndFunc
Func __Crypt_DllHandleSet($hAdvapi32)
$__g_aCryptInternalData[1] = $hAdvapi32
EndFunc
Func __Crypt_Context()
Return $__g_aCryptInternalData[2]
EndFunc
Func __Crypt_ContextSet($hCryptContext)
$__g_aCryptInternalData[2] = $hCryptContext
EndFunc
Func __Crypt_GetCalgFromCryptKey($vCryptKey)
Local $tAlgId = DllStructCreate("uint")
Local $aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptGetKeyParam", "handle", $vCryptKey, "dword", $KP_ALGID, "struct*", $tAlgId, "dword*", DllStructGetSize($tAlgId), "dword", 0)
Local $iError = @error, $iExtended = @extended
If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
If $iError Or Not $aCall[0] Then
Return SetError($iError + 80, $iExtended, $CRYPT_USERDATA)
Else
Return DllStructGetData($tAlgId, 1)
EndIf
EndFunc
OnAutoItExitRegister('__OAER_OnExit')
Global Enum $iOAER_bSet_ErrLine, $iOAER_bIn_Proc, $iOAER_bUse_StdOut, $iOAER_iPID, $iOAER_hErr_Callback, $iOAER_hErr_WinHook, $iOAER_sUserFunc, $iOAER_vUserParams, $iOAER_iCOMErrorNumber, $iOAER_sCOMErrorDesc, $iOAER_Total
Global $aOAER_DATA[$iOAER_Total]
Global Const $sOAER_CRYPT_KEY = 'MY_CRYPT_KEY'
Global Const $iOAER_CRYPT_ALG = $CALG_RC4
Global $sOAER_Main_Title = 'AutoIt3 Error'
Global $sOAER_ErrMsgSendFrmt_Msg = 'Program Path: %s\r\n\r\nError Line: %i\r\n\r\nError Description:\r\n\r\n%s\r\n\r\n====================\r\n%s'
Global $sOAER_ErrMsgDispFrmt_Msg = 'Program has been Terminated :(.\r\nPlease report about this bug to developer, sorry for the inconvenience!\r\n\r\n' & $sOAER_ErrMsgSendFrmt_Msg
Global $sOAER_SendBugReport_Tip = 'Please fill the following data (* requierd fields):'
Global $sOAER_Body_Lbl = '* Body (bug report):'
Func _OnAutoItErrorRegister($sFunction = '', $vParams = '', $sTitle = '', $bUseStdOut = False, $bSetErrLine = False)
If $aOAER_DATA[$iOAER_bIn_Proc] Then
Return
EndIf
$aOAER_DATA[$iOAER_bIn_Proc] = True
$aOAER_DATA[$iOAER_bSet_ErrLine] =($bSetErrLine = True)
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
If StringInStr($CmdLineRaw, '/ErrorStdOut') Then
$bUseStdOut = True
EndIf
$aOAER_DATA[$iOAER_bUse_StdOut] = $bUseStdOut
$aOAER_DATA[$iOAER_sUserFunc] = $sFunction
$aOAER_DATA[$iOAER_vUserParams] = $vParams
If $sTitle Then
$sOAER_Main_Title = $sTitle
EndIf
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
If StringRegExp($CmdLineRaw, ' /OAER:\d+') Then
$aOAER_DATA[$iOAER_iPID] = Number(StringRegExpReplace($CmdLineRaw, '.*/OAER:(\d+)', '\1'))
$CmdLineRaw = StringRegExpReplace($CmdLineRaw, ' /OAER:\d+', '')
Return 1
Else
Opt('TrayIconHide', 1)
EndIf
Local $sRunCmd, $iPID, $sError_Msg = '', $hBitmap = 0
$sRunCmd = @AutoItExe & ' /ErrorStdOut ' &(@Compiled ? '' : '/AutoIt3ExecuteScript "' & @ScriptFullPath & '" ') & $CmdLineRaw & ' /OAER:' & @AutoItPID
$iPID = Run($sRunCmd, @ScriptDir, 0, $STDERR_MERGED)
While 1
$sError_Msg &= StdoutRead($iPID)
If @error Then
ExitLoop
EndIf
If $hBitmap = 0 And StringRegExp($sError_Msg, '\(\d+\) : ==> .*:') Then
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
Exit
EndFunc
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
Case 5
If Not _WinAPI_FindWindow('#32770', 'AutoIt Error') Then
Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
EndIf
Local $hError_Wnd = HWnd($wParam)
Local $sError_Msg = StringRegExpReplace(ControlGetText($hError_Wnd, '', 'Static2'), '(?<!\r)\n', @CRLF)
If(_WinAPI_GetClassName($hError_Wnd) <> '#32770' And WinGetTitle($hError_Wnd) <> 'AutoIt Error') Or Not StringRegExp($sError_Msg, '(?is)^.*Line \d+\s+\(File "(.*?)"\):\s+.*Error: .*') Then
Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
EndIf
_WinAPI_DestroyWindow($hError_Wnd)
__OAER_OnExit()
Local $aEnumWin = _WinAPI_EnumWindows()
For $i = 1 To $aEnumWin[0][0]
If WinGetProcess($aEnumWin[$i][0]) = @AutoItPID And $aEnumWin[$i][1] = 'AutoIt v3 GUI' Then
_WinAPI_ShowWindow($aEnumWin[$i][0], @SW_HIDE)
EndIf
Next
Local $sScriptPath, $iScriptLine
__OAER_ParseErrorMsg($sScriptPath, $iScriptLine, $sError_Msg)
If @error Then
Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
EndIf
EndSwitch
Return _WinAPI_CallNextHookEx($aOAER_DATA[$iOAER_hErr_WinHook], $nCode, $wParam, $lParam)
EndFunc
Func __OAER_ParseErrorMsg(ByRef $sPath, ByRef $iLine, ByRef $sMsg)
Local $sScriptPath_Pttrn =($aOAER_DATA[$iOAER_bUse_StdOut] ? '(?is)^.*"([a-z]:\\.*?)" \(\d+\) : ==> .*' : '(?is)^.*Line \d+\s+\(File "(.*?)"\):\s+.*Error: .*')
Local $sScriptLine_Pttrn =($aOAER_DATA[$iOAER_bUse_StdOut] ? '(?is)^.*[a-z]:\\.*? \((\d+)\) : ==> .*' : '(?is)^.*Line (\d+)\s+\(File ".*?"\):\s+.*Error: .*')
Local $sErrDesc_Pttrn =($aOAER_DATA[$iOAER_bUse_StdOut] ? '(?is)^.*[a-z]:\\.*? \(\d+\) : ==> (.*)' : '(?is)^.*Line \d+\s+\(File ".*?"\):\s+(.*Error: .*)')
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
Local $iLen =($iPos2 > 0 ? $iPos2 - $iPos1 : -1)
$sMsg &= @CRLF & StringStripWS(StringMid($sRead, $iPos1, $iLen), 3)
EndIf
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
Local Static $sAutoIt_Incl_Dir = StringRegExpReplace(@AutoItExe, '\\[^\\]+$', '') & '\Include'
Local Static $aUDL = StringRegExp(RegRead('HKCU\Software\AutoIt v3\AutoIt', 'Include'), '([^;]+)(?:;|$)', 3)
While 1
If Not _WinAPI_PathIsRelative($sInclude) Then
If FileExists($sInclude) Then
$sRet = $sInclude
Else
$iError = 2
EndIf
ExitLoop
EndIf
$sAU3 = $sScriptDir & '\' & $sInclude
$sSYS = $sAutoIt_Incl_Dir & '\' & $sInclude
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
For $i = 0 To UBound($aUDL) - 1
$aUDL[$i] &= '\' & $sInclude
If FileExists($aUDL[$i]) Then
$sRet = $aUDL[$i]
ExitLoop 2
EndIf
Next
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
If Not $sOpenStrChar And($aChars[$iChar] = '"' Or $aChars[$iChar] = "'") Then
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
_OnAutoItErrorRegister('_MyErrorHandler', '', '', False, True)
$ScriptName = StringRegExpReplace(@ScriptName, '\..{2,3}$', '', 1)
$sPath_ini = @ScriptDir & '\' & $ScriptName & '.ini'
Global $logFile = @ScriptDir & '\' & $ScriptName & '.log'
Global $tempLog
_closeLastProc($sPath_ini)
$WorkRestart = True
$aPlatfs = _getLastPlatformWeb64()
If Not $WorkRestart Then _ArrayInsert($aPlatfs, 0, 'C:\Program Files\1cv8\9.9.99.9999')
$newVer = StringRegExp($aPlatfs[0], '\\(\d+\.\d+\.\d+[^\\]*)\\?', 3)
$newVer = $newVer[0]
If UBound($aPlatfs) < 2 Then _quit('Нет новых платформ')
ConsoleWrite('@@ Debug(' &  1738 & ') :  UBound($aPlatfs) = ' & UBound($aPlatfs) & @CRLF & '>Error code: ' & @error & @CRLF)
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
ConsoleWrite('@@ Debug(' &  1750 & ') : $atestfile = ' & $atestfile & @CRLF & '>Error code: ' & @error & @CRLF)
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
$aPublic = _getWebIISPublication()
For $ii = 0 To UBound($aPublic) - 1
If StringInStr($aPlatfs[0], $aPublic[$ii][0]) Then
_log('Уже стоит новая версия ' & $aPublic[$ii][0])
ExitLoop
ElseIf StringInStr($aPlatfs[1], $aPublic[$ii][0]) Then
_log('Начинаем публикацию IIS с версии ' & $aPublic[$ii][0] & ' на ' & $aPlatfs[0] & ' для файла '&$aPublic[$ii][1])
$sRead=FileRead($aPublic[$ii][1])
$sNewText = StringRegExpReplace($sRead, '(scriptProcessor="[^"]*?)\\(\d+\.\d+\.\d+[^/\\]*)\\', '\1/' & $newVer & '/')
$atestfile = StringRegExp($sNewText, 'scriptProcessor="([^"]*)"', 3)
$atestfile=StringReplace($atestfile[0],'/','\')
ConsoleWrite('@@ Debug(' &  1781 & ') : $atestfile = ' & $atestfile & @CRLF & '>Error code: ' & @error & @CRLF)
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
$tmpf=_TempFile(@TempDir,'','.txt')
FileWriteLine($tmpf,$tempLog)
exit
Func _getWebIISPublication()
Local $aRes[0][3]
$aServ = _FileListToArrayRec('C:\inetpub\wwwroot', 'web.config', $FLTA_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
_ArrayDelete($aServ, 0)
For $ii = 0 To UBound($aServ) - 1
$conf = $aServ[$ii]
ConsoleWrite('@@ Debug(' &  1810 & ') : $conf = ' & $conf & @CRLF & '>Error code: ' & @error & @CRLF)
$sRead=FileRead($conf)
$aver=StringRegExp($sRead,'scriptProcessor="[^"]*\\(\d+\.\d+\.\d+[^/\\"]*)\\',3)
if @error then ContinueLoop
ConsoleWrite('@@ Debug(' &  1814 & ') : $aver[0] = ' & $aver[0] & @CRLF & '>Error code: ' & @error & @CRLF)
_ArrayAdd($aRes, $aver[0] & '|' & $conf & '|' & 'W3SVC')
Next
Return $aRes
EndFunc
Func _getApachePublication()
Local $aRes[0][3]
$aServ = _GetServicesList()
For $ii = 0 To UBound($aServ) - 1
If StringInStr($aServ[$ii][1], 'Apache') > 0 Or StringInStr($aServ[$ii][1], 'httpd.exe') Then
$conf = StringRegExpReplace($aServ[$ii][1], '\\bin\\.*', '\\conf\\httpd.conf')
$conf = StringReplace($conf, '"', '')
ConsoleWrite('@@ Debug(' &  1826 & ') : $conf = ' & $conf & @CRLF & '>Error code: ' & @error & @CRLF)
$sRead = FileRead($conf)
$aver = StringRegExp($sRead, '_1cws_module.*/(\d+\.\d+\.\d+[^/]*)/', 3)
If @error Then ContinueLoop
_ArrayAdd($aRes, $aver[0] & '|' & $conf & '|' & $aServ[$ii][0])
ConsoleWrite('@@ Debug(' &  1831 & ') : $aver[0] = ' & $aver[0] & @CRLF & '>Error code: ' & @error & @CRLF)
EndIf
Next
Return $aRes
EndFunc
Func _GetServicesList()
$strComputer = "."
$objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Service WHERE Started = 'True' ")
Local $aRes[0][2]
For $objItem In $colItems
_ArrayAdd($aRes, $objItem.Name & '|' & $objItem.PathName)
Next
Return $aRes
EndFunc
Func _getLastPlatformWeb64()
$t = _FileListToArray('C:\Program Files\1cv8', '*', $FLTA_FOlders, True)
_ArraySort($t, 1, 1)
For $ii = $t[0] To 1 Step -1
If Not StringRegExp($t[$ii], '\d+\.\d+\.\d+') Then _ArrayDelete($t, $ii)
If Not FileExists($t[$ii] & '\bin\webinst.exe') Then _ArrayDelete($t, $ii)
Next
_ArrayDelete($t, 0)
Return $t
EndFunc
Func _log($text, $parm2 = '', $parm3 = '', $parm4 = '', $parm5 = '')
ConsoleWrite('@@ Debug(' &  1857 & ') : $text = ' &($text) & @CRLF)
$time = @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & '-' & @MIN & '-' & @SEC
$nameThis = @ComputerName
$textl = $nameThis & @TAB & $text & @TAB & $parm2 & @TAB & $parm3 & @TAB & $parm4 & @TAB & $parm5
$tempLog=Eval('tempLog')&$textl&@CRLF
ConsoleWrite('@@ Debug(' &  1862 & ') : $tempLog = ' & $tempLog & @CRLF & '>Error code: ' & @error & @CRLF)
$hFile = FileOpen($logFile, 0)
FileSetPos($hFile, StringLen($textl) * -1.99, $FILE_END)
$chl = FileRead($hFile, StringLen($textl) * 1.99)
FileClose($hFile)
If StringInStr($chl, $textl) Then Return 0
ConsoleWrite('@@ Debug(' & $textl & ') : $chl = ' & $chl & @CRLF & '>Error code: ' & @error & @CRLF)
FileWriteLine($logFile, $time & @TAB & $textl)
EndFunc
Func _closeLastProc($sPath_ini)
$last_pid = IniRead($sPath_ini, "Settings", '$last_pid', '-1')
$last_pid2 = IniRead($sPath_ini, "Settings", '$last_pid2', '-1')
IniWrite($sPath_ini, "Settings", "$last_pid", @AutoItPID)
IniWrite($sPath_ini, "Settings", "$last_pid2", $last_pid)
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
EndFunc
Func _quit($msg = '')
If $msg <> '' Then _log($msg)
Exit
EndFunc
