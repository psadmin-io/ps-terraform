#Requires -Version 5

<#PSScriptInfo

    .VERSION 1.0

    .GUID cad7db76-01e8-4abd-bdb9-3fca50cadbc7

    .AUTHOR psadmin.io

    .SYNOPSIS
        ps-vagabond prepare server for creating an EC2 AMI

    .DESCRIPTION
        Provisioning script for ps-vagabond to prepare server for becoming an AMI

    .EXAMPLE
        provision-utilities.ps1 
#>

#-----------------------------------------------------------[Parameters]----------------------------------------------------------

[CmdletBinding()]
Param(
)


#---------------------------------------------------------[Initialization]--------------------------------------------------------

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

#-----------------------------------------------------------[Variables]-----------------------------------------------------------


#-----------------------------------------------------------[Functions]-----------------------------------------------------------

function update_admin_password() {
  Write-Output "[${env:COMPUTERNAME}] Updating Administrator Password"
  $ec2file = "c:\programdata\amazon\ec2-windows\launch\config\LaunchConfig.json"
  $launchConfig = Get-Content -Path $ec2file  | ConvertFrom-Json
  $launchConfig.adminPasswordType = 'Specify'
  $launchConfig.adminPassword = 'touch46?S!nk'
  $launchConfig

  Set-Content -Value ($launchConfig | ConvertTo-Json) -Path $ec2file
}

function schedule_initialization() {
  Write-Output "[${env:COMPUTERNAME}] Scheduling Windows Initialization - Windows will shut down."
  C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule
  C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\SendEventLogs.ps1 -Schedule
  C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\SendWindowsIsReady.ps1 -Schedule
  C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1
}



#-----------------------------------------------------------[Execution]-----------------------------------------------------------


. update_admin_password
. schedule_initialization