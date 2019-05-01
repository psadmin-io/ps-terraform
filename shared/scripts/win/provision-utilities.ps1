#Requires -Version 5

<#PSScriptInfo

    .VERSION 1.0

    .GUID cad7db76-01e8-4abd-bdb9-3fca50cadbc7

    .AUTHOR psadmin.io

    .SYNOPSIS
        ps-vagabond provisioning utilitis

    .DESCRIPTION
        Provisioning script for ps-vagabond to install various utilities

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

function install_psadmin_plus() {
  # Fix Ruby Gems CA
  # https://gist.github.com/iversond/772e73257c4ca59a9e6137baa7288788
  $CACertFile = Join-Path -Path $ENV:AppData -ChildPath 'RubyCACert.pem'

  If (-Not (Test-Path -Path $CACertFile)) {  
    #"Downloading CA Cert bundle.."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://curl.haxx.se/ca/cacert.pem' -UseBasicParsing -OutFile $CACertFile | Out-Null
  }

  # Update PATH
  Write-Output "[${env:COMPUTERNAME}] Adding gem and git to PATH"
  $env:PATH+=";C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin;C:\Program Files\Git\bin"
  [System.Environment]::SetEnvironmentVariable('PATH',$env:PATH, [System.EnvironmentVariableTarget]::Machine)

  # "Setting CA Certificate store set to $CACertFile.."
  $ENV:SSL_CERT_FILE = $CACertFile
  [System.Environment]::SetEnvironmentVariable('SSL_CERT_FILE',$CACertFile, [System.EnvironmentVariableTarget]::Machine)

  gem install psadmin_plus
}

function install_browsers() {
  Write-Output "[${env:COMPUTERNAME}] Installing Browsers"
  choco install googlechrome -y
	choco install firefox -y
}

function install_code_management() {
  Write-Output "[${env:COMPUTERNAME}] Installing Code Management Software"
  choco install VSCode -y
	choco install git -y
}

#-----------------------------------------------------------[Execution]-----------------------------------------------------------


. install_browsers
. install_code_management
. install_psadmin_plus