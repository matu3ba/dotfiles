REM http://steve-jansen.github.io/guides/windows-batch-scripting/part-1-getting-started.html
REM TODO extend by guide
REM https://www.robvanderwoude.com/battech_fileproperties.php
REM TODO extend by collection
REM https://ss64.com/nt/if.html
REM TODO check out

REM cd without args shows pwd
REM dir shows ls
REM variables are used with %VAR%
REM batch files have .bat as extension, but .cmd and .btm also exists

REM Comments:
::   comment
REM  comment
REM your commands here      & ::  commenttttttttttt
:: may also fail within setlocal ENABLEDELAYEDEXPANSION

REM SOME CODE
GOTO LABEL  ::REM out this line to exeucute code between this GOTO and :LABEL
REM some_code ...
:LABEL
REM other_code

REM split veeeeeeeeeeeeeeeeeeeeery ^
REM long commands via carret
REM To prevent broken behavior, make sure to always end with blank linke after ^

REM There is no global history. Must use powershell for this. Only current history
REM can be searched through via F7.
REM Use http://mridgers.github.io/clink/ to fix broken Windows behavior.

REM %cd% is current working dir (variable)
echo %cd%
REM %~dp0 is full path to batch file's dir (static)
echo %~dp0
REM %~dpnx0 and %~f0 are full path to batch dir and file name (static).
echo %~dpnx0
echo %~f0

REM setting variables
set bat_path=%~dp0
set call_path=%cd%
cd %bat_path%
ECHO CMD^> %cd%
set /A count=0
set /p count=0

REM checking errors and exiting without quitting cmd altogether
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
if %ERRORLEVEL% neq 0 goto EXIT

:EXIT
  exit /b %ERRORLEVEL%

REM TODO fixup this part
REM loop example with path comparison
REM /d indicates that %%i is a directory loop variable
for /d %%i in (%bat_path%*) do (
  set path=%%i
  echo StartupPath %%i
  REM %%~nxi is current folder
  set Folder=%%~nxi
  if !Folder!==%SrcPath% (
     echo Skip Special Folder !Folder!
  ) else (
    REM extract first character from path Folder
    REM !variable! means delayed expansion, see help set
    set L=!Folder:~0,1!
    if !L!==_ (
      echo Skip Folder !Folder!
    ) else (
      REM TODO function call
      if DoUpdate GTR 0 (
        copy %AbsSrcPath%\*.exe %%i
        copy %AbsSrcPath%\*.dll %%i
        copy %AbsSrcPath%\Files\*.* %%i\Files\
      )
      if exist %%i\%Process% (
        start "" /D %%i %%i\%Process%
      ) else (
        echo %%i\%Process% does not exist.
      )
    )
  )
)

Silence all output:
1. Start your batch file with: @ECHO OFF
2. And redirect all command output by appending: >NUL 2>&1

Change partition:
cd /d D:
D:

check if file exists
if exist "C:\myprogram\sync\data.handler" echo Now Exiting && Exit
if not exist "C:\myprogram\html\data.sql" Exit