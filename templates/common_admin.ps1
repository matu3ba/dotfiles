#! Common PowerShell administration operations

#====process_list
#====iis
#====hyper-v
#====vm_usage

#====process_list
get-process
taskkill
tasklist
wmic process list

#====iis
#dump IIS services
# %SYSTEMROOT%\System32\inetsrv\config
#
# C:\Windows\System32\inetsrv\config\applicationHost.config:
# For schema documentation, see
#     %windir%\system32\inetsrv\config\schema\IIS_schema.xml.
# <configuration>
#   <configSections>
#     <system.applicationHost>
#       <applicationPools>
#         <add name=".NET v4.5 Classic" managedRuntimeVersion="v4.0" managedPipelineMode="Classic" />
#         <add name="FancyDancy" autoStart="true" managedRuntimeVersion="v4.0">
#           <processModel identityType="ApplicationPoolIdentity" loadUserProfile="true" idleTimeout="00:00:00" />
#           <recycling>
#             <periodicRestart time="00:00:00">
#               <schedule>
#                 <clear />
#                 <add value="04:01:00" />
#               </schedule>
#             </periodicRestart>
#           </recycling>
#         </add>
#       </applicationPools>
#
#       <customMetadata />
#
#       <listenerAdapters>
#         <add name="http" />
#       </listenerAdapters>
#
#       <log>
#         <centralBinaryLogFile enabled="true" directory="%SystemDrive%\inetpub\logs\LogFiles" />
#         <centralW3CLogFile enabled="true" directory="%SystemDrive%\inetpub\logs\LogFiles" />
#       </log>
#
#       <sites>
#       </sites>
#
#       <webLimits />
#
#     </system.applicationHost>
#   </configSections>
# <configuration>


# registry:
# HKLM\Software\Microsoft\InetStp\Components
# HKLM\Software\Microsoft\WebManagement\Server

# https://learn.microsoft.com/en-us/iis/publish/using-web-deploy/synchronize-iis
# C:\Windows\System32\inetsrv\appcmd backup /?
#appcmd add backup srviis1-backup-2019
#appcmd list backup
#appcmd restore backup srviis1-backup-2019
# Windows Server 2019, Powershell > 7.0.x IIS backup: Export-IISConfiguration

#====hyper-v
##setup as admin
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
##fixup permissions
# get-LocalGroup | ft Name, SID
# $loggedInUser =  (get-wmiobject  win32_computersystem).username
# Add-LocalGroupMember -group "Hyper-V-Administrators" -member $loggedInUser
# Add-LocalGroupMember -group "Hyper-V-Administratoren" -member $loggedInUser
# log out and in to validate explicit+implicit groups membership: whoami /groups
# for explicit network groups: net user /domain username

#====vm_usage
# https://learn.microsoft.com/en-us/powershell/module/hyper-v/import-vm
# https://learn.microsoft.com/en-us/powershell/module/hyper-v/remove-vm
# https://learn.microsoft.com/en-us/archive/technet-wiki/1350.hyper-v-export-vm-config-only-using-powershell
#SHENNANIGAN hyper-v has no option to remove machine with keeping the vm config metadata (name etc)
# must 1 make a backup of the config xor 2 create new vm labels
#VM1
#  - Virtual Hard Disks
#  - Snapshots
#  - Virtual Machines   (this is the folder to backup)
Import-VM -ComputerName "PCName"
Import-VM -ComputerName "PCName" -Path 'Virtual Machines\9B9C9999-999D-99D9-A9C9-99E9999C9999.vmcx'
Rename-VM PCName -NewName W10-Dev-VM
Export-VM -Name W10-Dev-VM -Path $HOME\VMBackups\
# delete snapshots after merging
# https://learn.microsoft.com/en-us/troubleshoot/windows-server/virtualization/hyper-v-snapshots-checkpoints-differencing-disks
Get-VM | Get-VMSnapshot | Remove-VMSnapshot
Get-VMSnapshot -VMName W10-Test-VM | Remove-VMSnapshot
$hvnodes = get-clusternode | select name -expandproperty name
  foreach ($hvnode in $hvnodes) {
  Get-VM -computername $hvnode | Get-VMSnapshot | Remove-VMSnapshot
}
Start-VM -Name W10-Dev-VM
Start-VM -Name W10-Test-VM
Stop-VM -Name W10-Dev-VM
Stop-VM -Name W10-Test-VM

##port forwarding
#WSL
# ifconfig
# ip addr show
# hostname -I
#powershell
# netsh interface portproxy add v4tov4 listenport=[PORT] listenaddress=0.0.0.0 connectport=[PORT] connectaddress=[WSL_IP]
netsh interface portproxy show v4tov4
#admin powershell for inbound firewall rule
New-NetFirewallRule -DisplayName "WSL2 Port Bridge" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443,10000,3000,5000
#But: WSL changes ip on every boot, automation

# for automatic task execution to be put into BridgeWslPorts.ps1
function brige_WslPorts {
  # for logs: Start-Transcript -Path "C:\Logs\Bridge-WslPorts.log" -Append
  $ports = @(80, 443, 10000, 3000, 5000);

  $wslAddress = bash.exe -c "ifconfig eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"

  if ($wslAddress -match '^(\d{1,3}\.){3}\d{1,3}$') {
    Write-Host "WSL IP address: $wslAddress" -ForegroundColor Green
    Write-Host "Ports: $ports" -ForegroundColor Green
  }
  else {
    Write-Host "Error: Could not find WSL IP address." -ForegroundColor Red
    exit
  }

  $listenAddress = '0.0.0.0';

  foreach ($port in $ports) {
    Invoke-Expression "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$listenAddress";
    Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$listenAddress connectport=$port connectaddress=$wslAddress";
  }

  $fireWallDisplayName = 'WSL Port Forwarding';
  $portsStr = $ports -join ",";

  Invoke-Expression "Remove-NetFireWallRule -DisplayName $fireWallDisplayName";
  Invoke-Expression "New-NetFireWallRule -DisplayName $fireWallDisplayName -Direction Outbound -LocalPort $portsStr -Action Allow -Protocol TCP";
  Invoke-Expression "New-NetFireWallRule -DisplayName $fireWallDisplayName -Direction Inbound -LocalPort $portsStr -Action Allow -Protocol TCP";
}
#without ifconfig, set $wslAddress with another command like ip, addr or hostname
#list distros: wslconfig /l

function setupWindowsTask {
  $a = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"[PATH_TO_SCRIPT]\BridgeWslPorts.ps1`" -WindowStyle Hidden -ExecutionPolicy Bypass"
  $t = New-ScheduledTaskTrigger -AtLogon
  $s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
  $p = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
  Register-ScheduledTask -TaskName "WSL2PortsBridge" -Action $a -Trigger $t -Settings $s -Principal $p
}

#====setup_kubenetes
# see TODO
# best instructions?
