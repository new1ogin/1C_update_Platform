REM @Echo off
chcp 1251 >nul

REM "%windir%\system32\schtasks.exe" /create /IT /RU "%USERNAME%" /TN "1C_Web_update_Publication" /TR "%~dp0Копия и регистрация NameDecl.bat" /SC ONSTART /RL HIGHEST /F
"%windir%\system32\schtasks.exe" /DELETE /F /TN "1C_Web_update_Publication"
ping 127.0.0.1 -n 2 >nul
"%windir%\system32\schtasks.exe" /create /IT /RU "%USERNAME%" /TN "1C_Web_update_Publication" /TR "'%~dp0AutoIt3.exe' '%~dp01C_Web_update_Publication_stripped.au3'" /sc MINUTE /mo 5 /RL HIGHEST /F
"%windir%\system32\schtasks.exe" /RUN /I /TN "1C_Web_update_Publication"
@timeout /t 10
REM pause
exit

