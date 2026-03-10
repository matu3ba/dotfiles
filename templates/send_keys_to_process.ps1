# https://stackoverflow.com/questions/74147128/how-do-i-send-keys-to-an-active-window-in-powershell
## function send_keys_to_active_program() {
##   $ps = Start-Process -PassThru -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -WindowStyle Normal
##   $wshell = New-Object -ComObject wscript.shell
##
##   # Wait until activating the target process succeeds.
##   # Note: You may want to implement a timeout here.
##   while (-not $wshell.AppActivate($ps.Id)) {
##     Start-Sleep -MilliSeconds 200
##   }
##   $wshell.SendKeys('~')
##   Sleep 3
##   $wshell.SendKeys('username')
##   Sleep 2
##   $wshell.SendKeys('{TAB}')
##   Sleep 1
##   $wshell.SendKeys('password')
##   Stop-Process -Id $ps.Id
## }
