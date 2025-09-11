>Get-ExecutionPolicy
Restricted
Allows individual commands, but no scripts including formatting and configuration (.ps1xml),
module script files (.psm1) and powershell profiles (.ps1).

This means that only history is available and all other things must be done via individual command 
1 files copy pasting, 2 dense indirect execution or 3 manual/scripted policy bypassing execution,
4 batch file bypass.

3 is the easiest to do with $POLICY = Bypass/Unrestricted/AllSigned/Restricted
where Bypass has no warnings, Unrestricted warns on file from non-local network, 
Allsigned requires signed scripts for execution, Restricted only allows single cmds
>PowerShell.exe -ExecutionPolicy $POLICY -File .\echo_helloworld.ps1
and also works for persistent state
>Set-ExecutionPolicy $POLICY -Scope Process
or scripted
$ExecutionContext.InvokeCommand.InvokeScript("Set-ExecutionPolicy $POLICY -Scope Process")

When Powershell usage (for user) is blocked on the system, one can use 
System.Management.Automation.dll methods to get powershell.

4 should work via batch file creation and clicking on it via mouse
C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe LocationOfPS1File

====find
https://devblogs.microsoft.com/scripting/use-windows-powershell-to-search-for-files/
Get-ChildItem -Recurse *.* | Select-String -Pattern "foobar" | Select-Object -Unique Path
dir -recurse *.* | sls -pattern "foobar" | select -unique path

====grep
https://adamtheautomator.com/powershell-grep/
https://www.progress.com/blogs/select-string-the-grep-of-powershell
https://www.powershell-user.de/grep-mit-der-powershell/
https://petri.com/powershell-grep-select-string/
https://www.ideadrops.info/post/cat-grep-cut-sort-uniq-sed-with-powershell
https://www.designgurus.io/answers/detail/how-to-search-a-string-in-multiple-files-and-return-the-names-of-files-in-powershell

recursive grep: 
PS5: get-childitem "folder_where_to_look" -include *.txt -rec | where { $_ | Select-String -Pattern ‘find_me_1’ } | where { $_ | Select-String -Pattern ‘find_me_2’ }
PS7: Select-String -Path "C:\Projects\*" -Pattern "Timeout" -Recurse
Select-String -Path "C:\Data\*" -Pattern "Database" -List | Select-Object -ExpandProperty Path | Out-File "C:\Data\database_files.txt"
case sensitive: -CaseSensitive
speedup: -SimpleMatch
common selections: Select-Object Filename, LineNumber, Line