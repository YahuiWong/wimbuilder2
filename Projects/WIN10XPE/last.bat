rem display startmenu folders/shortcuts name with language
attrib +s "%X%\Users\Default\AppData\Roaming\Microsoft\Windows\SendTo"
attrib +s "%X%\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessibility"
attrib +s "%X%\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories"
attrib +s "%X%\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools"

rem startup with pecmd.exe
:PECMD_ENTRY
if not exist "%X%\Windows\System32\pecmd.exe" goto :STARTNET_ENTRY
reg add HKLM\Tmp_System\Setup /v CmdLine /d "Pecmd.exe Main %%Windir%%\System32\Pecmd.ini" /f
goto :STARTUP_ENTRY_END

:STARTNET_ENTRY
rem startup shell

call AddFiles %0 :end_files
goto :end_files
windows\system32\taskkill.exe
:end_files


set "X32=%X%\Windows\System32"
del /q "%X%\setup.exe"
del /q "%X32%\winpeshl.ini"
del /q "%X32%\WallpaperHost.exe"

rem update startnet.cmd
call OpenTextFile JS %X32%\startnet.cmd %0 :end_startnet_edit
goto :end_startnet_edit

TXT.before('wpeinit').insert('set USERPROFILE=X:\\Users\\Default');
TXT.append('\r\n\
if exist %SystemRoot%\\System32\\IME_Cmd.cmd (\r\n\
    call %SystemRoot%\\System32\\IME_Cmd.cmd\r\n\
    @echo on\r\n\
)\r\n\
');
TXT.append('\r\nstart explorer.exe\r\n');

:end_startnet_edit


if "x%opt[shell.app]%"=="xwinxshell" (
    call TextReplace "%X32%\startnet.cmd" "start explorer.exe" "start #qShell#q #q#pProgramFiles#p\WinXShell\WinXShell.exe#q -winpe"
)

if not "x%opt[shell.app]%"=="xwinxshell" (
    echo ping -n 2 127.1 1^>nul>>"%X32%\startnet.cmd"
    echo taskkill /f /im explorer.exe>>"%X32%\startnet.cmd"
    echo explorer.exe>>"%X32%\startnet.cmd"
)
echo cmd.exe>>"%X32%\startnet.cmd"

:STARTUP_ENTRY_END

rem use prepared HIVE files
call PERegPorter.bat Tmp UNLOAD 1>nul

call :FULLREG DEFAULT
call :FULLREG SOFTWARE
call :FULLREG SYSTEM
call :FULLREG COMPONENTS
call :FULLREG DRIVERS
goto :EOF

:FULLREG
if exist "%~dp0%1" (
   xcopy /E /Y "%~dp0%1" %X%\Windows\System32\Config\
)

