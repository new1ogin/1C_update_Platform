REM @Echo off
chcp 1251 >nul

REM "%windir%\system32\schtasks.exe" /create /IT /RU "%USERNAME%" /TN "1C_update_Platform" /TR "%~dp0Копия и регистрация NameDecl.bat" /SC ONSTART /RL HIGHEST /F
"%windir%\system32\schtasks.exe" /DELETE /F /TN "1C_update_Platform"
ping 127.0.0.1 -n 2 >nul
"%windir%\system32\schtasks.exe" /create /IT /RU "%USERNAME%" /TN "1C_update_Platform" /TR "'%~dp0AutoIt3.exe' '%~dp01C_update_Platform_stripped.au3'" /sc MINUTE /mo 3 /RL HIGHEST /F
"%windir%\system32\schtasks.exe" /RUN /I /TN "1C_update_Platform"
@timeout /t 10
REM pause
exit

