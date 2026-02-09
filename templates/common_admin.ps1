#! Common PowerShell administration operations

#====process_list
#====iis
#====hyper-v


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
